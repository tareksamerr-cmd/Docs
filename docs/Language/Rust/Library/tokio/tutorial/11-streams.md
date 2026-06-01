---
title: "التدفقات (Streams)"
---

التدفق (stream) هو سلسلة غير متزامنة من القيم. إنه المعادل غير المتزامن لـ [`std::iter::Iterator`][iter] في Rust ويتم تمثيله بواسطة سمة (trait) [`Stream`]. يمكن تكرار التدفقات في وظائف `async`. كما يمكن تحويلها باستخدام المحولات (adapters). يوفر Tokio عدداً من المحولات الشائعة في سمة [`StreamExt`].

توفر Tokio دعم التدفق في حزمة (crate) منفصلة: `tokio-stream`.

```toml
tokio-stream = "0.1"
```

> **معلومات**
> حالياً، توجد أدوات Tokio للتدفق (Stream utilities) في حزمة `tokio-stream`. بمجرد استقرار سمة `Stream` في مكتبة Rust القياسية، سيتم نقل أدوات التدفق الخاصة بـ Tokio إلى حزمة `tokio`.

# التكرار (Iteration)

حالياً، لا تدعم لغة البرمجة Rust حلقات `for` غير المتزامنة. بدلاً من ذلك، يتم تكرار التدفقات باستخدام حلقة `while let` مقترنة بـ [`StreamExt::next()`][next].

```rust
use tokio_stream::StreamExt;

#[tokio::main]
async fn main() {
    let mut stream = tokio_stream::iter(&[1, 2, 3]);

    while let Some(v) = stream.next().await {
        println!("تلقيت = {:?}", v);
    }
}
```

مثل المكررات (iterators)، يرجع أسلوب `next()` القيمة `Option<T>` حيث `T` هو نوع قيمة التدفق. يشير تلقي `None` إلى انتهاء تكرار التدفق.

## بث Mini-Redis (Mini-Redis broadcast)

دعونا نستعرض مثالاً أكثر تعقيداً قليلاً باستخدام عميل Mini-Redis.

يمكن العثور على الكود الكامل [هنا][full].

```rust
use tokio_stream::StreamExt;
use mini_redis::client;

async fn publish() -> mini_redis::Result<()> {
    let mut client = client::connect("127.0.0.1:6379").await?;

    // نشر بعض البيانات
    client.publish("numbers", "1".into()).await?;
    client.publish("numbers", "two".into()).await?;
    client.publish("numbers", "3".into()).await?;
    client.publish("numbers", "four".into()).await?;
    client.publish("numbers", "five".into()).await?;
    client.publish("numbers", "6".into()).await?;
    Ok(())
}

async fn subscribe() -> mini_redis::Result<()> {
    let client = client::connect("127.0.0.1:6379").await?;
    let subscriber = client.subscribe(vec!["numbers".to_string()]).await?;
    let messages = subscriber.into_stream();

    tokio::pin!(messages);

    while let Some(msg) = messages.next().await {
        println!("تلقيت = {:?}", msg);
    }

    Ok(())
}

# fn dox() {
#[tokio::main]
async fn main() -> mini_redis::Result<()> {
    tokio::spawn(async {
        publish().await
    });

    subscribe().await?;

    println!("انتهى");

    Ok(())
}
# }
```

يتم إنشاء مهمة لنشر الرسائل إلى خادم Mini-Redis على قناة "numbers". ثم، في المهمة الرئيسية، نشترك في قناة "numbers" ونعرض الرسائل المستلمة.

بعد الاشتراك، يتم استدعاء [`into_stream()`] على المشترك المرتجع. هذا يستهلك `Subscriber` ، ويرجع تدفقاً ينتج رسائل فور وصولها. قبل أن نبدأ في تكرار الرسائل، لاحظ أن التدفق يتم [تثبيته (pinned)][pin] في المكدس (stack) باستخدام [`tokio::pin!`]. يتطلب استدعاء `next()` على تدفق أن يكون التدفق [مثبتاً][pin]. ترجع وظيفة `into_stream()` تدفقاً *غير* مثبت، ويجب علينا تثبيته صراحةً لتكراره.

> **معلومات**
> تكون قيمة Rust "مثبتة" (pinned) عندما لا يعود بالإمكان نقلها في الذاكرة. من الخصائص الرئيسية للقيمة المثبتة أنه يمكن أخذ مؤشرات (pointers) للبيانات المثبتة ويمكن للمستدعي أن يثق في أن المؤشر يظل صالحاً. يتم استخدام هذه الميزة بواسطة `async/await` لدعم استعارة البيانات عبر نقاط `.await`.

إذا نسيت تثبيت التدفق، فستحصل على خطأ في التجميع. إذا واجهت رسالة خطأ كهذه، فحاول تثبيت القيمة!

قبل محاولة تشغيل هذا، ابدأ خادم Mini-Redis:

```bash
$ mini-redis-server
```

ثم حاول تشغيل الكود. سنرى الرسائل تظهر في STDOUT.

قد يتم إسقاط بعض الرسائل المبكرة لوجود سباق (race) بين الاشتراك والنشر. البرنامج لا ينتهي أبداً، حيث يظل الاشتراك في قناة Mini-Redis نشطاً طالما أن الخادم نشط.

# المحولات (Adapters)

الوظائف التي تأخذ [`Stream`] وترجع [`Stream`] آخر تسمى غالباً "محولات التدفق" (stream adapters). تشمل محولات التدفق الشائعة [`map`] و [`take`] و [`filter`].

دعونا نحدث برنامج Mini-Redis بحيث ينتهي. بعد تلقي ثلاث رسائل، توقف عن تكرار الرسائل. يتم ذلك باستخدام [`take`]. يحد هذا المحول التدفق لينتج **على الأكثر** `n` من الرسائل.

```rust
let messages = subscriber
    .into_stream()
    .take(3);
```

بتشغيل البرنامج مرة أخرى، ينتهي البرنامج بعد ثلاث رسائل.

الآن، لنحدد التدفق بالأرقام المكونة من رقم واحد فقط. سنقوم بالتحقق من ذلك عن طريق فحص طول الرسالة. نستخدم محول [`filter`] لإسقاط أي رسالة لا تطابق الشرط.

```rust
let messages = subscriber
    .into_stream()
    .filter(|msg| match msg {
        Ok(msg) if msg.content.len() == 1 => true,
        _ => false,
    })
    .take(3);
```

لاحظ أن ترتيب تطبيق المحولات مهم. استدعاء `filter` أولاً ثم `take` يختلف عن استدعاء `take` ثم `filter`.

أخيراً، سنقوم بتنسيق المخرجات عن طريق إزالة جزء `Ok(Message { ... })`. يتم ذلك باستخدام [`map`]. بما أن هذا يتم تطبيقه **بعد** `filter` ، فإننا نعلم أن الرسالة هي `Ok` ، لذا يمكننا استخدام `unwrap()`.

```rust
let messages = subscriber
    .into_stream()
    .filter(|msg| match msg {
        Ok(msg) if msg.content.len() == 1 => true,
        _ => false,
    })
    .map(|msg| msg.unwrap().content)
    .take(3);
```

هناك خيار آخر وهو دمج خطوتي [`filter`] و [`map`] في استدعاء واحد باستخدام [`filter_map`].

# تنفيذ الـ `Stream`

سمة [`Stream`] مشابهة جداً لسمة [`Future`].

```rust
use std::pin::Pin;
use std::task::{Context, Poll};

pub trait Stream {
    type Item;

    fn poll_next(
        self: Pin<&mut Self>, 
        cx: &mut Context<'_>
    ) -> Poll<Option<Self::Item>>;

    fn size_hint(&self) -> (usize, Option<usize>) {
        (0, None)
    }
}
```

وظيفة `Stream::poll_next()` تشبه إلى حد كبير `Future::poll` ، باستثناء أنه يمكن استدعاؤها بشكل متكرر لتلقي العديد من القيم من التدفق. تماماً كما رأينا في [Async in depth][async] ، عندما **لا** يكون التدفق جاهزاً لإرجاع قيمة، يتم إرجاع `Poll::Pending` بدلاً من ذلك. يتم تسجيل waker المهمة، وبمجرد أن يصبح التدفق جاهزاً للفحص مرة أخرى، يتم إخطار الـ waker.

تُستخدم وظيفة `size_hint()` بنفس الطريقة التي تُستخدم بها مع [المكررات (iterators)][iter].

عادةً، عند تنفيذ `Stream` يدوياً، يتم ذلك عن طريق تركيب futures وتدفقات أخرى.

## `async-stream`

يمكن أن يكون تنفيذ التدفقات يدوياً باستخدام سمة [`Stream`] مملاً. لسوء الحظ، لا تدعم لغة البرمجة Rust بعد صيغة `async/await` لتعريف التدفقات.

حزمة [`async-stream`] متاحة كحل مؤقت. توفر هذه الحزمة ماكرو `stream!` الذي يحول المدخلات إلى تدفق. باستخدام هذه الحزمة، يمكن تنفيذ التدفقات بسهولة أكبر باستخدام `yield`.

[iter]: https://doc.rust-lang.org/book/ch13-02-iterators.html
[`Stream`]: https://docs.rs/futures-core/0.3/futures_core/stream/trait.Stream.html
[async]: async
[`StreamExt`]: https://docs.rs/tokio-stream/0.1/tokio_stream/trait.StreamExt.html
[next]: https://docs.rs/tokio-stream/0.1/tokio_stream/trait.StreamExt.html#method.next
[`into_stream()`]: https://docs.rs/mini-redis/0.4/mini_redis/client/struct.Subscriber.html#method.into_stream
[pin]: https://doc.rust-lang.org/std/pin/index.html
[`tokio::pin!`]: https://docs.rs/tokio/1/tokio/macro.pin.html
[`map`]: https://docs.rs/tokio-stream/0.1/tokio_stream/trait.StreamExt.html#method.map
[`take`]: https://docs.rs/tokio-stream/0.1/tokio_stream/trait.StreamExt.html#method.take
[`filter`]: https://docs.rs/tokio-stream/0.1/tokio_stream/trait.StreamExt.html#method.filter
[`filter_map`]: https://docs.rs/tokio-stream/0.1/tokio_stream/trait.StreamExt.html#method.filter_map
[`async-stream`]: https://docs.rs/async-stream
