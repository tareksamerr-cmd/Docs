# شرح شامل لمكتبة Axum في Rust

---

## نظرة عامة

**Axum** هو إطار عمل ويب طوّره فريق Tokio، يتميز بتصميم مبني على الأنواع (type-safe) ويعتمد على نظام الاستخراج (Extractors) لمعالجة الطلبات، ونظام التوجيه (Routing) لتوزيعها على المعالجات (Handlers) المناسبة. يتكامل بشكل كامل مع منظومة Tower للوسائط (Middleware).

---

## 1. الهياكل (Structs)

### 1.1 الهياكل الجذرية (Root Level)

| الهيكل | الشرح |
|--------|-------|
| `Error` | نوع الخطأ العام في Axum، يُغلف أي خطأ يحدث أثناء معالجة الطلبات |
| `Extension` | مُستخرج (Extractor) يسحب بيانات مشتركة مُخزنة كإضافة (extension) في الطلب أو حالة التطبيق |
| `Form` | مُستخرج يُحلل بيانات النماذج (form data) من جسم الطلب بصيغة `application/x-www-form-urlencoded` |
| `Json` | مُستخرج يُحلل جسم الطلب كـ JSON ويُحوله إلى نوع Rust، ويُستخدم أيضاً كاستجابة JSON |
| `Router` | الموجه الرئيسي الذي يربط المسارات (routes) بالمعالجات، وهو نقطة البداية لبناء التطبيق |

### 1.2 وحدة الجسم (`body`)

| الهيكل | الشرح |
|--------|-------|
| `body::Body` | نوع جسم HTTP الافتراضي في Axum، يُغلف تيار بايتات غير متزامن |
| `body::BodyDataStream` | يُحول جسم HTTP إلى تيار (Stream) من أجزاء البيانات |

### 1.3 وحدة معالجة الأخطاء (`error_handling`)

| الهيكل | الشرح |
|--------|-------|
| `error_handling::HandleError` | خدمة تلتقط الأخطاء من خدمة داخلية وتحولها إلى استجابات HTTP |
| `error_handling::HandleErrorLayer` | طبقة Tower تُنشئ `HandleError` لكل طلب |
| `error_handling::future::HandleErrorFuture` | المستقبل (Future) الناتج عن `HandleError` |

### 1.4 وحدة الاستخراج (`extract`)

| الهيكل | الشرح |
|--------|-------|
| `extract::ConnectInfo` | مُستخرج يوفر معلومات الاتصال (مثل عنوان IP للعميل) |
| `extract::DefaultBodyLimit` | يُحدد الحد الأقصى لحجم جسم الطلب (افتراضياً 2MB) |
| `extract::MatchedPath` | مُستخرج يُرجع نمط المسار المُطابق (مثل `/users/:id`) |
| `extract::Multipart` | مُستخرج لمعالجة بيانات `multipart/form-data` (رفع الملفات) |
| `extract::NestedPath` | مُستخرج يُرجع بادئة المسار عند استخدام التوجيه المتداخل |
| `extract::OriginalUri` | مُستخرج يُرجع URI الأصلي قبل أي تعديل من التوجيه المتداخل |
| `extract::Path` | مُستخرج يسحب المعاملات من مسار URL (مثل `/users/:id` → `id`) |
| `extract::Query` | مُستخرج يُحلل معاملات الاستعلام (query string) من URL |
| `extract::RawForm` | مُستخرج يُرجع بيانات النموذج الخام كبايتات |
| `extract::RawPathParams` | مُستخرج يُرجع معاملات المسار الخام كأزواج مفتاح-قيمة نصية |
| `extract::RawQuery` | مُستخرج يُرجع سلسلة الاستعلام الخام بدون تحليل |
| `extract::State` | مُستخرج يسحب حالة التطبيق المشتركة (Application State) |
| `extract::WebSocketUpgrade` | مُستخرج يُدير ترقية اتصال HTTP إلى WebSocket |

### 1.5 وحدة معلومات الاتصال (`extract::connect_info`)

| الهيكل | الشرح |
|--------|-------|
| `extract::connect_info::ConnectInfo` | يحمل معلومات الاتصال المُستخرجة |
| `extract::connect_info::IntoMakeServiceWithConnectInfo` | يُحول الموجه إلى خدمة تُمرر معلومات الاتصال |
| `extract::connect_info::MockConnectInfo` | طبقة لمحاكاة معلومات الاتصال في الاختبارات |
| `extract::connect_info::ResponseFuture` | المستقبل الناتج عن خدمة معلومات الاتصال |

### 1.6 وحدة البيانات المتعددة الأجزاء (`extract::multipart`)

| الهيكل | الشرح |
|--------|-------|
| `extract::multipart::Field` | يمثل حقلاً واحداً في بيانات multipart (ملف أو حقل نصي) |
| `extract::multipart::InvalidBoundary` | خطأ عند وجود حد فاصل (boundary) غير صالح |
| `extract::multipart::Multipart` | المُستخرج الرئيسي لمعالجة بيانات multipart |
| `extract::multipart::MultipartError` | خطأ عام أثناء معالجة بيانات multipart |

### 1.7 وحدة معاملات المسار (`extract::path`)

| الهيكل | الشرح |
|--------|-------|
| `extract::path::FailedToDeserializePathParams` | خطأ عند فشل تحويل معاملات المسار إلى النوع المطلوب |
| `extract::path::InvalidUtf8InPathParam` | خطأ عند وجود ترميز UTF-8 غير صالح في معامل المسار |
| `extract::path::Path` | مُستخرج معاملات المسار |
| `extract::path::RawPathParams` | معاملات المسار الخام |
| `extract::path::RawPathParamsIter` | مُكرر على معاملات المسار الخام |

### 1.8 وحدة أخطاء الرفض (`extract::rejection`)

| الهيكل | الشرح |
|--------|-------|
| `extract::rejection::FailedToDeserializeForm` | فشل تحليل بيانات النموذج |
| `extract::rejection::FailedToDeserializeFormBody` | فشل تحليل جسم النموذج |
| `extract::rejection::FailedToDeserializeQueryString` | فشل تحليل سلسلة الاستعلام |
| `extract::rejection::InvalidFormContentType` | نوع محتوى النموذج غير صالح |
| `extract::rejection::InvalidUtf8` | ترميز UTF-8 غير صالح في الجسم |
| `extract::rejection::JsonDataError` | خطأ في بيانات JSON (مثل نوع غير متوقع) |
| `extract::rejection::JsonSyntaxError` | خطأ في بنية JSON (صيغة غير صالحة) |
| `extract::rejection::LengthLimitError` | تجاوز حد حجم الجسم المسموح |
| `extract::rejection::MatchedPathMissing` | المسار المُطابق غير متوفر |
| `extract::rejection::MissingExtension` | الإضافة المطلوبة غير موجودة في الطلب |
| `extract::rejection::MissingJsonContentType` | رأس Content-Type لا يشير إلى JSON |
| `extract::rejection::MissingPathParams` | معاملات المسار مفقودة |
| `extract::rejection::NestedPathRejection` | خطأ في المسار المتداخل |
| `extract::rejection::UnknownBodyError` | خطأ غير معروف في جسم الطلب |

### 1.9 وحدة WebSocket (`extract::ws`)

| الهيكل | الشرح |
|--------|-------|
| `extract::ws::CloseFrame` | إطار إغلاق WebSocket يحتوي على رمز السبب ورسالة |
| `extract::ws::DefaultOnFailedUpgrade` | السلوك الافتراضي عند فشل ترقية WebSocket (تسجيل الخطأ) |
| `extract::ws::Utf8Bytes` | بايتات مضمونة الترميز بـ UTF-8 |
| `extract::ws::WebSocket` | اتصال WebSocket نشط يسمح بإرسال واستقبال الرسائل |
| `extract::ws::WebSocketUpgrade` | يُدير عملية ترقية HTTP إلى WebSocket |

### 1.10 وحدة أخطاء رفض WebSocket (`extract::ws::rejection`)

| الهيكل | الشرح |
|--------|-------|
| `extract::ws::rejection::ConnectionNotUpgradable` | الاتصال لا يدعم الترقية |
| `extract::ws::rejection::InvalidConnectionHeader` | رأس Connection غير صالح |
| `extract::ws::rejection::InvalidProtocolPseudoheader` | رأس بروتوكول زائف غير صالح (HTTP/2) |
| `extract::ws::rejection::InvalidUpgradeHeader` | رأس Upgrade غير صالح |
| `extract::ws::rejection::InvalidWebSocketVersionHeader` | إصدار WebSocket غير مدعوم |
| `extract::ws::rejection::MethodNotConnect` | الطريقة ليست CONNECT (مطلوبة لـ HTTP/2) |
| `extract::ws::rejection::MethodNotGet` | الطريقة ليست GET (مطلوبة لـ HTTP/1.1) |
| `extract::ws::rejection::WebSocketKeyHeaderMissing` | رأس Sec-WebSocket-Key مفقود |

### 1.11 وحدة المعالجات (`handler`)

| الهيكل | الشرح |
|--------|-------|
| `handler::HandlerService` | يُحول معالج Axum إلى خدمة Tower |
| `handler::Layered` | معالج مُغلف بطبقات وسيطة |
| `handler::future::IntoServiceFuture` | المستقبل الناتج عن `HandlerService` |
| `handler::future::LayeredFuture` | المستقبل الناتج عن معالج مُطبق |

### 1.12 وحدة الوسائط (`middleware`)

| الهيكل | الشرح |
|--------|-------|
| `middleware::AddExtension` | وسيط يُضيف بيانات مشتركة (extension) لكل طلب |
| `middleware::FromExtractor` | وسيط يُشغل مُستخرجاً قبل المعالج ويرفض الطلب إذا فشل |
| `middleware::FromExtractorLayer` | طبقة Tower لإنشاء `FromExtractor` |
| `middleware::FromFn` | وسيط مبني من دالة عادية |
| `middleware::FromFnLayer` | طبقة Tower لإنشاء `FromFn` |
| `middleware::MapRequest` | وسيط يُعدل الطلب قبل تمريره للمعالج |
| `middleware::MapRequestLayer` | طبقة Tower لإنشاء `MapRequest` |
| `middleware::MapResponse` | وسيط يُعدل الاستجابة بعد المعالج |
| `middleware::MapResponseLayer` | طبقة Tower لإنشاء `MapResponse` |
| `middleware::Next` | يمثل بقية سلسلة الوسائط والمعالج، يُستدعى لتمرير الطلب |
| `middleware::ResponseAxumBody` | وسيط يُحول جسم الاستجابة إلى نوع Axum الافتراضي |
| `middleware::ResponseAxumBodyFuture` | المستقبل الناتج عن `ResponseAxumBody` |
| `middleware::ResponseAxumBodyLayer` | طبقة Tower لإنشاء `ResponseAxumBody` |
| `middleware::future::FromExtractorResponseFuture` | المستقبل الناتج عن وسيط `FromExtractor` |
| `middleware::future::FromFnResponseFuture` | المستقبل الناتج عن وسيط `FromFn` |
| `middleware::future::MapRequestResponseFuture` | المستقبل الناتج عن وسيط `MapRequest` |
| `middleware::future::MapResponseResponseFuture` | المستقبل الناتج عن وسيط `MapResponse` |

### 1.13 وحدة الاستجابات (`response`)

| الهيكل | الشرح |
|--------|-------|
| `response::AppendHeaders` | يُضيف رؤوس HTTP إضافية للاستجابة |
| `response::ErrorResponse` | استجابة خطأ تُنشأ من أي نوع يُنفذ `IntoResponse` |
| `response::Html` | استجابة HTML مع رأس `Content-Type: text/html` |
| `response::NoContent` | استجابة بدون محتوى (204 No Content) |
| `response::Redirect` | استجابة إعادة توجيه (301, 302, 307, 308) |
| `response::ResponseParts` | أجزاء الاستجابة (رؤوس، إضافات) قابلة للتعديل |
| `response::Sse` | استجابة Server-Sent Events لإرسال أحداث مباشرة للعميل |

### 1.14 وحدة SSE (`response::sse`)

| الهيكل | الشرح |
|--------|-------|
| `response::sse::Event` | حدث SSE واحد يحتوي على بيانات واسم ومعرف اختياري |
| `response::sse::EventDataWriter` | كاتب بيانات الحدث |
| `response::sse::KeepAlive` | يُرسل رسائل keep-alive دورية لمنع انقطاع الاتصال |
| `response::sse::KeepAliveStream` | تيار SSE مع keep-alive مُدمج |
| `response::sse::Sse` | نوع الاستجابة SSE الرئيسي |

### 1.15 وحدة التوجيه (`routing`)

| الهيكل | الشرح |
|--------|-------|
| `routing::IntoMakeService` | يُحول الموجه إلى خدمة قابلة للاستخدام مع Hyper |
| `routing::MethodFilter` | فلتر يُحدد طرق HTTP المسموحة (GET, POST, إلخ) |
| `routing::Route` | مسار واحد مُسجل في الموجه |
| `routing::Router` | الموجه الرئيسي لتسجيل المسارات والوسائط |
| `routing::RouterAsService` | الموجه كخدمة Tower (بمرجع) |
| `routing::RouterIntoService` | الموجه كخدمة Tower (بملكية) |
| `routing::future::InfallibleRouteFuture` | مستقبل مسار لا يفشل أبداً |
| `routing::future::IntoMakeServiceFuture` | مستقبل إنشاء الخدمة |
| `routing::future::RouteFuture` | المستقبل الناتج عن معالجة مسار |
| `routing::method_routing::MethodRouter` | موجه خاص بطريقة HTTP محددة |

### 1.16 وحدة الخادم (`serve`)

| الهيكل | الشرح |
|--------|-------|
| `serve::IncomingStream` | تيار الاتصالات الواردة |
| `serve::Serve` | خادم Axum قيد التشغيل |
| `serve::TapIo` | يسمح بالوصول لتيار I/O الخام للاتصال |
| `serve::WithGracefulShutdown` | خادم مع دعم الإيقاف الرشيق (graceful shutdown) |

### 1.17 وحدة أدوات الاختبار (`test_helpers`)

| الهيكل | الشرح |
|--------|-------|
| `test_helpers::RequestBuilder` | بانٍ لإنشاء طلبات HTTP للاختبار |
| `test_helpers::TestClient` | عميل HTTP وهمي لاختبار التطبيق بدون خادم حقيقي |
| `test_helpers::TestResponse` | استجابة اختبارية مع دوال مساعدة للتحقق |

---

## 2. التعدادات (Enums)

التعدادات تمثل أنواعاً يمكن أن تكون إحدى عدة قيم محددة.

### 2.1 أخطاء الرفض

| التعداد | الشرح |
|---------|-------|
| `extract::multipart::MultipartRejection` | أسباب رفض طلب multipart (حد غير صالح، خطأ في الجسم) |
| `extract::path::ErrorKind` | أنواع أخطاء معاملات المسار (مفقود، نوع خاطئ، إلخ) |
| `extract::rejection::BytesRejection` | رفض استخراج البايتات الخام |
| `extract::rejection::ExtensionRejection` | رفض استخراج الإضافة (غير موجودة) |
| `extract::rejection::FailedToBufferBody` | فشل تخزين جسم الطلب مؤقتاً |
| `extract::rejection::FormRejection` | رفض استخراج بيانات النموذج |
| `extract::rejection::JsonRejection` | رفض استخراج JSON (بنية خاطئة، نوع محتوى خاطئ) |
| `extract::rejection::MatchedPathRejection` | رفض استخراج المسار المُطابق |
| `extract::rejection::PathRejection` | رفض استخراج معاملات المسار |
| `extract::rejection::QueryRejection` | رفض استخراج معاملات الاستعلام |
| `extract::rejection::RawFormRejection` | رفض استخراج النموذج الخام |
| `extract::rejection::RawPathParamsRejection` | رفض استخراج معاملات المسار الخام |
| `extract::rejection::StringRejection` | رفض استخراج النص (ليس UTF-8 صالح) |

### 2.2 WebSocket

| التعداد | الشرح |
|---------|-------|
| `extract::ws::Message` | أنواع رسائل WebSocket (نص، ثنائي، ping، pong، إغلاق) |
| `extract::ws::rejection::WebSocketUpgradeRejection` | أسباب رفض ترقية WebSocket |

---

## 3. السمات (Traits)

السمات تُعرِّف سلوكاً مشتركاً يمكن لأنواع مختلفة تنفيذه.

### 3.1 سمات جذرية

| السمة | الشرح |
|-------|-------|
| `RequestExt` | دوال إضافية على نوع الطلب لاستخراج البيانات مباشرة |
| `RequestPartsExt` | دوال إضافية على أجزاء الطلب (رؤوس، URI) لاستخراج البيانات |
| `ServiceExt` | دوال إضافية على الخدمات لتسهيل التكامل مع Axum |

### 3.2 سمات الاستخراج

| السمة | الشرح |
|-------|-------|
| `extract::FromRef` | استخراج مرجع من حالة التطبيق (لتقسيم الحالة إلى أجزاء) |
| `extract::FromRequest` | السمة الأساسية لتعريف مُستخرج يستهلك جسم الطلب |
| `extract::FromRequestParts` | مُستخرج يعمل على أجزاء الطلب فقط (بدون الجسم) |
| `extract::OptionalFromRequest` | مُستخرج اختياري لا يُفشل الطلب إذا لم تتوفر البيانات |
| `extract::OptionalFromRequestParts` | مُستخرج اختياري من أجزاء الطلب |
| `extract::connect_info::Connected` | سمة لاستخراج معلومات الاتصال من تيار I/O |
| `extract::ws::OnFailedUpgrade` | سمة تُحدد السلوك عند فشل ترقية WebSocket |

### 3.3 سمات المعالجات

| السمة | الشرح |
|-------|-------|
| `handler::Handler` | السمة الأساسية للمعالجات — أي دالة غير متزامنة تقبل مُستخرجات وتُرجع استجابة |
| `handler::HandlerWithoutStateExt` | دوال إضافية للمعالجات التي لا تحتاج حالة |

### 3.4 سمات الوسائط

| السمة | الشرح |
|-------|-------|
| `middleware::IntoMapRequestResult` | تحويل نتيجة تعديل الطلب إلى إما طلب مُعدل أو استجابة مبكرة |

### 3.5 سمات الاستجابة

| السمة | الشرح |
|-------|-------|
| `response::IntoResponse` | السمة الأساسية لتحويل أي نوع إلى استجابة HTTP |
| `response::IntoResponseParts` | تحويل نوع إلى أجزاء استجابة (رؤوس، إضافات) |

### 3.6 سمات الخادم

| السمة | الشرح |
|-------|-------|
| `serve::Listener` | سمة لمستمع يقبل اتصالات واردة (TCP أو غيره) |
| `serve::ListenerExt` | دوال إضافية على المستمع (مثل `tap_io`) |

---

## 4. ماكروهات السمات (Attribute Macros)

| الماكرو | الشرح |
|---------|-------|
| `#[debug_handler]` | يُحسن رسائل خطأ الترجمة للمعالجات بإظهار أخطاء واضحة عند عدم تطابق الأنواع |
| `#[debug_middleware]` | يُحسن رسائل خطأ الترجمة للوسائط |

---

## 5. ماكروهات الاشتقاق (Derive Macros)

| الماكرو | الشرح |
|---------|-------|
| `#[derive(FromRef)]` | يُولد تلقائياً تنفيذ `FromRef` لاستخراج حقول من حالة التطبيق |
| `#[derive(FromRequest)]` | يُولد تلقائياً تنفيذ `FromRequest` لهيكل مخصص |
| `#[derive(FromRequestParts)]` | يُولد تلقائياً تنفيذ `FromRequestParts` لهيكل مخصص |

---

## 6. الدوال (Functions)

### 6.1 دوال الجسم (`body`)

| الدالة | الشرح |
|--------|-------|
| `body::to_bytes` | تقرأ جسم HTTP كاملاً وتُحوله إلى `Bytes` |

### 6.2 دوال الوسائط (`middleware`)

| الدالة | الشرح |
|--------|-------|
| `middleware::from_extractor` | تُنشئ وسيطاً من مُستخرج (يرفض الطلب إذا فشل الاستخراج) |
| `middleware::from_extractor_with_state` | مثل السابقة مع تمرير حالة مخصصة |
| `middleware::from_fn` | تُنشئ وسيطاً من دالة عادية غير متزامنة |
| `middleware::from_fn_with_state` | مثل السابقة مع تمرير حالة مخصصة |
| `middleware::map_request` | تُنشئ وسيطاً يُعدل الطلب |
| `middleware::map_request_with_state` | مثل السابقة مع حالة مخصصة |
| `middleware::map_response` | تُنشئ وسيطاً يُعدل الاستجابة |
| `middleware::map_response_with_state` | مثل السابقة مع حالة مخصصة |

### 6.3 دوال توجيه الطرق (`routing::method_routing`)

| الدالة | الشرح |
|--------|-------|
| `routing::method_routing::any` | يُطابق أي طريقة HTTP |
| `routing::method_routing::any_service` | مثل `any` لكن يقبل خدمة Tower بدلاً من معالج |
| `routing::method_routing::connect` | يُطابق طريقة CONNECT |
| `routing::method_routing::connect_service` | مثل `connect` لخدمة Tower |
| `routing::method_routing::delete` | يُطابق طريقة DELETE |
| `routing::method_routing::delete_service` | مثل `delete` لخدمة Tower |
| `routing::method_routing::get` | يُطابق طريقة GET |
| `routing::method_routing::get_service` | مثل `get` لخدمة Tower |
| `routing::method_routing::head` | يُطابق طريقة HEAD |
| `routing::method_routing::head_service` | مثل `head` لخدمة Tower |
| `routing::method_routing::on` | يُطابق طريقة HTTP مُحددة بفلتر |
| `routing::method_routing::on_service` | مثل `on` لخدمة Tower |
| `routing::method_routing::options` | يُطابق طريقة OPTIONS |
| `routing::method_routing::options_service` | مثل `options` لخدمة Tower |
| `routing::method_routing::patch` | يُطابق طريقة PATCH |
| `routing::method_routing::patch_service` | مثل `patch` لخدمة Tower |
| `routing::method_routing::post` | يُطابق طريقة POST |
| `routing::method_routing::post_service` | مثل `post` لخدمة Tower |
| `routing::method_routing::put` | يُطابق طريقة PUT |
| `routing::method_routing::put_service` | مثل `put` لخدمة Tower |
| `routing::method_routing::trace` | يُطابق طريقة TRACE |
| `routing::method_routing::trace_service` | مثل `trace` لخدمة Tower |

### 6.4 دوال الخادم (`serve`)

| الدالة | الشرح |
|--------|-------|
| `serve` | تُشغل خادم HTTP يستمع على عنوان محدد ويخدم الموجه |
| `serve::serve` | الدالة الداخلية لتشغيل الخادم |

---

## 7. أسماء الأنواع المستعارة (Type Aliases)

| الاسم المستعار | الشرح |
|----------------|-------|
| `BoxError` | `Box<dyn Error + Send + Sync>` — نوع خطأ عام مُغلف |
| `extract::Request` | اسم مستعار لـ `http::Request<Body>` — طلب HTTP مع جسم Axum |
| `extract::ws::CloseCode` | نوع رمز إغلاق WebSocket (عدد صحيح 16-بت) |
| `response::Response` | اسم مستعار لـ `http::Response<Body>` — استجابة HTTP مع جسم Axum |
| `response::Result` | `Result<T, ErrorResponse>` — نتيجة مختصرة للاستجابات |

---

## 8. الثوابت (Constants)

### رموز إغلاق WebSocket (`extract::ws::close_code`)

| الثابت | الشرح |
|--------|-------|
| `NORMAL` | إغلاق طبيعي (1000) — اكتمل الغرض من الاتصال |
| `AWAY` | الطرف يغادر (1001) — مثل إغلاق المتصفح |
| `PROTOCOL` | خطأ في البروتوكول (1002) |
| `UNSUPPORTED` | نوع بيانات غير مدعوم (1003) |
| `STATUS` | لا يوجد رمز حالة (1005) — محجوز، لا يُرسل |
| `ABNORMAL` | إغلاق غير طبيعي (1006) — محجوز، لا يُرسل |
| `INVALID` | بيانات غير صالحة (1007) — مثل نص ليس UTF-8 |
| `POLICY` | انتهاك سياسة (1008) |
| `SIZE` | رسالة كبيرة جداً (1009) |
| `EXTENSION` | امتداد مطلوب غير متوفر (1010) |
| `ERROR` | خطأ غير متوقع في الخادم (1011) |
| `RESTART` | الخادم يُعاد تشغيله (1012) |
| `AGAIN` | حاول مرة أخرى لاحقاً (1013) |

---

## ملخص

تُقدم مكتبة **Axum** إطار عمل ويب متكامل وعالي الأداء في Rust، يتضمن:

- **توجيه** (`routing`) — ربط مسارات URL بمعالجات مع دعم كامل لجميع طرق HTTP
- **استخراج** (`extract`) — نظام مُستخرجات قوي لسحب البيانات من الطلبات (JSON, Form, Path, Query, State, WebSocket)
- **استجابات** (`response`) — أنواع استجابة متعددة (HTML, JSON, SSE, Redirect, NoContent)
- **وسائط** (`middleware`) — تكامل كامل مع Tower لإضافة منطق قبل/بعد المعالجة
- **معالجة أخطاء** (`error_handling`) — نظام رفض واضح مع رسائل خطأ مفصلة
- **WebSocket** — دعم كامل لاتصالات WebSocket ثنائية الاتجاه
- **خادم** (`serve`) — تشغيل الخادم مع دعم الإيقاف الرشيق
- **اختبار** (`test_helpers`) — أدوات لاختبار التطبيق بسهولة

يتميز Axum بأنه لا يستخدم ماكروهات إجرائية للتوجيه (على عكس Actix-web)، بل يعتمد على نظام الأنواع في Rust لضمان صحة التطبيق في وقت الترجمة.
