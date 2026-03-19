# الدليل العملاق والشامل للبرمجة غير المتزامنة (Async) في Flutter

تُعد البرمجة غير المتزامنة (Asynchronous Programming) حجر الزاوية في بناء تطبيقات Flutter احترافية وسلسة. بدون فهم عميق لهذا المفهوم، ستواجه مشاكل مثل تجميد واجهة المستخدم (UI Jitter)، تسريبات الذاكرة (Memory Leaks)، وصعوبة في إدارة البيانات القادمة من مصادر خارجية.

هذا الدليل هو مرجعك النهائي الذي يغطي كل شيء من المفاهيم النظرية العميقة إلى التطبيقات العملية المتقدمة، مع شرح لكل الودجت (Widgets) التي توفرها Flutter للتعامل مع العمليات غير المتزامنة.

---

## الفهرس
1. [فلسفة Dart في التزامن: Event Loop و Microtasks](#1-فلسفة-dart-في-التزامن-event-loop-و-microtasks)
2. [المفاهيم الأساسية: Future و Stream](#2-المفاهيم-أساسية-future-و-stream)
3. [شرح الودجت الأساسية (Async Widgets)](#3-شرح-الودجت-الأساسية-async-widgets)
    - [FutureBuilder: الملك المتوج للعمليات لمرة واحدة](#futurebuilder-الملك-المتوج-للعمليات-لمرة-واحدة)
    - [StreamBuilder: محرك البيانات الحية](#streambuilder-محرك-البيانات-الحية)
4. [الودجت المساعدة والبديلة (ValueListenableBuilder و ListenableBuilder)](#4-الودجت-المساعدة-والبديلة)
5. [التحكم المتقدم في الـ Streams (StreamController و RxDart)](#5-التحكم-المتقدم-في-الـ-streams)
6. [تعدد المهام الحقيقي: Isolates و Compute](#6-تعدد-المهام-الحقيقي-isolates-و-compute)
7. [أنماط Async المتقدمة (Future.wait, Future.any, StreamZip)](#7-أنماط-async-المتقدمة)
8. [معالجة الأخطاء الشاملة (Error Handling)](#8-معالجة-الأخطاء-الشاملة)
9. [إدارة الذاكرة وتجنب التسريبات](#9-إدارة-الذاكرة-وتجنب-التسريبات)
10. [اختبار الكود غير المتزامن (Async Testing)](#10-اختبار-الكود-غير-المتزامن)
11. [مشروع تطبيقي متكامل: نظام رفع ملفات ذكي](#11-مشروع-تطبيقي-متكامل)

---

## 1. فلسفة Dart في التزامن: Event Loop و Microtasks

لفهم كيف تعمل Flutter، يجب أن تفهم أولاً كيف تعالج لغة Dart الكود. Dart هي لغة **Single-threaded**، مما يعني أنها تنفذ تعليمة برمجية واحدة فقط في كل لحظة. ولكن، كيف يمكنها تحميل صورة من الإنترنت وفي نفس الوقت الاستجابة لنقرات المستخدم؟ السر يكمن في **Event Loop**.

### مكونات نظام التنفيذ في Dart:
1.  **Main Isolate**: هو الخيط (Thread) الرئيسي الذي يعمل عليه تطبيقك. يحتوي على مساحة ذاكرة خاصة به و Event Loop خاص به.
2.  **Microtask Queue**: طابور مخصص للمهام الصغيرة جداً والداخلية التي يجب تنفيذها فوراً بعد انتهاء المهمة الحالية وقبل العودة إلى الـ Event Loop.
3.  **Event Queue**: طابور يحتوي على الأحداث الخارجية مثل:
    - نقرات المستخدم (Tap events).
    - استجابات الشبكة (I/O).
    - المؤقتات (Timers).
    - رسم الإطارات (Painting).

> **قاعدة ذهبية**: الـ Event Loop يشبه الموظف الذي يخدم طابورين. هو دائماً ينهي كل المهام في "طابور الـ Microtasks" أولاً، وفقط عندما يفرغ تماماً، يذهب ليأخذ مهمة واحدة من "طابور الأحداث" (Event Queue)، ثم يعود ليتفقد طابور الـ Microtasks مرة أخرى.

**لماذا يهمك هذا؟**
إذا قمت بعملية حسابية ثقيلة (مثل فك تشفير ملف ضخم) داخل الـ Event Loop، فأنت تمنع الموظف من الذهاب لطابور الأحداث، وبالتالي لن يستطيع معالجة نقرات المستخدم أو رسم الإطارات، مما يؤدي لتجمد التطبيق (Jank).

---

## 2. المفاهيم الأساسية: Future و Stream

قبل أن نلمس الودجت، يجب أن نتقن الأدوات البرمجية.

### أ. الـ Future: الوعد الصادق
الـ `Future` يمثل قيمة ستكون متاحة في وقت ما في المستقبل. هو عملية تبدأ الآن وتكتمل لاحقاً بنتيجة واحدة (بيانات أو خطأ).

**حالات الـ Future:**
- **Uncompleted**: العملية لا تزال جارية.
- **Completed with Data**: نجحت العملية وحصلنا على النتيجة.
- **Completed with Error**: فشلت العملية لسبب ما.

```dart
Future<String> fetchUserBio() async {
  // محاكاة طلب شبكة يستغرق 3 ثوانٍ
  await Future.delayed(Duration(seconds: 3));
  return "مطور Flutter شغوف ببناء تطبيقات رائعة.";
}
```

### ب. الـ Stream: النهر المتدفق
الـ `Stream` هو سلسلة من الأحداث غير المتزامنة. بدلاً من الحصول على قيمة واحدة، تحصل على تدفق من القيم بمرور الوقت.

**أنواع الـ Streams:**
1.  **Single-subscription**: يسمح بمستمع واحد فقط. إذا حاولت الاستماع إليه مرتين، سيحدث خطأ. مثالي لتحميل ملف.
2.  **Broadcast**: يسمح بعدة مستمعين في نفس الوقت. مثالي لأحداث نظام تحديد المواقع (GPS) أو إشعارات الحالة العامة.

```dart
Stream<int> countSeconds(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i; // إرسال القيمة الحالية إلى الـ Stream
  }
}
```

---

## 3. شرح الودجت الأساسية (Async Widgets)

توفر Flutter ودجت ذكية تسمى "Builders" تقوم بإعادة بناء نفسها تلقائياً عندما تتغير حالة العملية غير المتزامنة.

### FutureBuilder: الملك المتوج للعمليات لمرة واحدة

يُستخدم `FutureBuilder` عندما يكون لديك عملية `Future` واحدة تريد عرض نتائجها.

**المعلمات الأساسية:**
- `future`: كائن الـ Future الذي تراقبه.
- `initialData`: بيانات اختيارية تظهر قبل اكتمال الـ Future.
- `builder`: دالة تأخذ `BuildContext` و `AsyncSnapshot`.

**تحليل الـ AsyncSnapshot:**
اللقطة (Snapshot) هي التي تخبرك بما يحدث الآن. تحتوي على:
- `connectionState`: حالة الاتصال (`none`, `waiting`, `active`, `done`).
- `data`: البيانات الفعلية (تأكد من فحص `hasData`).
- `error`: الخطأ إن وجد (تأكد من فحص `hasError`).

**مثال تطبيقي احترافي:**
```dart
class UserProfileWidget extends StatefulWidget {
  @override
  _UserProfileWidgetState createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late Future<Map<String, dynamic>> _userData;

  @override
  void initState() {
    super.initState();
    // هام جداً: أنشئ الـ Future هنا وليس داخل الـ build
    _userData = _fetchRemoteData();
  }

  Future<Map<String, dynamic>> _fetchRemoteData() async {
    await Future.delayed(Duration(seconds: 2));
    // محاكاة خطأ عشوائي للاختبار
    // throw Exception("فشل الاتصال بالخادم");
    return {"name": "أحمد", "level": "خبير"};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userData,
      builder: (context, snapshot) {
        // 1. حالة الانتظار
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        // 2. حالة الخطأ
        if (snapshot.hasError) {
          return Center(child: Text("حدث خطأ: ${snapshot.error}"));
        }

        // 3. حالة النجاح وتوفر البيانات
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return ListTile(
            title: Text(data['name']),
            subtitle: Text("المستوى: ${data['level']}"),
          );
        }

        // 4. الحالة الافتراضية
        return Center(child: Text("لا توجد بيانات"));
      },
    );
  }
}
```

---

### StreamBuilder: محرك البيانات الحية

يُستخدم `StreamBuilder` عندما تتوقع تدفقاً مستمراً من البيانات. هو يعمل بنفس منطق `FutureBuilder` ولكنه يعيد بناء الواجهة في كل مرة يصدر فيها الـ Stream قيمة جديدة.

**مثال: مراقب أسعار العملات الرقمية (محاكاة):**
```dart
Stream<double> getBitcoinPrice() async* {
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    yield 45000.0 + (new Random().nextDouble() * 1000);
  }
}

// داخل الـ Build
StreamBuilder<double>(
  stream: getBitcoinPrice(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text(
        "سعر البيتكوين الآن: $${snapshot.data!.toStringAsFixed(2)}",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

## 4. الودجت المساعدة والبديلة

أحياناً، لا تحتاج لـ `Future` أو `Stream` كامل، بل فقط لمراقبة قيمة متغيرة. هنا تأتي الودجت المساعدة:

### أ. ValueListenableBuilder
مثالي لمراقبة متغير واحد بسيط (مثل عداد أو حالة زر). هو أخف وزناً من `StreamBuilder`.

```dart
final ValueNotifier<int> _counter = ValueNotifier<int>(0);

// في الواجهة
ValueListenableBuilder<int>(
  valueListenable: _counter,
  builder: (context, value, child) {
    return Text("العدد الحالي: $value");
  },
)
```

### ب. ListenableBuilder
ودجت أحدث (تم تقديمه في إصدارات Flutter الأخيرة) يسمح لك بالاستماع لأي كائن ينفذ واجهة `Listenable` (مثل `ChangeNotifier` أو `ScrollController`).

---
(يتبع في الجزء القادم: التحكم المتقدم، Isolates، ومعالجة الأخطاء العميقة...)

---

## 5. التحكم المتقدم في الـ Streams (StreamController و RxDart)

عندما تريد إنشاء الـ Stream الخاص بك والتحكم فيه يدوياً، نستخدم `StreamController`. هو بمثابة "صنبور" و "أنبوب" في نفس الوقت.

### أ. StreamController: المتحكم الكامل
يحتوي `StreamController` على:
- `sink`: المدخل الذي تضع فيه البيانات (`add`).
- `stream`: المخرج الذي يستمع إليه الـ `StreamBuilder`.

**مثال: نظام إشعارات بسيط:**
```dart
class NotificationService {
  // إنشاء StreamController من نوع Broadcast للسماح بعدة مستمعين
  final _controller = StreamController<String>.broadcast();

  // المخرج (Stream)
  Stream<String> get notifications => _controller.stream;

  // المدخل (Sink)
  void sendNotification(String message) {
    _controller.sink.add(message);
  }

  // هام جداً: إغلاق الـ Controller عند الانتهاء
  void dispose() {
    _controller.close();
  }
}
```

### ب. RxDart: القوة الضاربة للـ Streams
مكتبة `rxdart` تضيف قدرات هائلة للـ Streams في Dart، مستوحاة من ReactiveX.

**أهم التقنيات في RxDart:**
1.  **Debouncing**: انتظر حتى يتوقف تدفق البيانات لفترة محددة (مثالي للبحث).
2.  **Throttling**: تجاهل البيانات المتكررة في فترة زمنية (مثالي لأزرار الإرسال).
3.  **BehaviorSubject**: نوع خاص من الـ StreamController يحتفظ بآخر قيمة تم إرسالها (مثالي لإدارة الحالة).

**مثال: حقل بحث ذكي (Debounce):**
```dart
final _searchSubject = BehaviorSubject<String>();

// في الـ initState
_searchSubject
  .debounceTime(Duration(milliseconds: 500)) // انتظر نصف ثانية بعد توقف الكتابة
  .distinctUntilChanged() // لا تبحث إذا كانت الكلمة هي نفسها السابقة
  .listen((query) {
    _performSearch(query);
  });

// في الـ TextField
onChanged: (value) => _searchSubject.add(value),
```

---

## 6. تعدد المهام الحقيقي: Isolates و Compute

تذكر أن Dart هي **Single-threaded**. إذا قمت بعملية حسابية ضخمة (مثل فك تشفير ملف JSON بحجم 50 ميجابايت)، فإن استخدام `async` و `await` لن يمنع تجمد الواجهة! لماذا؟ لأن `async` لا يعني "خيطاً آخر"، بل يعني "انتظر دون حظر". العملية الحسابية نفسها لا تزال تعمل على الخيط الرئيسي.

الحل هو **Isolates**. الـ Isolate هو خيط منفصل تماماً له ذاكرة خاصة به ولا يشاركها مع الخيط الرئيسي.

### أ. استخدام `compute` للسهولة
دالة `compute` هي أسهل طريقة لتشغيل دالة في Isolate منفصل والحصول على النتيجة.

```dart
import 'package:flutter/foundation.dart';

// دالة خارج الكلاس (Top-level function)
List<String> parseHugeJson(String jsonString) {
  // عمليات تحليل معقدة تستغرق وقتاً
  return jsonDecode(jsonString).cast<String>();
}

// تشغيلها دون تجميد التطبيق
List<String> result = await compute(parseHugeJson, hugeJsonData);
```

### ب. متى تستخدم Isolates؟
- تحليل ملفات JSON ضخمة.
- معالجة الصور أو الفيديو.
- التشفير وفك التشفير (Cryptography).
- العمليات الحسابية المعقدة (مثل الذكاء الاصطناعي المحلي).

---

## 7. أنماط Async المتقدمة (Advanced Async Patterns)

### أ. Future.wait: التوازي الحقيقي
بدلاً من انتظار طلبات الشبكة واحداً تلو الآخر، يمكنك تشغيلها جميعاً في نفس الوقت وانتظار اكتمالها معاً.

```dart
final results = await Future.wait([
  fetchPosts(),
  fetchComments(),
  fetchUserStats(),
]);
// النتائج تأتي كمصفوفة مرتبة بنفس ترتيب الـ Futures
final posts = results[0];
final comments = results[1];
```

### ب. Future.any: السباق
أول `Future` يكتمل (سواء بنجاح أو فشل) هو الذي نأخذ نتيجته. مفيد إذا كان لديك عدة خوادم (Mirrors) وتريد الأسرع بينها.

### ج. StreamZip: دمج الأنهار
دمج عدة Streams في Stream واحد يصدر قائمة تحتوي على أحدث قيمة من كل Stream.

---

## 8. معالجة الأخطاء الشاملة (Error Handling)

في البرمجة غير المتزامنة، الأخطاء قد تحدث في أي وقت.

### أ. استخدام `try-catch` مع `await`
هذه هي الطريقة الأبسط والأكثر شيوعاً.

```dart
try {
  final data = await api.getData();
} catch (e) {
  print("حدث خطأ: $e");
}
```

### ب. معالجة الأخطاء في الـ Streams
الـ Stream يمكنه إصدار خطأ تماماً كما يصدر البيانات.

```dart
stream.listen(
  (data) => print("بيانات: $data"),
  onError: (error) => print("خطأ في الـ Stream: $error"),
  onDone: () => print("اكتمل الـ Stream"),
);
```

### ج. التقاط الأخطاء الشاملة (runZonedGuarded)
هذه التقنية المتقدمة تسمح لك بالتقاط أي خطأ غير متوقع يحدث في أي مكان في تطبيقك، حتى في العمليات غير المتزامنة التي قد لا يغطيها `try-catch` العادي.

```dart
runZonedGuarded(() {
  runApp(MyApp());
}, (error, stack) {
  // إرسال الخطأ لخدمة تتبع الأخطاء مثل Firebase Crashlytics أو Sentry
  print('خطأ غير متوقع: $error');
});
```

---

## 9. إدارة الذاكرة وتجنب التسريبات (Memory Management)

أكبر عدو لمطور Flutter هو "تسريب الذاكرة" (Memory Leak). يحدث هذا غالباً عندما تستمر في الاستماع لـ Stream بعد إغلاق الصفحة.

### القواعد الذهبية:
1.  **أغلق الـ Controllers**: دائماً استدعِ `controller.close()` في دالة `dispose()`.
2.  **إلغاء الاشتراكات**: إذا استخدمت `stream.listen()`، فاحفظ الاشتراك في متغير من نوع `StreamSubscription` وألغه في `dispose()`.
3.  **استخدم الـ Builders**: ودجت `StreamBuilder` و `FutureBuilder` تقوم بإدارة الاشتراكات وإلغائها تلقائياً لك، لذا هي الخيار الأفضل دائماً.

```dart
StreamSubscription? _subscription;

@override
void initState() {
  _subscription = myStream.listen((_) {});
}

@override
void dispose() {
  _subscription?.cancel(); // هام جداً!
  super.dispose();
}
```

---
(يتبع في الجزء الأخير: الاختبارات، المشروع التطبيقي، والخلاصة...)

---

## 10. اختبار الكود غير المتزامن (Async Testing)

اختبار الكود غير المتزامن هو تحدٍ حقيقي لأنك لا تريد انتظار الوقت الفعلي في كل اختبار. توفر Flutter أدوات قوية للتحكم في الوقت.

### أ. استخدام `fakeAsync` للتحكم في الوقت
هذه التقنية تسمح لك بمحاكاة مرور الوقت دون انتظاره فعلياً.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  test('اختبار العداد غير المتزامن', () {
    fakeAsync((async) {
      int counter = 0;
      Future.delayed(Duration(seconds: 10), () => counter++);
      
      // محاكاة مرور 10 ثوانٍ فوراً
      async.elapse(Duration(seconds: 10));
      
      expect(counter, 1);
    });
  });
}
```

### ب. اختبار الودجت (Widget Testing)
استخدم `tester.pump()` و `tester.pumpAndSettle()` للانتظار حتى تستقر واجهة المستخدم بعد العمليات غير المتزامنة.

```dart
testWidgets('اختبار ظهور البيانات بعد التحميل', (tester) async {
  await tester.pumpWidget(MyAsyncApp());
  
  // في البداية يظهر مؤشر التحميل
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  
  // انتظر حتى تنتهي كل العمليات غير المتزامنة
  await tester.pumpAndSettle();
  
  // الآن يجب أن تظهر البيانات
  expect(find.text('تم تحميل البيانات بنجاح'), findsOneWidget);
});
```

---

## 11. مشروع تطبيقي متكامل: نظام رفع ملفات ذكي

هذا المثال يجمع بين `StreamController` للتقدم، و `Isolate` لمعالجة البيانات، و `StreamBuilder` للواجهة. هو مثال واقعي لما قد تفعله في تطبيق احترافي.

```dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 1. دالة معالجة البيانات في Isolate منفصل
List<int> encryptFile(List<int> bytes) {
  // محاكاة عملية تشفير ثقيلة
  return bytes.map((b) => b ^ 0xFF).toList();
}

class FileUploadManager {
  // 2. متحكم في تدفق التقدم (Progress Stream)
  final _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  Future<void> uploadFile(List<int> fileBytes) async {
    try {
      // أ. معالجة الملف في Isolate (تشفير)
      final processedData = await compute(encryptFile, fileBytes);
      
      // ب. محاكاة الرفع مع تحديث التقدم
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(Duration(milliseconds: 300));
        _progressController.sink.add(i / 100.0);
      }
      
      print("تم الرفع بنجاح!");
    } catch (e) {
      _progressController.sink.addError("فشل الرفع: $e");
    }
  }

  void dispose() {
    _progressController.close();
  }
}

// 3. واجهة المستخدم (UI)
class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _manager = FileUploadManager();

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("نظام الرفع الذكي")),
      body: Center(
        child: StreamBuilder<double>(
          stream: _manager.progressStream,
          initialData: 0.0,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("خطأ: ${snapshot.error}", style: TextStyle(color: Colors.red));
            }
            
            final progress = snapshot.data ?? 0.0;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(value: progress),
                SizedBox(height: 20),
                Text("نسبة التقدم: ${(progress * 100).toInt()}%"),
                if (progress == 1.0) Icon(Icons.check_circle, color: Colors.green, size: 50),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _manager.uploadFile([1, 2, 3, 4, 5]),
        child: Icon(Icons.upload_file),
      ),
    );
  }
}
```

---

## الخلاصة

البرمجة غير المتزامنة في Flutter ليست مجرد كلمات مفتاحية مثل `async` و `await`. إنها منظومة متكاملة تبدأ من فهم الـ **Event Loop**، وتمر عبر اختيار الودجت المناسب (`FutureBuilder` أو `StreamBuilder`) وتنتهي بإدارة الذاكرة والاختبار.

### نصائح ذهبية للنجاح:
1.  **لا تضع العمليات الثقيلة في الخيط الرئيسي**: استخدم `compute` أو `Isolates`.
2.  **إدارة الحالة بذكاء**: استخدم `StreamBuilder` و `FutureBuilder` لتقليل استخدام `setState`.
3.  **الأمان أولاً**: دائماً تعامل مع حالات الخطأ (`hasError`) وحالات الانتظار (`waiting`).
4.  **النظافة البرمجية**: أغلق كل الـ Streams والـ Controllers في دالة `dispose`.

باتباع هذا الدليل، ستكون قادراً على بناء تطبيقات Flutter سريعة، مستقرة، واحترافية قادرة على التعامل مع أعقد العمليات غير المتزامنة بكل سهولة.

### المراجع الرسمية لمزيد من التعمق:
- [Flutter Async Documentation](https://docs.flutter.dev/ui/widgets/async)
- [Dart Concurrency Guide](https://dart.dev/language/concurrency)
- [RxDart Documentation](https://pub.dev/packages/rxdart)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
