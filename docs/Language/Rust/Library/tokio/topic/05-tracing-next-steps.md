---
title: "الخطوات التالية مع التتبع (Next steps with Tracing)"
---

# Tokio-console

[`tokio-console`](https://github.com/tokio-rs/console) هي أداة تشبه htop تتيح لك رؤية عرض في الوقت الفعلي لنطاقات (spans) وأحداث (events) التطبيق. يمكنها أيضاً تمثيل "الموارد" (resources) التي أنشأها وقت تشغيل Tokio، مثل المهام (Tasks). إنها ضرورية لفهم مشكلات الأداء أثناء عملية التطوير.

على سبيل المثال، لاستخدام tokio-console في [مشروع mini-redis](https://github.com/tokio-rs/mini-redis)، تحتاج إلى تمكين ميزة `tracing` لحزمة Tokio:

```toml
# قم بتحديث استيراد tokio في ملف Cargo.toml الخاص بك
tokio = { version = "1", features = ["full", "tracing"] }
```

ملاحظة: ميزة `full` لا تقوم بتمكين `tracing`.

ستحتاج أيضاً إلى إضافة تبعية (dependency) لحزمة `console-subscriber`. توفر هذه الحزمة تنفيذ `Subscriber` سيحل محل التنفيذ المستخدم حالياً بواسطة mini-redis:

```toml
# أضف هذا إلى قسم dependencies في ملف Cargo.toml الخاص بك
console-subscriber = "0.1.5"
```

أخيراً، في `src/bin/server.rs` ، استبدل استدعاء `tracing_subscriber` باستدعاء `console-subscriber`:

استبدل هذا:

```rust
tracing_subscriber::fmt::try_init()?;
```

...بهذا:

```rust
console_subscriber::init();
```

سيؤدي هذا إلى تمكين `console_subscriber` ، مما يعني أنه سيتم تسجيل أي أدوات قياس (instrumentation) ذات صلة بـ `tokio-console`. سيظل تسجيل السجلات (logging) إلى المخرجات القياسية (stdout) يحدث (بناءً على قيمة متغير البيئة `RUST_LOG`).

الآن يجب أن نكون مستعدين لبدء تشغيل mini-redis مرة أخرى، هذه المرة باستخدام علم (flag) `tokio_unstable` (المطلوب لتمكين التتبع):

```sh
RUSTFLAGS="--cfg tokio_unstable" cargo run --bin mini-redis-server
```

يسمح لنا علم `tokio_unstable` بالاستفادة من واجهات برمجة التطبيقات (APIs) الإضافية التي توفرها Tokio والتي لا تملك حالياً ضماناً للاستقرار (بمعنى آخر، يسمح بالتغييرات الجذرية لهذه الواجهات).

كل ما تبقى هو تشغيل الكونسول نفسه في طرفية أخرى. أسهل طريقة للقيام بذلك هي تثبيته من crates.io:

```sh
cargo install --locked tokio-console
```

ثم قم بتشغيله باستخدام:

```sh
tokio-console
```

كلما احتجت إلى فحص وقت تشغيل Tokio لفهم أداء تطبيقك بشكل أفضل، يمكنك الاستفادة من tokio-console لعرض ما يحدث في الوقت الفعلي، مما يساعدك على اكتشاف حالات الجمود (deadlocks) والمشكلات الأخرى.

# التكامل مع OpenTelemetry

[OpenTelemetry](https://opentelemetry.io/) (OTel) تعني عدة أشياء؛ أولاً، إنها مواصفة مفتوحة، تحدد نموذج بيانات للتتبعات (traces) والمقاييس (metrics). ثانياً، إنها مجموعة من مجموعات أدوات تطوير البرمجيات (SDKs) الخاصة باللغات. ثالثاً، هناك OpenTelemetry Collector، وهو برنامج يجمع التتبعات والمقاييس ويرسلها إلى مزود خدمة التتبع مثل DataDog أو Honeycomb.

حزمة [opentelemetry crate](https://crates.io/crates/opentelemetry) هي ما يوفر SDK الخاص بـ OpenTelemetry لـ Rust.

في هذا الدليل، سنقوم بإعداد mini-redis لإرسال البيانات إلى [Jaeger](https://www.jaegertracing.io/)، وهو واجهة مستخدم لتصور التتبعات.

لتشغيل نسخة من Jaeger، يمكنك استخدام Docker:

```sh
docker run -d -p6831:6831/udp -p6832:6832/udp -p16686:16686 -p14268:14268 jaegertracing/all-in-one:latest
```

لإعداد mini-redis، سنحتاج أولاً إلى إضافة بعض التبعيات. قم بتحديث `Cargo.toml` الخاص بك بما يلي:

```toml
# ينفذ الأنواع المحددة في مواصفات Otel
opentelemetry = "0.17.0"
# التكامل بين حزمة tracing وحزمة opentelemetry
tracing-opentelemetry = "0.17.2" 
# يسمح لك بتصدير البيانات إلى Jaeger
opentelemetry-jaeger = "0.16.0"
```

الآن، في `src/bin/server.rs` ، أضف الاستيرادات التالية:

```rust
use opentelemetry::global;
use tracing_subscriber::{
    fmt, layer::SubscriberExt, util::SubscriberInitExt,
};
```

الخطوة التالية هي استبدال استدعاء `tracing_subscriber` بإعداد OTel:

```rust
// يسمح لك بتمرير السياق (مثل معرفات التتبع) عبر الخدمات
global::set_text_map_propagator(opentelemetry_jaeger::Propagator::new());

// إعداد الآلية اللازمة لتصدير البيانات إلى Jaeger
let tracer = opentelemetry_jaeger::new_pipeline()
    .with_service_name("mini-redis")
    .install_simple()?;

// إنشاء طبقة تتبع (tracing layer) مع الـ tracer الذي تم تكوينه
let opentelemetry = tracing_opentelemetry::layer().with_tracer(tracer);

// البدء في تسجيل السجلات والتتبع
tracing_subscriber::registry()
    .with(opentelemetry)
    // الاستمرار في تسجيل السجلات إلى stdout
    .with(fmt::Layer::default())
    .try_init()?;
```

الآن يجب أن تكون قادراً على بدء تشغيل mini-redis وفحص التتبعات في واجهة Jaeger. يساعدك هذا على رؤية تفاصيل النطاقات (spans) التي تم إصدارها أثناء معالجة الطلبات.
