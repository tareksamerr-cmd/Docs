---
title: "إنشاء المهام (Spawning)"
---

سنقوم بتغيير المسار والبدء في العمل على خادم Redis.

أولاً، انقل كود العميل لـ `SET`/`GET` من القسم السابق إلى ملف أمثلة (example file). بهذه الطريقة، يمكننا تشغيله مقابل خادمنا.

```bash
$ mkdir -p examples
$ mv src/main.rs examples/hello-redis.rs
```

ثم أنشئ ملف `src/main.rs` جديداً وفارغاً واستمر.

# قبول المقابس (Accepting sockets)

أول شيء يحتاج خادم Redis الخاص بنا للقيام به هو قبول مقابس TCP الواردة. يتم ذلك عن طريق ربط [`tokio::net::TcpListener`][tcpl] بالمنفذ **6379**.

> **معلومات**
> تمت تسمية العديد من أنواع Tokio بنفس أسماء نظيراتها المتزامنة في مكتبة Rust القياسية. عندما يكون ذلك منطقياً، تعرض Tokio نفس واجهات برمجة التطبيقات (APIs) مثل `std` ولكن باستخدام `async fn`.

بعد ذلك يتم قبول المقابس في حلقة (loop). تتم معالجة كل مقبس ثم إغلاقه. في الوقت الحالي، سنقوم بقراءة الأمر، وطباعته إلى المخرجات القياسية (stdout) والرد بخطأ.

`src/main.rs`

```rust
use tokio::net::{TcpListener, TcpStream};
use mini_redis::{Connection, Frame};

# fn dox() {
#[tokio::main]
async fn main() {
    // ربط المستمع (listener) بالعنوان
    let listener = TcpListener.bind("127.0.0.1:6379").await.unwrap();

    loop {
        // يحتوي العنصر الثاني على IP ومنفذ الاتصال الجديد.
        let (socket, _) = listener.accept().await.unwrap();
        process(socket).await;
    }
}
# }

async fn process(socket: TcpStream) {
    // يتيح لنا `Connection` قراءة/كتابة **إطارات** (frames) redis بدلاً من
    // تدفقات البايت. يتم تعريف نوع `Connection` بواسطة mini-redis.
    let mut connection = Connection::new(socket);

    if let Some(frame) = connection.read_frame().await.unwrap() {
        println!("تلقيت: {:?}", frame);

        // الرد بخطأ
        let response = Frame::Error("unimplemented".to_string());
        connection.write_frame(&response).await.unwrap();
    }
}
```

الآن، قم بتشغيل حلقة القبول هذه:

```bash
$ cargo run
```

في نافذة طرفية منفصلة، قم بتشغيل مثال `hello-redis` (أمر `SET`/`GET` من القسم السابق، والذي يلعب دور عميل Redis):

```bash
$ cargo run --example hello-redis
```

يجب أن تكون المخرجات:

```text
Error: "unimplemented"
```

في طرفية الخادم، المخرجات هي:

```text
GOT: Array([Bulk(b"set"), Bulk(b"hello"), Bulk(b"world")])
```

[tcpl]: https://docs.rs/tokio/1/tokio/net/struct.TcpListener.html

# التزامن (Concurrency)

يواجه خادمنا مشكلة بسيطة (بجانب الرد بالأخطاء فقط). إنه يعالج الطلبات الواردة واحداً تلو الآخر. عندما يتم قبول اتصال، يبقى الخادم داخل كتلة حلقة القبول حتى يتم كتابة الاستجابة بالكامل في المقبس.

نريد أن يقوم خادم Redis الخاص بنا بمعالجة **العديد** من الطلبات المتزامنة. للقيام بذلك، نحتاج إلى إضافة بعض التزامن.

> **معلومات**
> التزامن (Concurrency) والتوازي (Parallelism) ليسا نفس الشيء. إذا كنت تتنقل بين مهمتين، فأنت تعمل على كلتا المهمتين بشكل متزامن، ولكن ليس بالتوازي. لكي يعتبر الأمر توازياً، ستحتاج إلى شخصين، كل منهما مخصص لمهمة واحدة.
>
> إحدى مزايا استخدام Tokio هي أن الكود غير المتزامن يسمح لك بالعمل على العديد من المهام بشكل متزامن، دون الحاجة للعمل عليها بالتوازي باستخدام الخيوط (threads) العادية. في الواقع، يمكن لـ Tokio تشغيل العديد من المهام بشكل متزامن على خيط واحد!

لمعالجة الاتصالات بشكل متزامن، يتم إنشاء مهمة (spawn a new task) لكل اتصال وارد. تتم معالجة الاتصال في هذه المهمة.

تصبح حلقة القبول:

```rust
use tokio::net::TcpListener;

# fn dox() {
#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:6379").await.unwrap();

    loop {
        let (socket, _) = listener.accept().await.unwrap();
        // يتم إنشاء مهمة جديدة لكل مقبس وارد. يتم نقل
        // المقبس إلى المهمة الجديدة ومعالجته هناك.
        tokio::spawn(async move {
            process(socket).await;
        });
    }
}
# }
# async fn process(_: tokio::net::TcpStream) {}
```

## المهام (Tasks)

مهمة Tokio هي خيط أخضر (green thread) غير متزامن. يتم إنشاؤها عن طريق تمرير كتلة `async` إلى `tokio::spawn`. ترجع وظيفة `tokio::spawn` قيمة من نوع `JoinHandle` ، والتي يمكن للمستدعي استخدامها للتفاعل مع المهمة التي تم إنشاؤها. قد تحتوي كتلة `async` على قيمة مرجعة. يمكن للمستدعي الحصول على القيمة المرجعة باستخدام `.await` على الـ `JoinHandle`.

على سبيل المثال:

```rust
#[tokio::main]
async fn main() {
    let handle = tokio::spawn(async {
        // القيام ببعض العمل غير المتزامن
        "قيمة مرجعة"
    });

    // القيام ببعض الأعمال الأخرى

    let out = handle.await.unwrap();
    println!("تلقيت {}", out);
}
```

الانتظار على `JoinHandle` يرجع `Result`. عندما تواجه مهمة خطأ أثناء التنفيذ، سيرجع الـ `JoinHandle` القيمة `Err`. يحدث هذا عندما تتوقف المهمة بشكل مفاجئ (panic)، أو إذا تم إلغاء المهمة قسراً بسبب إغلاق وقت التشغيل (runtime).

المهام هي وحدة التنفيذ التي يديرها المجدول (scheduler). يؤدي إنشاء المهمة (spawning) إلى إرسالها إلى مجدول Tokio، والذي يضمن بعد ذلك تنفيذ المهمة عندما يكون لديها عمل للقيام به. قد يتم تنفيذ المهمة المنشأة على نفس الخيط الذي تم إنشاؤها فيه، أو قد يتم تنفيذها على خيط وقت تشغيل مختلف. يمكن أيضاً نقل المهمة بين الخيوط بعد إنشائها.

المهام في Tokio خفيفة الوزن للغاية. تحت الغطاء، تتطلب تخصيصاً واحداً فقط و 64 بايت من الذاكرة. يجب أن تشعر التطبيقات بالحرية في إنشاء الآلاف، إن لم يكن الملايين من المهام.

## قيد `'static` (`'static` bound)

عندما تقوم بإنشاء مهمة على وقت تشغيل Tokio، يجب أن يكون عمر نوعها (lifetime) هو `'static`. هذا يعني أن المهمة المنشأة يجب ألا تحتوي على أي مراجع لبيانات مملوكة خارج المهمة.

> **معلومات**
> من المفاهيم الخاطئة الشائعة أن `'static` تعني دائماً "يعيش للأبد"، ولكن ليس هذا هو الحال. مجرد كون القيمة `'static` لا يعني أن لديك تسرباً في الذاكرة (memory leak).

على سبيل المثال، الكود التالي لن يترجم:

```rust,compile_fail
use tokio::task;

#[tokio::main]
async fn main() {
    let v = vec![1, 2, 3];

    task::spawn(async {
        println!("إليك متجه: {:?}", v);
    });
}
```

يحدث هذا لأنه، بشكل افتراضي، لا يتم **نقل** (move) المتغيرات إلى الكتل غير المتزامنة. يظل المتجه `v` مملوكاً لوظيفة `main`. يقوم سطر `println!` باستعارة `v`. يشرح مترجم rust هذا لنا بل ويقترح الإصلاح! تغيير السطر 7 إلى `task::spawn(async move {` سيوجه المترجم إلى **نقل** `v` إلى المهمة المنشأة. الآن، تمتلك المهمة جميع بياناتها، مما يجعلها `'static`.

إذا كان يجب الوصول إلى قطعة واحدة من البيانات من أكثر من مهمة واحدة بشكل متزامن، فيجب مشاركتها باستخدام أدوات التزامن مثل `Arc`.

عندما نقول أن القيمة هي `'static` ، فكل ما يعنيه ذلك هو أنه لن يكون من الخطأ الاحتفاظ بتلك القيمة للأبد. هذا مهم لأن المترجم غير قادر على التفكير في المدة التي ستبقى فيها المهمة المنشأة حديثاً. علينا التأكد من السماح للمهمة بالعيش للأبد، حتى يتمكن Tokio من جعل المهمة تعمل طالما احتاجت إلى ذلك.

## قيد `Send` (`Send` bound)

المهام التي يتم إنشاؤها بواسطة `tokio::spawn` **يجب** أن تنفذ `Send`. يسمح هذا لوقت تشغيل Tokio بنقل المهام بين الخيوط أثناء تعليقها عند `.await`.

تكون المهام `Send` عندما تكون **جميع** البيانات التي يتم الاحتفاظ بها **عبر** استدعاءات `.await` هي `Send`. هذا أمر دقيق بعض الشيء. عند استدعاء `.await` ، تتخلى المهمة عن التحكم للمجدول. في المرة التالية التي يتم فيها تنفيذ المهمة، فإنها تستأنف من النقطة التي توقفت عندها. لجعل هذا يعمل، يجب حفظ جميع الحالات التي يتم استخدامها **بعد** `.await` بواسطة المهمة. إذا كانت هذه الحالة `Send` ، أي يمكن نقلها عبر الخيوط، فيمكن نقل المهمة نفسها عبر الخيوط. وعلى العكس من ذلك، إذا لم تكن الحالة `Send` ، فالمهمة ليست كذلك أيضاً.

على سبيل المثال، هذا يعمل:

```rust
use tokio::task::yield_now;
use std::rc::Rc;

#[tokio::main]
async fn main() {
    tokio::spawn(async {
        // النطاق يجبر `rc` على السقوط (drop) قبل `.await`.
        {
            let rc = Rc::new("hello");
            println!("{}", rc);
        }

        // لم يعد `rc` مستخدماً. لا يتم الاحتفاظ به عندما
        // تتخلى المهمة عن التحكم للمجدول
        yield_now().await;
    });
}
```

وهذا لا يعمل:

```rust,compile_fail
use tokio::task::yield_now;
use std::rc::Rc;

#[tokio::main]
async fn main() {
    tokio::spawn(async {
        let rc = Rc::new("hello");

        // يتم استخدام `rc` بعد `.await`. يجب الاحتفاظ به في
        // حالة المهمة.
        yield_now().await;

        println!("{}", rc);
    });
}
```

سنناقش حالة خاصة لهذا الخطأ بمزيد من التعمق [في الفصل القادم][mutex-guard].

[mutex-guard]: shared-state#holding-a-mutexguard-across-an-await

# تخزين القيم (Store values)

سنقوم الآن بتنفيذ وظيفة `process` للتعامل مع الأوامر الواردة. سنستخدم `HashMap` لتخزين القيم. ستقوم أوامر `SET` بالإدخال في `HashMap` وستقوم أوامر `GET` بتحميلها. بالإضافة إلى ذلك، سنستخدم حلقة لقبول أكثر من أمر واحد لكل اتصال.

```rust
use tokio::net::TcpStream;
use mini_redis::{Connection, Frame};

async fn process(socket: TcpStream) {
    use mini_redis::Command::{self, Get, Set};
    use std::collections::HashMap;

    // يتم استخدام hashmap لتخزين البيانات
    let mut db = HashMap::new();

    // Connection، المقدمة من `mini-redis` ، تتعامل مع تحليل الإطارات من المقبس
    let mut connection = Connection::new(socket);

    // استخدم `read_frame` لتلقي أمر من الاتصال.
    while let Some(frame) = connection.read_frame().await.unwrap() {
        let response = match Command::from_frame(frame).unwrap() {
            Set(cmd) => {
                // يتم تخزين القيمة كـ `Vec<u8>`
                db.insert(cmd.key().to_string(), cmd.value().to_vec());
                Frame::Simple("OK".to_string())
            }
            Get(cmd) => {
                if let Some(value) = db.get(cmd.key()) {
                    // يتوقع `Frame::Bulk` أن تكون البيانات من نوع `Bytes`.
                    // سيتم تغطية هذا النوع لاحقاً في الدليل. في الوقت الحالي،
                    // يتم تحويل `&Vec<u8>` إلى `Bytes` باستخدام `into()`.
                    Frame::Bulk(value.clone().into())
                } else {
                    Frame::Null
                }
            }
            cmd => panic!("غير منفذ {:?}", cmd),
        };

        // كتابة الاستجابة للعميل
        connection.write_frame(&response).await.unwrap();
    }
}
```

الآن، ابدأ الخادم:

```bash
$ cargo run
```

وفي نافذة طرفية منفصلة، قم بتشغيل مثال عميل `hello-redis` مرة أخرى:

```bash
$ cargo run --example hello-redis
```

الآن، ستكون مخرجات العميل:

```text
got value from the server; result=Some(b"world")
```

يمكننا الآن جلب وتعيين القيم، ولكن هناك مشكلة: القيم لا تتم مشاركتها بين الاتصالات. إذا اتصل مقبس آخر وحاول جلب (`GET`) مفتاح `hello` ، فلن يجد شيئاً.

سنقوم في القسم التالي بتنفيذ حفظ البيانات لجميع المقابس.

[full]: https://github.com/tokio-rs/website/blob/master/tutorial-code/spawning/src/main.rs
