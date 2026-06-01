---
title: "الحالة المشتركة (Shared state)"
---

حتى الآن، لدينا خادم مفتاح-قيمة (key-value server) يعمل. ومع ذلك، هناك خلل كبير: الحالة (state) لا تتم مشاركتها عبر الاتصالات. سنقوم بإصلاح ذلك في هذا المقال.

# الاستراتيجيات

هناك طريقتان مختلفتان لمشاركة الحالة في Tokio.

1. حماية الحالة المشتركة باستخدام `Mutex`.
2. إنشاء مهمة (spawn a task) لإدارة الحالة واستخدام تمرير الرسائل (message passing) للعمل عليها.

بشكل عام، ستحتاج إلى استخدام النهج الأول للبيانات البسيطة، والنهج الثاني للأشياء التي تتطلب عملاً غير متزامن مثل أدوات I/O الأساسية. في هذا الفصل، الحالة المشتركة هي `HashMap` والعمليات هي `insert` و `get`. لا توجد أي من هذه العمليات غير متزامنة، لذا سنستخدم `Mutex`.

يتم تغطية النهج الأخير في الفصل القادم.

# إضافة تبعية `bytes`

بدلاً من استخدام `Vec<u8>` ، تستخدم حزمة (crate) Mini-Redis النوع `Bytes` من حزمة [`bytes`]. الهدف من `Bytes` هو توفير هيكل مصفوفة بايت قوي لبرمجة الشبكات. الميزة الأكبر التي يضيفها على `Vec<u8>` هي النسخ الضحل (shallow cloning). بمعنى آخر، استدعاء `clone()` على مثيل `Bytes` لا ينسخ البيانات الأساسية. بدلاً من ذلك، مثيل `Bytes` هو مقبض (handle) معدود المراجع لبعض البيانات الأساسية. نوع `Bytes` هو تقريبًا `Arc<Vec<u8>>` ولكن مع بعض القدرات المضافة.

للاعتماد على `bytes` ، أضف ما يلي إلى ملف `Cargo.toml` في قسم `[dependencies]`:

```toml
bytes = "1"
```

[`bytes`]: https://docs.rs/bytes/1/bytes/struct.Bytes.html

# تهيئة الـ `HashMap`

سيتم مشاركة الـ `HashMap` عبر العديد من المهام وربما العديد من الخيوط (threads). لدعم ذلك، يتم تغليفه في `Arc<Mutex<_>>`.

أولاً، من أجل الراحة، أضف الاسم المستعار للنوع (type alias) التالي بعد عبارات `use`.

```rust
use bytes::Bytes;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

type Db = Arc<Mutex<HashMap<String, Bytes>>>;
```

بعد ذلك، قم بتحديث وظيفة `main` لتهيئة الـ `HashMap` وتمرير **مقبض** (handle) `Arc` إلى وظيفة `process`. يسمح استخدام `Arc` بالإشارة إلى الـ `HashMap` بشكل متزامن من العديد من المهام، التي قد تعمل على العديد من الخيوط. في جميع أنحاء Tokio، يُستخدم مصطلح **مقبض** (handle) للإشارة إلى قيمة توفر الوصول إلى حالة مشتركة معينة.

```rust
use tokio::net::TcpListener;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

# fn dox() {
#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:6379").await.unwrap();

    println!("Listening");

    let db = Arc::new(Mutex::new(HashMap::new()));

    loop {
        let (socket, _) = listener.accept().await.unwrap();
        // نسخ مقبض خريطة التجزئة (hash map).
        let db = db.clone();

        println!("Accepted");
        tokio::spawn(async move {
            process(socket, db).await;
        });
    }
}
# }
# type Db = Arc<Mutex<HashMap<(), ()>>>;
# async fn process(_: tokio::net::TcpStream, _: Db) {}
```

## حول استخدام `std::sync::Mutex` و `tokio::sync::Mutex`

لاحظ أنه يتم استخدام `std::sync::Mutex` وليس `tokio::sync::Mutex` لحماية الـ `HashMap`. الخطأ الشائع هو استخدام `tokio::sync::Mutex` بشكل غير مشروط من داخل الكود غير المتزامن. الـ mutex غير المتزامن هو mutex يتم قفله عبر الاستدعاءات لـ `.await`.

سيقوم الـ mutex المتزامن بحظر الخيط الحالي عند انتظار الحصول على القفل. وهذا بدوره سيمنع المهام الأخرى من المعالجة. سيؤدي التبديل إلى `tokio::sync::Mutex` إلى جعل المهمة تتخلى عن التحكم للمنفذ (executor)، ولكن هذا عادة لن يساعد في الأداء لأن الـ mutex غير المتزامن يستخدم mutex متزامن داخليًا.

كقاعدة عامة، يعد استخدام mutex متزامن من داخل كود غير متزامن أمرًا جيدًا طالما ظل التنافس (contention) منخفضًا ولا يتم الاحتفاظ بالقفل عبر الاستدعاءات لـ `.await`.

# تحديث `process()`

لم تعد وظيفة المعالجة تهيئ `HashMap`. بدلاً من ذلك، فإنها تأخذ المقبض المشترك للـ `HashMap` كوسيط (argument). تحتاج أيضًا إلى قفل الـ `HashMap` قبل استخدامه. تذكر أن نوع القيمة للـ `HashMap` هو الآن `Bytes` (والذي يمكننا نسخه بثمن بخس)، لذا يجب تغيير هذا أيضًا.

```rust
use tokio::net::TcpStream;
use mini_redis::{Connection, Frame};
# use std::collections::HashMap;
# use std::sync::{Arc, Mutex};
# type Db = Arc<Mutex<HashMap<String, bytes::Bytes>>>;

async fn process(socket: TcpStream, db: Db) {
    use mini_redis::Command::{self, Get, Set};

    // Connection، المقدمة من `mini-redis` ، تتعامل مع تحليل الإطارات من المقبس
    let mut connection = Connection::new(socket);

    while let Some(frame) = connection.read_frame().await.unwrap() {
        let response = match Command::from_frame(frame).unwrap() {
            Set(cmd) => {
                let mut db = db.lock().unwrap();
                db.insert(cmd.key().to_string(), cmd.value().clone());
                Frame::Simple("OK".to_string())
            }           
            Get(cmd) => {
                let db = db.lock().unwrap();
                if let Some(value) = db.get(cmd.key()) {
                    Frame::Bulk(value.clone())
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

# الاحتفاظ بـ `MutexGuard` عبر `.await`

قد تكتب كودًا يبدو كالتالي:
```rust
use std::sync::{Mutex, MutexGuard};

async fn increment_and_do_stuff(mutex: &Mutex<i32>) {
    let mut lock: MutexGuard<i32> = mutex.lock().unwrap();
    *lock += 1;

    do_something_async().await;
} // يخرج القفل من النطاق هنا
# async fn do_something_async() {}
```
عندما تحاول إنشاء شيء يستدعي هذه الوظيفة، ستواجه رسالة الخطأ التالية التي تفيد بأن الـ future لا يمكن إرساله بين الخيوط بأمان.

يحدث هذا لأن نوع `std::sync::MutexGuard` **ليس** `Send`. هذا يعني أنه لا يمكنك إرسال قفل mutex إلى خيط آخر، ويحدث الخطأ لأن وقت تشغيل Tokio يمكنه نقل مهمة بين الخيوط عند كل `.await`. لتجنب ذلك، يجب عليك إعادة هيكلة الكود الخاص بك بحيث يتم تشغيل مدمر (destructor) قفل الـ mutex قبل `.await`.

```rust
# use std::sync::{Mutex, MutexGuard};
// هذا يعمل!
async fn increment_and_do_stuff(mutex: &Mutex<i32>) {
    {
        let mut lock: MutexGuard<i32> = mutex.lock().unwrap();
        *lock += 1;
    } // يخرج القفل من النطاق هنا

    do_something_async().await;
}
# async fn do_something_async() {}
```
لاحظ أن هذا لا يعمل:
```rust
use std::sync::{Mutex, MutexGuard};

// هذا يفشل أيضًا.
async fn increment_and_do_stuff(mutex: &Mutex<i32>) {
    let mut lock: MutexGuard<i32> = mutex.lock().unwrap();
    *lock += 1;
    drop(lock);

    do_something_async().await;
}
# async fn do_something_async() {}
```
هذا لأن المترجم (compiler) يحسب حاليًا ما إذا كان الـ future هو `Send` بناءً على معلومات النطاق (scope) فقط. نأمل أن يتم تحديث المترجم لدعم إسقاطه صراحةً في المستقبل، ولكن في الوقت الحالي، يجب عليك استخدام النطاق صراحةً.

يجب ألا تحاول التحايل على هذه المشكلة عن طريق إنشاء المهمة بطريقة لا تتطلب أن تكون `Send` ، لأنه إذا قام Tokio بتعليق مهمتك عند `.await` بينما تحتفظ المهمة بالقفل، فقد يتم جدولة مهمة أخرى للعمل على نفس الخيط، وقد تحاول هذه المهمة الأخرى أيضًا قفل ذلك الـ mutex، مما سيؤدي إلى طريق مسدود (deadlock).

ضع في اعتبارك أن بعض حزم الـ mutex تنفذ `Send` لـ MutexGuards الخاصة بها. في هذه الحالة، لا يوجد خطأ مترجم، حتى لو كنت تحتفظ بـ MutexGuard عبر `.await`. الكود يترجم، ولكنه يؤدي إلى طريق مسدود!

سنناقش بعض الأساليب لتجنب هذه المشكلات أدناه:

## إعادة هيكلة الكود الخاص بك لعدم الاحتفاظ بالقفل عبر `.await`

الطريقة الأكثر أمانًا للتعامل مع mutex هي تغليفه في هيكل (struct)، وقفل الـ mutex فقط داخل الأساليب غير المتزامنة (non-async methods) في ذلك الهيكل.

```rust
use std::sync::Mutex;

struct CanIncrement {
    mutex: Mutex<i32>,
}
impl CanIncrement {
    // لم يتم وضع علامة async على هذه الوظيفة.
    fn increment(&self) {
        let mut lock = self.mutex.lock().unwrap();
        *lock += 1;
    }
}

async fn increment_and_do_stuff(can_incr: &CanIncrement) {
    can_incr.increment();
    do_something_async().await;
}
# async fn do_something_async() {}
```
يضمن هذا النمط أنك لن تواجه خطأ `Send` ، لأن حارس الـ mutex لا يظهر في أي مكان في وظيفة غير متزامنة. كما يحميك أيضًا من الطرق المسدودة (deadlocks) عند استخدام الحزم التي تنفذ `MutexGuard` الخاص بها `Send`.

## إنشاء مهمة لإدارة الحالة واستخدام تمرير الرسائل للعمل عليها

هذا هو النهج الثاني المذكور في بداية هذا الفصل، وغالبًا ما يُستخدم عندما يكون المورد المشترك مورد I/O. راجع الفصل القادم لمزيد من التفاصيل.

## استخدام mutex Tokio غير المتزامن

يمكن أيضًا استخدام نوع [`tokio::sync::Mutex`] الذي توفره Tokio. الميزة الأساسية لـ mutex Tokio هي أنه يمكن الاحتفاظ به عبر `.await` دون أي مشاكل. ومع ذلك، فإن الـ mutex غير المتزامن أغلى من الـ mutex العادي، وعادة ما يكون من الأفضل استخدام أحد النهجين الآخرين.

```rust
use tokio::sync::Mutex; // ملاحظة! هذا يستخدم mutex Tokio

// هذا يترجم!
// (ولكن إعادة هيكلة الكود ستكون أفضل في هذه الحالة)
async fn increment_and_do_stuff(mutex: &Mutex<i32>) {
    let mut lock = mutex.lock().await;
    *lock += 1;

    do_something_async().await;
} // يخرج القفل من النطاق هنا
# async fn do_something_async() {}
```

[`tokio::sync::Mutex`]: https://docs.rs/tokio/1/tokio/sync/struct.Mutex.html

# المهام، الخيوط، والتنافس (Tasks, threads, and contention)

يعد استخدام mutex الحظر لحماية الأقسام الحرجة (critical sections) القصيرة استراتيجية مقبولة عندما يكون التنافس ضئيلاً. عندما يكون هناك تنافس على القفل، يجب أن يحظر الخيط الذي ينفذ المهمة وينتظر الـ mutex. لن يؤدي هذا فقط إلى حظر المهمة الحالية ولكن سيؤدي أيضًا إلى حظر جميع المهام الأخرى المجدولة على الخيط الحالي.

بشكل افتراضي، يستخدم وقت تشغيل Tokio مجدولاً متعدد الخيوط (multi-threaded scheduler). يتم جدولة المهام على أي عدد من الخيوط التي يديرها وقت التشغيل. إذا تم جدولة عدد كبير من المهام للتنفيذ وكانت جميعها تتطلب الوصول إلى الـ mutex، فسيكون هناك تنافس. من ناحية أخرى، إذا تم استخدام نكهة وقت التشغيل [`current_thread`] ، فلن يكون هناك تنافس أبدًا على الـ mutex.

> **معلومات**
> نكهة وقت التشغيل [`current_thread`][basic-rt] هي وقت تشغيل خفيف الوزن وأحادي الخيط. إنه خيار جيد عند إنشاء عدد قليل من المهام وفتح حفنة من المقابس.

إذا أصبح التنافس على mutex متزامن مشكلة، فنادراً ما يكون الحل الأفضل هو التبديل إلى mutex Tokio. بدلاً من ذلك، الخيارات التي يجب مراعاتها هي:

- السماح لمهمة مخصصة بإدارة الحالة واستخدام تمرير الرسائل.
- تقسيم الـ mutex (Sharding).
- إعادة هيكلة الكود لتجنب الـ mutex.

## تقسيم الـ Mutex (Mutex sharding)

في حالتنا، بما أن كل *مفتاح* مستقل، فإن تقسيم الـ mutex سيعمل بشكل جيد. للقيام بذلك، بدلاً من امتلاك مثيل `Mutex<HashMap<_, _>>` واحد، سنقدم `N` من المثيلات المتميزة.

```rust
# use std::collections::HashMap;
# use std::sync::{Arc, Mutex};
type ShardedDb = Arc<Vec<Mutex<HashMap<String, Vec<u8>>>>>;

fn new_sharded_db(num_shards: usize) -> ShardedDb {
    let mut db = Vec::with_capacity(num_shards);
    for _ in 0..num_shards {
        db.push(Mutex::new(HashMap::new()));
    }
    Arc::new(db)
}
```

بعد ذلك، يصبح العثور على الخلية لأي مفتاح معين عملية من خطوتين. أولاً، يتم استخدام المفتاح لتحديد الجزء (shard) الذي ينتمي إليه. ثم يتم البحث عن المفتاح في `HashMap`.

```rust,compile_fail
let shard = db[hash(key) % db.len()].lock().unwrap();
shard.insert(key, value);
```

يتطلب التنفيذ البسيط الموضح أعلاه استخدام عدد ثابت من الأجزاء، ولا يمكن تغيير عدد الأجزاء بمجرد إنشاء الخريطة المقسمة. توفر حزمة [dashmap] تنفيذاً لخريطة تجزئة مقسمة أكثر تطوراً.

[current_thread]: https://docs.rs/tokio/1/tokio/runtime/index.html#current-thread-scheduler
[dashmap]: https://docs.rs/dashmap
[shared-mutable-state-blog-post]: https://draft.ryhl.io/blog/shared-mutable-state/
