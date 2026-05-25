# شرح شامل لمكتبة Redis في Rust


---

## نظرة عامة

**redis-rs** هي مكتبة Rust للتواصل مع خوادم Redis، تدعم الاتصال المتزامن وغير المتزامن، والعنقود (Cluster)، والحارس (Sentinel)، وPub/Sub، والتيارات (Streams)، والتخزين المؤقت من جانب العميل (Client-side Caching)، ومجموعات المتجهات (Vector Sets)، وWebSocket، وTLS، وMicrosoft Entra ID للمصادقة.

---

## 1. الهياكل (Structs)

### 1.1 الهياكل الجذرية (Core)

| الهيكل | الشرح |
|--------|-------|
| `AsyncConnectionConfig` | تكوين الاتصال غير المتزامن (مثل حجم المخزن المؤقت، إعدادات إعادة المحاولة) |
| `AsyncIter` | مُكرر غير متزامن لنتائج أوامر Redis (مثل SCAN) |
| `Client` | عميل Redis الرئيسي — نقطة البداية لإنشاء الاتصالات |
| `ClientCertificateCredentialOptions` | خيارات مصادقة بشهادة العميل (لـ Entra ID) |
| `ClientSecretCredentialOptions` | خيارات مصادقة بسر العميل (لـ Entra ID) |
| `ClientTlsConfig` | تكوين TLS من جانب العميل (شهادات، مفاتيح) |
| `Cmd` | يمثل أمر Redis واحد قابل للبناء والتنفيذ |
| `CommandCacheConfig` | تكوين التخزين المؤقت للأوامر |
| `Connection` | اتصال متزامن بخادم Redis |
| `ConnectionInfo` | معلومات الاتصال (عنوان، قاعدة بيانات، كلمة مرور) |
| `CopyOptions` | خيارات أمر COPY (استبدال، قاعدة بيانات الوجهة) |
| `DeveloperToolsCredentialOptions` | خيارات مصادقة أدوات المطور (لـ Entra ID) |
| `FlushAllOptions` | خيارات أمر FLUSHALL (متزامن أو غير متزامن) |
| `HashFieldExpirationOptions` | خيارات انتهاء صلاحية حقول Hash |
| `InfoDict` | قاموس يُحلل ناتج أمر INFO إلى أزواج مفتاح-قيمة |
| `Iter` | مُكرر متزامن لنتائج أوامر Redis |
| `LposOptions` | خيارات أمر LPOS (البحث عن موضع عنصر في قائمة) |
| `MSetOptions` | خيارات أمر MSET المتعدد |
| `ManagedIdentityCredentialOptions` | خيارات مصادقة الهوية المُدارة (Azure) |
| `Msg` | رسالة مُستلمة من قناة Pub/Sub |
| `Parser` | مُحلل بروتوكول RESP (Redis Serialization Protocol) |
| `ParsingError` | خطأ أثناء تحليل استجابة Redis |
| `Pipeline` | أنبوب أوامر — يجمع عدة أوامر لإرسالها دفعة واحدة |
| `PubSub` | اتصال Pub/Sub متزامن للاشتراك في القنوات |
| `PushInfo` | معلومات رسالة Push (في بروتوكول RESP3) |
| `RedisConnectionInfo` | معلومات اتصال Redis (اسم المستخدم، كلمة المرور، قاعدة البيانات) |
| `RedisError` | نوع الخطأ الرئيسي في المكتبة |
| `ReplicaInfo` | معلومات عن نسخة (replica) في العنقود |
| `ScanOptions` | خيارات أمر SCAN (نمط، عدد، نوع) |
| `Script` | سكريبت Lua مُحمل يمكن تنفيذه على الخادم |
| `ScriptInvocation` | استدعاء سكريبت Lua مع مفاتيح ومعاملات |
| `ServerError` | خطأ مُرجع من خادم Redis |
| `SetOptions` | خيارات أمر SET (انتهاء الصلاحية، شروط الوجود) |
| `SortedSetAddOptions` | خيارات أمر ZADD (شروط، تعديل السلوك) |
| `TlsCertificates` | شهادات TLS (شهادة CA، شهادة العميل، المفتاح) |

### 1.2 وحدة الاتصال غير المتزامن (`aio`)

| الهيكل | الشرح |
|--------|-------|
| `aio::ConnectionManager` | مدير اتصالات يُعيد الاتصال تلقائياً عند الانقطاع |
| `aio::ConnectionManagerConfig` | تكوين مدير الاتصالات (مهلة، عدد المحاولات) |
| `aio::Monitor` | اتصال مراقبة يعرض جميع الأوامر المُنفذة على الخادم |
| `aio::MultiplexedConnection` | اتصال مُتعدد الإرسال — يسمح بإرسال أوامر متعددة متزامنة على اتصال واحد |
| `aio::PubSub` | اتصال Pub/Sub غير متزامن |
| `aio::PubSubSink` | طرف الإرسال لاتصال Pub/Sub (اشتراك/إلغاء) |
| `aio::PubSubStream` | طرف الاستقبال لاتصال Pub/Sub (تيار الرسائل) |
| `aio::SendError` | خطأ عند فشل إرسال أمر عبر الاتصال |
| `aio::smol::SmolWrapped` | مُغلف لاستخدام بيئة تشغيل smol بدلاً من Tokio |

### 1.3 وحدة المصادقة (`auth`)

| الهيكل | الشرح |
|--------|-------|
| `auth::BasicAuth` | مصادقة أساسية (اسم مستخدم وكلمة مرور) |

### 1.4 وحدة إدارة المصادقة (`auth_management`)

| الهيكل | الشرح |
|--------|-------|
| `auth_management::RetryConfig` | تكوين إعادة المحاولة عند فشل تجديد الرمز |
| `auth_management::TokenRefreshConfig` | تكوين تجديد رمز المصادقة تلقائياً |

### 1.5 وحدة التخزين المؤقت (`caching`)

| الهيكل | الشرح |
|--------|-------|
| `caching::CacheConfig` | تكوين التخزين المؤقت من جانب العميل (حجم، مدة الصلاحية) |
| `caching::CacheStatistics` | إحصائيات التخزين المؤقت (عدد الإصابات، الإخفاقات) |

### 1.6 وحدة العنقود (`cluster`)

| الهيكل | الشرح |
|--------|-------|
| `cluster::ClusterClient` | عميل عنقود Redis — يتصل بعدة عقد ويوزع الأوامر |
| `cluster::ClusterClientBuilder` | بانٍ لتكوين عميل العنقود بخيارات مخصصة |
| `cluster::ClusterConfig` | تكوين العنقود (مهلات، سياسات إعادة المحاولة) |
| `cluster::ClusterConnection` | اتصال متزامن بعنقود Redis |
| `cluster::ClusterPipeline` | أنبوب أوامر للعنقود |
| `cluster::NodeAddress` | عنوان عقدة في العنقود (مضيف ومنفذ) |

### 1.7 وحدة العنقود غير المتزامن (`cluster_async`)

| الهيكل | الشرح |
|--------|-------|
| `cluster_async::ClusterConnection` | اتصال غير متزامن بعنقود Redis |

### 1.8 وحدة توجيه القراءة في العنقود (`cluster_read_routing`)

| الهيكل | الشرح |
|--------|-------|
| `cluster_read_routing::AnyNodeCandidates` | مرشحون من أي عقدة (رئيسية أو نسخة) |
| `cluster_read_routing::ClusterTopology` | طوبولوجيا العنقود (خريطة العقد والشرائح) |
| `cluster_read_routing::RandomReplicaStrategy` | استراتيجية اختيار نسخة عشوائية للقراءة |
| `cluster_read_routing::Replicas` | قائمة النسخ المتاحة |
| `cluster_read_routing::ReplicasOnlyCandidates` | مرشحون من النسخ فقط (لا العقد الرئيسية) |
| `cluster_read_routing::RoundRobinReplicaStrategy` | استراتيجية اختيار النسخ بالتناوب |
| `cluster_read_routing::Shard` | شريحة (shard) في العنقود تحتوي على نطاق فتحات (slots) |

### 1.9 وحدة توجيه العنقود (`cluster_routing`)

| الهيكل | الشرح |
|--------|-------|
| `cluster_routing::Route` | مسار توجيه يُحدد العقدة المستهدفة لأمر |
| `cluster_routing::Slot` | فتحة (slot) في العنقود مع عنوان العقدة المسؤولة |

### 1.10 وحدة Entra ID (`entra_id`)

| الهيكل | الشرح |
|--------|-------|
| `entra_id::ClientCertificate` | شهادة عميل لمصادقة Entra ID |
| `entra_id::EntraIdCredentialsProvider` | مزود بيانات اعتماد Microsoft Entra ID |

### 1.11 وحدة الإحداثيات الجغرافية (`geo`)

| الهيكل | الشرح |
|--------|-------|
| `geo::Coord` | إحداثيات جغرافية (خط طول وعرض) |
| `geo::RadiusOptions` | خيارات البحث بالنطاق الجغرافي (الترتيب، العدد، الإحداثيات) |
| `geo::RadiusSearchResult` | نتيجة بحث جغرافي (العضو، المسافة، الإحداثيات) |

### 1.12 وحدة إعدادات TCP (`io::tcp`)

| الهيكل | الشرح |
|--------|-------|
| `io::tcp::TcpSettings` | إعدادات اتصال TCP (keepalive، nodelay، مهلة) |

### 1.13 وحدة الحارس (`sentinel`)

| الهيكل | الشرح |
|--------|-------|
| `sentinel::LockedSentinelClient` | عميل حارس مُقفل (thread-safe) |
| `sentinel::Sentinel` | اتصال بنظام Redis Sentinel للاكتشاف التلقائي للرئيسي |
| `sentinel::SentinelClient` | عميل يتصل عبر Sentinel ويتبع الرئيسي تلقائياً |
| `sentinel::SentinelClientBuilder` | بانٍ لتكوين عميل Sentinel |
| `sentinel::SentinelNodeConnectionInfo` | معلومات اتصال عقدة Sentinel |

### 1.14 وحدة التيارات (`streams`)

| الهيكل | الشرح |
|--------|-------|
| `streams::StreamAddOptions` | خيارات أمر XADD (معرف، حد أقصى، idempotency) |
| `streams::StreamAutoClaimOptions` | خيارات أمر XAUTOCLAIM (استرداد الرسائل المعلقة تلقائياً) |
| `streams::StreamAutoClaimReply` | نتيجة XAUTOCLAIM |
| `streams::StreamClaimOptions` | خيارات أمر XCLAIM (استرداد رسائل معلقة) |
| `streams::StreamClaimReply` | نتيجة XCLAIM |
| `streams::StreamConfigOptions` | خيارات تكوين التيار |
| `streams::StreamId` | معرف رسالة في التيار (طابع زمني + تسلسل) |
| `streams::StreamInfoConsumer` | معلومات مستهلك في مجموعة |
| `streams::StreamInfoConsumersReply` | نتيجة XINFO CONSUMERS |
| `streams::StreamInfoGroup` | معلومات مجموعة مستهلكين |
| `streams::StreamInfoGroupsReply` | نتيجة XINFO GROUPS |
| `streams::StreamInfoStreamReply` | نتيجة XINFO STREAM |
| `streams::StreamInfoStreamReplyWithIdempotency` | نتيجة XINFO STREAM مع معلومات idempotency |
| `streams::StreamKey` | مفتاح تيار مع رسائله |
| `streams::StreamPendingCountReply` | نتيجة XPENDING مع عدد |
| `streams::StreamPendingData` | بيانات رسالة معلقة (معرف، مستهلك، وقت) |
| `streams::StreamPendingId` | معرف رسالة معلقة |
| `streams::StreamRangeReply` | نتيجة XRANGE/XREVRANGE |
| `streams::StreamReadOptions` | خيارات أمر XREAD/XREADGROUP |
| `streams::StreamReadReply` | نتيجة XREAD |
| `streams::StreamTrimOptions` | خيارات تقليم التيار |

### 1.15 وحدة مجموعات المتجهات (`vector_sets`)

| الهيكل | الشرح |
|--------|-------|
| `vector_sets::VAddOptions` | خيارات أمر VADD (إضافة متجه لمجموعة) |
| `vector_sets::VEmbOptions` | خيارات التضمين (embedding) للمتجهات |
| `vector_sets::VSimOptions` | خيارات البحث بالتشابه (similarity search) |

### 1.16 وحدة ACL (`acl`)

| الهيكل | الشرح |
|--------|-------|
| `acl::AclInfo` | معلومات قائمة التحكم بالوصول (ACL) لمستخدم |

---

## 2. التعدادات (Enums)

### 2.1 تعدادات جذرية

| التعداد | الشرح |
|---------|-------|
| `Arg` | معامل أمر Redis (نص، بايتات، أو عدد) |
| `ConnectionAddr` | نوع عنوان الاتصال (TCP، TLS، أو Unix socket) |
| `ControlFlow` | التحكم في تدفق الاشتراك (متابعة أو إيقاف) |
| `Direction` | اتجاه العملية (يسار أو يمين — لأوامر القوائم) |
| `ErrorKind` | أنواع أخطاء Redis (IO، مصادقة، عنقود، بروتوكول، إلخ) |
| `ExistenceCheck` | شرط وجود المفتاح (NX: غير موجود، XX: موجود) |
| `ExpireOption` | خيارات انتهاء الصلاحية (NX, XX, GT, LT) |
| `Expiry` | مدة انتهاء الصلاحية (ثوانٍ، ميلي ثانية، طابع زمني) |
| `FieldExistenceCheck` | شرط وجود حقل في Hash |
| `IntegerReplyOrNoOp` | استجابة عدد صحيح أو عدم تنفيذ |
| `NumericBehavior` | سلوك القيم العددية (عدد صحيح أو عشري) |
| `ProtocolVersion` | إصدار بروتوكول Redis (RESP2 أو RESP3) |
| `PushKind` | نوع رسالة Push (اشتراك، رسالة، إبطال تخزين مؤقت) |
| `RetryMethod` | طريقة إعادة المحاولة عند الفشل |
| `Role` | دور العقدة (رئيسية أو نسخة) |
| `ServerErrorKind` | نوع خطأ الخادم (MOVED, ASK, BUSY, إلخ) |
| `SetExpiry` | انتهاء صلاحية أمر SET (EX, PX, EXAT, PXAT, KEEPTTL) |
| `TlsMode` | وضع TLS (آمن أو غير آمن) |
| `UpdateCheck` | شرط التحديث (GT: أكبر، LT: أصغر) |
| `UserAssignedId` | معرف هوية مُعينة للمستخدم (Azure) |
| `Value` | قيمة Redis (نص، عدد، بايتات، مصفوفة، خريطة، Null، إلخ) |
| `ValueComparison` | مقارنة بين قيمتين |
| `ValueType` | نوع قيمة Redis (String, List, Set, Hash, ZSet, Stream) |
| `VerbatimFormat` | صيغة النص الحرفي في RESP3 (txt, mkd) |

### 2.2 تعدادات ACL

| التعداد | الشرح |
|---------|-------|
| `acl::Rule` | قاعدة ACL (سماح/منع أوامر، مفاتيح، قنوات) |

### 2.3 تعدادات التخزين المؤقت

| التعداد | الشرح |
|---------|-------|
| `caching::CacheMode` | وضع التخزين المؤقت (بث أو إبطال) |

### 2.4 تعدادات توجيه القراءة

| التعداد | الشرح |
|---------|-------|
| `cluster_read_routing::ReadCandidates` | مرشحو القراءة (أي عقدة، نسخ فقط، مخصص) |

### 2.5 تعدادات توجيه العنقود

| التعداد | الشرح |
|---------|-------|
| `cluster_routing::AggregateOp` | عملية تجميع النتائج من عدة عقد (أول، أخير، مجموع، أدنى، أقصى) |
| `cluster_routing::LogicalAggregateOp` | عملية تجميع منطقية (AND, OR) |
| `cluster_routing::MultiSlotArgPattern` | نمط معاملات متعددة الفتحات |
| `cluster_routing::MultipleNodeRoutingInfo` | معلومات توجيه لعدة عقد |
| `cluster_routing::ResponsePolicy` | سياسة معالجة الاستجابات من عدة عقد |
| `cluster_routing::RoutingInfo` | معلومات التوجيه لأمر (عقدة واحدة أو عدة عقد) |
| `cluster_routing::SingleNodeRoutingInfo` | معلومات توجيه لعقدة واحدة |
| `cluster_routing::SlotAddr` | عنوان الفتحة (رئيسي أو نسخة) |

### 2.6 تعدادات جغرافية

| التعداد | الشرح |
|---------|-------|
| `geo::RadiusOrder` | ترتيب نتائج البحث الجغرافي (تصاعدي أو تنازلي بالمسافة) |
| `geo::Unit` | وحدة المسافة (متر، كيلومتر، ميل، قدم) |

### 2.7 تعدادات الحارس

| التعداد | الشرح |
|---------|-------|
| `sentinel::SentinelServerType` | نوع الخادم المطلوب من Sentinel (رئيسي أو نسخة) |

### 2.8 تعدادات التيارات

| التعداد | الشرح |
|---------|-------|
| `streams::StreamDeletionPolicy` | سياسة حذف الرسائل |
| `streams::StreamIdempotencyMode` | وضع عدم التكرار (idempotency) |
| `streams::StreamMaxlen` | الحد الأقصى لطول التيار (دقيق أو تقريبي) |
| `streams::StreamPendingReply` | نتيجة XPENDING (ملخص أو تفصيل) |
| `streams::StreamTrimStrategy` | استراتيجية التقليم (MAXLEN أو MINID) |
| `streams::StreamTrimmingMode` | وضع التقليم (دقيق أو تقريبي ~) |
| `streams::XAckDelStatusCode` | رمز حالة XACK/XDEL |
| `streams::XDelExStatusCode` | رمز حالة XDELEX |

### 2.9 تعدادات مجموعات المتجهات

| التعداد | الشرح |
|---------|-------|
| `vector_sets::EmbeddingInput` | مدخل التضمين (نص أو متجه) |
| `vector_sets::VectorAddInput` | مدخل إضافة متجه (قيم عددية أو نص) |
| `vector_sets::VectorQuantization` | نوع التكميم (Q8, BF16, FP32) |
| `vector_sets::VectorSimilaritySearchInput` | مدخل البحث بالتشابه |

---

## 3. السمات (Traits)

### 3.1 سمات الأوامر

| السمة | الشرح |
|-------|-------|
| `AsyncCommands` | أوامر Redis غير المتزامنة (get, set, del, إلخ) — تُستخدم مع `await` |
| `AsyncTypedCommands` | أوامر غير متزامنة مع تحويل أنواع تلقائي |
| `Commands` | أوامر Redis المتزامنة |
| `ConnectionLike` | السمة الأساسية لأي اتصال Redis (إرسال أوامر، التحقق من الحالة) |
| `TypedCommands` | أوامر متزامنة مع تحويل أنواع تلقائي |

### 3.2 سمات التحويل

| السمة | الشرح |
|-------|-------|
| `FromRedisValue` | تحويل قيمة Redis إلى نوع Rust (مثل `String`, `i64`, `Vec`) |
| `IntoConnectionInfo` | تحويل قيمة إلى معلومات اتصال (من URL أو هيكل) |
| `RedisWrite` | كتابة بيانات بصيغة بروتوكول Redis |
| `ToRedisArgs` | تحويل نوع Rust إلى معاملات أمر Redis |
| `ToSingleRedisArg` | تحويل نوع Rust إلى معامل Redis واحد |

### 3.3 سمات JSON

| السمة | الشرح |
|-------|-------|
| `JsonAsyncCommands` | أوامر وحدة RedisJSON غير المتزامنة (JSON.GET, JSON.SET, إلخ) |
| `JsonCommands` | أوامر وحدة RedisJSON المتزامنة |

### 3.4 سمات Pub/Sub

| السمة | الشرح |
|-------|-------|
| `PubSubCommands` | أوامر الاشتراك والنشر |

### 3.5 سمات الاتصال غير المتزامن

| السمة | الشرح |
|-------|-------|
| `aio::AsyncPushSender` | إرسال رسائل Push غير متزامنة |
| `aio::AsyncStream` | تيار I/O غير متزامن (قراءة + كتابة) |
| `aio::ConnectionLike` | السمة الأساسية للاتصال غير المتزامن |

### 3.6 سمات المصادقة

| السمة | الشرح |
|-------|-------|
| `auth::StreamingCredentialsProvider` | مزود بيانات اعتماد متجدد (يُرسل تحديثات تلقائية) |

### 3.7 سمات العنقود

| السمة | الشرح |
|-------|-------|
| `cluster::Connect` | سمة إنشاء اتصال متزامن بعقدة عنقود |
| `cluster_async::Connect` | سمة إنشاء اتصال غير متزامن بعقدة عنقود |

### 3.8 سمات توجيه القراءة

| السمة | الشرح |
|-------|-------|
| `cluster_read_routing::ReadRoutingStrategy` | استراتيجية اختيار العقدة للقراءة |
| `cluster_read_routing::ReadRoutingStrategyFactory` | مصنع استراتيجيات توجيه القراءة |

### 3.9 سمات DNS

| السمة | الشرح |
|-------|-------|
| `io::AsyncDNSResolver` | مُحلل DNS غير متزامن مخصص |

---

## 4. الدوال (Functions)

| الدالة | الشرح |
|--------|-------|
| `aio::prefer_smol` | تُفضل بيئة تشغيل smol للاتصالات غير المتزامنة |
| `aio::prefer_tokio` | تُفضل بيئة تشغيل Tokio للاتصالات غير المتزامنة |
| `aio::transaction_async` | تُنفذ معاملة (transaction) غير متزامنة مع WATCH/MULTI/EXEC |
| `calculate_value_digest` | تحسب بصمة (digest) لقيمة Redis |
| `cluster::cluster_pipe` | تُنشئ أنبوب أوامر للعنقود |
| `cmd` | تُنشئ أمر Redis جديد من اسمه (مثل `cmd("GET")`) |
| `from_redis_value` | تُحول قيمة Redis إلى نوع Rust (نسخة مملوكة) |
| `from_redis_value_ref` | تُحول مرجع قيمة Redis إلى نوع Rust |
| `is_valid_16_bytes_hex_digest` | تتحقق من صحة بصمة hex بطول 16 بايت |
| `make_extension_error` | تُنشئ خطأ امتداد مخصص |
| `pack_command` | تُحزم أمر Redis بصيغة بروتوكول RESP |
| `parse_redis_url` | تُحلل URL اتصال Redis إلى مكوناته |
| `parse_redis_value` | تُحلل استجابة Redis من بايتات خام |
| `parse_redis_value_async` | تُحلل استجابة Redis بشكل غير متزامن من تيار |
| `pipe` | تُنشئ أنبوب أوامر (Pipeline) جديد |
| `transaction` | تُنفذ معاملة متزامنة مع WATCH/MULTI/EXEC |

---

## 5. أسماء الأنواع المستعارة (Type Aliases)

| الاسم المستعار | الشرح |
|----------------|-------|
| `FlushDbOptions` | خيارات أمر FLUSHDB (اسم مستعار لـ `FlushAllOptions`) |
| `RedisFuture` | مستقبل Redis — `Pin<Box<dyn Future<Output = RedisResult<T>>>>` |
| `RedisResult` | نتيجة Redis — `Result<T, RedisError>` |

---

## 6. الثوابت (Constants)

### 6.1 ثوابت Entra ID

| الثابت | الشرح |
|--------|-------|
| `entra_id::REDIS_SCOPE_DEFAULT` | النطاق الافتراضي لمصادقة Redis عبر Entra ID |

### 6.2 ثوابت التيارات

| الثابت | الشرح |
|--------|-------|
| `streams::IDMP_DURATION_MAX` | الحد الأقصى لمدة عدم التكرار |
| `streams::IDMP_DURATION_MIN` | الحد الأدنى لمدة عدم التكرار |
| `streams::IDMP_MAXSIZE_MAX` | الحد الأقصى لحجم عدم التكرار |
| `streams::IDMP_MAXSIZE_MIN` | الحد الأدنى لحجم عدم التكرار |

---

## ملخص

تُقدم مكتبة **redis-rs** واجهة شاملة للتواصل مع Redis في Rust، وتتضمن:

- **اتصال أساسي** — متزامن وغير متزامن مع دعم TLS وUnix sockets
- **عنقود Redis** (`cluster`) — توزيع الأوامر تلقائياً على العقد المناسبة مع إعادة التوجيه
- **حارس Redis** (`sentinel`) — اكتشاف تلقائي للعقدة الرئيسية وتجاوز الأعطال
- **Pub/Sub** — نشر واشتراك في القنوات بشكل متزامن وغير متزامن
- **تيارات** (`streams`) — دعم كامل لـ Redis Streams مع مجموعات المستهلكين
- **مجموعات المتجهات** (`vector_sets`) — بحث بالتشابه باستخدام المتجهات
- **تخزين مؤقت** (`caching`) — تخزين مؤقت من جانب العميل مع إبطال تلقائي
- **جغرافي** (`geo`) — أوامر البحث الجغرافي
- **JSON** — دعم وحدة RedisJSON
- **ACL** — إدارة قوائم التحكم بالوصول
- **سكريبتات Lua** — تحميل وتنفيذ سكريبتات على الخادم
- **أنابيب** (`Pipeline`) — تجميع الأوامر لتقليل زمن الشبكة
- **معاملات** (`Transaction`) — تنفيذ ذري لمجموعة أوامر
- **مصادقة Azure Entra ID** — دعم مصادقة السحابة
