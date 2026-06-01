---
title: "الإغلاق السلس (Graceful Shutdown)"
---

الغرض من هذه الصفحة هو تقديم نظرة عامة على كيفية تنفيذ الإغلاق (shutdown) بشكل صحيح في التطبيقات غير المتزامنة.

عادة ما تكون هناك ثلاثة أجزاء لتنفيذ الإغلاق السلس:

 * تحديد متى يجب الإغلاق.
 * إخبار كل جزء من البرنامج بالإغلاق.
 * انتظار الأجزاء الأخرى من البرنامج حتى تنتهي من الإغلاق.

سيتناول بقية هذا المقال هذه الأجزاء. يمكن العثور على تنفيذ واقعي للنهج الموصوف هنا في [mini-redis] ، وتحديداً في ملفي [`src/server.rs`][server.rs] و [`src/shutdown.rs`][shutdown.rs].

## تحديد متى يجب الإغلاق

يعتمد هذا بالطبع على التطبيق، ولكن أحد معايير الإغلاق الشائعة جداً هو عندما يتلقى التطبيق إشارة (signal) من نظام التشغيل. يحدث هذا على سبيل المثال عند الضغط على ctrl+c في الطرفية أثناء تشغيل البرنامج. لاكتشاف ذلك، توفر Tokio وظيفة [`tokio::signal::ctrl_c`][ctrl_c] ، والتي ستنتظر حتى يتم تلقي مثل هذه الإشارة. يمكنك استخدامها كالتالي:

```rust
use tokio::signal;

#[tokio::main]
async fn main() {
    // ... إنشاء التطبيق كمهمة منفصلة ...

    match signal::ctrl_c().await {
        Ok(()) => {},
        Err(err) => {
            eprintln!("غير قادر على الاستماع لإشارة الإغلاق: {}", err);
            // نغلق أيضاً في حالة حدوث خطأ
        },
    }

    // إرسال إشارة الإغلاق للتطبيق والانتظار
}
```

إذا كان لديك عدة شروط للإغلاق، يمكنك استخدام [قناة mpsc][mpsc] لإرسال إشارة الإغلاق إلى مكان واحد. يمكنك بعد ذلك استخدام [select] على [`ctrl_c`][ctrl_c] والقناة.

## إخبار الأجزاء بالإغلاق

عندما تريد إخبار مهمة واحدة أو أكثر بالإغلاق، يمكنك استخدام [رموز الإلغاء (Cancellation Tokens)][cancellation-tokens]. تسمح لك هذه الرموز بإخطار المهام بضرورة إنهاء نفسها استجابة لطلب إلغاء، مما يسهل تنفيذ الإغلاق السلس.

لمشاركة `CancellationToken` بين عدة مهام، يجب عليك نسخه (clone). يرجع ذلك إلى قاعدة الملكية الفردية التي تتطلب أن يكون لكل قيمة مالك واحد. عند نسخ الرمز، تحصل على رمز آخر لا يمكن تمييزه عن الأصلي؛ إذا تم إلغاء أحدهما، فسيتم إلغاء الآخر أيضاً. يمكنك عمل أي عدد تريده من النسخ، وعندما تستدعي `cancel` على أحدها، يتم إلغاؤها جميعاً.

فيما يلي خطوات استخدام `CancellationToken` في مهام متعددة:

1. أولاً، أنشئ `CancellationToken` جديداً.
2. بعد ذلك، أنشئ نسخة من الـ `CancellationToken` الأصلي عن طريق استدعاء أسلوب `clone` على الرمز الأصلي. سيؤدي هذا إلى إنشاء رمز جديد يمكن استخدامه بواسطة مهمة أخرى.
3. مرر الرمز الأصلي أو المنسوخ إلى المهام التي يجب أن تستجيب لطلبات الإلغاء.
4. عندما تريد إغلاق المهام بسلاسة، استدعِ أسلوب `cancel` على الرمز الأصلي أو المنسوخ. سيتم إخطار أي مهمة تستمع لطلب الإلغاء على الرمز الأصلي أو المنسوخ بالإغلاق.

باستخدام رموز الإلغاء، ليس عليك إغلاق المهمة فوراً عند إلغاء الرمز. بدلاً من ذلك، يمكنك تشغيل إجراء إغلاق قبل إنهاء المهمة، مثل تفريغ البيانات (flushing) إلى ملف أو قاعدة بيانات، أو إرسال رسالة إغلاق عبر الاتصال.

## انتظار انتهاء الإغلاق

بمجرد إخبار المهام الأخرى بالإغلاق، ستحتاج إلى انتظارها حتى تنتهي. إحدى الطرق السهلة للقيام بذلك هي استخدام [متتبع المهام (task tracker)]. متتبع المهام هو مجموعة من المهام. يوفر لك أسلوب [`wait`] الخاص بمتتبع المهام future يتم حله فقط بعد حل جميع الـ futures الموجودة بداخله **و** إغلاق متتبع المهام.

يوضح المثال التالي إنشاء 10 مهام، ثم استخدام متتبع المهام لانتظار إغلاقها.

```rust
use std::time::Duration;
use tokio::time::sleep;
use tokio_util::task::TaskTracker;

#[tokio::main]
async fn main() {
    let tracker = TaskTracker::new();

    for i in 0..10 {
        tracker.spawn(some_operation(i));
    }

    // بمجرد إنشاء كل شيء، نغلق المتتبع.
    tracker.close();

    // ننتظر حتى ينتهي كل شيء.
    tracker.wait().await;

    println!("يتم طباعة هذا بعد انتهاء جميع المهام.");
}

async fn some_operation(i: u64) {
    sleep(Duration::from_millis(100 * i)).await;
    println!("المهمة {} تغلق.", i);
}
```

[ctrl_c]: https://docs.rs/tokio/1/tokio/signal/fn.ctrl_c.html
[task tracker]: https://docs.rs/tokio-util/latest/tokio_util/task/task_tracker
[`wait`]: https://docs.rs/tokio-util/latest/tokio_util/task/task_tracker/struct.TaskTracker.html#method.wait
[select]: https://docs.rs/tokio/1/tokio/macro.select.html
[cancellation-tokens]: https://docs.rs/tokio-util/latest/tokio_util/sync/struct.CancellationToken.html
[shutdown.rs]: https://github.com/tokio-rs/mini-redis/blob/master/src/shutdown.rs
[server.rs]: https://github.com/tokio-rs/mini-redis/blob/master/src/server.rs
[mini-redis]: https://github.com/tokio-rs/mini-redis/
[mpsc]: https://docs.rs/tokio/1/tokio/sync/mpsc/index.html
