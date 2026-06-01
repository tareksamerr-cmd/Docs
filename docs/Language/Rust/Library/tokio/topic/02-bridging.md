---
title: "الربط مع الكود المتزامن (Bridging with sync code)"
---

في معظم أمثلة استخدام Tokio، نضع علامة `#[tokio::main]` على الوظيفة الرئيسية ونجعل المشروع بأكمله غير متزامن.

في بعض الحالات، قد تحتاج إلى تشغيل جزء صغير من الكود المتزامن. لمزيد من المعلومات حول ذلك، راجع [`spawn_blocking`].

في حالات أخرى، قد يكون من الأسهل هيكلة التطبيق ليكون متزامناً إلى حد كبير، مع أجزاء أصغر أو متميزة منطقياً غير متزامنة. على سبيل المثال، قد يرغب تطبيق واجهة مستخدم رسومية (GUI) في تشغيل كود واجهة المستخدم على الخيط الرئيسي وتشغيل وقت تشغيل Tokio بجانبه على خيط آخر.

تشرح هذه الصفحة كيف يمكنك عزل async/await في جزء صغير من مشروعك.

# ما الذي يتوسع إليه `#[tokio::main]`

ماكرو `#[tokio::main]` هو ماكرو يستبدل وظيفتك الرئيسية بوظيفة رئيسية غير متزامنة تبدأ وقت تشغيل (runtime) ثم تستدعي الكود الخاص بك. على سبيل المثال، هذا:

```rust
#[tokio::main]
async fn main() {
    println!("Hello world");
}
```

يتم تحويله إلى هذا بواسطة الماكرو:

```rust
fn main() {
    tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .unwrap()
        .block_on(async {
            println!("Hello world");
        })
}
```

لاستخدام async/await في مشاريعنا الخاصة، يمكننا القيام بشيء مماثل حيث نستفيد من أسلوب [`block_on`] للدخول إلى السياق غير المتزامن حيثما كان ذلك مناسباً.

# واجهة متزامنة لـ mini-redis

في هذا القسم، سنستعرض كيفية بناء واجهة متزامنة لـ mini-redis عن طريق تخزين كائن `Runtime` واستخدام أسلوب `block_on` الخاص به.

الواجهة التي سنقوم بتغليفها هي نوع [`Client`] غير المتزامن. لديها عدة أساليب، وسنقوم بتنفيذ نسخة حظر (blocking version) من الأساليب التالية:

 * [`Client::get`]
 * [`Client::set`]
 * [`Client::set_expires`]
 * [`Client::publish`]
 * [`Client::subscribe`]

للقيام بذلك، نقدم ملفاً جديداً يسمى `src/clients/blocking_client.rs` ونهيئه بهيكل تغليف (wrapper struct) حول نوع `Client` غير المتزامن:

```rust
use tokio::net::ToSocketAddrs;
use tokio::runtime::Runtime;

pub use crate::clients::client::Message;

/// اتصال مؤسس مع خادم Redis.
pub struct BlockingClient {
    /// الـ `Client` غير المتزامن.
    inner: crate::clients::Client,

    /// وقت تشغيل `current_thread` لتنفيذ العمليات على
    /// العميل غير المتزامن بطريقة حظر (blocking manner).
    rt: Runtime,
}

impl BlockingClient {
    pub fn connect<T: ToSocketAddrs>(addr: T) -> crate::Result<BlockingClient> {
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()?;

        // استدعاء أسلوب الاتصال غير المتزامن باستخدام وقت التشغيل.
        let inner = rt.block_on(crate::clients::Client::connect(addr))?;

        Ok(BlockingClient { inner, rt })
    }
}
```

هنا، قمنا بتضمين وظيفة المنشئ كمثالنا الأول على كيفية تنفيذ الأساليب غير المتزامنة في سياق غير متزامن. نقوم بذلك باستخدام أسلوب [`block_on`] على نوع [`Runtime`] الخاص بـ Tokio، والذي ينفذ أسلوباً غير متزامن ويرجع نتيجته.

أحد التفاصيل المهمة هو استخدام وقت تشغيل [`current_thread`]. عادةً عند استخدام Tokio، ستستخدم وقت تشغيل [`multi_thread`] الافتراضي، والذي سينشئ مجموعة من خيوط الخلفية بحيث يمكنه تشغيل أشياء كثيرة في نفس الوقت بكفاءة. بالنسبة لحالة الاستخدام الخاصة بنا، سنقوم فقط بالقيام بشيء واحد في كل مرة، لذا لن نجني أي فائدة من تشغيل خيوط متعددة. وهذا يجعل وقت تشغيل [`current_thread`] مناسباً تماماً لأنه لا ينشئ أي خيوط.

يقوم استدعاء [`enable_all`] بتمكين برامج تشغيل IO والمؤقت (timer) في وقت تشغيل Tokio. إذا لم يتم تمكينها، فلن يتمكن وقت التشغيل من تنفيذ عمليات IO أو المؤقتات.

> **تحذير**
> لأن وقت تشغيل `current_thread` لا ينشئ خيوطاً، فإنه يعمل فقط عند استدعاء `block_on`. بمجرد عودة `block_on` ، ستتجمد جميع المهام المنشأة على وقت التشغيل هذا حتى تستدعي `block_on` مرة أخرى. استخدم وقت تشغيل `multi_threaded` إذا كان يجب أن تستمر المهام المنشأة في العمل عند عدم استدعاء `block_on`.

بمجرد حصولنا على هذا الهيكل، يسهل تنفيذ معظم الأساليب:

```rust
impl BlockingClient {
    pub fn get(&mut self, key: &str) -> crate::Result<Option<Bytes>> {
        self.rt.block_on(self.inner.get(key))
    }

    pub fn set(&mut self, key: &str, value: Bytes) -> crate::Result<()> {
        self.rt.block_on(self.inner.set(key, value))
    }

    pub fn set_expires(
        &mut self,
        key: &str,
        value: Bytes,
        expiration: Duration,
    ) -> crate::Result<()> {
        self.rt.block_on(self.inner.set_expires(key, value, expiration))
    }

    pub fn publish(&mut self, channel: &str, message: Bytes) -> crate::Result<u64> {
        self.rt.block_on(self.inner.publish(channel, message))
    }
}
```

أسلوب [`Client::subscribe`] أكثر إثارة للاهتمام لأنه يحول `Client` إلى كائن `Subscriber`. يمكننا تنفيذه بالطريقة التالية:

```rust
/// عميل دخل في وضع النشر/الاشتراك (pub/sub).
pub struct BlockingSubscriber {
    /// الـ `Subscriber` غير المتزامن.
    inner: crate::clients::Subscriber,

    /// وقت تشغيل `current_thread` لتنفيذ العمليات على
    /// العميل غير المتزامن بطريقة حظر.
    rt: Runtime,
}

impl BlockingClient {
    pub fn subscribe(self, channels: Vec<String>) -> crate::Result<BlockingSubscriber> {
        let subscriber = self.rt.block_on(self.inner.subscribe(channels))?;
        Ok(BlockingSubscriber {
            inner: subscriber,
            rt: self.rt,
        })
    }
}
```

لذا، سيستخدم أسلوب `subscribe` أولاً وقت التشغيل لتحويل الـ `Client` غير المتزامن إلى `Subscriber` غير متزامن. بعد ذلك، سيقوم بتخزين الـ `Subscriber` الناتج مع الـ `Runtime` وتنفيذ الأساليب المختلفة باستخدام [`block_on`].

# نُهج أخرى

يوضح القسم أعلاه أبسط طريقة لتنفيذ غلاف متزامن، لكنها ليست الطريقة الوحيدة. النهج هي:

 * إنشاء [`Runtime`] واستدعاء [`block_on`] على الكود غير المتزامن.
 * إنشاء [`Runtime`] وإنشاء مهام ([`spawn`][spawn]) عليه.
 * تشغيل الـ [`Runtime`] في خيط منفصل وإرسال رسائل إليه.

لقد رأينا بالفعل النهج الأول. النهج الآخران موضحان أدناه.

## إنشاء مهام على وقت التشغيل (Spawning things on a runtime)

كائن [`Runtime`] لديه أسلوب يسمى [`spawn`]. عند استدعاء هذا الأسلوب، فإنك تنشئ مهمة خلفية جديدة لتعمل على وقت التشغيل. على سبيل المثال، يمكن أن يكون هذا وسيلة جيدة لتنفيذ طلبات الشبكة الخلفية في تطبيق رسومي لأن طلبات الشبكة تستغرق وقتاً طويلاً جداً لتشغيلها على خيط واجهة المستخدم الرئيسي. بدلاً من ذلك، تقوم بإنشاء الطلب على وقت تشغيل Tokio الذي يعمل في الخلفية، وتجعل المهمة ترسل المعلومات مرة أخرى إلى كود واجهة المستخدم عند انتهاء الطلب.

في هذا المثال، من المهم تكوين وقت التشغيل ليكون وقت تشغيل [`multi_thread`]. إذا قمت بتغييره ليكون وقت تشغيل [`current_thread`] ، فستجد أن المهمة المستهلكة للوقت تنتهي قبل أن تبدأ أي من المهام الخلفية. وذلك لأن المهام الخلفية المنشأة على وقت تشغيل `current_thread` لن يتم تنفيذها إلا أثناء الاستدعاءات لـ `block_on`.

## إرسال الرسائل (Sending messages)

التقنية الثالثة هي إنشاء وقت تشغيل واستخدام تمرير الرسائل للتواصل معه. يتضمن ذلك القليل من الكود المتكرر (boilerplate) أكثر من النهجين الآخرين، ولكنه النهج الأكثر مرونة. عند إنشاء وقت تشغيل بهذه الطريقة، فإنه يعتبر نوعاً من [الـ actor][actor].

[`Runtime`]: https://docs.rs/tokio/1/tokio/runtime/struct.Runtime.html
[`block_on`]: https://docs.rs/tokio/1/tokio/runtime/struct.Runtime.html#method.block_on
[`spawn`]: https://docs.rs/tokio/1/tokio/runtime/struct.Runtime.html#method.spawn
[`spawn_blocking`]: https://docs.rs/tokio/1/tokio/task/fn.spawn_blocking.html
[`multi_thread`]: https://docs.rs/tokio/1/tokio/runtime/struct.Builder.html#method.new_multi_thread
[`current_thread`]: https://docs.rs/tokio/1/tokio/runtime/struct.Builder.html#method.new_current_thread
[`enable_all`]: https://docs.rs/tokio/1/tokio/runtime/struct.Builder.html#method.enable_all
[`JoinHandle`]: https://docs.rs/tokio/1/tokio/task/struct.JoinHandle.html
[`tokio::sync::mpsc`]: https://docs.rs/tokio/1/tokio/sync/mpsc/index.html
[`Handle`]: https://docs.rs/tokio/1/tokio/runtime/struct.Handle.html
[`Semaphore`]: https://docs.rs/tokio/1/tokio/sync/struct.Semaphore.html
[`Client`]: https://docs.rs/mini-redis/0.4/mini_redis/client/struct.Client.html
[`Client::get`]: https://docs.rs/mini-redis/0.4/mini_redis/client/struct.Client.html#method.get
[`Client::set`]: https://docs.rs/mini-redis/0.4/mini_redis/client/struct.Client.html#method.set
[`Client::set_expires`]: https://docs.rs/mini-redis/0.4/mini_redis/client/struct.Client.html#method.set_expires
[`Client::publish`]: https://docs.rs/mini-redis/0.4/mini_redis/client/struct.Client.html#method.publish
[`Client::subscribe`]: https://docs.rs/mini-redis/0.4/mini_redis/client/struct.Client.html#method.subscribe
[actor]: https://ryhl.io/blog/actors-with-tokio/
