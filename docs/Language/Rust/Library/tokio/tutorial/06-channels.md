---
title: "Channels (القنوات)"
---

الآن بعد أن تعلمنا القليل عن التزامن (concurrency) مع Tokio، دعنا نطبق هذا على جانب العميل (client side). ضع كود الخادم (server code) الذي كتبناه سابقًا في ملف ثنائي (binary file) صريح:

```bash
$ mkdir src/bin
$ mv src/main.rs src/bin/server.rs
```

وأنشئ ملفًا ثنائيًا جديدًا سيحتوي على كود العميل:

```bash
$ touch src/bin/client.rs
```

في هذا الملف ستكتب كود هذه الصفحة. كلما أردت تشغيله، سيتعين عليك تشغيل الخادم أولاً في نافذة طرفية (terminal window) منفصلة:

```bash
$ cargo run --bin server
```

ثم العميل، **بشكل منفصل**:

```bash
$ cargo run --bin client
```

بعد قولي هذا، دعنا نبرمج!

لنفترض أننا نريد تشغيل أمرين Redis متزامنين. يمكننا إنشاء مهمة (task) واحدة لكل أمر. ثم سيحدث الأمران بشكل متزامن.

في البداية، قد نحاول شيئًا مثل:

```rust,compile_fail
use mini_redis::client;

#[tokio::main]
async fn main() {
    // Establish a connection to the server
    let mut client = client::connect("127.0.0.1:6379").await.unwrap();

    // Spawn two tasks, one gets a key, the other sets a key
    let t1 = tokio::spawn(async {
        let res = client.get("foo").await;
    });

    let t2 = tokio::spawn(async {
        client.set("foo", "bar".into()).await;
    });

    t1.await.unwrap();
    t2.await.unwrap();
}
```

هذا لا يتم تجميعه (compile) لأن كلتا المهمتين تحتاجان إلى الوصول إلى `client` بطريقة ما. نظرًا لأن `Client` لا يُطبق `Copy`، فلن يتم تجميعه بدون بعض الكود لتسهيل هذا المشاركة. بالإضافة إلى ذلك، تأخذ `Client::set` `&mut self`، مما يعني أن الوصول الحصري (exclusive access) مطلوب لاستدعائها. يمكننا فتح اتصال لكل مهمة، لكن هذا ليس مثاليًا. لا يمكننا استخدام `std::sync::Mutex` لأن `.await` سيتعين استدعاؤه مع قفل (lock) محتجز. يمكننا استخدام `tokio::sync::Mutex`، لكن هذا سيسمح بطلب واحد فقط قيد التنفيذ (in-flight request). إذا كان العميل يُطبق [pipelining] (باختصار، إرسال العديد من الأوامر دون انتظار استجابة كل أمر سابق)، فإن mutex غير المتزامن يؤدي إلى عدم الاستفادة الكاملة من الاتصال.

[pipelining]: https://redis.io/topics/pipelining

# Message passing (تمرير الرسائل)

الجواب هو استخدام تمرير الرسائل. يتضمن النمط إنشاء مهمة مخصصة لإدارة مورد `client`. أي مهمة ترغب في إصدار طلب تُرسل رسالة إلى مهمة `client`. تُصدر مهمة `client` الطلب نيابة عن المرسل، وتُرسل الاستجابة مرة أخرى إلى المرسل.

باستخدام هذه الاستراتيجية، يتم إنشاء اتصال واحد. يمكن للمهمة التي تدير `client` الحصول على وصول حصري لاستدعاء `get` و`set`. بالإضافة إلى ذلك، تعمل القناة كمخزن مؤقت (buffer). يمكن إرسال العمليات إلى مهمة `client` بينما تكون مهمة `client` مشغولة. بمجرد أن تصبح مهمة `client` متاحة لمعالجة الطلبات الجديدة، فإنها تسحب الطلب التالي من القناة. يمكن أن يؤدي هذا إلى إنتاجية أفضل، ويمكن تمديده لدعم تجميع الاتصالات (connection pooling).

# Tokio's channel primitives (بدائيات قنوات Tokio)

يوفر Tokio [عددًا من القنوات][channels]، كل منها يخدم غرضًا مختلفًا.

- [mpsc]: قناة متعددة المنتجين، مستهلك واحد (multi-producer, single-consumer channel). يمكن إرسال العديد من القيم.
- [oneshot]: قناة منتج واحد، مستهلك واحد (single-producer, single-consumer channel). يمكن إرسال قيمة واحدة.
- [broadcast]: متعدد المنتجين، متعدد المستهلكين (multi-producer, multi-consumer). يمكن إرسال العديد من القيم. يرى كل مستلم كل قيمة.
- [watch]: متعدد المنتجين، متعدد المستهلكين. يمكن إرسال العديد من القيم، ولكن لا يتم الاحتفاظ بسجل (history). يرى المستلمون أحدث قيمة فقط.

إذا كنت بحاجة إلى قناة متعددة المنتجين متعددة المستهلكين حيث يرى مستهلك واحد فقط كل رسالة، يمكنك استخدام crate [`async-channel`]. توجد أيضًا قنوات للاستخدام خارج Rust غير المتزامن، مثل [`std::sync::mpsc`] و[`crossbeam::channel`]. تنتظر هذه القنوات الرسائل عن طريق حظر مؤشر الترابط (blocking the thread)، وهو أمر غير مسموح به في الكود غير المتزامن.

في هذا القسم، سنستخدم [mpsc] و[oneshot]. يتم استكشاف الأنواع الأخرى من قنوات تمرير الرسائل في الأقسام اللاحقة. يمكن العثور على الكود الكامل من هذا القسم [هنا][full].

[channels]: https://docs.rs/tokio/1/tokio/sync/index.html
[mpsc]: https://docs.rs/tokio/1/tokio/sync/mpsc/index.html
[oneshot]: https://docs.rs/tokio/1/tokio/sync/oneshot/index.html
[broadcast]: https://docs.rs/tokio/1/tokio/sync/broadcast/index.html
[watch]: https://docs.rs/tokio/1/tokio/sync/watch/index.html
[`async-channel`]: https://docs.rs/async-channel/
[`std::sync::mpsc`]: https://doc.rust-lang.org/stable/std/sync/mpsc/index.html
[`crossbeam::channel`]: https://docs.rs/crossbeam/latest/crossbeam/channel/index.html

# Define the message type (تعريف نوع الرسالة)

في معظم الحالات، عند استخدام تمرير الرسائل، تستجيب المهمة التي تتلقى الرسائل لأكثر من أمر واحد. في حالتنا، ستستجيب المهمة لأوامر `GET` و`SET`. لنمذجة هذا، نقوم أولاً بتعريف enum `Command` وتضمين متغير لكل نوع أمر.

```rust
use bytes::Bytes;

#[derive(Debug)]
enum Command {
    Get {
        key: String,
    },
    Set {
        key: String,
        val: Bytes,
    }
}
```

# Create the channel (إنشاء القناة)

في دالة `main`، يتم إنشاء قناة `mpsc`.

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    // Create a new channel with a capacity of at most 32.
    let (tx, mut rx) = mpsc::channel(32);
# tx.send(()).await.unwrap();

    // ... Rest comes here
}
```

تُستخدم قناة `mpsc` **لإرسال** الأوامر إلى المهمة التي تدير اتصال redis. تسمح إمكانية المنتج المتعدد (multi-producer) بإرسال الرسائل من العديد من المهام. يُرجع إنشاء القناة قيمتين، مرسل (sender) ومستقبل (receiver). تُستخدم المقبضين (handles) بشكل منفصل. يمكن نقلهما إلى مهام مختلفة.

يتم إنشاء القناة بسعة 32. إذا تم إرسال الرسائل بشكل أسرع مما يتم استلامها، فستقوم القناة بتخزينها. بمجرد تخزين 32 رسالة في القناة، فإن استدعاء `send(...).await` سيذهب إلى وضع السكون (sleep) حتى تتم إزالة رسالة بواسطة المستقبل.

يتم الإرسال من مهام متعددة عن طريق **استنساخ** `Sender`. على سبيل المثال:

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    let (tx, mut rx) = mpsc::channel(32);
    let tx2 = tx.clone();

    tokio::spawn(async move {
        tx.send("sending from first handle").await.unwrap();
    });

    tokio::spawn(async move {
        tx2.send("sending from second handle").await.unwrap();
    });

    while let Some(message) = rx.recv().await {
        println!("GOT = {}", message);
    }
}
```

يتم إرسال كلتا الرسالتين إلى مقبض `Receiver` الفردي. لا يمكن استنساخ مستقبل قناة `mpsc`.

عندما يخرج كل `Sender` من النطاق (scope) أو يتم إسقاطه (dropped) بطريقة أخرى، لا يعود من الممكن إرسال المزيد من الرسائل إلى القناة. في هذه المرحلة، ستُرجع استدعاء `recv` على `Receiver` `None`، مما يعني أن جميع المرسلين قد اختفوا وأن القناة مغلقة.

في حالتنا لمهمة تدير اتصال Redis، فإنها تعلم أنه يمكنها إغلاق اتصال Redis بمجرد إغلاق القناة، حيث لن يتم استخدام الاتصال مرة أخرى.

# Spawn manager task (إنشاء مهمة المدير)

بعد ذلك، أنشئ مهمة تعالج الرسائل من القناة. أولاً، يتم إنشاء اتصال عميل بـ Redis. ثم، يتم إصدار الأوامر المستلمة عبر اتصال Redis.

```rust
use mini_redis::client;
# enum Command {
#    Get { key: String },
#    Set { key: String, val: bytes::Bytes }
# }
# async fn dox() {
# let (_, mut rx) = tokio::sync::mpsc::channel(10);
// The `move` keyword is used to **move** ownership of `rx` into the task.
let manager = tokio::spawn(async move {
    // Establish a connection to the server
    let mut client = client::connect("127.0.0.1:6379").await.unwrap();

    // Start receiving messages
    while let Some(cmd) = rx.recv().await {
        use Command::*;

        match cmd {
            Get { key } => {
                client.get(&key).await;
            }
            Set { key, val } => {
                client.set(&key, val).await;
            }
        }
    }
});
# }
```

الآن، قم بتحديث المهمتين لإرسال الأوامر عبر القناة بدلاً من إصدارها مباشرة على اتصال Redis.

```rust
# #[derive(Debug)]
# enum Command {
#    Get { key: String },
#    Set { key: String, val: bytes::Bytes }
# }
# async fn dox() {
# let (mut tx, _) = tokio::sync::mpsc::channel(10);
// The `Sender` handles are moved into the tasks. As there are two
// tasks, we need a second `Sender`.
let tx2 = tx.clone();

// Spawn two tasks, one gets a key, the other sets a key
let t1 = tokio::spawn(async move {
    let cmd = Command::Get {
        key: "foo".to_string(),
    };

    tx.send(cmd).await.unwrap();
});

let t2 = tokio::spawn(async move {
    let cmd = Command::Set {
        key: "foo".to_string(),
        val: "bar".into(),
    };

    tx2.send(cmd).await.unwrap();
});
# }
````

في أسفل دالة `main`، ننتظر `.await` مقبضات الانضمام (join handles) لضمان اكتمال الأوامر بالكامل قبل خروج العملية.

```rust
# type Jh = tokio::task::JoinHandle<()>;
# async fn dox(t1: Jh, t2: Jh, manager: Jh) {
t1.await.unwrap();
t2.await.unwrap();
manager.await.unwrap();
# }
```

# Receive responses (استقبال الاستجابات)

الخطوة الأخيرة هي استقبال الاستجابة من مهمة المدير. يحتاج أمر `GET` إلى الحصول على القيمة ويحتاج أمر `SET` إلى معرفة ما إذا كانت العملية قد اكتملت بنجاح.

لتمرير الاستجابة، تُستخدم قناة `oneshot`. قناة `oneshot` هي قناة منتج واحد، مستهلك واحد (single-producer, single-consumer) مُحسّنة لإرسال قيمة واحدة. في حالتنا، القيمة الواحدة هي الاستجابة.

على غرار `mpsc`، تُرجع `oneshot::channel()` مقبض مرسل ومستقبل.

```rust
use tokio::sync::oneshot;

# async fn dox() {
let (tx, rx) = oneshot::channel();
# tx.send(()).unwrap();
# }
```

على عكس `mpsc`، لا يتم تحديد سعة لأن السعة دائمًا واحدة. بالإضافة إلى ذلك، لا يمكن استنساخ أي من المقبضين.

لاستقبال الاستجابات من مهمة المدير، قبل إرسال أمر، يتم إنشاء قناة `oneshot`. يتم تضمين النصف المرسل من القناة في الأمر إلى مهمة المدير. يُستخدم النصف المستقبل لاستقبال الاستجابة.

أولاً، قم بتحديث `Command` لتضمين `Sender`. لتسهيل الأمر، يتم استخدام اسم مستعار للنوع (type alias) للإشارة إلى `Sender`.

```rust
use tokio::sync::oneshot;
use bytes::Bytes;

/// Multiple different commands are multiplexed over a single channel.
#[derive(Debug)]
enum Command {
    Get {
        key: String,
        resp: Responder<Option<Bytes>>,
    },
    Set {
        key: String,
        val: Bytes,
        resp: Responder<()>,
    },
}

/// Provided by the requester and used by the manager task to send
/// the command response back to the requester.
type Responder<T> = oneshot::Sender<mini_redis::Result<T>>;
```

الآن، قم بتحديث المهام التي تُصدر الأوامر لتضمين `oneshot::Sender`.

```rust
# use tokio::sync::{oneshot, mpsc};
# use bytes::Bytes;
# #[derive(Debug)]
# enum Command {
#     Get { key: String, resp: Responder<Option<bytes::Bytes>> },
#     Set { key: String, val: Bytes, resp: Responder<()> },
# }
# type Responder<T> = oneshot::Sender<mini_redis::Result<T>>;
# fn dox() {
# let (mut tx, mut rx) = mpsc::channel(10);
# let mut tx2 = tx.clone();
let t1 = tokio::spawn(async move {
    let (resp_tx, resp_rx) = oneshot::channel();
    let cmd = Command::Get {
        key: "foo".to_string(),
        resp: resp_tx,
    };

    // Send the GET request
    tx.send(cmd).await.unwrap();

    // Await the response
    let res = resp_rx.await;
    println!("GOT = {:?}", res);
});

let t2 = tokio::spawn(async move {
    let (resp_tx, resp_rx) = oneshot::channel();
    let cmd = Command::Set {
        key: "foo".to_string(),
        val: "bar".into(),
        resp: resp_tx,
    };

    // Send the SET request
    tx2.send(cmd).await.unwrap();

    // Await the response
    let res = resp_rx.await;
    println!("GOT = {:?}", res);
});
# }
```

أخيرًا، قم بتحديث مهمة المدير لإرسال الاستجابة عبر قناة `oneshot`.

```rust
# use tokio::sync::{oneshot, mpsc};
# use bytes::Bytes;
# #[derive(Debug)]
# enum Command {
#     Get { key: String, resp: Responder<Option<bytes::Bytes>> },
#     Set { key: String, val: Bytes, resp: Responder<()> },
# }
# type Responder<T> = oneshot::Sender<mini_redis::Result<T>>;
# async fn dox(mut client: mini_redis::client::Client) {
# let (_, mut rx) = mpsc::channel::<Command>(10);
while let Some(cmd) = rx.recv().await {
    match cmd {
        Command::Get { key, resp } => {
            let res = client.get(&key).await;
            // Ignore errors
            let _ = resp.send(res);
        }
        Command::Set { key, val, resp } => {
            let res = client.set(&key, val).await;
            // Ignore errors
            let _ = resp.send(res);
        }
    }
}
# }
```

استدعاء `send` على `oneshot::Sender` يكتمل على الفور ولا يتطلب `.await`. هذا لأن `send` على قناة `oneshot` سيفشل دائمًا أو ينجح على الفور دون أي شكل من أشكال الانتظار.

يُرجع إرسال قيمة على قناة oneshot `Err` عندما يكون النصف المستقبل قد تم إسقاطه (dropped). يشير هذا إلى أن المستقبل لم يعد مهتمًا بالاستجابة. في سيناريونا، يعتبر إلغاء اهتمام المستقبل حدثًا مقبولًا. لا يلزم التعامل مع `Err` الذي تُرجعه `resp.send(...)`.

يمكنك العثور على الكود بأكمله [هنا][full].

# Backpressure and bounded channels (الضغط العكسي والقنوات المحدودة)

كلما تم إدخال التزامن أو قائمة الانتظار (queuing)، من المهم التأكد من أن قائمة الانتظار محدودة وأن النظام سيتعامل مع الحمل بأمان. ستملأ قوائم الانتظار غير المحدودة في النهاية كل الذاكرة المتاحة وتتسبب في فشل النظام بطرق غير متوقعة.

يهتم Tokio بتجنب قائمة الانتظار الضمنية (implicit queuing). جزء كبير من هذا هو حقيقة أن العمليات غير المتزامنة كسولة (lazy). ضع في اعتبارك ما يلي:

```rust
# fn async_op() {}
# fn dox() {
loop {
    async_op();
}
# }
# fn main() {}
```

إذا تم تشغيل العملية غير المتزامنة بحماس (eagerly)، فستقوم الحلقة بوضع `async_op` جديد في قائمة الانتظار بشكل متكرر للتشغيل دون التأكد من اكتمال العملية السابقة. يؤدي هذا إلى قائمة انتظار ضمنية غير محدودة. الأنظمة القائمة على رد الاتصال (callback based systems) والأنظمة القائمة على الـ future **الحماسية** معرضة بشكل خاص لهذا.

ومع ذلك، مع Tokio وRust غير المتزامن، فإن القصاصة أعلاه **لن** تؤدي إلى تشغيل `async_op` على الإطلاق. هذا لأن `.await` لا يتم استدعاؤه أبدًا. إذا تم تحديث القصاصة لاستخدام `.await`، فإن الحلقة تنتظر اكتمال العملية قبل البدء من جديد.

```rust
# async fn async_op() {}
# async fn dox() {
loop {
    // Will not repeat until `async_op` completes
    async_op().await;
}
# }
# fn main() {}
```

يجب إدخال التزامن وقائمة الانتظار بشكل صريح. تشمل طرق القيام بذلك ما يلي:

* `tokio::spawn`
* `select!`
* `join!`
* `mpsc::channel`

عند القيام بذلك، احرص على التأكد من أن إجمالي مقدار التزامن محدود. على سبيل المثال، عند كتابة حلقة قبول TCP، تأكد من أن العدد الإجمالي للمقابس المفتوحة محدود. عند استخدام `mpsc::channel`، اختر سعة قناة يمكن التحكم فيها. ستكون قيم الحدود المحددة خاصة بالتطبيق.

يعد الاهتمام واختيار الحدود الجيدة جزءًا كبيرًا من كتابة تطبيقات Tokio موثوقة.

[full]: https://github.com/tokio-rs/website/blob/master/tutorial-code/channels/src/main.rs
