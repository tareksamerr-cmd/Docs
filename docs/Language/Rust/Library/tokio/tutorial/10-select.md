---
title: "Select"
---

حتى الآن، عندما أردنا إضافة التزامن (concurrency) إلى النظام، قمنا بإنشاء مهمة جديدة (spawn a new task). سنغطي الآن بعض الطرق الإضافية لتنفيذ الكود غير المتزامن بشكل متزامن مع Tokio.

# `tokio::select!`

يسمح ماكرو `tokio::select!` بالانتظار على حسابات غير متزامنة متعددة ويرجع عندما يكتمل حساب **واحد**.

على سبيل المثال:

```rust
use tokio::sync::oneshot;

#[tokio::main]
async fn main() {
    let (tx1, rx1) = oneshot::channel();
    let (tx2, rx2) = oneshot::channel();

    tokio::spawn(async {
        let _ = tx1.send("one");
    });

    tokio::spawn(async {
        let _ = tx2.send("two");
    });

    tokio::select! {
        val = rx1 => {
            println!("rx1 اكتمل أولاً بـ {:?}", val);
        }
        val = rx2 => {
            println!("rx2 اكتمل أولاً بـ {:?}", val);
        }
    }
}
```

يتم استخدام قناتين من نوع oneshot. يمكن لأي من القناتين أن تكتمل أولاً. تنتظر عبارة `select!` على كلتا القناتين وتربط `val` بالقيمة التي ترجعها المهمة. عندما يكتمل `tx1` أو `tx2` ، يتم تنفيذ الكتلة البرمجية (block) المرتبطة.

يتم إسقاط (drop) الفرع الذي **لا يكتمل**. في المثال، ينتظر الحساب `oneshot::Receiver` لكل قناة. يتم إسقاط `oneshot::Receiver` للقناة التي لم تكتمل بعد.

## الإلغاء (Cancellation)

مع Rust غير المتزامن، يتم إجراء الإلغاء عن طريق إسقاط الـ future. تذكر من ["Async in depth"][async]، يتم تنفيذ عمليات Rust غير المتزامنة باستخدام الـ futures والـ futures هي كسولة (lazy). لا تستمر العملية إلا عندما يتم فحص (poll) الـ future. إذا تم إسقاط الـ future، فلا يمكن للعملية الاستمرار لأن جميع الحالات المرتبطة قد تم إسقاطها.

ومع ذلك، في بعض الأحيان ستقوم عملية غير متزامنة بإنشاء مهام خلفية (spawn background tasks) أو بدء عمليات أخرى تعمل في الخلفية. على سبيل المثال، في المثال أعلاه، يتم إنشاء مهمة لإرسال رسالة مرة أخرى. عادةً، ستقوم المهمة بإجراء بعض الحسابات لإنشاء القيمة.

يمكن للـ Futures أو الأنواع الأخرى تنفيذ `Drop` لتنظيف موارد الخلفية. ينفذ `oneshot::Receiver` الخاص بـ Tokio ميزة `Drop` عن طريق إرسال إشعار إغلاق إلى نصف الـ `Sender`. يمكن لنصف المرسل تلقي هذا الإشعار وإيقاف العملية قيد التنفيذ عن طريق إسقاطها.

```rust
use tokio::sync::oneshot;

async fn some_operation() -> String {
    // حساب القيمة هنا
# "wut".to_string()
}

#[tokio::main]
async fn main() {
    let (mut tx1, rx1) = oneshot::channel();
    let (tx2, rx2) = oneshot::channel();

    tokio::spawn(async {
        // Select على العملية وإشعار `closed()` الخاص بـ oneshot.
        tokio::select! {
            val = some_operation() => {
                let _ = tx1.send(val);
            }
            _ = tx1.closed() => {
                // تم إلغاء `some_operation()`، وتكتمل المهمة ويتم إسقاط `tx1`.
            }
        }
    });

    tokio::spawn(async {
        let _ = tx2.send("two");
    });

    tokio::select! {
        val = rx1 => {
            println!("rx1 اكتمل أولاً بـ {:?}", val);
        }
        val = rx2 => {
            println!("rx2 اكتمل أولاً بـ {:?}", val);
        }
    }
}
```

[async]: async

## تنفيذ الـ `Future`

للمساعدة في فهم كيفية عمل `select!` بشكل أفضل، دعنا نلقي نظرة على الشكل الذي قد يبدو عليه تنفيذ `Future` افتراضي. هذه نسخة مبسطة. في الممارسة العملية، يتضمن `select!` وظائف إضافية مثل اختيار الفرع الذي سيتم فحصه (poll) أولاً بشكل عشوائي.

```rust
use tokio::sync::oneshot;
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

struct MySelect {
    rx1: oneshot::Receiver<&'static str>,
    rx2: oneshot::Receiver<&'static str>,
}

impl Future for MySelect {
    type Output = ();

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        if let Poll::Ready(val) = Pin::new(&mut self.rx1).poll(cx) {
            println!("rx1 اكتمل أولاً بـ {:?}", val);
            return Poll::Ready(());
        }

        if let Poll::Ready(val) = Pin::new(&mut self.rx2).poll(cx) {
            println!("rx2 اكتمل أولاً بـ {:?}", val);
            return Poll::Ready(());
        }

        Poll::Pending
    }
}

#[tokio::main]
async fn main() {
    let (tx1, rx1) = oneshot::channel();
    let (tx2, rx2) = oneshot::channel();

    // استخدم tx1 و tx2
# tx1.send("one").unwrap();
# tx2.send("two").unwrap();

    MySelect {
        rx1,
        rx2,
    }.await;
}
```

يحتوي الـ future `MySelect` على الـ futures من كل فرع. عندما يتم فحص `MySelect` ، يتم فحص الفرع الأول. إذا كان جاهزًا (ready)، يتم استخدام القيمة ويكتمل `MySelect`. بعد أن يتلقى `.await` المخرجات من future، يتم إسقاط الـ future. يؤدي هذا إلى إسقاط الـ futures لكلا الفرعين. نظرًا لأن أحد الفروع لم يكتمل، يتم إلغاء العملية فعليًا.

تذكر من القسم السابق:

> عندما يرجع الـ future القيمة `Poll::Pending` ، يجب أن يضمن إرسال إشارة إلى الـ waker في مرحلة ما في المستقبل. نسيان القيام بذلك يؤدي إلى تعليق المهمة إلى أجل غير مسمى.

لا يوجد استخدام صريح لوسيط `Context` في تنفيذ `MySelect`. بدلاً من ذلك، يتم تلبية متطلبات الـ waker عن طريق تمرير `cx` إلى الـ futures الداخلية. نظرًا لأن الـ future الداخلي يجب أن يلبي أيضًا متطلبات الـ waker، فمن خلال إرجاع `Poll::Pending` فقط عند تلقي `Poll::Pending` من future داخلي، يلبي `MySelect` أيضًا متطلبات الـ waker.

# الصيغة (Syntax)

يمكن لماكرو `select!` التعامل مع أكثر من فرعين. الحد الحالي هو 64 فرعًا. يتم تنظيم كل فرع كالتالي:

```text
<pattern> = <async expression> => <handler>,
```

عند تقييم ماكرو `select` ، يتم تجميع جميع الـ `<async expression>` وتنفيذها بشكل متزامن. عندما يكتمل تعبير، تتم مطابقة النتيجة مع الـ `<pattern>`. إذا تطابقت النتيجة مع النمط، يتم إسقاط جميع التعبيرات غير المتزامنة المتبقية ويتم تنفيذ الـ `<handler>`. يمكن لتعبير الـ `<handler>` الوصول إلى أي روابط تم إنشاؤها بواسطة الـ `<pattern>`.

الحالة الأساسية لـ `<pattern>` هي اسم متغير، حيث يتم ربط نتيجة التعبير غير المتزامن باسم المتغير ويكون للـ `<handler>` وصول إلى ذلك المتغير. لهذا السبب، في المثال الأصلي، تم استخدام `val` للـ `<pattern>` وكان الـ `<handler>` قادرًا على الوصول إلى `val`.

إذا كان الـ `<pattern>` **لا يطابق** نتيجة الحساب غير المتزامن، فإن التعبيرات غير المتزامنة المتبقية تستمر في التنفيذ بشكل متزامن حتى يكتمل التعبير التالي. في هذا الوقت، يتم تطبيق نفس المنطق على تلك النتيجة.

نظرًا لأن `select!` يأخذ أي تعبير غير متزامن، فمن الممكن تحديد حسابات أكثر تعقيدًا للاختيار منها.

هنا، نختار بين مخرجات قناة `oneshot` واتصال TCP.

```rust
use tokio::net::TcpStream;
use tokio::sync::oneshot;

#[tokio::main]
async fn main() {
    let (tx, rx) = oneshot::channel();

    // إنشاء مهمة ترسل رسالة عبر oneshot
    tokio::spawn(async move {
        tx.send("done").unwrap();
    });

    tokio::select! {
        socket = TcpStream::connect("localhost:3465") => {
            println!("Socket متصل {:?}", socket);
        }
        msg = rx => {
            println!("تلقيت رسالة أولاً {:?}", msg);
        }
    }
}
```

هنا، نختار بين oneshot وقبول المقابس من `TcpListener`.

```rust
use tokio::net::TcpListener;
use tokio::sync::oneshot;
use std::io;

#[tokio::main]
async fn main() -> io::Result<()> {
    let (tx, rx) = oneshot::channel();

    tokio::spawn(async move {
        tx.send(()).unwrap();
    });

    let mut listener = TcpListener::bind("localhost:3465").await?;

    tokio::select! {
        _ = async {
            loop {
                let (socket, _) = listener.accept().await?;
                tokio::spawn(async move { process(socket) });
            }

            // مساعدة مستنتج النوع في rust
            Ok::<_, io::Error>(())
        } => {}
        _ = rx => {
            println!("إنهاء حلقة القبول");
        }
    }

    Ok(())
}
# async fn process(_: tokio::net::TcpStream) {}
```

تستمر حلقة القبول حتى يتم مواجهة خطأ أو تتلقى `rx` قيمة. يشير النمط `_` إلى أننا ليس لدينا اهتمام بالقيمة المرجعة للحساب غير المتزامن.

# القيمة المرجعة (Return value)

يرجع ماكرو `tokio::select!` نتيجة تعبير الـ `<handler>` الذي تم تقييمه.

```rust
async fn computation1() -> String {
    // .. حساب
# unimplemented!();
}

async fn computation2() -> String {
    // .. حساب
# unimplemented!();
}

# fn dox() {
#[tokio::main]
async fn main() {
    let out = tokio::select! {
        res1 = computation1() => res1,
        res2 = computation2() => res2,
    };

    println!("النتيجة = {}", out);
}
# }
```

بسبب هذا، من الضروري أن يتم تقييم تعبير الـ `<handler>` لكل فرع إلى نفس النوع. إذا لم تكن مخرجات تعبير `select!` مطلوبة، فمن الممارسات الجيدة أن يتم تقييم التعبير إلى `()`.

# الأخطاء (Errors)

يؤدي استخدام المشغل `?` إلى نشر الخطأ من التعبير. تعتمد كيفية عمل ذلك على ما إذا كان `?` مستخدمًا من تعبير غير متزامن أو من معالج (handler). يؤدي استخدام `?` في تعبير غير متزامن إلى نشر الخطأ خارج التعبير غير المتزامن. وهذا يجعل مخرجات التعبير غير المتزامن `Result`. يؤدي استخدام `?` من معالج إلى نشر الخطأ على الفور خارج تعبير `select!`. دعونا ننظر في مثال حلقة القبول مرة أخرى:

```rust
use tokio::net::TcpListener;
use tokio::sync::oneshot;
use std::io;

#[tokio::main]
async fn main() -> io::Result<()> {
    // [إعداد قناة `rx` oneshot]
# let (tx, rx) = oneshot::channel();
# tx.send(()).unwrap();

    let listener = TcpListener::bind("localhost:3465").await?;

    tokio::select! {
        res = async {
            loop {
                let (socket, _) = listener.accept().await?;
                tokio::spawn(async move { process(socket) });
            }

            // مساعدة مستنتج النوع في rust
            Ok::<_, io::Error>(())
        } => {
            res?;
        }
        _ = rx => {
            println!("إنهاء حلقة القبول");
        }
    }

    Ok(())
}
# async fn process(_: tokio::net::TcpStream) {}
```

لاحظ `listener.accept().await?`. يقوم المشغل `?` بنشر الخطأ خارج ذلك التعبير وإلى رابط `res`. عند حدوث خطأ، سيتم تعيين `res` إلى `Err(_)`. ثم، في المعالج، يتم استخدام المشغل `?` مرة أخرى. ستقوم عبارة `res?` بنشر خطأ خارج وظيفة `main`.

# مطابقة الأنماط (Pattern matching)

تذكر أن صيغة فرع ماكرو `select!` تم تعريفها كالتالي:

```text
<pattern> = <async expression> => <handler>,
```

حتى الآن، استخدمنا فقط روابط المتغيرات لـ `<pattern>`. ومع ذلك، يمكن استخدام أي نمط Rust. على سبيل المثال، لنفترض أننا نتلقى من قنوات MPSC متعددة، فقد نفعل شيئًا كهذا:

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    let (mut tx1, mut rx1) = mpsc::channel(128);
    let (mut tx2, mut rx2) = mpsc::channel(128);

    tokio::spawn(async move {
        // افعل شيئًا بـ `tx1` و `tx2`
# tx1.send(1).await.unwrap();
# tx2.send(2).await.unwrap();
    });

    tokio::select! {
        Some(v) = rx1.recv() => {
            println!("تلقيت {:?} من rx1", v);
        }
        Some(v) = rx2.recv() => {
            println!("تلقيت {:?} من rx2", v);
        }
        else => {
            println!("كلتا القناتين مغلقتان");
        }
    }
}
```

في هذا المثال، ينتظر تعبير `select!` تلقي قيمة من `rx1` و `rx2`. إذا أغلقت قناة، يرجع `recv()` القيمة `None`. هذا **لا يطابق** النمط ويتم تعطيل الفرع. سيستمر تعبير `select!` في الانتظار على الفروع المتبقية.

لاحظ أن تعبير `select!` هذا يتضمن فرع `else`. يجب أن يتم تقييم تعبير `select!` إلى قيمة. عند استخدام مطابقة الأنماط، من الممكن ألا يطابق **أي** من الفروع أنماطها المرتبطة. إذا حدث هذا، يتم تقييم فرع `else`.

# الاستعارة (Borrowing)

عند إنشاء المهام (spawning tasks)، يجب أن يمتلك التعبير غير المتزامن المنشأ جميع بياناته. ماكرو `select!` ليس لديه هذا القيد. قد يستعير التعبير غير المتزامن لكل فرع البيانات ويعمل بشكل متزامن. باتباع قواعد الاستعارة في Rust، قد تستعير تعبيرات غير متزامنة متعددة قطعة واحدة من البيانات بشكل غير قابل للتغيير (immutably) **أو** قد يستعير تعبير غير متزامن واحد قطعة من البيانات بشكل قابل للتغيير (mutably).

دعونا نلقي نظرة على بعض الأمثلة. هنا، نرسل نفس البيانات في وقت واحد إلى وجهتي TCP مختلفتين.

```rust
use tokio::io::AsyncWriteExt;
use tokio::net::TcpStream;
use std::io;
use std::net::SocketAddr;

async fn race(
    data: &[u8],
    addr1: SocketAddr,
    addr2: SocketAddr
) -> io::Result<()> {
    tokio::select! {
        Ok(_) = async {
            let mut socket = TcpStream::connect(addr1).await?;
            socket.write_all(data).await?;
            Ok::<_, io::Error>(())
        } => {}
        Ok(_) = async {
            let mut socket = TcpStream::connect(addr2).await?;
            socket.write_all(data).await?;
            Ok::<_, io::Error>(())
        } => {}
        else => {}
    };

    Ok(())
}
# fn main() {}
```

يتم استعارة متغير `data` **بشكل غير قابل للتغيير** من كلا التعبيرين غير المتزامنين. عندما تكتمل إحدى العمليات بنجاح، يتم إسقاط الأخرى. نظرًا لأننا نطابق النمط على `Ok(_)` ، إذا فشل أحد التعبيرات، يستمر الآخر في التنفيذ.

عندما يتعلق الأمر بـ `<handler>` لكل فرع، يضمن `select!` تشغيل `<handler>` واحد فقط. وبسبب هذا، قد يستعير كل `<handler>` نفس البيانات بشكل قابل للتغيير.

على سبيل المثال، هذا يعدل `out` في كلا المعالجين:

```rust
use tokio::sync::oneshot;

#[tokio::main]
async fn main() {
    let (tx1, rx1) = oneshot::channel();
    let (tx2, rx2) = oneshot::channel();

    let mut out = String::new();

    tokio::spawn(async move {
        // إرسال القيم على `tx1` و `tx2`.
# let _ = tx1.send("one");
# let _ = tx2.send("two");
    });

    tokio::select! {
        _ = rx1 => {
            out.push_str("rx1 اكتملت");
        }
        _ = rx2 => {
            out.push_str("rx2 اكتملت");
        }
    }

    println!("{}", out);
}
```

# الحلقات (Loops)

غالبًا ما يُستخدم ماكرو `select!` في الحلقات. سيستعرض هذا القسم بعض الأمثلة لإظهار الطرق الشائعة لاستخدام ماكرو `select!` في حلقة. نبدأ بالاختيار عبر قنوات متعددة:

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    let (tx1, mut rx1) = mpsc::channel(128);
    let (tx2, mut rx2) = mpsc::channel(128);
    let (tx3, mut rx3) = mpsc::channel(128);

    loop {
        let msg = tokio::select! {
            Some(msg) = rx1.recv() => msg,
            Some(msg) = rx2.recv() => msg,
            Some(msg) = rx3.recv() => msg,
            else => { break }
        };

        println!("تلقيت {:?}", msg);
    }

    println!("تم إغلاق جميع القنوات.");
}
```

يختار هذا المثال عبر مستقبلات القنوات الثلاث. عند تلقي رسالة على أي قناة، يتم كتابتها إلى STDOUT. عند إغلاق قناة، يرجع `recv()` القيمة `None`. باستخدام مطابقة الأنماط، يستمر ماكرو `select!` في الانتظار على القنوات المتبقية. عند إغلاق جميع القنوات، يتم تقييم فرع `else` ويتم إنهاء الحلقة.

يختار ماكرو `select!` الفروع عشوائيًا للتحقق من الجاهزية أولاً. عندما يكون لقنوات متعددة قيم معلقة، سيتم اختيار قناة عشوائية للاستلام منها. هذا للتعامل مع الحالة التي تعالج فيها حلقة الاستلام الرسائل بشكل أبطأ مما يتم دفعها في القنوات، مما يعني أن القنوات تبدأ في الامتلاء. إذا كان `select!` **لا** يختار فرعًا عشوائيًا للتحقق منه أولاً، فسيتم التحقق من `rx1` أولاً في كل تكرار للحلقة. إذا كان `rx1` يحتوي دائمًا على رسالة جديدة، فلن يتم التحقق من القنوات المتبقية أبدًا.

> **معلومات**
> إذا كان لقنوات متعددة رسائل معلقة عند تقييم `select!` ، يتم سحب قيمة واحدة فقط من قناة واحدة. تظل جميع القنوات الأخرى دون تغيير، وتبقى رسائلها في تلك القنوات حتى التكرار التالي للحلقة. لا تضيع أي رسائل.

## استئناف عملية غير متزامنة (Resuming an async operation)

الآن سنوضح كيفية تشغيل عملية غير متزامنة عبر استدعاءات متعددة لـ `select!`. في هذا المثال، لدينا قناة MPSC بنوع عنصر `i32` ، ووظيفة غير متزامنة. نريد تشغيل الوظيفة غير المتزامنة حتى تكتمل أو يتم تلقي عدد صحيح زوجي على القناة.

```rust
async fn action() {
    // بعض المنطق غير المتزامن
}

#[tokio::main]
async fn main() {
    let (mut tx, mut rx) = tokio::sync::mpsc::channel(128);    
    
    let operation = action();
    tokio::pin!(operation);
    
    loop {
        tokio::select! {
            _ = &mut operation => break,
            Some(v) = rx.recv() => {
                if v % 2 == 0 {
                    break;
                }
            }
        }
    }
}
```

لاحظ كيف أنه بدلاً من استدعاء `action()` في ماكرو `select!` ، يتم استدعاؤه **خارج** الحلقة. يتم تعيين نتيجة `action()` إلى `operation` **بدون** استدعاء `.await`. ثم نستدعي `tokio::pin!` على `operation`.

داخل حلقة `select!` ، بدلاً من تمرير `operation` ، نمرر `&mut operation`. يقوم متغير `operation` بتتبع العملية غير المتزامنة الجارية. يستخدم كل تكرار للحلقة نفس العملية بدلاً من إصدار استدعاء جديد لـ `action()`.

يستقبل فرع `select!` الآخر رسالة من القناة. إذا كان الرقم زوجيًا، نكون قد انتهينا من الحلقة. وإلا، نبدأ `select!` مرة أخرى.

هذه هي المرة الأولى التي نستخدم فيها `tokio::pin!`. لن ندخل في تفاصيل التثبيت (pinning) بعد. الشيء الذي يجب ملاحظته هو أنه لعمل `.await` لمرجع، يجب أن تكون القيمة المشار إليها مثبتة (pinned) أو تنفذ `Unpin`.

إذا قمنا بإزالة سطر `tokio::pin!` وحاولنا التجميع، فسنحصل على خطأ يشير إلى أن الـ future ربما يحتاج إلى التثبيت.

## تعديل فرع (Modifying a branch)

دعونا ننظر في حلقة أكثر تعقيدًا قليلاً. لدينا:

1. قناة من قيم `i32`.
2. عملية غير متزامنة لإجرائها على قيم `i32`.

المنطق الذي نريد تنفيذه هو:

1. الانتظار لعدد **زوجي** على القناة.
2. بدء العملية غير المتزامنة باستخدام الرقم الزوجي كمدخل.
3. انتظار العملية، ولكن في نفس الوقت الاستماع لمزيد من الأرقام الزوجية على القناة.
4. إذا تم تلقي رقم زوجي جديد قبل اكتمال العملية الحالية، قم بإلغاء العملية الحالية وابدأها من جديد بالرقم الزوجي الجديد.

```rust
async fn action(input: Option<i32>) -> Option<String> {
    let i = match input {
        Some(input) => input,
        None => return None,
    };
    // المنطق غير المتزامن هنا
#   Some(i.to_string())
}

#[tokio::main]
async fn main() {
    let (mut tx, mut rx) = tokio::sync::mpsc::channel(128);
    
    let mut done = false;
    let operation = action(None);
    tokio::pin!(operation);
    
    loop {
        tokio::select! {
            res = &mut operation, if !done => {
                done = true;
                if let Some(v) = res {
                    println!("GOT = {}", v);
                }
            }
            Some(v) = rx.recv() => {
                if v % 2 == 0 {
                    // ابدأ العملية من جديد
                    operation.set(action(Some(v)));
                    done = false;
                }
            }
        }
    }
}
```

نستخدم `operation.set` لتغيير الـ future الجاري مع الاحتفاظ به مثبتًا (pinned). يوضح هذا المثال أيضًا استخدام حارس (guard) في `select!` مثل `if !done`. بمجرد اكتمال العملية وتعيين `done = true` ، يتم تعطيل هذا الفرع حتى يتم استلام رقم زوجي جديد.

[pin]: https://doc.rust-lang.org/std/pin/index.html
