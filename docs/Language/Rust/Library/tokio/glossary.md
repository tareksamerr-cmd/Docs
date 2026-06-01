---
title: Glossary (مسرد المصطلحات)
---

## Asynchronous (غير متزامن)

في سياق Rust، يشير الكود غير المتزامن إلى الكود الذي يستخدم ميزة اللغة async/await، والتي تسمح للعديد من المهام (tasks) بالعمل بشكل متزامن (concurrently) على عدد قليل من مؤشرات الترابط (threads) (أو حتى مؤشر ترابط واحد).

## Concurrency and parallelism (التزامن والتوازي)

التزامن (Concurrency) والتوازي (parallelism) هما مفهومان مرتبطان يُستخدمان عند الحديث عن أداء مهام متعددة في نفس الوقت. إذا حدث شيء ما بالتوازي، فإنه يحدث أيضًا بشكل متزامن، ولكن العكس ليس صحيحًا: التبديل بين مهمتين، ولكن عدم العمل عليهما في نفس الوقت هو تزامن ولكنه ليس توازيًا.

## Future (المستقبل)

الـ future هي قيمة تخزن الحالة الحالية لعملية ما. يحتوي الـ future أيضًا على طريقة `poll`، التي تجعل العملية تستمر حتى تحتاج إلى انتظار شيء ما، مثل اتصال شبكة. يجب أن تُرجع استدعاءات طريقة `poll` بسرعة كبيرة.

غالبًا ما يتم إنشاء الـ futures عن طريق دمج العديد من الـ futures باستخدام `.await` في كتلة async.

## Executor/scheduler (المنفذ/المجدول)

الـ executor أو scheduler هو شيء يقوم بتنفيذ الـ futures عن طريق استدعاء طريقة `poll` بشكل متكرر. لا يوجد executor في المكتبة القياسية (standard library)، لذلك تحتاج إلى مكتبة خارجية لذلك، ويتم توفير الـ executor الأكثر استخدامًا بواسطة Tokio runtime.

يمكن للـ executor تشغيل عدد كبير من الـ futures بشكل متزامن على عدد قليل من مؤشرات الترابط. يقوم بذلك عن طريق تبديل المهمة قيد التشغيل حاليًا عند الـ awaits. إذا قضى الكود وقتًا طويلاً دون الوصول إلى `.await`، يُطلق على ذلك "blocking the thread" (حظر مؤشر الترابط) أو "not yielding back to the executor" (عدم العودة إلى الـ executor)، مما يمنع المهام الأخرى من العمل.

## Runtime (وقت التشغيل)

الـ runtime هي مكتبة تحتوي على executor جنبًا إلى جنب مع أدوات مساعدة مختلفة تتكامل مع هذا الـ executor، مثل أدوات التوقيت والإدخال/الإخراج (IO). تُستخدم كلمتا runtime وexecutor أحيانًا بالتبادل. لا تحتوي المكتبة القياسية على runtime، لذلك تحتاج إلى مكتبة خارجية لذلك، ويعد Tokio runtime هو الأكثر استخدامًا.

تُستخدم كلمة Runtime أيضًا في سياقات أخرى، على سبيل المثال، تُستخدم عبارة "Rust has no runtime" أحيانًا لتعني أن Rust لا يقوم بجمع البيانات المهملة (garbage collection) أو التجميع في الوقت المناسب (just-in-time compilation).

## Task (المهمة)

الـ task هي عملية تعمل على Tokio runtime، تم إنشاؤها بواسطة دالة [`tokio::spawn`] أو [`Runtime::block_on`]. لا تُنشئ أدوات إنشاء الـ futures عن طريق دمجها مثل `.await` و[`join!`] مهامًا جديدة، ويُقال إن كل جزء مدمج "في نفس المهمة".

تُعد المهام المتعددة ضرورية للتوازي، ولكن من الممكن القيام بالعديد من الأشياء بشكل متزامن في مهمة واحدة باستخدام أدوات مثل `join!`.

[`Runtime::block_on`]: https://docs.rs/tokio/1/tokio/runtime/struct.Runtime.html#method.block_on
[`join!`]: https://docs.rs/tokio/1/tokio/macro.join.html

## Spawning (الإنشاء/التفريخ)

الـ Spawning هو عندما تُستخدم دالة [`tokio::spawn`] لإنشاء مهمة جديدة. يمكن أن يشير أيضًا إلى إنشاء مؤشر ترابط جديد باستخدام [`std::thread::spawn`].

[`tokio::spawn`]: https://docs.rs/tokio/1/tokio/fn.spawn.html
[`std::thread::spawn`]: https://doc.rust-lang.org/stable/std/thread/fn.spawn.html

## Async block (كتلة async)

الـ async block هي طريقة سهلة لإنشاء future يُشغل بعض الكود. على سبيل المثال:

```rust
let world = async {
    println!(" world!");
};
let my_future = async {
    print!("Hello ");
    world.await;
};
```

ينشئ الكود أعلاه future يسمى `my_future`، والذي إذا تم تنفيذه يطبع `Hello world!`. يقوم بذلك عن طريق طباعة hello أولاً، ثم تشغيل الـ `world` future. لاحظ أن الكود أعلاه لا يطبع أي شيء بمفرده — يجب عليك بالفعل تنفيذ `my_future` قبل حدوث أي شيء، إما عن طريق إنشائه مباشرة، أو عن طريق `.await`ing له في شيء تقوم بإنشائه.

## Async function (دالة async)

على غرار async block، فإن دالة async هي طريقة سهلة لإنشاء دالة يصبح جسمها future. يمكن إعادة كتابة جميع دوال async إلى دوال عادية تُرجع future:

```rust
async fn do_stuff(i: i32) -> String {
    // do stuff
    format!("The integer is {}.", i)
}
```

```rust
use std::future::Future;

// the async function above is the same as this:
fn do_stuff(i: i32) -> impl Future<Output = String> {
    async move {
        // do stuff
        format!("The integer is {}.", i)
    }
}
```

يستخدم هذا [صيغة `impl Trait`][book10-02] لإرجاع future، نظرًا لأن [`Future`] هي سمة (trait). لاحظ أنه نظرًا لأن الـ future الذي تم إنشاؤه بواسطة async block لا يفعل أي شيء حتى يتم تنفيذه، فإن استدعاء دالة async لا يفعل أي شيء حتى يتم تنفيذ الـ future الذي تُرجعه [(تجاهله يؤدي إلى تحذير)][unused-warning].

[book10-02]: https://doc.rust-lang.org/book/ch10-02-traits.html#returning-types-that-implement-traits
[`Future`]: https://doc.rust-lang.org/stable/std/future/trait.Future.html
[unused-warning]: https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=4faf44e08b4a3bb1269a7985460f1923

## Yielding (التنازل/الفسح)

في سياق Rust غير المتزامن، الـ yielding هو ما يسمح للـ executor بتنفيذ العديد من الـ futures على مؤشر ترابط واحد. في كل مرة يتنازل فيها future، يمكن للـ executor تبديل هذا الـ future بـ future آخر، وعن طريق تبديل المهمة الحالية بشكل متكرر، يمكن للـ executor تنفيذ عدد كبير من المهام بشكل متزامن. يمكن للـ future التنازل فقط عند `.await`، لذلك فإن الـ futures التي تقضي وقتًا طويلاً بين `.await`s يمكن أن تمنع المهام الأخرى من العمل.

لتحديد ذلك، يتنازل الـ future كلما عاد من طريقة [`poll`].

[`poll`]: https://doc.rust-lang.org/stable/std/future/trait.Future.html#method.poll

## Blocking (الحظر)

تُستخدم كلمة "blocking" بطريقتين مختلفتين: المعنى الأول لـ "blocking" هو ببساطة الانتظار حتى ينتهي شيء ما، والمعنى الآخر لـ blocking هو عندما يقضي future وقتًا طويلاً دون التنازل. لتجنب الغموض، يمكنك استخدام عبارة "blocking the thread" (حظر مؤشر الترابط) للمعنى الثاني.

ستستخدم وثائق Tokio دائمًا المعنى الثاني لـ "blocking".

لتشغيل كود blocking داخل Tokio، يرجى مراجعة قسم [CPU-bound tasks and blocking code][api-blocking] من مرجع Tokio API.

[api-blocking]: https://docs.rs/tokio/1/tokio/#cpu-bound-tasks-and-blocking-code

## Stream (التدفق)

الـ [`Stream`] هو نسخة غير متزامنة من [`Iterator`]، ويوفر تدفقًا من القيم. يُستخدم عادةً مع حلقة `while let` على النحو التالي:

```rust
use tokio_stream::StreamExt; // for next()

# async fn dox() {
# let mut stream = tokio_stream::empty::<()>();
while let Some(item) = stream.next().await {
    // do something
}
# }
```

تُستخدم كلمة stream بشكل مربك أحيانًا للإشارة إلى سمات [`AsyncRead`] و[`AsyncWrite`].

يتم توفير أدوات تدفق Tokio حاليًا بواسطة crate [`tokio-stream`]. بمجرد استقرار سمة `Stream` في std، سيتم نقل أدوات التدفق إلى crate `tokio`.

[`Stream`]: https://docs.rs/tokio-stream/0.1/tokio/trait.Stream.html
[`tokio-stream`]: https://docs.rs/tokio-stream
[`Iterator`]: https://doc.rust-lang.org/stable/std/iter/trait.Iterator.html
[`AsyncRead`]: https://docs.rs/tokio/1/tokio/io/trait.AsyncRead.html
[`AsyncWrite`]: https://docs.rs/tokio/1/tokio/io/trait.AsyncWrite.html

## Channel (القناة)

الـ channel هي أداة تسمح لجزء واحد من الكود بإرسال رسائل إلى أجزاء أخرى. يوفر Tokio [عددًا من القنوات][channels]، كل منها يخدم غرضًا مختلفًا.

- [mpsc]: قناة متعددة المنتجين، مستهلك واحد (multi-producer, single-consumer channel). يمكن إرسال العديد من القيم.
- [oneshot]: قناة منتج واحد، مستهلك واحد (single-producer, single-consumer channel). يمكن إرسال قيمة واحدة.
- [broadcast]: متعدد المنتجين، متعدد المستهلكين (multi-producer, multi-consumer). يمكن إرسال العديد من القيم. يرى كل مستقبل كل قيمة.
- [watch]: منتج واحد، متعدد المستهلكين (single-producer, multi-consumer). يمكن إرسال العديد من القيم، ولكن لا يتم الاحتفاظ بسجل. يرى المستلمون أحدث قيمة فقط.

إذا كنت بحاجة إلى قناة متعددة المنتجين متعددة المستهلكين حيث يرى مستهلك واحد فقط كل رسالة، يمكنك استخدام crate [`async-channel`].

توجد أيضًا قنوات للاستخدام خارج Rust غير المتزامن، مثل [`std::sync::mpsc`] و[`crossbeam::channel`]. تنتظر هذه القنوات الرسائل عن طريق حظر مؤشر الترابط، وهو أمر غير مسموح به في الكود غير المتزامن.

[channels]: https://docs.rs/tokio/1/tokio/sync/index.html
[mpsc]: https://docs.rs/tokio/1/tokio/sync/mpsc/index.html
[oneshot]: https://docs.rs/tokio/1/tokio/sync/oneshot/index.html
[broadcast]: https://docs.rs/tokio/1/tokio/sync/broadcast/index.html
[watch]: https://docs.rs/tokio/1/tokio/sync/watch/index.html
[`async-channel`]: https://docs.rs/async-channel/
[`std::sync::mpsc`]: https://doc.rust-lang.org/stable/std/sync/mpsc/index.html
[`crossbeam::channel`]: https://docs.rs/crossbeam/latest/crossbeam/channel/index.html

## Backpressure (الضغط العكسي)

الـ Backpressure هو نمط لتصميم التطبيقات التي تستجيب جيدًا للحمل العالي. على سبيل المثال، تأتي قناة `mpsc` في شكلين: محدود وغير محدود. باستخدام القناة المحدودة، يمكن للمستقبل ممارسة "backpressure" على المرسل إذا لم يتمكن المستقبل من مواكبة عدد الرسائل، مما يتجنب نمو استخدام الذاكرة بلا حدود مع إرسال المزيد والمزيد من الرسائل على القناة.

## Actor (الممثل)

نمط تصميم لتصميم التطبيقات. يشير الـ actor إلى مهمة تم إنشاؤها بشكل مستقل تدير موردًا نيابة عن أجزاء أخرى من التطبيق، باستخدام القنوات للتواصل مع تلك الأجزاء الأخرى من التطبيق.

راجع [فصل القنوات][the channels chapter] للحصول على مثال على actor.

[the channels chapter]: /tokio/tutorial/channels
