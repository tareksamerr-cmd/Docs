---
title: "Async in depth (Async بتعمق)"
---

في هذه المرحلة، أكملنا جولة شاملة إلى حد ما في Rust غير المتزامن (asynchronous Rust) وTokio. الآن سنتعمق أكثر في نموذج وقت التشغيل غير المتزامن (asynchronous runtime model) الخاص بـ Rust. في بداية البرنامج التعليمي، ألمحنا إلى أن Rust غير المتزامن يتبع نهجًا فريدًا. الآن، سنشرح ما يعنيه ذلك.

# Futures (المستقبليات)

كمراجعة سريعة، دعنا نأخذ دالة غير متزامنة (asynchronous function) أساسية جدًا. هذا ليس شيئًا جديدًا مقارنة بما غطاه البرنامج التعليمي حتى الآن.

```rust
use tokio::net::TcpStream;

async fn my_async_fn() {
    println!("hello from async");
    let _socket = TcpStream::connect("127.0.0.1:3000").await.unwrap();
    println!("async TCP operation complete");
}
```

نستدعي الدالة (function) وتُرجع قيمة ما. نستدعي `.await` على تلك القيمة.

```rust
# async fn my_async_fn() {}
#[tokio::main]
async fn main() {
    let what_is_this = my_async_fn();
    // Nothing has been printed yet.
    what_is_this.await;
    // Text has been printed and socket has been
    // established and closed.
}
```

القيمة التي تُرجعها `my_async_fn()` هي future. الـ future هي قيمة تُطبق السمة [`std::future::Future`][trait] التي توفرها المكتبة القياسية (standard library). إنها قيم تحتوي على الحساب غير المتزامن (asynchronous computation) قيد التقدم.

تعريف السمة [`std::future::Future`][trait] هو:

```rust
use std::pin::Pin;
use std::task::{Context, Poll};

pub trait Future {
    type Output;

    fn poll(self: Pin<&mut Self>, cx: &mut Context)
        -> Poll<Self::Output>;
}
```

النوع المرتبط (associated type) `Output` هو النوع الذي ينتجه الـ future بمجرد اكتماله. نوع [`Pin`][pin] هو كيف يمكن لـ Rust دعم الاستعارات (borrows) في دوال `async`. راجع وثائق [المكتبة القياسية][pin] لمزيد من التفاصيل.

على عكس كيفية تنفيذ الـ futures في لغات أخرى، فإن Rust future لا يمثل عملية حسابية تحدث في الخلفية، بل إن Rust future **هو** العملية الحسابية نفسها. مالك الـ future مسؤول عن تقدم العملية الحسابية عن طريق استقصاء (polling) الـ future. يتم ذلك عن طريق استدعاء `Future::poll`.

## Implementing `Future` (تطبيق Future)

دعنا نطبق future بسيطًا جدًا. هذا الـ future سيقوم بما يلي:

1. الانتظار حتى لحظة زمنية محددة.
2. إخراج بعض النصوص إلى STDOUT.
3. إرجاع سلسلة (string).

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};
use std::time::{Duration, Instant};

struct Delay {
    when: Instant,
}

impl Future for Delay {
    type Output = &'static str;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>)
        -> Poll<&'static str>
    {
        if Instant::now() >= self.when {
            println!("Hello world");
            Poll::Ready("done")
        } else {
            // Ignore this line for now.
            cx.waker().wake_by_ref();
            Poll::Pending
        }
    }
}

#[tokio::main]
async fn main() {
    let when = Instant::now() + Duration::from_millis(10);
    let future = Delay { when };

    let out = future.await;
    assert_eq!(out, "done");
}
```

## Async fn as a Future (دالة Async كـ Future)

في الدالة main، نقوم بإنشاء الـ future واستدعاء `.await` عليها. من دوال async، يمكننا استدعاء `.await` على أي قيمة تُطبق `Future`. بدوره، استدعاء دالة `async` يُرجع نوعًا مجهولًا (anonymous type) يُطبق `Future`. في حالة `async fn main()`، فإن الـ future المُنشأ هو تقريبًا:

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};
use std::time::{Duration, Instant};

enum MainFuture {
    // Initialized, never polled
    State0,
    // Waiting on `Delay`, i.e. the `future.await` line.
    State1(Delay),
    // The future has completed.
    Terminated,
}
# struct Delay { when: Instant };
# impl Future for Delay {
#     type Output = &'static str;
#     fn poll(self: Pin<&mut Self>, _: &mut Context<'_>) -> Poll<&'static str> {
#         unimplemented!();
#     }
# }

impl Future for MainFuture {
    type Output = ();

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>)
        -> Poll<()>
    {
        use MainFuture::*;

        loop {
            match *self {
                State0 => {
                    let when = Instant::now() +
                        Duration::from_millis(10);
                    let future = Delay { when };
                    *self = State1(future);
                }
                State1(ref mut my_future) => {
                    match Pin::new(my_future).poll(cx) {
                        Poll::Ready(out) => {
                            assert_eq!(out, "done");
                            *self = Terminated;
                            return Poll::Ready(());
                        }
                        Poll::Pending => {
                            return Poll::Pending;
                        }
                    }
                }
                Terminated => {
                    panic!("future polled after completion")
                }
            }
        }
    }
}
```

Rust futures هي **آلات حالات (state machines)**. هنا، يتم تمثيل `MainFuture` كـ `enum` للحالات المحتملة للـ future. يبدأ الـ future في حالة `State0`. عندما يتم استدعاء `poll`، يحاول الـ future التقدم في حالته الداخلية قدر الإمكان. إذا كان الـ future قادرًا على الاكتمال، يتم إرجاع `Poll::Ready` الذي يحتوي على ناتج الحساب غير المتزامن.

إذا كان الـ future **غير** قادر على الاكتمال، وعادة ما يكون ذلك بسبب عدم جاهزية الموارد التي ينتظرها، يتم إرجاع `Poll::Pending`. يشير استلام `Poll::Pending` إلى المتصل (caller) بأن الـ future سيكتمل في وقت لاحق ويجب على المتصل استدعاء `poll` مرة أخرى لاحقًا.

نرى أيضًا أن الـ futures تتكون من futures أخرى. يؤدي استدعاء `poll` على الـ future الخارجي إلى استدعاء دالة `poll` للـ future الداخلي.

# Executors (المنفذون)

تُرجع دوال Rust غير المتزامنة futures. يجب استدعاء `poll` على الـ futures لتقدم حالتها. تتكون الـ futures من futures أخرى. لذا، السؤال هو، ما الذي يستدعي `poll` على الـ future الخارجي الأبعد؟

تذكر من قبل، لتشغيل الدوال غير المتزامنة، يجب إما تمريرها إلى `tokio::spawn` أو أن تكون الدالة الرئيسية مشروحة بـ `#[tokio::main]`. يؤدي هذا إلى إرسال الـ future الخارجي المُنشأ إلى Tokio executor. الـ executor مسؤول عن استدعاء `Future::poll` على الـ future الخارجي، مما يدفع الحساب غير المتزامن إلى الاكتمال.

## Mini Tokio (توكيو المصغر)

لفهم أفضل لكيفية عمل كل هذا معًا، دعنا نطبق نسختنا المصغرة من Tokio! يمكن العثور على الكود الكامل [هنا][mini-tokio].

```rust
use std::collections::VecDeque;
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};
use std::time::{Duration, Instant};
use futures::task;

fn main() {
    let mut mini_tokio = MiniTokio::new();

    mini_tokio.spawn(async {
        let when = Instant::now() + Duration::from_millis(10);
        let future = Delay { when };

        let out = future.await;
        assert_eq!(out, "done");
    });

    mini_tokio.run();
}
# struct Delay { when: Instant }
# impl Future for Delay {
#     type Output = &'static str;
#     fn poll(self: Pin<&mut Self>, _: &mut Context<'_>) -> Poll<&'static str> {
#         Poll::Ready("done")
#     }
# }

struct MiniTokio {
    tasks: VecDeque<Task>,
}

type Task = Pin<Box<dyn Future<Output = ()> + Send>>;

impl MiniTokio {
    fn new() -> MiniTokio {
        MiniTokio {
            tasks: VecDeque::new(),
        }
    }

    /// Spawn a future onto the mini-tokio instance.
    fn spawn<F>(&mut self, future: F)
    where
        F: Future<Output = ()> + Send + 'static,
    {
        self.tasks.push_back(Box::pin(future));
    }

    fn run(&mut self) {
        let waker = task::noop_waker();
        let mut cx = Context::from_waker(&waker);

        while let Some(mut task) = self.tasks.pop_front() {
            if task.as_mut().poll(&mut cx).is_pending() {
                self.tasks.push_back(task);
            }
        }
    }
}
```

هذا يشغل كتلة async. يتم إنشاء مثيل `Delay` مع التأخير المطلوب ويتم انتظاره. ومع ذلك، فإن تطبيقنا حتى الآن به **عيب** كبير. الـ executor الخاص بنا لا يذهب أبدًا إلى النوم. يقوم الـ executor بحلقة مستمرة على **جميع** الـ futures التي تم إنشاؤها ويستقصيها. في معظم الأحيان، لن تكون الـ futures جاهزة لأداء المزيد من العمل وستُرجع `Poll::Pending` مرة أخرى. ستستهلك العملية دورات وحدة المعالجة المركزية (CPU cycles) ولن تكون فعالة جدًا بشكل عام.

من الناحية المثالية، نريد أن يقوم mini-tokio باستقصاء الـ futures فقط عندما يكون الـ future قادرًا على إحراز تقدم. يحدث هذا عندما يصبح المورد الذي تعتمد عليه المهمة جاهزًا لأداء العملية المطلوبة. إذا كانت المهمة تريد قراءة البيانات من مقبس TCP (TCP socket)، فإننا نريد فقط استقصاء المهمة عندما يكون مقبس TCP قد استقبل البيانات. في حالتنا، المهمة معلقة على الوصول إلى `Instant` المحدد. من الناحية المثالية، سيقوم mini-tokio باستقصاء المهمة فقط بمجرد مرور تلك اللحظة الزمنية.

لتحقيق ذلك، عندما يتم استقصاء مورد، ويكون المورد **غير** جاهز، سيرسل المورد إشعارًا بمجرد انتقاله إلى حالة جاهزة.

# Wakers (الموقظون)

Wakers هي القطعة المفقودة. هذا هو النظام الذي يمكن للمورد من خلاله إخطار المهمة المنتظرة بأن المورد أصبح جاهزًا لمتابعة عملية ما.

دعنا نلقي نظرة على تعريف `Future::poll` مرة أخرى:

```rust,compile_fail
fn poll(self: Pin<&mut Self>, cx: &mut Context)
    -> Poll<Self::Output>;
```

الوسيط `Context` لـ `poll` لديه طريقة `waker()`. تُرجع هذه الطريقة [`Waker`] المرتبط بالمهمة الحالية. الـ [`Waker`] لديه طريقة `wake()`. استدعاء هذه الطريقة يشير إلى الـ executor بأن المهمة المرتبطة يجب جدولتها للتنفيذ. تستدعي الموارد `wake()` عندما تنتقل إلى حالة جاهزة لإخطار الـ executor بأن استقصاء المهمة سيكون قادرًا على إحراز تقدم.

## Updating `Delay` (تحديث Delay)

يمكننا تحديث `Delay` لاستخدام wakers:

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};
use std::time::{Duration, Instant};
use std::thread;

struct Delay {
    when: Instant,
}

impl Future for Delay {
    type Output = &'static str;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>)
        -> Poll<&'static str>
    {
        if Instant::now() >= self.when {
            println!("Hello world");
            Poll::Ready("done")
        } else {
            // Get a handle to the waker for the current task
            let waker = cx.waker().clone();
            let when = self.when;

            // Spawn a timer thread.
            thread::spawn(move || {
                let now = Instant::now();

                if now < when {
                    thread::sleep(when - now);
                }

                waker.wake();
            });

            Poll::Pending
        }
    }
}
```

الآن، بمجرد انقضاء المدة المطلوبة، يتم إخطار المهمة المتصلة ويمكن للـ executor التأكد من إعادة جدولة المهمة. الخطوة التالية هي تحديث mini-tokio للاستماع لإشعارات wake.

لا تزال هناك بعض المشكلات المتبقية في تطبيق `Delay` الخاص بنا. سنقوم بإصلاحها لاحقًا.

> **warning** (تحذير)
> عندما يُرجع future `Poll::Pending`، يجب عليه **التأكد** من إرسال إشارة إلى الـ waker في مرحلة ما. نسيان القيام بذلك يؤدي إلى تعليق المهمة إلى أجل غير مسمى.
>
> نسيان إيقاظ مهمة بعد إرجاع `Poll::Pending` هو مصدر شائع للأخطاء (bugs).

تذكر التكرار الأول لـ `Delay`. كان هذا هو تطبيق الـ future:

```rust
# use std::future::Future;
# use std::pin::Pin;
# use std::task::{Context, Poll};
# use std::time::Instant;
# struct Delay { when: Instant }
impl Future for Delay {
    type Output = &'static str;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>)
        -> Poll<&'static str>
    {
        if Instant::now() >= self.when {
            println!("Hello world");
            Poll::Ready("done")
        } else {
            // Ignore this line for now.
            cx.waker().wake_by_ref();
            Poll::Pending
        }
    }
}
```

قبل إرجاع `Poll::Pending`، استدعينا `cx.waker().wake_by_ref()`. هذا لتلبية عقد الـ future. بإرجاع `Poll::Pending`، نحن مسؤولون عن إرسال إشارة إلى الـ waker. نظرًا لأننا لم نطبق مؤشر الترابط الزمني (timer thread) بعد، فقد أرسلنا إشارة إلى الـ waker بشكل مباشر. سيؤدي القيام بذلك إلى إعادة جدولة الـ future على الفور، وتنفيذه مرة أخرى، وربما لن يكون جاهزًا للاكتمال.

لاحظ أنه يُسمح لك بإرسال إشارة إلى الـ waker أكثر من اللازم. في هذه الحالة بالذات، نرسل إشارة إلى الـ waker على الرغم من أننا لسنا مستعدين لمتابعة العملية على الإطلاق. لا يوجد خطأ في هذا بخلاف بعض دورات وحدة المعالجة المركزية المهدرة. ومع ذلك، سيؤدي هذا التطبيق بالذات إلى حلقة مشغولة (busy loop).

## Updating Mini Tokio (تحديث Mini Tokio)

الخطوة التالية هي تحديث Mini Tokio لاستقبال إشعارات waker. نريد أن يقوم الـ executor بتشغيل المهام فقط عندما يتم إيقاظها، وللقيام بذلك، سيوفر Mini Tokio الـ waker الخاص به. عندما يتم استدعاء الـ waker، يتم وضع المهمة المرتبطة في قائمة الانتظار ليتم تنفيذها. يمرر Mini-Tokio هذا الـ waker إلى الـ future عندما يستقصي الـ future.

سيستخدم Mini Tokio المحدث قناة (channel) لتخزين المهام المجدولة. تسمح القنوات بوضع المهام في قائمة الانتظار للتنفيذ من أي مؤشر ترابط (thread). يجب أن تكون Wakers `Send` و`Sync`.

> **info** (معلومات)
> سمات `Send` و`Sync` هي سمات علامة (marker traits) تتعلق بالتزامن (concurrency) توفرها Rust. الأنواع التي يمكن **إرسالها** إلى مؤشر ترابط مختلف هي `Send`. معظم الأنواع هي `Send`، ولكن شيئًا مثل [`Rc`] ليس كذلك. الأنواع التي يمكن الوصول إليها **بشكل متزامن** من خلال مراجع غير قابلة للتغيير (immutable references) هي `Sync`. يمكن أن يكون النوع `Send` ولكنه ليس `Sync` - مثال جيد هو [`Cell`]، والذي يمكن تعديله من خلال مرجع غير قابل للتغيير، وبالتالي فهو غير آمن للوصول إليه بشكل متزامن.
>
> لمزيد من التفاصيل، راجع [الفصل ذي الصلة في كتاب Rust][ch].

[`Rc`]: https://doc.rust-lang.org/std/rc/struct.Rc.html
[`Cell`]: https://doc.rust-lang.org/std/cell/struct.Cell.html
[ch]: https://doc.rust-lang.org/book/ch16-04-extensible-concurrency-sync-and-send.html

قم بتحديث بنية `MiniTokio`.

```rust
use std::sync::mpsc;
use std::sync::Arc;

struct MiniTokio {
    scheduled: mpsc::Receiver<Arc<Task>>,
    sender: mpsc::Sender<Arc<Task>>,
}

struct Task {
    // This will be filled in soon.
}
```

Wakers هي `Sync` ويمكن استنساخها (cloned). عندما يتم استدعاء `wake`، يجب جدولة المهمة للتنفيذ. لتطبيق هذا، لدينا قناة. عندما يتم استدعاء `wake()` على الـ waker، يتم دفع المهمة إلى النصف المرسل من القناة. ستقوم بنية `Task` الخاصة بنا بتطبيق منطق wake. للقيام بذلك، تحتاج إلى احتواء كل من الـ future الذي تم إنشاؤه ونصف إرسال القناة.

```toml
futures = "0.3"
```

ثم طبق [`futures::task::ArcWake`][`ArcWake`].

```rust
use futures::task::{self, ArcWake};
use std::sync::Arc;
# struct Task {}
# impl Task {
#     fn schedule(self: &Arc<Self>) {}
# }
impl ArcWake for Task {
    fn wake_by_ref(arc_self: &Arc<Self>) {
        arc_self.schedule();
    }
}
```

عندما يستدعي مؤشر الترابط الزمني أعلاه `waker.wake()`، يتم دفع المهمة إلى القناة. بعد ذلك، نقوم بتطبيق استلام وتنفيذ المهام في دالة `MiniTokio::run()`.

```rust
# use std::sync::mpsc;
# use futures::task::{self, ArcWake};
# use std::future::Future;
# use std::pin::Pin;
# use std::sync::{Arc, Mutex};
# use std::task::{Context, Poll};
# struct MiniTokio {
#   scheduled: mpsc::Receiver<Arc<Task>>,
#   sender: mpsc::Sender<Arc<Task>>,
# }
# struct TaskFuture {
#     future: Pin<Box<dyn Future<Output = ()> + Send>>,
#     poll: Poll<()>,
# }
# struct Task {
#   task_future: Mutex<TaskFuture>,
#   executor: mpsc::Sender<Arc<Task>>,
# }
# impl ArcWake for Task {
#   fn wake_by_ref(arc_self: &Arc<Self>) {}
# }
impl MiniTokio {
    fn run(&self) {
        while let Ok(task) = self.scheduled.recv() {
            task.poll();
        }
    }

    /// Initialize a new mini-tokio instance.
    fn new() -> MiniTokio {
        let (sender, scheduled) = mpsc::channel();

        MiniTokio { scheduled, sender }
    }

    /// Spawn a future onto the mini-tokio instance.
    ///
    /// The given future is wrapped with the `Task` harness and pushed into the
    /// `scheduled` queue. The future will be executed when `run` is called.
    fn spawn<F>(&self, future: F)
    where
        F: Future<Output = ()> + Send + 'static,
    {
        Task::spawn(future, &self.sender);
    }
}

impl TaskFuture {
    fn new(future: impl Future<Output = ()> + Send + 'static) -> TaskFuture {
        TaskFuture {
            future: Box::pin(future),
            poll: Poll::Pending,
        }
    }

    fn poll(&mut self, cx: &mut Context<'_>) {
        // Spurious wake-ups are allowed, even after a future has                                  
        // returned `Ready`. However, polling a future which has                                   
        // already returned `Ready` is *not* allowed. For this                                     
        // reason we need to check that the future is still pending                                
        // before we call it. Failure to do so can lead to a panic.
        if self.poll.is_pending() {
            self.poll = self.future.as_mut().poll(cx);
        }
    }
}

impl Task {
    fn poll(self: Arc<Self>) {
        // Create a waker from the `Task` instance. This
        // uses the `ArcWake` impl from above.
        let waker = task::waker(self.clone());
        let mut cx = Context::from_waker(&waker);

        // No other thread ever tries to lock the task_future
        let mut task_future = self.task_future.try_lock().unwrap();

        // Poll the inner future
        task_future.poll(&mut cx);
    }

    // Spawns a new task with the given future.
    //
    // Initializes a new Task harness containing the given future and pushes it
    // onto `sender`. The receiver half of the channel will get the task and
    // execute it.
    fn spawn<F>(future: F, sender: &mpsc::Sender<Arc<Task>>)
    where
        F: Future<Output = ()> + Send + 'static,
    {
        let task = Arc::new(Task {
            task_future: Mutex::new(TaskFuture::new(future)),
            executor: sender.clone(),
        });

        let _ = sender.send(task);
    }
}
```

تحدث عدة أشياء هنا. أولاً، تم تطبيق `MiniTokio::run()`. تعمل الدالة في حلقة تستقبل المهام المجدولة من القناة. نظرًا لأن المهام تُدفع إلى القناة عند إيقاظها، فإن هذه المهام تكون قادرة على إحراز تقدم عند تنفيذها.

بالإضافة إلى ذلك، تم تعديل دالتي `MiniTokio::new()` و`MiniTokio::spawn()` لاستخدام قناة بدلاً من `VecDeque`. عندما يتم إنشاء مهام جديدة، يتم إعطاؤها نسخة من الجزء المرسل من القناة، والذي يمكن للمهمة استخدامه لجدولة نفسها على وقت التشغيل (runtime).

تُنشئ دالة `Task::poll()` الـ waker باستخدام أداة [`ArcWake`] من crate `futures`. يُستخدم الـ waker لإنشاء `task::Context`. يتم تمرير `task::Context` هذا إلى `poll`.

# Summary (ملخص)

لقد رأينا الآن مثالًا شاملاً لكيفية عمل Rust غير المتزامن. تعتمد ميزة `async/await` في Rust على السمات (traits). يسمح هذا لـ crates الخارجية، مثل Tokio، بتوفير تفاصيل التنفيذ.

* عمليات Rust غير المتزامنة هي كسولة (lazy) وتتطلب من المتصل استقصاءها.
* يتم تمرير Wakers إلى futures لربط future بالمهمة التي تستدعيها.
* عندما يكون المورد **غير** جاهز لإكمال عملية ما، يتم إرجاع `Poll::Pending` ويتم تسجيل waker المهمة.
* عندما يصبح المورد جاهزًا، يتم إخطار waker المهمة.
* يستقبل الـ executor الإشعار ويجدول المهمة للتنفيذ.
* يتم استقصاء المهمة مرة أخرى، وهذه المرة يكون المورد جاهزًا وتُحرز المهمة تقدمًا.

# A few loose ends (بعض الأمور المعلقة)

تذكر عندما كنا نطبق `Delay` future، قلنا أن هناك بعض الأشياء الأخرى التي يجب إصلاحها. يسمح نموذج Rust غير المتزامن لـ future واحد بالانتقال عبر المهام أثناء تنفيذه. ضع في اعتبارك ما يلي:

```rust
use futures::future::poll_fn;
use std::future::Future;
use std::pin::Pin;
# use std::task::{Context, Poll};
# use std::time::{Duration, Instant};
# struct Delay { when: Instant }
# impl Future for Delay {
#   type Output = ();
#   fn poll(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<()> {
#       Poll::Pending
#   }
# }

#[tokio::main]
async fn main() {
    let when = Instant::now() + Duration::from_millis(10);
    let mut delay = Some(Delay { when });

    poll_fn(move |cx| {
        let mut delay = delay.take().unwrap();
        let res = Pin::new(&mut delay).poll(cx);
        assert!(res.is_pending());
        tokio::spawn(async move {
            delay.await;
        });

        Poll::Ready(())
    }).await;
}
```

تُنشئ دالة `poll_fn` مثيل `Future` باستخدام إغلاق (closure). تُنشئ القصاصة أعلاه مثيل `Delay`، وتستقصيه مرة واحدة، ثم تُرسل مثيل `Delay` إلى مهمة جديدة حيث يتم انتظاره. في هذا المثال، يتم استدعاء `Delay::poll` أكثر من مرة مع مثيلات `Waker` **مختلفة**. عندما يحدث هذا، يجب عليك التأكد من استدعاء `wake` على الـ `Waker` الذي تم تمريره إلى _أحدث_ استدعاء لـ `poll`.

عند تطبيق future، من الأهمية بمكان افتراض أن كل استدعاء لـ `poll` **يمكن** أن يوفر مثيل `Waker` مختلفًا. يجب أن تقوم دالة poll بتحديث أي waker مسجل مسبقًا بالـ waker الجديد.

تطبيقنا السابق لـ `Delay` أنشأ مؤشر ترابط جديد في كل مرة يتم استقصاؤه. هذا جيد، ولكنه قد يكون غير فعال للغاية إذا تم استقصاؤه كثيرًا (على سبيل المثال، إذا قمت بـ `select!` على هذا الـ future وبعض الـ future الآخر، يتم استقصاء كلاهما عندما يكون لأي منهما حدث). أحد الأساليب لذلك هو تذكر ما إذا كنت قد أنشأت مؤشر ترابط بالفعل، وإنشاء مؤشر ترابط جديد فقط إذا لم تكن قد أنشأت واحدًا بالفعل. ومع ذلك، إذا قمت بذلك، يجب عليك التأكد من تحديث `Waker` الخاص بمؤشر الترابط في الاستدعاءات اللاحقة لـ poll، وإلا فإنك لا توقظ أحدث `Waker`.

لإصلاح تطبيقنا السابق، يمكننا القيام بشيء كهذا:

```rust
use std::future::Future;
use std::pin::Pin;
use std::sync::{Arc, Mutex};
use std::task::{Context, Poll, Waker};
use std::thread;
use std::time::{Duration, Instant};

struct Delay {
    when: Instant,
    // This is Some when we have spawned a thread, and None otherwise.
    waker: Option<Arc<Mutex<Waker>>>,
}

impl Future for Delay {
    type Output = ();

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        // Check the current instant. If the duration has elapsed, then
        // this future has completed so we return `Poll::Ready`.
        if Instant::now() >= self.when {
            return Poll::Ready(());
        }

        // The duration has not elapsed. If this is the first time the future
        // is called, spawn the timer thread. If the timer thread is already
        // running, ensure the stored `Waker` matches the current task's waker.
        if let Some(waker) = &self.waker {
            let mut waker = waker.lock().unwrap();

            // Check if the stored waker matches the current task's waker.
            // This is necessary as the `Delay` future instance may move to
            // a different task between calls to `poll`. If this happens, the
            // waker contained by the given `Context` will differ and we
            // must update our stored waker to reflect this change.
            if !waker.will_wake(cx.waker()) {
                *waker = cx.waker().clone();
            }
        } else {
            let when = self.when;
            let waker = Arc::new(Mutex::new(cx.waker().clone()));
            self.waker = Some(waker.clone());

            // This is the first time `poll` is called, spawn the timer thread.
            thread::spawn(move || {
                let now = Instant::now();

                if now < when {
                    thread::sleep(when - now);
                }

                // The duration has elapsed. Notify the caller by invoking
                // the waker.
                let waker = waker.lock().unwrap();
                waker.wake_by_ref();
            });
        }

        // By now, the waker is stored and the timer thread is started.
        // The duration has not elapsed (recall that we checked for this
        // first thing), ergo the future has not completed so we must
        // return `Poll::Pending`.
        //
        // The `Future` trait contract requires that when `Pending` is
        // returned, the future ensures that the given waker is signalled
        // once the future should be polled again. In our case, by
        // returning `Pending` here, we are promising that we will
        // invoke the given waker included in the `Context` argument
        // once the requested duration has elapsed. We ensure this by
        // spawning the timer thread above.
        //
        // If we forget to invoke the waker, the task will hang
        // indefinitely.
        Poll::Pending
    }
}
```

الأمر معقد بعض الشيء، لكن الفكرة هي، في كل استدعاء لـ `poll`، يتحقق الـ future مما إذا كان الـ waker المقدم يطابق الـ waker المسجل مسبقًا. إذا تطابق الـ wakers، فلا يوجد شيء آخر للقيام به. إذا لم يتطابقا، فيجب تحديث الـ waker المسجل.

## `Notify` utility (أداة Notify)

لقد أوضحنا كيف يمكن تطبيق `Delay` future يدويًا باستخدام wakers. Wakers هي أساس كيفية عمل Rust غير المتزامن. عادة، ليس من الضروري النزول إلى هذا المستوى. على سبيل المثال، في حالة `Delay`، يمكننا تطبيقها بالكامل باستخدام `async/await` باستخدام أداة [`tokio::sync::Notify`][notify]. توفر هذه الأداة آلية إخطار أساسية للمهام. إنها تتعامل مع تفاصيل wakers، بما في ذلك التأكد من أن الـ waker المسجل يطابق مهمة (task) الحالية.

باستخدام [`Notify`][notify]، يمكننا تطبيق دالة `delay` باستخدام `async/await` على النحو التالي:

```rust
use tokio::sync::Notify;
use std::sync::Arc;
use std::time::{Duration, Instant};
use std::thread;

async fn delay(dur: Duration) {
    let when = Instant::now() + dur;
    let notify = Arc::new(Notify::new());
    let notify_clone = notify.clone();

    thread::spawn(move || {
        let now = Instant::now();

        if now < when {
            thread::sleep(when - now);
        }

        notify_clone.notify_one();
    });


    notify.notified().await;
}
```

[assoc]: https://doc.rust-lang.org/book/ch19-03-advanced-traits.html#specifying-placeholder-types-in-trait-definitions-with-associated-types
[trait]: https://doc.rust-lang.org/std/future/trait.Future.html
[pin]: https://doc.rust-lang.org/std/pin/index.html
[`Waker`]: https://doc.rust-lang.org/std/task/struct.Waker.html
[mini-tokio]: https://github.com/tokio-rs/website/blob/master/tutorial-code/mini-tokio/src/main.rs
[vtable]: https://doc.rust-lang.org/std/task/struct.RawWakerVTable.html
[`ArcWake`]: https://docs.rs/futures/0.3/futures/task/trait.ArcWake.html
[`futures`]: https://docs.rs/futures/
[notify]: https://docs.rs/tokio/1/tokio/sync/struct.Notify.html
