---
title: "Hello Tokio (مرحباً توكيو)"
---

سنبدأ بكتابة تطبيق Tokio أساسي جدًا. سيتصل بخادم Mini-Redis، ويضبط قيمة المفتاح `hello` إلى `world`. ثم سيقرأ المفتاح مرة أخرى. سيتم ذلك باستخدام مكتبة عميل Mini-Redis.

# The code (الكود)

## Generate a new crate (إنشاء crate جديد)

دعنا نبدأ بإنشاء تطبيق Rust جديد:

```bash
$ cargo new my-redis
$ cd my-redis
```

## Add dependencies (إضافة التبعيات)

بعد ذلك، افتح `Cargo.toml` وأضف ما يلي مباشرة تحت `[dependencies]`:

```toml
tokio = { version = "1", features = ["full"] }
mini-redis = "0.4"
```

## Write the code (كتابة الكود)

ثم، افتح `main.rs` واستبدل محتويات الملف بما يلي:

```rust
use mini_redis::{client, Result};

# fn dox() {
#[tokio::main]
async fn main() -> Result<()> {
    // Open a connection to the mini-redis address.
    let mut client = client::connect("127.0.0.1:6379").await?;

    // Set the key "hello" with value "world"
    client.set("hello", "world".into()).await?;

    // Get key "hello"
    let result = client.get("hello").await?;

    println!("got value from the server; result={:?}", result);

    Ok(())
}
# }
```

تأكد من أن خادم Mini-Redis يعمل. في نافذة طرفية منفصلة، قم بتشغيل:

```bash
$ mini-redis-server
```

إذا لم تكن قد قمت بتثبيت mini-redis بالفعل، يمكنك القيام بذلك باستخدام:

```bash
$ cargo install mini-redis
```

الآن، قم بتشغيل تطبيق `my-redis`:

```bash
$ cargo run
got value from the server; result=Some(b"world")
```

نجاح!

يمكنك العثور على الكود الكامل [هنا][full].

[full]: https://github.com/tokio-rs/website/blob/master/tutorial-code/hello-tokio/src/main.rs

# Breaking it down (تحليل الكود)

دعنا نأخذ بعض الوقت لمراجعة ما فعلناه للتو. لا يوجد الكثير من الكود، ولكن الكثير يحدث.

```rust
# use mini_redis::client;
# async fn dox() -> mini_redis::Result<()> {
let mut client = client::connect("127.0.0.1:6379").await?;
# Ok(())
# }
```

يتم توفير دالة [`client::connect`] بواسطة crate `mini-redis`. تقوم بإنشاء اتصال TCP بشكل غير متزامن مع العنوان البعيد المحدد. بمجرد إنشاء الاتصال، يتم إرجاع مقبض `client`. على الرغم من أن العملية تتم بشكل غير متزامن، إلا أن الكود الذي نكتبه **يبدو** متزامنًا. المؤشر الوحيد على أن العملية غير متزامنة هو عامل التشغيل `.await`.

[`client::connect`]: https://docs.rs/mini-redis/0.4/mini_redis/client/fn.connect.html

## What is asynchronous programming? (ما هي البرمجة غير المتزامنة؟)

يتم تنفيذ معظم برامج الكمبيوتر بنفس الترتيب الذي تُكتب به. يتم تنفيذ السطر الأول، ثم التالي، وهكذا. مع البرمجة المتزامنة (synchronous programming)، عندما يواجه البرنامج عملية لا يمكن إكمالها على الفور، فإنه سيحظر (block) حتى تكتمل العملية. على سبيل المثال، يتطلب إنشاء اتصال TCP تبادلًا مع نظير عبر الشبكة، والذي يمكن أن يستغرق قدرًا كبيرًا من الوقت. خلال هذا الوقت، يتم حظر مؤشر الترابط (thread).

مع البرمجة غير المتزامنة (asynchronous programming)، يتم تعليق العمليات التي لا يمكن إكمالها على الفور في الخلفية. لا يتم حظر مؤشر الترابط، ويمكنه الاستمرار في تشغيل أشياء أخرى. بمجرد اكتمال العملية، يتم إلغاء تعليق المهمة وتستمر المعالجة من حيث توقفت. مثالنا السابق يحتوي على مهمة واحدة فقط، لذلك لا يحدث شيء أثناء تعليقها، ولكن البرامج غير المتزامنة عادة ما تحتوي على العديد من هذه المهام.

على الرغم من أن البرمجة غير المتزامنة يمكن أن تؤدي إلى تطبيقات أسرع، إلا أنها غالبًا ما تؤدي إلى برامج أكثر تعقيدًا. يُطلب من المبرمج تتبع جميع الحالات اللازمة لاستئناف العمل بمجرد اكتمال العملية غير المتزامنة. تاريخيًا، هذه مهمة مملة وعرضة للأخطاء.

## Compile-time green-threading (الخيوط الخضراء في وقت التجميع)

تُطبق Rust البرمجة غير المتزامنة باستخدام ميزة تسمى [`async/await`]. يتم تسمية الدوال التي تُجري عمليات غير متزامنة بكلمة `async`. في مثالنا، يتم تعريف دالة `connect` على النحو التالي:

```rust
use mini_redis::Result;
use mini_redis::client::Client;
use tokio::net::ToSocketAddrs;

pub async fn connect<T: ToSocketAddrs>(addr: T) -> Result<Client> {
    // ...
# unimplemented!()
}
```

يبدو تعريف `async fn` كدالة متزامنة عادية، ولكنه يعمل بشكل غير متزامن. تُحوّل Rust دالة `async fn` في وقت **التجميع** إلى روتين يعمل بشكل غير متزامن. أي استدعاءات لـ `.await` داخل `async fn` تُعيد التحكم إلى مؤشر الترابط. قد يقوم مؤشر الترابط بعمل آخر بينما تُعالج العملية في الخلفية.

> **warning** (تحذير)
> على الرغم من أن اللغات الأخرى تُطبق [`async/await`] أيضًا، إلا أن Rust تتبع نهجًا فريدًا. بشكل أساسي، عمليات Rust غير المتزامنة **كسولة** (lazy). يؤدي هذا إلى دلالات وقت تشغيل (runtime semantics) مختلفة عن اللغات الأخرى.

[`async/await`]: https://en.wikipedia.org/wiki/Async/await

إذا لم يكن هذا مفهومًا تمامًا بعد، فلا تقلق. سنستكشف `async/await` أكثر خلال الدليل.

## Using `async/await` (استخدام async/await)

يتم استدعاء الدوال غير المتزامنة مثل أي دالة Rust أخرى. ومع ذلك، فإن استدعاء هذه الدوال لا يؤدي إلى تنفيذ جسم الدالة. بدلاً من ذلك، يُرجع استدعاء `async fn` قيمة تمثل العملية. هذا مشابه من الناحية المفاهيمية لإغلاق بدون وسيطات (zero-argument closure). لتشغيل العملية فعليًا، يجب عليك استخدام عامل التشغيل `.await` على القيمة المرجعة.

على سبيل المثال، البرنامج المعطى:

```rust
async fn say_world() {
    println!("world");
}

#[tokio::main]
async fn main() {
    // Calling `say_world()` does not execute the body of `say_world()`.
    let op = say_world();

    // This println! comes first
    println!("hello");

    // Calling `.await` on `op` starts executing `say_world`.
    op.await;
}
```

يُخرج:

```text
hello
world
```

القيمة المرجعة لدالة `async fn` هي نوع مجهول يُطبق سمة [`Future`].

[`Future`]: https://doc.rust-lang.org/std/future/trait.Future.html

## Async `main` function (دالة main غير المتزامنة)

تختلف دالة main المستخدمة لتشغيل التطبيق عن الدالة المعتادة الموجودة في معظم crates Rust.

1. إنها `async fn`
2. إنها مشروحة بـ `#[tokio::main]`

تُستخدم `async fn` لأننا نريد الدخول في سياق غير متزامن. ومع ذلك، يجب تنفيذ الدوال غير المتزامنة بواسطة [runtime]. يحتوي الـ runtime على مُجدول المهام غير المتزامنة (asynchronous task scheduler)، ويوفر I/O الموجه بالأحداث (evented I/O)، والمؤقتات (timers)، وما إلى ذلك. لا يبدأ الـ runtime تلقائيًا، لذلك تحتاج دالة main إلى تشغيله.

دالة `#[tokio::main]` هي ماكرو (macro). تُحوّل `async fn main()` إلى `fn main()` متزامنة تُهيئ مثيل runtime وتُنفذ دالة main غير المتزامنة.

على سبيل المثال، ما يلي:

```rust
#[tokio::main]
async fn main() {
    println!("hello");
}
```

يتم تحويله إلى:

```rust
fn main() {
    let mut rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        println!("hello");
    })
}
```

سيتم تغطية تفاصيل Tokio runtime لاحقًا.

[runtime]: https://docs.rs/tokio/1/tokio/runtime/index.html

## Cargo features (ميزات Cargo)

عند الاعتماد على Tokio لهذا البرنامج التعليمي، يتم تمكين علامة الميزة `full`:

```toml
tokio = { version = "1", features = ["full"] }
```

يحتوي Tokio على الكثير من الوظائف (TCP، UDP، مقابس Unix، المؤقتات، أدوات المزامنة، أنواع مُجدولات متعددة، إلخ). لا تحتاج جميع التطبيقات إلى جميع الوظائف. عند محاولة تحسين وقت التجميع أو حجم التطبيق النهائي، يمكن للتطبيق اختيار **فقط** الميزات التي يستخدمها.
