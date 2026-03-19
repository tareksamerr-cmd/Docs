# الدليل النهائي لـ GoRouter في Flutter

**بقلم: أتوها أنتوني (Atuoha Anthony) مع إضافات وتوسيعات من Manus AI**

*تاريخ التحديث: 18 مارس 2026*

---

## مقدمة

يعد التنقل (Navigation) بين الشاشات في Flutter أمراً بالغ الأهمية لأي تطبيق. وبينما توفر واجهة برمجة تطبيقات `Navigator` المدمجة الوظائف اللازمة، إلا أنها قد تصبح معقدة في المشاريع الكبيرة. هنا يأتي دور **`go_router`**، حيث يقدم نظام تنقل أكثر تصريحاً (declarative)، يعتمد على الروابط (URL-based)، وغني بالميزات. يتناول هذا الدليل كل تفاصيل `go_router`، ويرشدك من الإعداد إلى الميزات المتقدمة مثل إعادة التوجيه (redirection) والمسارات المتداخلة (nested routes)، بالإضافة إلى استكشاف حالات الاستخدام المتقدمة وأفضل الممارسات.

`go_router` هي مكتبة توجيه (routing library) مرنة وخفيفة الوزن لـ Flutter تبسط عملية التنقل وتوفر واجهة برمجة تطبيقات (API) نظيفة لإدارة المسارات (routes)، وتمرير المعاملات (parameters)، والتعامل مع عمليات إعادة التوجيه. لقد صُممت لتكون سهلة الاستخدام مع توفير ميزات متقدمة لمتطلبات التنقل الأكثر تعقيداً.

---

## جدول المحتويات

1.  **مقدمة عن GoRouter وأساسيات التنقل في Flutter**
    1.1. مقارنة بين حلول التنقل: `Navigator 1.0`، `Navigator 2.0`، و`GoRouter`
    1.2. لماذا تختار `GoRouter`؟

2.  **البدء مع GoRouter: التثبيت والإعداد الأولي**
    2.1. المتطلبات الأساسية (Prerequisites)
    2.2. التثبيت (Installation)
    2.3. تعريف المسارات الأساسية (`GoRoute`)
    2.4. تهيئة الراوتر (`GoRouter`)
    2.5. التكامل مع `MaterialApp.router`

3.  **التنقل الأساسي: أوامر التنقل الرئيسية**
    3.1. التنقل باستخدام المسارات (`context.go`) و (`context.goNamed`)
    3.2. دفع المسارات (`context.push`) و (`context.pushNamed`)
    3.3. استبدال المسارات (`context.replace`) و (`context.replaceNamed`)
    3.4. العودة إلى الشاشة السابقة (`context.pop`)

4.  **تمرير البيانات بين المسارات: المعاملات والكائنات**
    4.1. معاملات المسار (Path Parameters)
    4.2. معاملات الاستعلام (Query Parameters)
    4.3. تمرير كائنات معقدة باستخدام `extra`

5.  **التنقل المتقدم وهيكل واجهة المستخدم: المسارات المتداخلة**
    5.1. المسارات الفرعية (Sub-routes)
    5.2. `ShellRoute`: واجهات المستخدم المشتركة (مثل `BottomNavigationBar`)
    5.3. `StatefulShellRoute`: الحفاظ على حالة التبويبات (Tabs) وتجربة المستخدم السلسة

6.  **التحكم في تدفق التنقل: إعادة التوجيه وحراس الخروج**
    6.1. إعادة التوجيه (`redirect`): الحماية والمصادقة ومنطق التحكم في الوصول
    6.2. حراس الخروج (`onExit`): تأكيد المغادرة ومنع فقدان البيانات
    6.3. التعامل مع الأخطاء وصفحات 404 (`errorBuilder`): تجربة مستخدم سلسة

7.  **التكامل مع الويب والروابط العميقة (Deep Linking): دعم المنصات المتعددة**
    7.1. مبادئ التنقل في الويب
    7.2. إعداد الروابط العميقة لنظام Android
    7.3. إعداد الروابط العميقة لنظام iOS

8.  **إدارة الحالة (State Management) مع GoRouter: التكامل مع حلول إدارة الحالة**
    8.1. التفاعل مع `refreshListenable`
    8.2. دمج `GoRouter` مع `Provider`
    8.3. دمج `GoRouter` مع `Bloc/Cubit`
    8.4. دمج `GoRouter` مع `Riverpod`

9.  **ميزات متقدمة وأفضل الممارسات: تحسين الأداء والأمان**
    9.1. تحسين الأداء: التحميل الكسول (Lazy Loading) والتخزين المؤقت (Caching)
    9.2. الانتقالات المخصصة (`pageBuilder`): تجربة مستخدم فريدة
    9.3. مراقبو المسار (`observers`): تتبع أحداث التنقل
    9.4. أفضل ممارسات الأمان: حماية المسارات والبيانات
    9.5. اختبار منطق التنقل في `GoRouter`

10. **مشروع عملي: تطبيق تسوق باستخدام GoRouter**
    10.1. هيكل المشروع
    10.2. الكود الكامل للمشروع (Models, Controllers, Screens, Widgets)

11. **الخاتمة والمراجع**

---

## 1. مقدمة عن GoRouter وأساسيات التنقل في Flutter

لفهم قيمة `go_router` بشكل كامل، من الضروري مقارنته بحلول التنقل الأخرى المتاحة في Flutter، وفهم السياق الذي نشأت فيه هذه المكتبة.

### 1.1. مقارنة بين حلول التنقل: `Navigator 1.0`، `Navigator 2.0`، و`GoRouter`

#### Navigator 1.0

`Navigator 1.0` هو الحل الأصلي للتنقل في Flutter، ويعتمد على مفهوم مكدس (stack) من الصفحات. يتم التنقل باستخدام دوال إجرائية (imperative) مثل `Navigator.push()` و `Navigator.pop()`.

**المزايا:**
*   **البساطة:** سهل التعلم والاستخدام للمشاريع الصغيرة والبسيطة التي لا تتطلب روابط عميقة أو إدارة معقدة للحالة.
*   **مباشر:** يوفر واجهة برمجة تطبيقات واضحة لدفع وسحب الصفحات من المكدس.

**العيوب:**
*   **غير تصريحي (Imperative):** يعتمد على الأوامر (commands) بدلاً من وصف الحالة، مما يجعل إدارة مكدس التنقل معقداً في السيناريوهات المعقدة، خاصة عند الحاجة إلى تعديل المكدس بشكل غير خطي.
*   **صعوبة في الروابط العميقة (Deep Linking):** لا يدعم الروابط العميقة بشكل طبيعي، ويتطلب حلولاً مخصصة ومعقدة للتعامل معها.
*   **صعوبة في الويب:** لا يتكيف جيداً مع التنقل القائم على URL في تطبيقات الويب، مما يجعله غير مناسب لتطبيقات Flutter للويب المعقدة.
*   **إدارة الحالة:** يمكن أن يصبح تحدياً عند الحاجة إلى تمرير البيانات بين الصفحات أو إعادة بناء مكدس التنقل بناءً على تغييرات الحالة العالمية.

#### Navigator 2.0 (Router API)

قدم `Navigator 2.0`، المعروف أيضاً باسم Router API، نهجاً تصريحياً (declarative) للتنقل. يعتمد على مفهوم `RouterDelegate` و `RouteInformationParser`، مما يمنح المطورين تحكماً كاملاً في مكدس التنقل وكيفية تفاعله مع الروابط. تم تصميمه لمعالجة أوجه القصور في `Navigator 1.0`، خاصة فيما يتعلق بالروابط العميقة وتطبيقات الويب.

**المزايا:**
*   **تصريحي (Declarative):** يسمح بوصف حالة التنقل، مما يسهل إدارة مكدس التنقل المعقد وتعديله برمجياً.
*   **دعم الروابط العميقة والويب:** مصمم لدعم الروابط العميقة والتنقل القائم على URL في تطبيقات الويب بشكل فعال، مما يجعله الخيار الأمثل لتطبيقات الويب وتطبيقات الهاتف المحمول التي تتطلب هذه الميزات.
*   **تحكم كامل:** يوفر تحكماً دقيقاً في كل جانب من جوانب التنقل، من كيفية تحليل الروابط إلى كيفية بناء مكدس الصفحات.

**العيوب:**
*   **التعقيد:** منحنى تعلم حاد جداً، ويتطلب كتابة الكثير من الكود المعقد حتى للسيناريوهات البسيطة. هذا التعقيد يمكن أن يكون عائقاً كبيراً للمطورين.
*   **الكود المطول (Boilerplate Code):** يتطلب قدراً كبيراً من الكود المتكرر لإعداد Router API، مما يزيد من حجم الكود ويقلل من قابلية القراءة.
*   **صعوبة في الصيانة:** يمكن أن يصبح الكود صعب القراءة والصيانة بسبب تعقيده وكمية الكود المطول المطلوبة.

#### GoRouter: المزايا والعيوب

`go_router` هي مكتبة مبنية فوق `Navigator 2.0`، تهدف إلى تبسيط تعقيداته مع الاحتفاظ بفوائده التصريحية. إنها توفر واجهة برمجة تطبيقات أكثر بساطة وفعالية لإدارة التنقل، مما يجعلها حلاً وسطاً مثالياً بين بساطة `Navigator 1.0` وقوة `Navigator 2.0`.

**المزايا:**
*   **تصريحي ومبسط:** يجمع بين قوة `Navigator 2.0` وبساطة واجهة برمجة تطبيقات سهلة الاستخدام، مما يقلل بشكل كبير من الكود المطول.
*   **دعم الروابط العميقة والويب:** يدعم الروابط العميقة وتغيير URL في المتصفح بشكل طبيعي، مما يجعله مناسباً لتطبيقات الويب وتطبيقات الهاتف المحمول.
*   **إدارة الحالة:** يسهل تمرير المعاملات وإدارة حالة التنقل، ويتكامل بشكل جيد مع حلول إدارة الحالة الشائعة.
*   **المسارات المتداخلة (Nested Routes):** يدعم تنظيم المسارات في هياكل هرمية معقدة باستخدام `ShellRoute` و `StatefulShellRoute`، مما يسهل بناء واجهات مستخدم معقدة مثل أشرطة التنقل السفلية (bottom navigation bars) أو القوائم الجانبية (side drawers).
*   **إعادة التوجيه والحماية (Redirection and Guards):** يوفر آليات قوية للتحكم في الوصول وإعادة توجيه المستخدمين بناءً على الشروط، مثل المصادقة والتخويل.
*   **مجتمع نشط:** يتم صيانته وتطويره بنشاط من قبل فريق Flutter، مما يضمن تحديثات مستمرة ودعماً جيداً.

**العيوب:**
*   **لا يزال يتطلب فهماً لـ Navigator 2.0:** على الرغم من تبسيطه، فإن فهم المفاهيم الأساسية لـ `Navigator 2.0` يمكن أن يكون مفيداً لحل المشكلات المعقدة أو عند الحاجة إلى تخصيص سلوك التنقل بشكل كبير.
*   **قد يكون مبالغاً فيه للمشاريع الصغيرة جداً:** للمشاريع التي تحتوي على عدد قليل جداً من الشاشات ولا تتطلب ميزات متقدمة، قد يكون `Navigator 1.0` كافياً وأبسط.

**جدول مقارنة بين حلول التنقل في Flutter:**

| الميزة / الحل      | Navigator 1.0       | Navigator 2.0 (Router API) | GoRouter                                  |
| :----------------- | :------------------ | :------------------------- | :---------------------------------------- |
| **النموذج**         | إجرائي (Imperative) | تصريحي (Declarative)       | تصريحي (Declarative) ومبسط                |
| **سهولة الاستخدام** | سهل للمبتدئين       | صعب جداً                   | متوسط إلى سهل (بعد فهم المفاهيم)         |
| **الروابط العميقة** | ضعيف                | ممتاز                     | ممتاز                                    |
| **دعم الويب**       | ضعيف                | ممتاز                     | ممتاز                                    |
| **الكود المطول**    | قليل                | كثير جداً                  | متوسط (أقل بكثير من Navigator 2.0 الخام) |
| **المسارات المتداخلة** | لا يدعم             | يدعم                       | يدعم بقوة (ShellRoute, StatefulShellRoute)|
| **إعادة التوجيه**   | يدوي                | يدعم                       | يدعم بقوة                                 |
| **إدارة الحالة**    | تحدي                | معقد                       | مبسط وفعال                                |

### 1.2. لماذا تختار `GoRouter`؟

`go_router` هو الخيار المفضل للعديد من مطوري Flutter للأسباب التالية:

*   **الإنتاجية:** يقلل بشكل كبير من كمية الكود المطول اللازم لإعداد التنقل المعقد، مما يسمح للمطورين بالتركيز على بناء الميزات الأساسية للتطبيق.
*   **قابلية الصيانة:** بفضل واجهته التصريحية، يصبح الكود أكثر قابلية للقراءة والفهم والصيانة على المدى الطويل.
*   **دعم الويب والروابط العميقة:** يوفر دعماً ممتازاً لتطبيقات الويب والروابط العميقة، وهي ميزات أساسية في التطبيقات الحديثة.
*   **المرونة:** يدعم مجموعة واسعة من سيناريوهات التنقل، من البسيطة إلى المعقدة، ويتكامل بسلاسة مع حلول إدارة الحالة المختلفة.
*   **المستقبل:** كونه مدعوماً من فريق Flutter، فإنه يضمن التوافق مع أحدث إصدارات Flutter والميزات الجديدة.

باختصار، `go_router` يسد الفجوة بين بساطة `Navigator 1.0` وقوة `Navigator 2.0`، مما يجعله حلاً مثالياً لمعظم تطبيقات Flutter الحديثة.

---

## 2. البدء مع GoRouter

للبدء في استخدام `go_router` في مشروع Flutter الخاص بك، اتبع الخطوات التالية:

### 2.1. المتطلبات الأساسية (Prerequisites)

للمتابعة مع هذا الدليل وبناء التطبيق المثال، ستحتاج إلى:
*   **Flutter SDK:** تأكد من تثبيت Flutter وتهيئته على جهاز التطوير الخاص بك. يمكنك العثور على تعليمات التثبيت على [الموقع الرسمي لـ Flutter](https://flutter.dev/docs/get-started/install).
*   **معرفة أساسية بـ Flutter:** الإلمام بويدجت (widgets) Flutter، وإدارة الحالة (state management) (حتى `setState` الأساسية)، ومفاهيم تطوير التطبيقات العامة سيكون مفيداً.
*   **أساسيات لغة Dart:** فهم جيد لبناء جملة (syntax) Dart، والأصناف (classes)، والوظائف (functions) أمر ضروري.
*   **بيئة تطوير متكاملة (IDE):** مثل Visual Studio Code أو Android Studio مع تثبيت إضافات Flutter و Dart.

### 2.2. التثبيت (Installation)

للبدء، أضف `go_router` إلى ملف `pubspec.yaml` الخاص بك:

```yaml
dependencies:
  go_router: ^13.0.0 # استخدم أحدث إصدار متاح
```

يضيف هذا حزمة `go_router` كاعتماد (dependency) لمشروعك، مما يتيح لك استخدام وظائفها.

ثم قم بتشغيل الأمر التالي في الطرفية (terminal) لجلب التبعية:

```bash
flutter pub get
```

بعد التثبيت، استورد الحزمة في ملفات Dart الخاصة بك حيث تحتاج إلى استخدام وظائف `go_router`:

```dart
import 'package:go_router/go_router.dart';
```

يجعل هذا البيان جميع الأصناف (classes) والوظائف (functions) التي توفرها حزمة `go_router` متاحة للاستخدام في ملف Dart الخاص بك.
### 2.3. تعريف المسارات الأساسية (`GoRoute`)
المسارات الأساسية (`GoRoute`)

تعتمد `go_router` على تعريف المسارات بشكل تصريحي (declarative). يتم ذلك عادةً بإنشاء قائمة من كائنات `GoRoute`، حيث يمثل كل كائن مساراً فريداً في تطبيقك.

```dart
final _routes = [
  GoRoute(
    path: '/', // المسار الجذري (root path) للتطبيق
    builder: (context, state) => const HomeScreen(), // الويدجت الذي سيتم عرضه لهذا المسار
  ),
  GoRoute(
    path: '/products/:id', // مسار ديناميكي مع معامل مسار (path parameter) يسمى 'id'
    name: 'product_details', // اسم فريد للمسار يمكن استخدامه للتنقل
    builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!), // استخدام المعامل
  ),
  GoRoute(
    path: '/settings', // مسار ثابت لشاشة الإعدادات
    builder: (context, state) => const SettingsScreen(),
  ),
];
```

**شرح تفصيلي لمكونات `GoRoute`:**

*   **`path` (مطلوب):** هذه الخاصية تحدد نمط URL للمسار. يمكن أن يكون مساراً ثابتاً (مثل `/home`) أو يحتوي على معاملات مسار ديناميكية (مثل `/products/:id`).
    *   **المسارات الثابتة:** تطابق URL بالضبط.
    *   **معاملات المسار (Path Parameters):** تبدأ بـ `:` (مثل `:id`). يتم استخراج القيمة المقابلة في URL وتخزينها في `state.pathParameters` كـ `Map<String, String>`.
*   **`name` (اختياري):** اسم فريد للمسار. يوصى بشدة بتحديد أسماء للمسارات، حيث يجعل التنقل أكثر قوة وأقل عرضة للأخطاء (مثلاً، بدلاً من `context.go('/products/123')`، يمكنك استخدام `context.goNamed('product_details', pathParameters: {'id': '123'})`).
*   **`builder` (مطلوب):** هذه الدالة هي المسؤولة عن بناء الويدجت (widget) الذي سيتم عرضه عندما يكون هذا المسار نشطاً. تستقبل `BuildContext` و `GoRouterState`.
    *   `context`: يوفر سياق البناء المعتاد في Flutter.
    *   `state`: كائن `GoRouterState` يوفر معلومات حول المسار الحالي، مثل `pathParameters`، `queryParameters`، `uri`، و `extra`.
*   **`pageBuilder` (اختياري):** بدلاً من `builder`، يمكنك استخدام `pageBuilder` لتوفير كائن `Page` مخصص. هذا يمنحك تحكماً كاملاً في نوع الصفحة (مثل `MaterialPage` أو `CupertinoPage`) والانتقالات (transitions) المرتبطة بها. إذا لم يتم توفيره، سيقوم `go_router` بإنشاء `MaterialPage` افتراضية.
    ```dart
    GoRoute(
      path: '/custom-transition',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: CustomTransitionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // بناء انتقال مخصص هنا، مثلاً FadeTransition
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
    ```
*   **`routes` (اختياري):** قائمة من `RouteBase`s الفرعية التي تنتمي إلى هذا المسار. تُستخدم لإنشاء مسارات متداخلة (nested routes)، حيث يكون المسار الفرعي مسبوقاً بمسار الأب. سيتم شرحها بالتفصيل في قسم `ShellRoute`.
*   **`redirect` (اختياري):** دالة `GoRouterRedirect` خاصة بهذا المسار. يتم استدعاؤها قبل التنقل إلى هذا المسار أو أي من مساراته الفرعية. تسمح لك بتنفيذ منطق إعادة التوجيه الشرطي الخاص بهذا المسار فقط.
*   **`onExit` (اختياري):** دالة `GoRouterPageExitGuard` يتم استدعاؤها عندما يحاول المستخدم مغادرة هذا المسار. يمكن استخدامها لعرض تأكيد للمستخدم قبل المغادرة (مثل حفظ التغييرات).
    ```dart
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => EditProfileScreen(),
      onExit: (context) async {
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('تأكيد'),
            content: const Text('هل أنت متأكد من مغادرة الصفحة دون حفظ التغييرات؟'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('مغادرة')),
            ],
          ),
        );
        return confirmed ?? false; // إذا لم يتم التأكيد، يتم إلغاء عملية الخروج
      },
    ),
    ```
*   **`parentNavigatorKey` (اختياري):** في السيناريوهات التي تستخدم فيها `ShellRoute` أو عدة `Navigator`s، قد تحتاج إلى تحديد أي `Navigator` يجب أن يدفع المسار إليه. تسمح لك هذه الخاصية بتوفير `GlobalKey<NavigatorState>` لـ `Navigator` الأب المستهدف. هذا مهم بشكل خاص عند دفع مسار فوق `ShellRoute`.
*   **`restorationId` (اختياري):** هذه الخاصية مفيدة لاستعادة حالة التنقل (navigation state) عبر عمليات إعادة تشغيل التطبيق أو تغييرات التكوين. يوفر `restorationId` معرفاً فريداً للمسار يمكن استخدامه بواسطة نظام استعادة الحالة في Flutter.

### 2.4. تهيئة الراوتر (`GoRouter`)

بعد تعريف المسارات، تحتاج إلى إنشاء مثيل (instance) من `GoRouter` وتمرير قائمة المسارات إليه. هذا هو الكائن الذي سيدير جميع عمليات التنقل في تطبيقك.

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// شاشات وهمية لأغراض المثال
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الرئيسية')), body: Center(child: Column(children: [const Text('الشاشة الرئيسية'), ElevatedButton(onPressed: () => context.go('/products/123'), child: const Text('اذهب للمنتج 123')), ElevatedButton(onPressed: () => context.go('/settings'), child: const Text('اذهب للإعدادات'))])));}
class ProductDetailsScreen extends StatelessWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('تفاصيل المنتج $productId')), body: Center(child: Text('تفاصيل المنتج: $productId')));}
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الإعدادات')), body: const Center(child: Text('شاشة الإعدادات')));}

// تعريف المسارات كما في القسم السابق
final _routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/products/:id',
    name: 'product_details',
    builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
  ),
];

// تهيئة GoRouter
final GoRouter router = GoRouter(
  routes: _routes,
  // يمكن إضافة معاملات إضافية هنا مثل redirect, errorBuilder, etc.
);
```

**شرح معاملات `GoRouter` الإنشائية (Constructor Parameters):**

*   **`routes` (مطلوب):** قائمة كائنات `RouteBase` (عادةً `GoRoute` أو `ShellRoute`) التي تحدد جميع المسارات الممكنة في تطبيقك. هذا هو جوهر تكوين الراوتر.

*   **`initialLocation` (اختياري):** المسار الأولي الذي يجب أن يعرضه التطبيق عند بدء التشغيل. إذا لم يتم تحديده، فسيتم استخدام `/` كمسار افتراضي. يمكن أن يكون مفيداً لتحديد نقطة دخول مختلفة لتطبيقات الويب أو اختبار سيناريوهات معينة.
    ```dart
    final _router = GoRouter(
      routes: _routes,
      initialLocation: '/splash', // يبدأ التطبيق بشاشة البداية
    );
    ```

*   **`initialExtra` (اختياري):** كائن يمكن تمريره كـ `extra` إلى المسار الأولي المحدد بواسطة `initialLocation`. مفيد لتمرير بيانات التهيئة الأولية.

*   **`debugLogDiagnostics` (اختياري، افتراضياً `false`):** إذا تم تعيينه على `true`، فسيقوم `go_router` بتسجيل معلومات تشخيصية مفصلة إلى وحدة التحكم (console) حول عملية التنقل، مثل مطابقة المسار، وإعادة التوجيه، وتغييرات مكدس التنقل. هذا مفيد جداً لتصحيح الأخطاء.

*   **`refreshListenable` (اختياري):** كائن `Listenable` (مثل `ChangeNotifier` أو `Stream`) الذي، عند إرسال إشعار، سيؤدي إلى إعادة تقييم دالة `redirect` الخاصة بالراوتر. هذا أمر بالغ الأهمية لسيناريوهات مثل إعادة التوجيه بناءً على حالة المصادقة التي تتغير بمرور الوقت. سيتم شرحه بالتفصيل في قسم إدارة الحالة.

*   **`redirect` (اختياري):** دالة `GoRouterRedirect` يتم استدعاؤها قبل كل عملية تنقل. تسمح لك بتنفيذ منطق إعادة التوجيه الشرطي (مثل حماية المسارات غير المصرح بها أو إعادة توجيه المستخدمين غير المصادق عليهم إلى صفحة تسجيل الدخول). يجب أن تُرجع `null` إذا لم يكن هناك إعادة توجيه، أو سلسلة (string) تمثل المسار الجديد. سيتم شرحها بالتفصيل في قسم التحكم في تدفق التنقل.

*   **`redirectLimit` (اختياري، افتراضياً `5`):** يحدد الحد الأقصى لعدد عمليات إعادة التوجيه المتتالية المسموح بها قبل أن يرمي `go_router` خطأ `GoRouterRedirectLimitExceededException`. هذا يمنع حلقات إعادة التوجيه اللانهائية.

*   **`redirectCancelPop` (اختياري، افتراضياً `false`):** إذا تم تعيينه على `true`، فسيتم إلغاء عملية `pop` (العودة إلى الشاشة السابقة) إذا أدت إلى إعادة توجيه. هذا يمكن أن يكون مفيداً في سيناريوهات معينة لمنع المستخدمين من العودة إلى حالة غير صالحة.

*   **`errorBuilder` (اختياري):** دالة `GoRouterWidgetBuilder` تُستخدم لبناء ويدجت شاشة الخطأ عندما لا يمكن مطابقة مسار أو يحدث خطأ أثناء تحليل المسار. إذا لم يتم توفيره، فسيتم عرض شاشة خطأ افتراضية. سيتم شرحها بالتفصيل في قسم التعامل مع الأخطاء.

*   **`observers` (اختياري):** قائمة من `NavigatorObserver`s التي يمكن استخدامها لمراقبة أحداث التنقل (مثل دفع المسارات، سحبها، أو استبدالها). مفيد لتسجيل التحليلات أو تنفيذ منطق مخصص. سيتم شرحها بالتفصيل في قسم الميزات المتقدمة.

*   **`navigatorKey` (اختياري):** `GlobalKey<NavigatorState>` يمكن توفيره للتحكم في `Navigator` الجذري. هذا مفيد بشكل خاص عند استخدام `ShellRoute`s أو عندما تحتاج إلى التفاعل مع `Navigator` الجذري برمجياً.

*   **`debugEither` (اختياري، افتراضياً `false`):** يستخدم لتصحيح الأخطاء المتعلقة بـ `Navigator 1.0` و `Navigator 2.0` في نفس الوقت. لا يُنصح بتعيينه على `true` في الإنتاج.

*   **`urlPathStrategy` (مهمل):** كان يستخدم لتحديد استراتيجية مسار URL لتطبيقات الويب. تم إهماله لصالح `UrlPathStrategy.path` الذي أصبح السلوك الافتراضي.

### 2.5. التكامل مع `MaterialApp.router`

لجعل `go_router` يعمل في تطبيق Flutter الخاص بك، تحتاج إلى استخدام `MaterialApp.router` (أو `CupertinoApp.router` لتطبيقات iOS) وتمرير كائن `GoRouter` الذي قمت بإنشائه إلى خاصية `routerConfig`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// استيراد ملف الراوتر الذي يحتوي على تعريف 'router'
// import 'path/to/your/router_config.dart'; // افترض أن router تم تعريفه هنا

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp.router(
      title: 'Flutter GoRouter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      routerConfig: router, // تمرير كائن GoRouter هنا
    );
  }
}
```

**ملاحظات هامة:**
*   `MaterialApp.router` هو مُنشئ (constructor) خاص لـ `MaterialApp` يتكامل مع مفوض الراوتر (router delegate)، مثل `GoRouter`.
*   `routerConfig`: هذه الخاصية هي التي تربط `GoRouter` بإطار عمل Flutter للتنقل. بمجرد تعيينها، سيتولى `GoRouter` مسؤولية إدارة مكدس التنقل في تطبيقك.

بهذه الخطوات، تكون قد أعددت `go_router` بنجاح في مشروعك، وأصبحت جاهزاً للبدء في التنقل بين الشاشات.

## 3. التنقل الأساسي

يوفر `go_router` عدة طرق للتنقل بين الشاشات، كل منها مصمم لسيناريوهات مختلفة. فهم هذه الطرق أمر أساسي لإدارة تدفق المستخدم في تطبيقك.

### 3.1. التنقل باستخدام المسارات (`context.go`) و (`context.goNamed`)

تُستخدم دالة `go()` للانتقال إلى مسار معين عن طريق استبدال مكدس التنقل الحالي بالمسار الجديد. هذا يعني أنه لا يمكن للمستخدم العودة إلى المسارات السابقة باستخدام زر العودة.

*   **الاستخدام:** عندما تريد الانتقال إلى شاشة جديدة ومسح سجل التنقل السابق (مثل بعد تسجيل الدخول أو الخروج).
*   **الصيغة:** `context.go(path, {extra, queryParameters, pathParameters})`

```dart
// الانتقال إلى الشاشة الرئيسية ومسح سجل التنقل
context.go(
  '/',
  extra: 'Welcome Back!', // يمكن تمرير بيانات إضافية
);

// الانتقال إلى شاشة تفاصيل المنتج باستخدام معامل مسار
context.go(
  '/products/456',
  queryParameters: {'source': 'home_page'},
);
```

### 3.2. دفع المسارات (`context.push`) و (`context.pushNamed`)

تُستخدم دالة `push()` لإضافة مسار جديد إلى أعلى مكدس التنقل الحالي. هذا يسمح للمستخدم بالعودة إلى الشاشة السابقة باستخدام زر العودة.

*   **الاستخدام:** عندما تريد الانتقال إلى شاشة جديدة مع الاحتفاظ بسجل التنقل، مما يسمح للمستخدم بالعودة.
*   **الصيغة:** `context.push(path, {extra, queryParameters, pathParameters})`

```dart
// دفع شاشة إعدادات جديدة فوق الشاشة الحالية
context.push('/settings');

// دفع شاشة تفاصيل منتج مع إمكانية العودة
context.push('/products/789');
```

### 3.3. استبدال المسارات (`context.replace`) و (`context.replaceNamed`)

بدلاً من استخدام المسارات المباشرة (مثل `/products/123`)، يمكنك استخدام الأسماء التي قمت بتعريفها للمسارات (مثل `product_details`). هذا يجعل الكود أكثر قابلية للقراءة والصيانة، ويقلل من الأخطاء الناتجة عن تغيير أنماط المسارات.

*   **`context.goNamed()`:** ينتقل إلى مسار مسمى ويستبدل مكدس التنقل.
*   **`context.pushNamed()`:** يدفع مساراً مسمى إلى أعلى مكدس التنقل.

**الصيغة:** `context.goNamed(name, {pathParameters, queryParameters, extra})`

```dart
// تعريف المسار المسمى مسبقاً:
// GoRoute(
//   path: '/products/:id',
//   name: 'product_details',
//   builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!),
// ),

// التنقل باستخدام المسار المسمى
context.goNamed(
  'product_details',
  pathParameters: {'id': '123'},
  queryParameters: {'from': 'featured'},
);

// دفع مسار مسمى
context.pushNamed(
  'settings',
  extra: {'user_id': 'abc'},
);
```

### 3.4. العودة إلى الشاشة السابقة (`context.pop`)

تُستخدم دالة `pop()` لإزالة المسار العلوي من مكدس التنقل، مما يعيد المستخدم إلى الشاشة السابقة. هذه الدالة مكافئة لـ `Navigator.pop()`.

*   **الاستخدام:** عندما تريد السماح للمستخدم بالعودة إلى الشاشة التي جاء منها.
*   **الصيغة:** `context.pop([result])`

```dart
// العودة إلى الشاشة السابقة
context.pop();

// العودة مع تمرير نتيجة (مثلاً، بعد إكمال عملية ما)
context.pop('تم حفظ التغييرات بنجاح');
```

### 3.5. طرق تنقل إضافية

يوفر `go_router` أيضاً طرقاً أخرى للتحكم الدقيق في مكدس التنقل:

*   **`context.replace(path)` / `context.replaceNamed(name)`:** تستبدل المسار الحالي في مكدس التنقل بالمسار الجديد. على عكس `go()`، فإنه لا يمسح المكدس بأكمله، بل يستبدل العنصر العلوي فقط. هذا مفيد عندما لا تريد أن يتمكن المستخدم من العودة إلى الشاشة التي استبدلتها.
    ```dart
    // استبدال شاشة التحميل بشاشة الرئيسية بعد انتهاء التحميل
    context.replace('/');
    ```

*   **`context.pushReplacement(path)` / `context.pushReplacementNamed(name)`:** يدفع مساراً جديداً إلى المكدس ويزيل المسار الحالي. هذا يختلف عن `replace()` في أنه لا يزال يضيف إلى المكدس، ولكنه يضمن أن الشاشة السابقة غير قابلة للوصول عبر زر العودة.
    ```dart
    // بعد إكمال عملية الشراء، انتقل إلى شاشة التأكيد واستبدل شاشة الشراء
    context.pushReplacement('/order-confirmation');
    ```

*   **`context.goBranch(index)`:** هذه الطريقة خاصة بـ `ShellRoute` وتُستخدم للانتقال بين فروع `ShellRoute` المختلفة (عادةً ما تكون علامات تبويب `BottomNavigationBar`). سيتم شرحها بالتفصيل في قسم `ShellRoute`.
    ```dart
    // الانتقال إلى الفرع الثاني (الفهرس 1) من ShellRoute
    context.goBranch(1);
    ```

*   **`context.popToNamed(name)`:** تزيل جميع المسارات من المكدس حتى تصل إلى المسار المسمى المحدد. إذا لم يتم العثور على المسار، فلن يحدث شيء.
    ```dart
    // العودة إلى الشاشة الرئيسية المسمّاة 'homeRoute'
    context.popToNamed('homeRoute');
    ```

---

## 4. تمرير البيانات بين المسارات

يعد تمرير البيانات بين الشاشات جانباً أساسياً في أي تطبيق. يوفر `go_router` طرقاً مرنة وقوية للقيام بذلك.

### 4.1. معاملات المسار (Path Parameters)

معاملات المسار هي جزء من المسار نفسه وعادة ما تكون مطلوبة. بدونها، لا يكون للمسار معنى (مثل معرف المنتج أو معرف المستخدم).

*   **التعريف:** يتم تحديدها في `path` باستخدام `:`. مثال: `/products/:id`.
*   **التنقل:** يتم تمريرها كـ `Map<String, String>` إلى `pathParameters` عند استخدام `goNamed` أو `pushNamed`.
*   **الاستلام:** يتم الوصول إليها من `state.pathParameters` في دالة `builder` للمسار.

**مثال:**

```dart
// تعريف المسار
GoRoute(
  path: '/users/:userId/posts/:postId',
  name: 'user_post_details',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    final postId = state.pathParameters['postId']!;
    return UserPostDetailsScreen(userId: userId, postId: postId);
  },
),

// التنقل إلى المسار
context.goNamed(
  'user_post_details',
  pathParameters: {
    'userId': '123',
    'postId': 'abc',
  },
);
```

### 4.2. معاملات الاستعلام (Query Parameters)

معاملات الاستعلام هي أزواج مفتاح-قيمة (key-value pairs) مرنة مرفقة بـ URL بعد علامة الاستفهام `?`. تُستخدم هذه عادةً للمعلومات غير الأساسية أو الاختيارية، مثل عوامل التصفية، استعلامات البحث، أو المعرفات الثانوية.

*   **التعريف:** لا يتم تعريفها في `path` الخاص بـ `GoRoute`.
*   **التنقل:** يتم تمريرها كـ `Map<String, String>` إلى `queryParameters` عند استخدام `go`, `push`, `goNamed`, أو `pushNamed`.
*   **الاستلام:** يتم الوصول إليها من `state.uri.queryParameters` في دالة `builder` للمسار.

**مثال:**

```dart
// تعريف المسار (لا يتطلب تعريف معاملات الاستعلام في الـ path)
GoRoute(
  path: '/search',
  name: 'search_results',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    final category = state.uri.queryParameters['category'] ?? 'all';
    return SearchResultsScreen(query: query, category: category);
  },
),

// التنقل إلى المسار
context.goNamed(
  'search_results',
  queryParameters: {
    'q': 'flutter widgets',
    'category': 'development',
  },
);
// URL الناتج سيكون: /search?q=flutter%20widgets&category=development
```

### 4.3. تمرير كائنات معقدة باستخدام `extra`

بالإضافة إلى `pathParameters` و `queryParameters`، يوفر `go_router` طريقة قوية لتمرير كائنات Dart معقدة بين المسارات باستخدام المعامل `extra`.

*   **الميزة:** يسمح لك بتمرير أي كائن Dart (وليس فقط سلاسل أو أرقام) بين الشاشات دون الحاجة إلى تسلسل (serialize) أو إلغاء تسلسل (deserialize) يدوياً. هذا مفيد بشكل خاص لتمرير كائنات النموذج (model objects) أو البيانات المعقدة التي لا تحتاج إلى أن تكون جزءاً من URL.
*   **القيود:** لا يتم تضمين البيانات التي يتم تمريرها عبر `extra` في URL، مما يعني أنها لن تكون مرئية في شريط عنوان المتصفح (لتطبيقات الويب) ولن يتم الحفاظ عليها عند تحديث الصفحة أو مشاركة الرابط. لذلك، يجب استخدامها للبيانات المؤقتة أو التي لا تحتاج إلى أن تكون جزءاً من حالة URL.

**مثال:**

```dart
class Product {
  final String id;
  final String name;
  // ... المزيد من الخصائص
  Product({required this.id, required this.name});
}

// تعريف المسار
GoRoute(
  path: '/product-details-object',
  name: 'product_details_object',
  builder: (context, state) {
    final product = state.extra as Product?; // يتم إرجاعها كـ Object?، لذا تحتاج إلى cast
    if (product == null) {
      return const Text('خطأ: المنتج غير موجود!');
    }
    return ProductDetailsScreen(productId: product.id, productName: product.name);
  },
),

// التنقل وتمرير كائن Product
final myProduct = Product(id: 'p101', name: 'سماعات بلوتوث');
context.goNamed(
  'product_details_object',
  extra: myProduct,
);
```

**أفضل الممارسات لـ `extra`:**
*   **استخدمها للبيانات غير الدائمة:** البيانات التي لا تحتاج إلى أن تكون جزءاً من URL أو التي لا تحتاج إلى أن تكون قابلة للمشاركة أو الإشارة إليها.
*   **تجنب تمرير الكائنات الكبيرة جداً:** على الرغم من أنها تسمح بتمرير أي كائن، إلا أن تمرير كائنات ضخمة قد يؤثر على الأداء.
*   **التحقق من النوع (Type Checking):** دائماً قم بالتحقق من نوع الكائن الذي تم تمريره عبر `extra` أو استخدم `as Type?` للتعامل مع الحالات التي قد يكون فيها `extra` من نوع مختلف أو `null`.

---

## 5. التنقل المتقدم وهيكل واجهة المستخدم

مع نمو التطبيقات، تصبح الحاجة إلى تنظيم المسارات وهيكل واجهة المستخدم أكثر أهمية. يوفر `go_router` أدوات قوية مثل المسارات الفرعية (`Sub-routes`) و `ShellRoute` و `StatefulShellRoute` للتعامل مع هذه السيناريوهات.

### 5.1. المسارات الفرعية (Sub-routes)

تسمح لك المسارات الفرعية بتداخل المسارات تحت مسار أب (parent). يحافظ هذا على تجميع المسارات ذات الصلة معاً ويجعل بنية المسارات أكثر منطقية.

**مثال:** ملف التعريف (Profile) وصفحة إعداداته الفرعية.

```dart
GoRoute(
  path: '/profile',
  builder: (context, state) => ProfileScreen(),
  routes: [
    GoRoute(
      path: 'edit', // المسار الكامل سيكون '/profile/edit'
      builder: (context, state) => EditProfileScreen(),
    ),
    GoRoute(
      path: 'settings', // المسار الكامل سيكون '/profile/settings'
      builder: (context, state) => ProfileSettingsScreen(),
    ),
  ],
),
```

في هذا المثال، `EditProfileScreen` و `ProfileSettingsScreen` هما مساران فرعيان لـ `/profile`. عند التنقل إلى `/profile/edit`، سيتم عرض `EditProfileScreen`، ولكن `ProfileScreen` لن تكون جزءاً من شجرة الويدجت (widget tree) في نفس الوقت (ما لم يتم تعريفها بشكل خاص لتكون كذلك).

### 5.2. `ShellRoute`: واجهات المستخدم المشتركة (Shared UI, مثل `BottomNavigationBar`)

`ShellRoute` هي أداة قوية لإنشاء واجهات مستخدم مشتركة (مثل شريط التنقل السفلي `BottomNavigationBar`، شريط التطبيق `AppBar`، أو قائمة جانبية `Drawer`) التي تظل مرئية أثناء التنقل بين المسارات الفرعية. كل مسار فرعي داخل `ShellRoute` يتم عرضه داخل 
الـ `ShellRoute`، مما يسمح بمشاركة عناصر واجهة المستخدم.

**مثال:** استخدام `ShellRoute` مع `BottomNavigationBar`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// شاشات وهمية
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الرئيسية')), body: Center(child: Text('الشاشة الرئيسية')));}
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الإعدادات')), body: Center(child: Text('شاشة الإعدادات')));}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الملف الشخصي')), body: Center(child: Text('شاشة الملف الشخصي')));}

// مفتاح Navigator الخاص بـ ShellRoute
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter routerWithShell = GoRouter(
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey, // ربط ShellRoute بمفتاح Navigator الخاص به
      builder: (context, state, child) {
        // هذا الـ builder سيحتوي على واجهة المستخدم المشتركة (مثل BottomNavigationBar)
        return Scaffold(
          body: child, // هنا يتم عرض الويدجت الخاص بالمسار الفرعي الحالي
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(context), // دالة لحساب الفهرس الحالي
            onTap: (index) => _onItemTapped(context, index), // دالة للتنقل عند النقر
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف الشخصي'),
            ],
          ),
        );
      },
      routes: [
        // المسارات الفرعية التي ستعرض داخل ShellRoute
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // يمكن إضافة مسارات تفتح فوق ShellRoute بالكامل هنا (مثل شاشة تسجيل الدخول)
    GoRoute(
      path: '/login',
      builder: (context, state) => const Text('شاشة تسجيل الدخول'),
    ),
  ],
);

// دالة مساعدة لحساب الفهرس المحدد لـ BottomNavigationBar
int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouter.of(context).location;
  if (location.startsWith('/home')) {
    return 0;
  } else if (location.startsWith('/settings')) {
    return 1;
  } else if (location.startsWith('/profile')) {
    return 2;
  }
  return 0;
}

// دالة مساعدة للتنقل عند النقر على عنصر في BottomNavigationBar
void _onItemTapped(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/home');
      break;
    case 1:
      context.go('/settings');
      break;
    case 2:
      context.go('/profile');
      break;
  }
}
```

**ملاحظات هامة حول `ShellRoute`:**
*   **`navigatorKey`:** يجب توفير `GlobalKey<NavigatorState>` لـ `ShellRoute`. هذا المفتاح يربط `ShellRoute` بـ `Navigator` الخاص به، والذي سيتم استخدامه لدفع المسارات الفرعية. هذا يسمح لـ `ShellRoute` بإدارة مكدس التنقل الخاص به بشكل مستقل عن `Navigator` الجذري.
*   **`builder`:** يستقبل هذا الـ `builder` ثلاثة معاملات: `context`، `state`، و `child`. الـ `child` هو الويدجت الخاص بالمسار الفرعي الحالي الذي يجب عرضه داخل واجهة المستخدم المشتركة.
*   **التنقل داخل `ShellRoute`:** عند التنقل بين المسارات الفرعية لـ `ShellRoute` (مثل التبديل بين علامات تبويب `BottomNavigationBar`)، يجب استخدام `context.go()` أو `context.goNamed()` للحفاظ على حالة التنقل لكل فرع. استخدام `context.push()` سيدفع مساراً جديداً فوق المسار الحالي داخل الفرع، مما قد لا يكون السلوك المطلوب عند التبديل بين علامات التبويب الرئيسية.

### 5.3. `StatefulShellRoute`: الحفاظ على حالة التبويبات (Tabs) وتجربة المستخدم السلسة

بينما `ShellRoute` مفيد لواجهات المستخدم المشتركة، فإنه لا يحافظ على حالة `Navigator`s الداخلية لكل فرع بشكل افتراضي عند التبديل بينها. هذا يعني أنه إذا انتقلت إلى علامة تبويب، ثم انتقلت إلى شاشة داخل تلك العلامة، ثم بدلت إلى علامة تبويب أخرى وعدت، فستفقد الشاشة الداخلية وتعود إلى المسار الجذري لتلك العلامة.

هنا يأتي دور **`StatefulShellRoute`**. تم تقديم `StatefulShellRoute` في `go_router` لإصدار 6.0.0 وما بعده، وهو مصمم خصيصاً للحفاظ على حالة `Navigator`s الداخلية لكل فرع (branch) عند التبديل بينها، مما يجعله مثالياً لسيناريوهات مثل `BottomNavigationBar` أو `IndexedStack`.

**كيف يعمل `StatefulShellRoute`؟**

`StatefulShellRoute` يستخدم `IndexedStack` داخلياً للحفاظ على حالة كل فرع. عندما تنتقل بين الفروع، لا يتم إزالة الويدجت من شجرة الويدجت، بل يتم إخفاؤه فقط، مما يحافظ على حالته.

**مثال:** استخدام `StatefulShellRoute` مع `BottomNavigationBar`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// شاشات وهمية
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الرئيسية')), body: Center(child: Column(children: [const Text('الشاشة الرئيسية'), ElevatedButton(onPressed: () => context.go('/home/details'), child: const Text('تفاصيل الرئيسية'))])));}
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الإعدادات')), body: Center(child: Column(children: [const Text('شاشة الإعدادات'), ElevatedButton(onPressed: () => context.go('/settings/privacy'), child: const Text('الخصوصية'))])));}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الملف الشخصي')), body: Center(child: Text('شاشة الملف الشخصي')));}
class HomeDetailsScreen extends StatelessWidget {
  const HomeDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تفاصيل الرئيسية')), body: Center(child: Text('شاشة تفاصيل الرئيسية')));}
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الخصوصية')), body: Center(child: Text('شاشة الخصوصية')));}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter statefulRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // هذا الـ builder سيحتوي على واجهة المستخدم المشتركة (مثل BottomNavigationBar)
        return Scaffold(
          body: navigationShell, // هنا يتم عرض StatefulNavigationShell
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              // التبديل بين الفروع مع الحفاظ على الحالة
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف الشخصي'),
            ],
          ),
        );
      },
      branches: [
        // الفرع الأول: الرئيسية
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'details',
                  builder: (context, state) => const HomeDetailsScreen(),
                ),
              ],
            ),
          ],
        ),
        // الفرع الثاني: الإعدادات
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'privacy',
                  builder: (context, state) => const PrivacyScreen(),
                ),
              ],
            ),
          ],
        ),
        // الفرع الثالث: الملف الشخصي
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // مسارات تفتح فوق StatefulShellRoute بالكامل (مثل شاشة تسجيل الدخول)
    GoRoute(
      path: '/login',
      builder: (context, state) => const Text('شاشة تسجيل الدخول'),
      parentNavigatorKey: _rootNavigatorKey, // يدفع إلى Navigator الجذري
    ),
  ],
);
```

**شرح مكونات `StatefulShellRoute`:**
*   **`StatefulShellRoute.indexedStack`:** هو المُنشئ الموصى به لـ `StatefulShellRoute`، والذي يستخدم `IndexedStack` للحفاظ على حالة الفروع.
*   **`builder`:** يستقبل `context`، `state`، و `navigationShell` (وهو كائن `StatefulNavigationShell`). الـ `navigationShell` هو الويدجت الذي يجب عرضه في المكان الذي تريد أن تظهر فيه محتويات الفروع.
*   **`branches`:** قائمة من `StatefulShellBranch`s، يمثل كل منها فرعاً مستقلاً (مثل علامة تبويب). كل `StatefulShellBranch` يحتوي على قائمة `routes` خاصة به.
*   **`navigationShell.currentIndex`:** يوفر الفهرس الحالي للفرع النشط.
*   **`navigationShell.goBranch(index, {initialLocation})`:** هذه الدالة هي الطريقة الصحيحة للتبديل بين الفروع في `StatefulShellRoute`. المعامل `initialLocation` (افتراضياً `false`) يحدد ما إذا كان يجب إعادة تعيين الفرع إلى موقعه الأولي عند التبديل إليه.

**متى تستخدم `StatefulShellRoute`؟**
*   عندما يكون لديك واجهة مستخدم ذات علامات تبويب (مثل `BottomNavigationBar`) وتريد الحفاظ على حالة التنقل لكل علامة تبويب عند التبديل بينها.
*   عندما تحتاج إلى `Navigator`s مستقلة لكل قسم من تطبيقك، مع الاحتفاظ بحالتها.

---

## 6. التحكم في تدفق التنقل

يعد التحكم في كيفية وصول المستخدمين إلى المسارات المختلفة أمراً بالغ الأهمية للأمان وتجربة المستخدم. يوفر `go_router` آليات قوية مثل `redirect` و `onExit` و `errorBuilder` لإدارة تدفق التنقل.

### 6.1. إعادة التوجيه (`redirect`): الحماية والمصادقة ومنطق التحكم في الوصول

تعد دالة `redirect` في `GoRouter` أداة قوية لتنفيذ منطق Middleware أو Guards. يمكنها اعتراض أي محاولة تنقل وتغيير الوجهة بناءً على شروط معينة. يمكن استخدامها لسيناريوهات تتجاوز مجرد المصادقة، مثل التحقق من الأدوار، أو قبول شروط الخدمة، أو إكمال ملف التعريف.

يمكن تعريف دالة `redirect` على مستوى `GoRouter` بالكامل، أو على مستوى `GoRoute` فردي.

#### إعادة التوجيه على مستوى الراوتر (Global Redirect)

تُطبق دالة `redirect` المعرفة في مُنشئ `GoRouter` على جميع المسارات في التطبيق. هذا مثالي لسيناريوهات المصادقة والتخويل العامة.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // مثال على استخدام Provider لإدارة حالة المصادقة

// خدمة مصادقة وهمية
class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

// شاشات وهمية
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تسجيل الدخول')), body: Center(child: ElevatedButton(onPressed: () => context.read<AuthService>().login(), child: const Text('تسجيل الدخول'))));}
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الرئيسية')), body: Center(child: ElevatedButton(onPressed: () => context.read<AuthService>().logout(), child: const Text('تسجيل الخروج'))));}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الملف الشخصي')), body: Center(child: Text('شاشة الملف الشخصي')));}

final GoRouter authRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
  ],
  redirect: (context, state) {
    final authService = context.read<AuthService>();
    final isLoggedIn = authService.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';

    // إذا لم يكن مسجلاً الدخول ويحاول الوصول إلى أي صفحة غير تسجيل الدخول
    if (!isLoggedIn && !isLoggingIn) {
      return '/login'; // إعادة التوجيه إلى صفحة تسجيل الدخول
    }

    // إذا كان مسجلاً الدخول ويحاول الوصول إلى صفحة تسجيل الدخول
    if (isLoggedIn && isLoggingIn) {
      return '/'; // إعادة التوجيه إلى الصفحة الرئيسية
    }

    return null; // لا يوجد إعادة توجيه
  },
  refreshListenable: AuthService(), // يجب أن يكون AuthService متاحاً عبر Provider أو ما شابه
);
```

**شرح دالة `redirect`:**
*   تستقبل `BuildContext` و `GoRouterState`.
*   يجب أن تُرجع `null` إذا لم يكن هناك حاجة لإعادة التوجيه.
*   يجب أن تُرجع سلسلة (string) تمثل المسار الجديد إذا كان هناك حاجة لإعادة التوجيه.
*   يمكنها الوصول إلى حالة التطبيق (مثل حالة المصادقة) لاتخاذ قرارات إعادة التوجيه.

#### إعادة التوجيه على مستوى المسار (Route-Level Redirect)

يمكنك أيضاً تعريف دالة `redirect` داخل `GoRoute` فردي. هذا مفيد لتطبيق منطق إعادة توجيه خاص بمسار معين أو مجموعة من المسارات الفرعية.

```dart
GoRoute(
  path: '/admin',
  redirect: (context, state) {
    final authService = context.read<AuthService>();
    if (!authService.isAdmin) {
      return '/'; // إعادة التوجيه إلى الصفحة الرئيسية إذا لم يكن مسؤولاً
    }
    return null;
  },
  builder: (context, state) => const AdminDashboardScreen(),
  routes: [
    GoRoute(
      path: 'users',
      builder: (context, state) => const AdminUsersScreen(),
    ),
  ],
),
```

في هذا المثال، أي محاولة للوصول إلى `/admin` أو `/admin/users` ستؤدي إلى التحقق مما إذا كان المستخدم مسؤولاً. إذا لم يكن كذلك، فسيتم إعادة توجيهه إلى الصفحة الرئيسية.

### 6.2. حراس الخروج (`onExit`): تأكيد المغادرة ومنع فقدان البيانات

تُستخدم دالة `onExit` في `GoRoute` لتنفيذ منطق معين عندما يحاول المستخدم مغادرة مسار معين. هذا مفيد لسيناريوهات مثل:
*   تأكيد حفظ التغييرات في نموذج قبل المغادرة.
*   تنظيف الموارد أو إلغاء الاشتراكات.

```dart
GoRoute(
  path: '/edit-profile',
  builder: (context, state) => EditProfileScreen(),
  onExit: (context) async {
    // عرض مربع حوار للتأكيد قبل المغادرة
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد المغادرة'),
        content: const Text('هل أنت متأكد من مغادرة الصفحة؟ قد تفقد التغييرات غير المحفوظة.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('مغادرة')),
        ],
      ),
    );
    return confirmed ?? false; // إذا لم يتم التأكيد، يتم إلغاء عملية الخروج
  },
),
```

**ملاحظات هامة حول `onExit`:**
*   يجب أن تكون دالة `async` وتُرجع `Future<bool>`.
*   إذا أرجعت `true`، فسيتم السماح بالمغادرة.
*   إذا أرجعت `false`، فسيتم إلغاء عملية المغادرة وسيظل المستخدم في المسار الحالي.

### 6.3. التعامل مع الأخطاء وصفحات 404 (`errorBuilder`): تجربة مستخدم سلسة

عندما لا يتمكن `go_router` من مطابقة مسار معين (على سبيل المثال، المستخدم يدخل URL غير صالح)، فإنه سيستخدم `errorBuilder` لعرض شاشة خطأ مخصصة. هذا يضمن تجربة مستخدم سلسة حتى في حالة وجود أخطاء في التنقل.

يمكن تعريف `errorBuilder` في مُنشئ `GoRouter`.

```dart
final GoRouter errorHandlingRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/products', builder: (context, state) => const Text('قائمة المنتجات')),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('خطأ')), 
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'عذراً، الصفحة غير موجودة (404)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('المسار الذي حاولت الوصول إليه: ${state.uri.toString()}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/'), // العودة إلى الصفحة الرئيسية
            child: const Text('العودة إلى الرئيسية'),
          ),
        ],
      ),
    ),
  ),
);
```

**ملاحظات هامة حول `errorBuilder`:**
*   يستقبل `BuildContext` و `GoRouterState`. كائن `state` سيحتوي على معلومات حول الخطأ، بما في ذلك `state.error` (الاستثناء الذي تسبب في الخطأ) و `state.uri` (المسار الذي لم يتم العثور عليه).
*   يمكنك تخصيص شاشة الخطأ بالكامل لتتناسب مع تصميم تطبيقك.

#### التعامل مع أخطاء تحليل المسار (Route Parsing Errors)

بالإضافة إلى الأخطاء 404 (المسار غير الموجود)، قد تحدث أخطاء أثناء تحليل المسار إذا كانت المعاملات غير صالحة أو مفقودة. يمكن لـ `errorBuilder` التعامل مع هذه الحالات أيضاً.

```dart
final GoRouter parsingErrorRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || int.tryParse(id) == null) {
          // يمكن رمي استثناء هنا أو إعادة توجيه إلى صفحة خطأ محددة
          // go_router سيلتقط هذا الاستثناء ويعرض errorBuilder
          throw Exception('معرف المنتج غير صالح');
        }
        return ProductScreen(productId: int.parse(id));
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('خطأ في البيانات')), 
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'عذراً، حدث خطأ في معالجة طلبك.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('الخطأ: ${state.error.toString()}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('العودة إلى الرئيسية'),
          ),
        ],
      ),
    ),
  ),
);

class ProductScreen extends StatelessWidget {
  final int productId;
  const ProductScreen({super.key, required this.productId});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('المنتج $productId')), body: Center(child: Text('شاشة المنتج: $productId')));}
```

في هذا المثال، إذا كان `id` غير رقمي، فسيتم رمي استثناء، وسيتم التقاطه بواسطة `errorBuilder` لعرض شاشة خطأ مخصصة توضح المشكلة.

---

## 7. التكامل مع الويب والروابط العميقة (Deep Linking)

تعد الروابط العميقة (Deep Linking) ميزة أساسية في التطبيقات الحديثة، حيث تسمح للمستخدمين بالانتقال مباشرة إلى محتوى معين داخل التطبيق من خلال رابط URL. `go_router` مصمم لدعم الروابط العميقة وتطبيقات الويب بشكل طبيعي وفعال.

### 7.1. مبادئ التنقل في الويب

في تطبيقات الويب، يتم استخدام URL لتحديد الموقع الحالي في التطبيق. `go_router` يستفيد من هذا المفهوم، حيث يتم تمثيل كل مسار في التطبيق بواسطة URL فريد. هذا يسمح بـ:
*   **المشاركة (Sharing):** يمكن للمستخدمين مشاركة روابط مباشرة إلى صفحات معينة في تطبيقك.
*   **الإشارة المرجعية (Bookmarking):** يمكن للمستخدمين حفظ روابط لصفحات معينة والعودة إليها لاحقاً.
*   **تحسين محركات البحث (SEO):** يمكن لمحركات البحث فهرسة صفحات تطبيق الويب الخاص بك إذا كانت تحتوي على روابط فريدة.

`go_router` يتعامل تلقائياً مع تحليل URL من المتصفح ومطابقته مع المسارات المعرفة في تطبيقك. لا يتطلب إعداداً خاصاً للتنقل الأساسي في الويب، ولكن الروابط العميقة على الأجهزة المحمولة تتطلب بعض التكوينات الخاصة بالمنصة.

### 7.2. إعداد الروابط العميقة لنظام Android

لتمكين الروابط العميقة في تطبيق Flutter على Android، تحتاج إلى تعديل ملف `AndroidManifest.xml` لإخبار نظام التشغيل بالروابط التي يمكن لتطبيقك التعامل معها.

1.  **افتح ملف `AndroidManifest.xml`:**
    ستجده في `android/app/src/main/AndroidManifest.xml`.

2.  **أضف `intent-filter` داخل علامة `<activity>`:**
    ابحث عن علامة `<activity>` التي تحتوي على `android:name=

".MainActivity` وأضف `intent-filter` التالي:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">

    <!-- ... محتوى آخر ... -->

    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- هنا تحدد مخطط URL الخاص بك (scheme) والمضيف (host) -->
        <!-- مثال: myapp://products/123 -->
        <data android:scheme="myapp" android:host="products" />
        <!-- يمكنك إضافة المزيد من عناصر <data> لأنماط مختلفة -->
        <!-- مثال: https://www.yourdomain.com/products -->
        <data android:scheme="https" android:host="www.yourdomain.com" android:pathPrefix="/products" />
    </intent-filter>
</activity>
```

**شرح:**
*   `<action android:name="android.intent.action.VIEW" />`: يحدد أن هذا الـ `intent-filter` يمكنه التعامل مع إجراءات عرض البيانات.
*   `<category android:name="android.intent.category.DEFAULT" />`: يسمح للـ `intent` بتلقي `implicit intents`.
*   `<category android:name="android.intent.category.BROWSABLE" />`: يسمح للرابط بالفتح من متصفح الويب.
*   `<data android:scheme="myapp" android:host="products" />`: هذا هو الجزء الأهم. يحدد أن تطبيقك يمكنه التعامل مع الروابط التي تبدأ بـ `myapp://products`. على سبيل المثال، إذا نقر المستخدم على رابط `myapp://products/123`، فسيتم فتح تطبيقك وسيتم تمرير هذا الرابط إلى `go_router`.
*   يمكنك أيضاً تحديد `scheme="https"` و `host="www.yourdomain.com"` للتعامل مع روابط الويب العادية كروابط عميقة (App Links).

3.  **التحقق من الروابط العميقة (اختياري، ولكن موصى به):**
    بعد تعديل `AndroidManifest.xml`، يمكنك اختبار الروابط العميقة باستخدام الأمر `adb`:
    ```bash
    adb shell am start -W -a android.intent.action.VIEW -d "myapp://products/456"
    ```
    أو لروابط الويب:
    ```bash
    adb shell am start -W -a android.intent.action.VIEW -d "https://www.yourdomain.com/products/789"
    ```

### 7.3. إعداد الروابط العميقة لنظام iOS

لتمكين الروابط العميقة في تطبيق Flutter على iOS، تحتاج إلى تعديل ملف `Info.plist` وإعداد `Associated Domains`.

1.  **افتح ملف `Info.plist`:**
    ستجده في `ios/Runner/Info.plist`.

2.  **أضف `CFBundleURLTypes`:**
    أضف الكود التالي داخل علامة `<dict>` الرئيسية:

    ```xml
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.yourcompany.yourapp</string> <!-- استبدل بمعرف الحزمة الخاص بك -->
            <key>CFBundleURLSchemes</key>
            <array>
                <string>myapp</string> <!-- نفس المخطط الذي استخدمته في Android -->
            </array>
        </dict>
    </array>
    ```
    هذا يخبر iOS أن تطبيقك يمكنه التعامل مع الروابط التي تبدأ بـ `myapp://`.

3.  **إعداد `Associated Domains` (لروابط الويب العالمية - Universal Links):**
    إذا كنت تريد أن يتعامل تطبيقك مع روابط الويب العادية (مثل `https://www.yourdomain.com/products`) كروابط عميقة، فأنت بحاجة إلى إعداد `Associated Domains`.

    *   **في Xcode:**
        *   افتح مشروع Flutter الخاص بك في Xcode (`ios/Runner.xcworkspace`).
        *   حدد `Runner` في شريط التنقل الأيسر، ثم انتقل إلى علامة التبويب `Signing & Capabilities`.
        *   انقر على `+ Capability` وأضف `Associated Domains`.
        *   أضف نطاقاتك في التنسيق `applinks:yourdomain.com`. على سبيل المثال: `applinks:www.yourdomain.com`.

    *   **ملف `apple-app-site-association`:**
        *   يجب عليك استضافة ملف JSON يسمى `apple-app-site-association` على جذر نطاقك (أو في مجلد `.well-known`).
        *   يجب أن يكون هذا الملف متاحاً عبر HTTPS ولا يحتوي على امتداد `.json`.
        *   مثال لمحتوى الملف:
            ```json
            {
                "applinks": {
                    "apps": [],
                    "details": [
                        {
                            "appID": "YOUR_TEAM_ID.com.yourcompany.yourapp",
                            "paths": [ "/products/*", "/profile/*", "*" ]
                        }
                    ]
                }
            }
            ```
            *   استبدل `YOUR_TEAM_ID` بمعرف فريق Apple Developer الخاص بك.
            *   استبدل `com.yourcompany.yourapp` بمعرف الحزمة (Bundle ID) لتطبيقك.
            *   `paths`: تحدد المسارات التي يجب أن يتعامل معها تطبيقك. `*` يعني جميع المسارات.

4.  **التحقق من الروابط العميقة:**
    بعد إعداد `Info.plist` و `Associated Domains`، يمكنك اختبار الروابط العميقة عن طريق إرسال رابط إلى جهاز iOS الخاص بك (عبر البريد الإلكتروني، الرسائل، أو الملاحظات) والنقر عليه.

### 7.4. التعامل مع الروابط العميقة في GoRouter

بمجرد تكوين الروابط العميقة على مستوى المنصة (Android/iOS)، سيتعامل `go_router` تلقائياً مع تحليل الروابط الواردة ومطابقتها مع المسارات المعرفة في `GoRouter` الخاص بك. لا تحتاج إلى كود إضافي في Flutter للتعامل مع الروابط العميقة نفسها، فقط تأكد من أن المسارات في `GoRouter` تتطابق مع أنماط الروابط العميقة التي قمت بتكوينها.

**مثال:** إذا كان لديك رابط عميق `myapp://products/123`، وكنت قد عرفت مساراً في `go_router` كـ `/products/:id`، فسيتم توجيه المستخدم مباشرة إلى `ProductDetailsScreen` مع `productId` الصحيح.

---

## 8. إدارة الحالة (State Management) مع GoRouter

على الرغم من أن `go_router` يركز بشكل أساسي على التنقل، إلا أنه يتكامل بسلاسة مع حلول إدارة الحالة الشائعة في Flutter. هذا التكامل ضروري لسيناريوهات مثل إعادة التوجيه بناءً على حالة المصادقة، أو تحديث واجهة المستخدم بناءً على التغييرات في الحالة، أو تمرير البيانات المعقدة.

### 8.1. التفاعل مع `refreshListenable`

خاصية `refreshListenable` في مُنشئ `GoRouter` تسمح لك بتوفير كائن `Listenable` (مثل `ChangeNotifier` أو `Stream`) الذي سيؤدي إلى إعادة تقييم منطق إعادة التوجيه (دالة `redirect`) عند حدوث تغيير. هذا أمر بالغ الأهمية لسيناريوهات مثل حماية المسارات بناءً على حالة المصادقة.

**مثال:** استخدام `ChangeNotifier` مع `refreshListenable`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners(); // إعلام المستمعين بالتغيير
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

final AuthNotifier authNotifier = AuthNotifier();

final GoRouter authRefreshRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية (مطلوب تسجيل الدخول)')),
    GoRoute(path: '/login', builder: (context, state) => const Text('صفحة تسجيل الدخول')),
  ],
  redirect: (context, state) {
    final isLoggedIn = authNotifier.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }
    return null;
  },
  refreshListenable: authNotifier, // هنا يتم ربط AuthNotifier بالراوتر
);

// في MyApp:
// MaterialApp.router(
//   routerConfig: authRefreshRouter,
//   // ...
// );
```

عندما يتم استدعاء `notifyListeners()` في `AuthNotifier` (بعد تسجيل الدخول أو الخروج)، سيتم إعادة تقييم دالة `redirect` في `authRefreshRouter`، مما يضمن توجيه المستخدم إلى المسار الصحيح بناءً على حالة المصادقة الجديدة.

### 8.2. دمج `GoRouter` مع `Provider`

`Provider` هو حل بسيط لإدارة الحالة يعتمد على `InheritedWidget`. يمكن استخدامه بسهولة مع `go_router` لتوفير حالة المصادقة أو أي حالة أخرى يحتاجها الراوتر.

**مثال:** استخدام `Provider` مع `refreshListenable`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// AuthNotifier كما هو معرف أعلاه

// في main.dart أو أعلى شجرة الويدجت:
void main() {
  runApp(
    ChangeNotifierProvider( // توفير AuthNotifier عبر Provider
      create: (_) => AuthNotifier(),
      child: const MyAppWithProvider(),
    ),
  );
}

class MyAppWithProvider extends StatelessWidget {
  const MyAppWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();

    final GoRouter router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية (مطلوب تسجيل الدخول)')),
        GoRoute(path: '/login', builder: (context, state) => const Text('صفحة تسجيل الدخول')),
      ],
      redirect: (context, state) {
        final isLoggedIn = authNotifier.isLoggedIn;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }
        if (isLoggedIn && isLoggingIn) {
          return '/';
        }
        return null;
      },
      refreshListenable: authNotifier, // ربط AuthNotifier بالراوتر
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter GoRouter with Provider',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
```

### 8.3. دمج `GoRouter` مع `Bloc/Cubit`

`Bloc` هو حل شائع لإدارة الحالة يفصل منطق الأعمال عن واجهة المستخدم. يمكن استخدامه مع `go_router` لإدارة حالة المصادقة والتحكم في التنقل بشكل فعال.

**مثال:** إعادة التوجيه بناءً على حالة المصادقة في `Bloc`.

1.  **`AuthBloc` (أو `AuthCubit`):**
    ```dart
    // auth_state.dart
    import 'package:equatable/equatable.dart';

    enum AuthStatus { unknown, authenticated, unauthenticated }

    class AuthState extends Equatable {
      final AuthStatus status;
      final String? userId;

      const AuthState._({this.status = AuthStatus.unknown, this.userId});

      const AuthState.unknown() : this._();
      const AuthState.authenticated(String userId) : this._(status: AuthStatus.authenticated, userId: userId);
      const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

      @override
      List<Object?> get props => [status, userId];
    }

    // auth_cubit.dart (مثال بسيط باستخدام Cubit)
    import 'package:flutter_bloc/flutter_bloc.dart';
    import 'auth_state.dart';

    class AuthCubit extends Cubit<AuthState> {
      AuthCubit() : super(const AuthState.unknown());

      Future<void> login(String username, String password) async {
        emit(const AuthState.unknown()); // حالة تحميل
        await Future.delayed(const Duration(seconds: 1)); // محاكاة API call
        emit(const AuthState.authenticated('user123'));
      }

      void logout() {
        emit(const AuthState.unauthenticated());
      }
    }
    ```

2.  **تكوين `GoRouter` مع `refreshListenable`:**
    لربط `GoRouter` بـ `Bloc` أو `Cubit`، يمكنك استخدام `GoRouterRefreshStream` الذي يحول `Stream` (مثل `Bloc` أو `Cubit` `stream`) إلى `Listenable`.

    ```dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'package:flutter_bloc/flutter_bloc.dart';
    import 'auth_cubit.dart';
    import 'auth_state.dart';

    // فئة مساعدة لتحويل Stream إلى Listenable
    class GoRouterRefreshStream extends ChangeNotifier {
      GoRouterRefreshStream(Stream<dynamic> stream) {
        notifyListeners();
        _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
      }

      late final StreamSubscription<dynamic> _subscription;

      @override
      void dispose() {
        _subscription.cancel();
        super.dispose();
      }
    }

    // في main.dart أو أعلى شجرة الويدجت:
    void main() {
      runApp(
        BlocProvider( // توفير AuthCubit عبر BlocProvider
          create: (_) => AuthCubit(),
          child: const MyAppWithBloc(),
        ),
      );
    }

    class MyAppWithBloc extends StatelessWidget {
      const MyAppWithBloc({super.key});

      @override
      Widget build(BuildContext context) {
        final GoRouter router = GoRouter(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية (مطلوب تسجيل الدخول)')),
            GoRoute(path: '/login', builder: (context, state) => const Text('صفحة تسجيل الدخول')),
          ],
          redirect: (context, state) {
            final authState = context.read<AuthCubit>().state;
            final isLoggedIn = authState.status == AuthStatus.authenticated;
            final isLoggingIn = state.matchedLocation == '/login';

            if (!isLoggedIn && !isLoggingIn) {
              return '/login';
            }
            if (isLoggedIn && isLoggingIn) {
              return '/';
            }
            return null;
          },
          refreshListenable: GoRouterRefreshStream(context.read<AuthCubit>().stream), // ربط Cubit stream بالراوتر
        );

        return MaterialApp.router(
          routerConfig: router,
          title: 'Flutter GoRouter with Bloc',
          theme: ThemeData(primarySwatch: Colors.blue),
        );
      }
    }
    ```
    *   عندما يصدر `AuthCubit` حالة جديدة، سيتم تشغيل دالة `redirect` مرة أخرى، مما يضمن أن المستخدم يتم توجيهه إلى المسار الصحيح بناءً على حالة المصادقة الجديدة.

### 8.4. دمج `GoRouter` مع `Riverpod`

`Riverpod` هو حل حديث لإدارة الحالة يوفر مرونة وأماناً أكبر من `Provider`. التكامل مع `go_router` بسيط وفعال، وغالباً ما لا يتطلب `refreshListenable` بشكل مباشر إذا تم تكوين الراوتر بشكل صحيح.

**مثال:** إعادة التوجيه باستخدام `StateNotifierProvider`.

1.  **`AuthNotifier` و `Provider`:**
    ```dart
    // auth_provider.dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'auth_state.dart'; // استخدم نفس AuthState من مثال Bloc

    final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
      return AuthNotifier();
    });

    class AuthNotifier extends StateNotifier<AuthState> {
      AuthNotifier() : super(const AuthState.unauthenticated());

      Future<void> login(String username, String password) async {
        state = const AuthState.unknown();
        await Future.delayed(const Duration(seconds: 1));
        state = const AuthState.authenticated('user123');
      }

      void logout() {
        state = const AuthState.unauthenticated();
      }
    }
    ```

2.  **تكوين `GoRouter`:**
    في `Riverpod`، يمكنك جعل `GoRouter` نفسه `Provider`، مما يسمح له بإعادة البناء تلقائياً عند تغيير حالة المصادقة التي يعتمد عليها.

    ```dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'auth_provider.dart';
    import 'auth_state.dart';

    final routerProvider = Provider<GoRouter>((ref) {
      final authState = ref.watch(authStateProvider); // مراقبة حالة المصادقة

      return GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية (مطلوب تسجيل الدخول)')),
          GoRoute(path: '/login', builder: (context, state) => const Text('صفحة تسجيل الدخول')),
        ],
        redirect: (context, state) {
          final isLoggedIn = authState.status == AuthStatus.authenticated;
          final isLoggingIn = state.matchedLocation == '/login';

          if (!isLoggedIn && !isLoggingIn) {
            return '/login';
          }
          if (isLoggedIn && isLoggingIn) {
            return '/';
          }
          return null;
        },
      );
    });

    // في main.dart:
    void main() {
      runApp(
        const ProviderScope( // يجب أن يكون التطبيق مغلفاً بـ ProviderScope
          child: MyAppWithRiverpod(),
        ),
      );
    }

    class MyAppWithRiverpod extends ConsumerWidget {
      const MyAppWithRiverpod({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final router = ref.watch(routerProvider); // قراءة الراوتر من Provider

        return MaterialApp.router(
          routerConfig: router,
          title: 'Flutter GoRouter with Riverpod',
          theme: ThemeData(primarySwatch: Colors.blue),
        );
      }
    }
    ```
    *   `ref.watch(authStateProvider)` سيؤدي إلى إعادة بناء `GoRouter` (وبالتالي إعادة تقييم `redirect`) كلما تغيرت حالة المصادقة.

---

## 9. ميزات متقدمة وأفضل الممارسات

يستمر `go_router` في تقديم ميزات قوية لسيناريوهات التنقل المعقدة، بالإضافة إلى أفضل الممارسات التي تضمن تطبيقات قابلة للتطوير والصيانة.

### 9.1. تحسين الأداء: التحميل الكسول (Lazy Loading) والتخزين المؤقت (Caching)

في التطبيقات الكبيرة، يمكن أن يؤثر تحميل جميع المسارات والويدجت المرتبطة بها مقدماً على وقت بدء التشغيل واستهلاك الذاكرة. يوفر `go_router` تقنيات لتحسين الأداء، مثل التحميل الكسول (lazy loading).

#### التحميل الكسول للمسارات (Lazy Loading Routes)

التحميل الكسول يعني تأجيل تحميل كود المسار والويدجت المرتبط به حتى يتم طلبه بالفعل. يمكن تحقيق ذلك باستخدام `deferred as` في Dart.

1.  **إنشاء ملفات منفصلة للمسارات:**
    ضع كل شاشة (أو مجموعة من الشاشات ذات الصلة) في ملف Dart منفصل.

2.  **استخدام `deferred as`:**
    في ملف تكوين الراوتر الرئيسي، استورد هذه الملفات باستخدام `deferred as`.

    ```dart
    // router_config.dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';

    // استيراد الشاشات بـ deferred as
    import 'package:your_app/screens/home_screen.dart' deferred as home_screen;
    import 'package:your_app/screens/settings_screen.dart' deferred as settings_screen;

    final GoRouter lazyLoadingRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => FutureBuilder<void>(
            future: home_screen.loadLibrary(), // تحميل المكتبة عند الطلب
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return home_screen.HomeScreen(); // بناء الويدجت بعد التحميل
              }
              return const Center(child: CircularProgressIndicator()); // عرض مؤشر تحميل
            },
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => FutureBuilder<void>(
            future: settings_screen.loadLibrary(), // تحميل المكتبة عند الطلب
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return settings_screen.SettingsScreen(); // بناء الويدجت بعد التحميل
              }
              return const Center(child: CircularProgressIndicator()); // عرض مؤشر تحميل
            },
          ),
        ),
      ],
    );
    ```
    *   `deferred as` يخبر Dart بعدم تضمين الكود من `settings_screen.dart` في ملف الإخراج الرئيسي.
    *   `settings_screen.loadLibrary()` هي دالة يتم إنشاؤها تلقائياً تقوم بتحميل الكود المؤجل عند استدعائها.
    *   يتم استخدام `FutureBuilder` لعرض مؤشر تحميل أثناء تحميل الكود، ثم بناء الويدجت بمجرد اكتمال التحميل.

**ملاحظة:** التحميل الكسول مفيد بشكل خاص في تطبيقات الويب لتقليل حجم الحزمة الأولية وتحسين وقت التحميل الأولي للصفحة.

#### التخزين المؤقت (Caching)

بينما لا يوفر `go_router` آلية تخزين مؤقت مدمجة للمسارات، يمكنك تحقيق التخزين المؤقت على مستوى البيانات أو الويدجت لتحسين الأداء وتجربة المستخدم.

*   **التخزين المؤقت للبيانات (Data Caching):**
    إذا كانت شاشاتك تعرض بيانات يتم جلبها من الشبكة، فيمكنك استخدام حلول إدارة الحالة (مثل `Bloc`, `Provider`, `Riverpod`) لتخزين هذه البيانات مؤقتاً. بهذه الطريقة، عندما يعود المستخدم إلى شاشة سبق له زيارتها، لا تحتاج إلى إعادة جلب البيانات من الخادم.

    ```dart
    // مثال باستخدام Provider (كما هو موضح في قسم إدارة الحالة)
    class ProductRepository extends ChangeNotifier {
      List<Product> _products = [];
      bool _isLoading = false;

      List<Product> get products => _products;
      bool get isLoading => _isLoading;

      Future<void> fetchProducts() async {
        if (_products.isNotEmpty && !_isLoading) return; // لا تجلب إذا كانت موجودة وغير محملة
        _isLoading = true;
        notifyListeners();

        // محاكاة جلب البيانات
        await Future.delayed(const Duration(seconds: 2));
        _products = [ /* بيانات المنتج */ ];
        _isLoading = false;
        notifyListeners();
      }
    }
    ```

*   **التخزين المؤقت للويدجت (Widget Caching):**
    في بعض الحالات، قد ترغب في الحفاظ على حالة ويدجت معين حتى عند إزالته مؤقتاً من شجرة الويدجت (widget tree). يمكن تحقيق ذلك باستخدام `AutomaticKeepAliveClientMixin` في `StatefulWidget`s التي تكون جزءاً من `PageView` أو `IndexedStack` داخل `ShellRoute` أو `StatefulShellRoute`.

    ```dart
    class MyTabScreen extends StatefulWidget {
      const MyTabScreen({super.key});

      @override
      State<MyTabScreen> createState() => _MyTabScreenState();
    }

    class _MyTabScreenState extends State<MyTabScreen> with AutomaticKeepAliveClientMixin {
      int _counter = 0;

      @override
      bool get wantKeepAlive => true; // الحفاظ على حالة الويدجت

      @override
      Widget build(BuildContext context) {
        super.build(context); // يجب استدعاء هذا في build
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Counter: $_counter'),
              ElevatedButton(
                onPressed: () => setState(() => _counter++),
                child: const Text('Increment'),
              ),
            ],
          ),
        );
      }
    }
    ```

### 9.2. الانتقالات المخصصة (`pageBuilder`): تجربة مستخدم فريدة

يتيح لك `go_router` تخصيص الرسوم المتحركة والانتقالات بين الصفحات باستخدام `pageBuilder` بدلاً من `builder` في `GoRoute`.

```dart
GoRoute(
  path: '/fade-in',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: FadeInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // يمكنك استخدام أي TransitionWidget هنا
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  },
),

class FadeInScreen extends StatelessWidget {
  const FadeInScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('شاشة التلاشي للداخل')), body: const Center(child: Text('هذه الشاشة تظهر بتأثير التلاشي للداخل')));}
```

*   **`CustomTransitionPage`:** يمنحك تحكماً كاملاً في كيفية بناء الصفحة والانتقال إليها.
*   **`transitionsBuilder`:** دالة تُرجع ويدجت انتقال (transition widget) (مثل `FadeTransition`, `SlideTransition`, `ScaleTransition`).
*   **`transitionDuration`:** يحدد مدة الرسوم المتحركة.

### 9.3. مراقبو المسار (`observers`): تتبع أحداث التنقل

يمكنك استخدام `GoRouterObserver` لمراقبة أحداث التنقل (مثل دفع المسارات، سحبها، أو استبدالها). هذا مفيد لتسجيل التحليلات (analytics)، أو تسجيل الدخول (logging)، أو تنفيذ منطق مخصص عند تغيير المسار.

1.  **إنشاء `GoRouterObserver` مخصص:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';

    class MyGoRouterObserver extends GoRouterObserver {
      @override
      void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print('New route pushed: ${route.settings.name ?? route.settings.arguments ?? route.settings.toString()}');
      }

      @override
      void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print('Route popped: ${route.settings.name ?? route.settings.arguments ?? route.settings.toString()}');
      }

      @override
      void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
        print('Route replaced: ${oldRoute?.settings.name ?? oldRoute?.settings.arguments ?? oldRoute?.settings.toString()} with ${newRoute?.settings.name ?? newRoute?.settings.arguments ?? newRoute?.settings.toString()}');
      }

      @override
      void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print('Route removed: ${route.settings.name ?? route.settings.arguments ?? route.settings.toString()}');
      }

      @override
      void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print('User gesture started on route: ${route.settings.name ?? route.settings.arguments ?? route.settings.toString()}');
      }

      @override
      void didStopUserGesture() {
        print('User gesture stopped.');
      }
    }
    ```

2.  **إضافة المراقب إلى `GoRouter`:**
    ```dart
    final GoRouter routerWithObserver = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية')),
        GoRoute(path: '/details', builder: (context, state) => const Text('التفاصيل')),
      ],
      observers: [MyGoRouterObserver()], // إضافة المراقب هنا
    );
    ```

### 9.4. أفضل ممارسات الأمان: حماية المسارات والبيانات

يعد تأمين المسارات الحساسة أمراً بالغ الأهمية، خاصة في التطبيقات التي تتعامل مع بيانات المستخدم أو لديها أقسام إدارية.

*   **استخدام `redirect` للمصادقة والتخويل:** كما هو موضح في قسم إعادة التوجيه، استخدم `redirect` لفرض قواعد المصادقة (هل المستخدم مسجل الدخول؟) والتخويل (هل لدى المستخدم الدور الصحيح؟).
*   **عدم تمرير البيانات الحساسة في URL:** تجنب وضع البيانات الحساسة (مثل الرموز المميزة (tokens) أو كلمات المرور) في معاملات المسار أو الاستعلام، حيث يمكن أن يتم تسجيلها أو تخزينها مؤقتاً. استخدم `extra` أو حلول إدارة الحالة لتمرير هذه البيانات بشكل آمن.
*   **التحقق من صحة المعاملات:** تحقق دائماً من صحة المعاملات التي تتلقاها من `GoRouterState`. لا تثق أبداً في أن البيانات ستكون بالتنسيق المتوقع. على سبيل المثال، إذا كنت تتوقع معرفاً رقمياً، فتأكد من تحليله والتعامل مع الأخطاء المحتملة.
*   **فصل منطق التوجيه:** حافظ على منطق التوجيه الخاص بك (خاصة منطق إعادة التوجيه) منفصلاً عن واجهة المستخدم قدر الإمكان. هذا يجعله أسهل في الاختبار والمراجعة بحثاً عن الثغرات الأمنية.
*   **تصفية المدخلات (Input Sanitization):** إذا كنت تستخدم معاملات المسار أو الاستعلام لعرض المحتوى مباشرة في واجهة المستخدم (خاصة في تطبيقات الويب)، فتأكد من تصفية (sanitize) هذه المدخلات لمنع هجمات البرمجة النصية عبر المواقع (XSS).
*   **التحقق من التخويل على الخادم (Server-side Authorization):** لا تعتمد فقط على منطق العميل (client-side logic) للتحكم في الوصول. يجب أن يتم التحقق من التخويل دائماً على الخادم أيضاً، حيث يمكن تجاوز منطق العميل.
*   **استخدام HTTPS:** تأكد دائماً من استخدام HTTPS لجميع الاتصالات الشبكية لتشفير البيانات المنقولة، بما في ذلك أي بيانات حساسة قد تكون جزءاً من عناوين URL.

### 9.5. اختبار منطق التنقل في `GoRouter`

يعد اختبار منطق التنقل أمراً بالغ الأهمية لضمان سلوك التطبيق الصحيح. يمكن اختبار `go_router` باستخدام اختبارات الوحدة (unit tests) واختبارات الويدجت (widget tests).

#### اختبارات الوحدة لمنطق إعادة التوجيه (Unit Tests for Redirection Logic)

يمكنك اختبار دالة `redirect` بشكل منفصل عن واجهة المستخدم.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart'; // لإصلاح خطأ BuildContext

// Mock AuthService for testing
class MockAuthService extends Mock {
  bool isLoggedIn() => false;
}

void main() {
  group('GoRouter Redirection Tests', () {
    late MockAuthService mockAuthService;
    late GoRouter router;

    setUp(() {
      mockAuthService = MockAuthService();
      // تهيئة GoRouter مع دالة redirect التي تعتمد على MockAuthService
      router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Text('Home')),
          GoRoute(path: '/login', builder: (context, state) => const Text('Login')),
          GoRoute(path: '/dashboard', builder: (context, state) => const Text('Dashboard')),
        ],
        redirect: (context, state) {
          // يجب أن يكون MockAuthService متاحاً في السياق للاختبار
          // في بيئة الاختبار، يمكننا محاكاة ذلك أو تمرير الخدمة مباشرة
          final isLoggedIn = mockAuthService.isLoggedIn();
          final isLoggingIn = state.matchedLocation == '/login';

          if (!isLoggedIn && !isLoggingIn) return '/login';
          if (isLoggedIn && isLoggingIn) return '/';
          return null;
        },
      );
    });

    test('should redirect to login if not logged in and not on login page', () {
      when(mockAuthService.isLoggedIn()).thenReturn(false);
      final GoRouterState state = GoRouterState(location: '/dashboard', subloc: '/dashboard', path: '/dashboard', pageKey: const ValueKey('dashboard'));
      // نحتاج إلى BuildContext وهمي هنا. يمكن استخدام MaterialApp لتوفير واحد.
      final String? redirectPath = router.routerDelegate.redirect(FakeBuildContext(), state);
      expect(redirectPath, '/login');
    });

    test('should redirect to home if logged in and on login page', () {
      when(mockAuthService.isLoggedIn()).thenReturn(true);
      final GoRouterState state = GoRouterState(location: '/login', subloc: '/login', path: '/login', pageKey: const ValueKey('login'));
      final String? redirectPath = router.routerDelegate.redirect(FakeBuildContext(), state);
      expect(redirectPath, '/');
    });

    test('should not redirect if logged in and on dashboard page', () {
      when(mockAuthService.isLoggedIn()).thenReturn(true);
      final GoRouterState state = GoRouterState(location: '/dashboard', subloc: '/dashboard', path: '/dashboard', pageKey: const ValueKey('dashboard'));
      final String? redirectPath = router.routerDelegate.redirect(FakeBuildContext(), state);
      expect(redirectPath, isNull);
    });
  });
}

// فئة وهمية بسيطة لـ BuildContext
class FakeBuildContext extends Fake implements BuildContext {}
```

**ملاحظة:** ستحتاج إلى إضافة حزمة `mockito` إلى `dev_dependencies` في `pubspec.yaml`.

#### اختبارات الويدجت للتنقل (Widget Tests for Navigation)

يمكنك استخدام اختبارات الويدجت لمحاكاة تفاعلات المستخدم والتحقق من أن التنقل يحدث بشكل صحيح.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('GoRouter Widget Tests', () {
    testWidgets('should navigate to detail screen when button is tapped', (tester) async {
      final _router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (innerContext) => ElevatedButton(
                  onPressed: () => innerContext.go('/detail/123'),
                  child: const Text('Go to Detail'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/detail/:id',
            builder: (context, state) => Text('Detail Screen: ${state.pathParameters['id']!}'),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: _router));

      expect(find.text('Go to Detail'), findsOneWidget);
      expect(find.text('Detail Screen: 123'), findsNothing);

      await tester.tap(find.text('Go to Detail'));
      await tester.pumpAndSettle(); // انتظر حتى تكتمل الرسوم المتحركة للتنقل

      expect(find.text('Go to Detail'), findsNothing);
      expect(find.text('Detail Screen: 123'), findsOneWidget);
    });
  });
}
```

---

## 10. مشروع عملي: تطبيق تسوق

لتوضيح كيفية استخدام `go_router` في تطبيق حقيقي، سنقوم ببناء تطبيق تسوق بسيط. سيحتوي هذا التطبيق على قائمة بالمنتجات، شاشة تفاصيل المنتج، وشاشة شراء المنتج، مع استخدام `go_router` للتنقل بينها.

### 10.1. هيكل المشروع

سنتبع هيكلاً منظماً للمشروع للحفاظ على الكود نظيفاً وقابلاً للصيانة:

```text
go_router_project/
|-- lib/
| |-- main.dart
| |-- models/
| | |-- product.dart
| |-- controller/
| | |-- product_controller.dart
| |-- config/
| | |-- route_config.dart
| |-- screens/
| | |-- product_details_screen.dart
| | |-- product_list_screen.dart
| | |-- product_purchase_screen.dart
| |-- widgets/
| | |-- bottom_container.dart
| | |-- color_container.dart
| | |-- ratings.dart
| | |-- search_section.dart
| | |-- show_modal.dart
| | |-- single_product.dart
|-- pubspec.yaml
```

### 10.2. الكود الكامل للمشروع

#### `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router_project/config/route_config.dart'; // تأكد من المسار الصحيح

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp.router(
      title: 'Flutter GoRouter Shopping App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      routerConfig: router, // استخدام الراوتر المعرف في route_config.dart
    );
  }
}
```

#### Model (`models/product.dart`)

```dart
import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final double previousPrice;
  final String colors;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.previousPrice,
    required this.price,
    required this.colors,
  });

  factory Product.initial() => Product(
        id: '',
        name: '',
        imageUrl: '',
        description: '',
        previousPrice: 0.0,
        price: 0.0,
        colors: '',
      );
}
```

#### Controller (`controller/product_controller.dart`)

```dart
import '../models/product.dart';

class ProductController {
  Product findById(String? id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<Product> get products => _products;

  final List<Product> _products = [
    Product(
      id: 'p7',
      name: 'Leather BackPack',
      imageUrl:
          'https://images.unsplash.com/photo-1571689936114-b16146c9',
      description:
          'The stronger the better it is to load it with all that t',
      price: 30.9,
      previousPrice: 40.9,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p1',
      name: 'Smart Watch',
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6b',
      description: 'A white smart watch with good features and more',
      price: 29.99,
      previousPrice: 39.99,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p16',
      name: 'PowerBook',
      imageUrl:
          'https://get.pxhere.com/photo/laptop-computer-macbook-mac',
      description:
          'Awesome hardware, crappy keyboard and a hefty price. Buy',
      price: 2299.99,
      previousPrice: 3299.99,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p2',
      name: 'Red Sneakers',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27f',
      description:
          'Perfect for your joggers and black T-shirts and more. Th',
      price: 199.99,
      previousPrice: 299.99,
      colors: 'yellow,grey,black,red,teal',
    ),
    Product(
      id: 'p3',
      name: 'Nikon Camera',
      imageUrl:
          'https://images.unsplash.com/photo-1564466809058-bf4114d5',
      description:
          'You can only see clearer with your eyes but a camera sav',
      price: 89.9,
      previousPrice: 109.9,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p4',
      name: 'HeadSets',
      imageUrl:
          'https://images.unsplash.com/photo-1583394838336-acd97773',
      description:
          'The louder the sound, the better it feels inside with th',
      price: 120.1,
      previousPrice: 150.1,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p5',
      name: 'Amazon SoundBox',
      imageUrl:
          'https://images.unsplash.com/photo-1543512214-318c7553f23',
      description:
          'Automated soundbox with voice recognition and more. What',
      price: 78.19,
      previousPrice: 88.19,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p6',
      name: 'Xbox 360 GamePads',
      imageUrl:
          'https://images.unsplash.com/photo-1600080972464-8e5f35f6',
      description:
          'You never know when it is time to touch it better except',
      price: 98.99,
      previousPrice: 108.99,
      colors: 'red,grey,black,indigo,purple',
    ),
  ];
}
```

#### Config (`config/route_config.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_project/controller/product_controller.dart';
import 'package:go_router_project/screens/product_details_screen.dart';
import 'package:go_router_project/screens/product_list_screen.dart';
import 'package:go_router_project/screens/product_purchase_screen.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const ProductListScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: ProductDetailsScreen.routeName,
          name: ProductDetailsScreen.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return ProductDetailsScreen(
              productId: state.uri.queryParameters['id'] ?? "",
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'product-purchase/:description',
              name: ProductPurchaseScreen.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return ProductPurchaseScreen(
                  productImage: state.uri.queryParameters['img']!,
                  productPrice: state.uri.queryParameters['price']!,
                  productName: state.uri.queryParameters['name']!,
                  description: state.pathParameters['description']!,
                );
              },
              onExit: (BuildContext context) async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      content: const Text('Are you sure to leave this page?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    );
                  },
                );
                return confirmed ?? false;
              },
            )
          ],
        )
      ],
    ),
  ],
);
```

#### Screens

##### `screens/product_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router_project/controller/product_controller.dart';
import 'package:go_router_project/screens/product_details_screen.dart';
import 'package:go_router_project/widgets/search_section.dart';
import 'package:go_router_project/widgets/single_product.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProductController productController = ProductController();
    TextEditingController searchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SearchSection(
              searchController: searchController,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: productController.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  Product product = productController.products[index];
                  return GestureDetector(
                    onTap: () => context.goNamed(
                      ProductDetailsScreen.routeName,
                      queryParameters: {'id': product.id},
                    ),
                    child: SingleProduct(product: product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

##### `screens/product_details_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_project/controller/product_controller.dart';
import 'package:go_router_project/models/product.dart';
import 'package:go_router_project/widgets/bottom_container.dart';
import 'package:go_router_project/widgets/color_container.dart';
import 'package:go_router_project/widgets/ratings.dart';
import 'package:go_router_project/widgets/show_modal.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = 'product-details';
  final String productId;
  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    late Color colored;
    // get color
    Color getColor(String color) {
      switch (color) {
        case 'red':
          colored = Colors.red;
          break;
        case 'purple':
          colored = Colors.purple;
          break;
        case 'grey':
          colored = Colors.grey;
          break;
        case 'black':
          colored = Colors.black;
          break;
        case 'orange':
          colored = Colors.orange;
          break;
        case 'indigo':
          colored = Colors.indigo;
          break;
        case 'yellow':
          colored = Colors.yellow;
          break;
        case 'blue':
          colored = Colors.blue;
          break;
        case 'brown':
          colored = Colors.brown;
          break;
        case 'teal':
          colored = Colors.teal;
          break;
        default:
      }
      return colored;
    }

    ProductController productController = ProductController();
    Product product = productController.findById(productId);
    List<String> availableColors = product.colors.split(',');
    // pay now
    void payNow() {
      context.goNamed(
        'pay-now',
        pathParameters: <String, String>{
          'description': product.description,
        },
        queryParameters: <String, String>{
          'img': product.imageUrl.toString(),
          'price': product.price.toString(),
          'name': product.name.toString(),
        },
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => showImageModal(context, product),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(50),
                ),
                child: Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ratings(),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toString()}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '\$${product.previousPrice.toString()}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Available in stocks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Out of stocks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Colors Available',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var color in availableColors)
                        buildContainer(
                          color,
                          getColor,
                        )
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: bottomContainer(product, payNow),
    );
  }
}
```

##### `screens/product_purchase_screen.dart`

```dart
import 'package:flutter/material.dart';

class ProductPurchaseScreen extends StatelessWidget {
  const ProductPurchaseScreen({
    super.key,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.description,
  });
  static const routeName = 'pay-now';
  final String productName;
  final String productPrice;
  final String productImage;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        child: Icon(
          Icons.check_circle,
        ),
      ),
      appBar: AppBar(
        title: const Text('Purchase Item'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(productImage),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '\$$productPrice',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Widgets

##### `widgets/bottom_container.dart`

```dart
// bottom container
import 'package:flutter/material.dart';
import '../models/product.dart';

Container bottomContainer(Product productDetails, Function payNow) {
  return Container(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18.0,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Price',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '\$${productDetails.price}',
                style: const TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              )
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.brown.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5),
                  ),
                ),
                child: const Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.white,
                      ),
                      SizedBox(width: 15),
                      Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => payNow(),
                child: Container(
                  height: 50,
                  width: 120,
                  decoration: const BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}
```

##### `widgets/ratings.dart`

```dart
import 'package:flutter/material.dart';

Widget ratings() => const Row(
      children: [
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        SizedBox(width: 20),
        Text('(3400 Reviews)')
      ],
    );
```

##### `widgets/color_container.dart`

```dart
// build container for color
import 'package:flutter/cupertino.dart';

Widget buildContainer(String color, Function getColor) {
  return Container(
    height: 5,
    width: 40,
    decoration: BoxDecoration(
      color: getColor(color),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
```

##### `widgets/search_section.dart`

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          CupertinoIcons.search,
          color: Colors.black,
        ),
        hintText: 'Enter search keyword',
        label: const Text(
          'Search Here',
        ),
        fillColor: Colors.grey.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
```

##### `widgets/show_modal.dart`

```dart
// show modal for image
import 'package:flutter/material.dart';
import '../models/product.dart';

void showImageModal(BuildContext context, Product product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                width: double.infinity,
                fit: BoxFit.cover,
                image: NetworkImage(product.imageUrl),
              ),
            ),
            Positioned(
              right: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(product.name),
                      const SizedBox(width: 5),
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),
      );
    },
  );
}
```

##### `widgets/single_product.dart`

```dart
import 'package:flutter/material.dart';
import '../models/product.dart';

class SingleProduct extends StatelessWidget {
  const SingleProduct({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
            child: Hero(
              tag: product.id,
              child: Image.network(
                product.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${product.price}'),
                Text(
                  '\$${product.previousPrice}',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
```

---

## 11. الخاتمة والمراجع

### 11.1. الخاتمة (Conclusion)

`go_router` هي أداة قوية ومرنة بشكل لا يصدق في مجموعة أدوات مطور Flutter. من خلال تبسيط تعقيدات `Navigator 2.0` وتقديم واجهة برمجة تطبيقات نظيفة وقائمة على الروابط، فإنها تمكن المطورين من بناء هياكل تنقل معقدة بسهولة وثقة. سواء كنت تبني تطبيقاً بسيطاً للهاتف المحمول، أو تطبيق ويب معقداً، أو تطبيقاً متعدد المنصات، فإن `go_router` يوفر الأساس الذي تحتاجه لإنشاء تجربة مستخدم سلسة وقابلة للصيانة.

من خلال فهم المفاهيم الأساسية مثل المسارات، وإعادة التوجيه، و `ShellRoute`، و `StatefulShellRoute`، ودمجها مع حلول إدارة الحالة القوية، يمكنك الاستفادة الكاملة من إمكانات `go_router` وتركيز جهودك على بناء ميزات رائعة بدلاً من القلق بشأن إدارة مكدس التنقل.

### 11.2. المراجع (References)

1.  [الوثائق الرسمية لـ go_router على pub.dev](https://pub.dev/packages/go_router)
2.  [مستودع go_router على GitHub](https://github.com/flutter/packages/tree/main/packages/go_router)
3.  [فيديو: تعلم GoRouter (Flutter)](https://www.youtube.com/watch?v=ny__51K9o-k)
4.  [مقال: التنقل في Flutter باستخدام GoRouter](https://codewithandrea.com/articles/flutter-navigation-gorouter-go-vs-push/)
5.  [مقال: GoRouter: التنقل في Flutter بسهولة](https://medium.com/flutter-community/gorouter-navigation-in-flutter-with-ease-a67272223a6f)
6.  [وثائق Flutter الرسمية حول استعادة الحالة](https://docs.flutter.dev/ui/navigation/deep-linking#state-restoration)
7.  [وثائق Flutter الرسمية حول الروابط العميقة في Android](https://docs.flutter.dev/platform-integration/android/deep-linking)
8.  [وثائق Flutter الرسمية حول الروابط العميقة في iOS (Universal Links)](https://docs.flutter.dev/platform-integration/ios/universal-links)

**عن المؤلف:**
أتوها أنتوني هو مهندس برمجيات محمول أول (Senior Mobile Software Engineer) ولديه سجل حافل في بناء تطبيقات قابلة للتطوير وعالية الأداء عبر منصات مختلفة، بما في ذلك Android و iOS والويب وغيرها، باستخدام Flutter بشكل أساسي، إلى جانب Kotlin و Swift، والاستفادة من الذكاء الاصطناعي.

إذا قرأت هذا القدر، اشكر المؤلف لتظهر له اهتمامك.

[قل شكراً](https://www.freecodecamp.org/news/how-to-get-started-with-go-router-in-flutter/#say-thanks)

تعلم البرمجة مجاناً. ساعد منهج freeCodeCamp مفتوح المصدر أكثر من 40,000 شخص في الحصول على وظائف كمطورين.

[ابدأ](https://www.freecodecamp.org/)

freeCodeCamp هي منظمة خيرية معفاة من الضرائب بموجب المادة 501(c)(3) (الولايات المتحدة، رقم التعريف الضريبي الفيدرالي: 82-0779546) مدعومة من المتبرعين.
لكتروني، الرسائل، أو الملاحظات) والنقر عليه.

### 7.4. التعامل مع الروابط العميقة في GoRouter

بمجرد تكوين الروابط العميقة على مستوى المنصة (Android/iOS)، سيتعامل `go_router` تلقائياً مع تحليل الروابط الواردة ومطابقتها مع المسارات المعرفة في `GoRouter` الخاص بك. لا تحتاج إلى كود إضافي في Flutter للتعامل مع الروابط العميقة نفسها، فقط تأكد من أن المسارات في `GoRouter` تتطابق مع أنماط الروابط العميقة التي قمت بتكوينها.

**مثال:** إذا كان لديك رابط عميق `myapp://products/123`، وكنت قد عرفت مساراً في `go_router` كـ `/products/:id`، فسيتم توجيه المستخدم مباشرة إلى `ProductDetailsScreen` مع `productId` الصحيح.

---

## 8. إدارة الحالة (State Management) مع GoRouter

على الرغم من أن `go_router` يركز بشكل أساسي على التنقل، إلا أنه يتكامل بسلاسة مع حلول إدارة الحالة الشائعة في Flutter. هذا التكامل ضروري لسيناريوهات مثل إعادة التوجيه بناءً على حالة المصادقة، أو تحديث واجهة المستخدم بناءً على التغييرات في الحالة، أو تمرير البيانات المعقدة.

### 8.1. التفاعل مع `refreshListenable`

خاصية `refreshListenable` في مُنشئ `GoRouter` تسمح لك بتوفير كائن `Listenable` (مثل `ChangeNotifier` أو `Stream`) الذي سيؤدي إلى إعادة تقييم منطق إعادة التوجيه (دالة `redirect`) عند حدوث تغيير. هذا أمر بالغ الأهمية لسيناريوهات مثل حماية المسارات بناءً على حالة المصادقة.

**مثال:** استخدام `ChangeNotifier` مع `refreshListenable`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners(); // إعلام المستمعين بالتغيير
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

final AuthNotifier authNotifier = AuthNotifier();

final GoRouter authRefreshRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية (مطلوب تسجيل الدخول)')),
    GoRoute(path: '/login', builder: (context, state) => const Text('صفحة تسجيل الدخول')),
  ],
  redirect: (context, state) {
    final isLoggedIn = authNotifier.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }
    return null;
  },
  refreshListenable: authNotifier, // هنا يتم ربط AuthNotifier بالراوتر
);

// في MyApp:
// MaterialApp.router(
//   routerConfig: authRefreshRouter,
//   // ...
// );
```

عندما يتم استدعاء `notifyListeners()` في `AuthNotifier` (بعد تسجيل الدخول أو الخروج)، سيتم إعادة تقييم دالة `redirect` في `authRefreshRouter`، مما يضمن توجيه المستخدم إلى المسار الصحيح بناءً على حالة المصادقة الجديدة.

### 8.2. دمج `GoRouter` مع `Provider`

`Provider` هو حل بسيط لإدارة الحالة يعتمد على `InheritedWidget`. يمكن استخدامه بسهولة مع `go_router` لتوفير حالة المصادقة أو أي حالة أخرى يحتاجها الراوتر.

**مثال:** استخدام `Provider` مع `refreshListenable`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// AuthNotifier كما هو معرف أعلاه

// في main.dart أو أعلى شجرة الويدجت:
void main() {
  runApp(
    ChangeNotifierProvider( // توفير AuthNotifier عبر Provider
      create: (_) => AuthNotifier(),
      child: const MyAppWithProvider(),
    ),
  );
}

class MyAppWithProvider extends StatelessWidget {
  const MyAppWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();

    final GoRouter router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية (مطلوب تسجيل الدخول)')),
        GoRoute(path: '/login', builder: (context, state) => const Text('صفحة تسجيل الدخول')),
      ],
      redirect: (context, state) {
        final isLoggedIn = authNotifier.isLoggedIn;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }
        if (isLoggedIn && isLoggingIn) {
          return '/';
        }
        return null;
      },
      refreshListenable: authNotifier, // ربط AuthNotifier بالراوتر
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter GoRouter with Provider',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
```

### 8.3. دمج `GoRouter` مع `Bloc/Cubit`

`Bloc` هو حل شائع لإدارة الحالة يفصل منطق الأعمال عن واجهة المستخدم. يمكن استخدامه مع `go_router` لإدارة حالة المصادقة والتحكم في التنقل بشكل فعال.

**مثال:** إعادة التوجيه بناءً على حالة المصادقة في `Bloc`.

1.  **`AuthBloc` (أو `AuthCubit`):**
    ```dart
    // auth_state.dart
    import 'package:equatable/equatable.dart';

    enum AuthStatus { unknown, authenticated, unauthenticated }

    class AuthState extends Equatable {
      final AuthStatus status;
      final String? userId;

      const AuthState._({this.status = AuthStatus.unknown, this.userId});

      const AuthState.unknown() : this._();
      const AuthState.authenticated(String userId) : this._(status: AuthStatus.authenticated, userId: userId);
      const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

      @override
      List<Object?> get props => [status, userId];
    }

    // auth_cubit.dart (مثال بسيط باستخدام Cubit)
    import 'package:flutter_bloc/flutter_bloc.dart';
    import 'auth_state.dart';

    class AuthCubit extends Cubit<AuthState> {
      AuthCubit() : super(const AuthState.unknown());

      Future<void> login(String username, String password) async {
        emit(const AuthState.unknown()); // حالة تحميل
        await Future.delayed(const Duration(seconds: 1)); // محاكاة API call
        emit(const AuthState.authenticated('user123'));
      }

      void logout() {
        emit(const AuthState.unauthenticated());
      }
    }
    ```

2.  **تكوين `GoRouter` مع `refreshListenable`:**
    لربط `GoRouter` بـ `Bloc` أو `Cubit`، يمكنك استخدام `GoRouterRefreshStream` الذي يحول `Stream` (مثل `Bloc` أو `Cubit` `stream`) إلى `Listenable`.

    ```dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'package:flutter_bloc/flutter_bloc.dart';
    import 'auth_cubit.dart';
    import 'auth_state.dart';

    // فئة مساعدة لتحويل Stream إلى Listenable
    class GoRouterRefreshStream extends ChangeNotifier {
      GoRouterRefreshStream(Stream<dynamic> stream) {
        notifyListeners();
        _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
      }

      late final StreamSubscription<dynamic> _subscription;

      @override
      void dispose() {
        _subscription.cancel();
        super.dispose();
      }
    }

    // في main.dart أو أعلى شجرة الويدجت:
    void main() {
      runApp(
        BlocProvider( // توفير AuthCubit عبر BlocProvider
          create: (_) => AuthCubit(),
          child: const MyAppWithBloc(),
        ),
      );
    }

    class MyAppWithBloc extends StatelessWidget {
      const MyAppWithBloc({super.key});

      @override
      Widget build(BuildContext context) {
        final GoRouter router = GoRouter(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية (مطلوب تسجيل الدخول)')),
            GoRoute(path: '/login', builder: (context, state) => const Text('صفحة تسجيل الدخول')),
          ],
          redirect: (context, state) {
            final authState = context.read<AuthCubit>().state;
            final isLoggedIn = authState.status == AuthStatus.authenticated;
            final isLoggingIn = state.matchedLocation == '/login';

            if (!isLoggedIn && !isLoggingIn) {
              return '/login';
            }
            if (isLoggedIn && isLoggingIn) {
              return '/';
            }
            return null;
          },
          refreshListenable: GoRouterRefreshStream(context.read<AuthCubit>().stream), // ربط Cubit stream بالراوتر
        );

        return MaterialApp.router(
          routerConfig: router,
          title: 'Flutter GoRouter with Bloc',
          theme: ThemeData(primarySwatch: Colors.blue),
        );
      }
    }
    ```
    *   عندما يصدر `AuthCubit` حالة جديدة، سيتم تشغيل دالة `redirect` مرة أخرى، مما يضمن أن المستخدم يتم توجيهه إلى المسار الصحيح بناءً على حالة المصادقة الجديدة.

### 8.4. دمج `GoRouter` مع `Riverpod`

`Riverpod` هو حل حديث لإدارة الحالة يوفر مرونة وأماناً أكبر من `Provider`. التكامل مع `go_router` بسيط وفعال، وغالباً ما لا يتطلب `refreshListenable` بشكل مباشر إذا تم تكوين الراوتر بشكل صحيح.

**مثال:** إعادة التوجيه باستخدام `StateNotifierProvider`.

1.  **`AuthNotifier` و `Provider`:**
    ```dart
    // auth_provider.dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'auth_state.dart'; // استخدم نفس AuthState من مثال Bloc

    final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
      return AuthNotifier();
    });

    class AuthNotifier extends StateNotifier<AuthState> {
      AuthNotifier() : super(const AuthState.unauthenticated());

      Future<void> login(String username, String password) async {
        state = const AuthState.unknown();
        await Future.delayed(const Duration(seconds: 1));
        state = const AuthState.authenticated('user123');
      }

      void logout() {
        state = const AuthState.unauthenticated();
      }
    }
    ```

2.  **تكوين `GoRouter`:**
    في `Riverpod`، يمكنك جعل `GoRouter` نفسه `Provider`، مما يسمح له بإعادة البناء تلقائياً عند تغيير حالة المصادقة التي يعتمد عليها.

    ```dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'auth_provider.dart';
    import 'auth_state.dart';

    final routerProvider = Provider<GoRouter>((ref) {
      final authState = ref.watch(authStateProvider); // مراقبة حالة المصادقة

      return GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية (مطلوب تسجيل الدخول)')),
          GoRoute(path: '/login', builder: (context, state) => const Text('صفحة تسجيل الدخول')),
        ],
        redirect: (context, state) {
          final isLoggedIn = authState.status == AuthStatus.authenticated;
          final isLoggingIn = state.matchedLocation == '/login';

          if (!isLoggedIn && !isLoggingIn) {
            return '/login';
          }
          if (isLoggedIn && isLoggingIn) {
            return '/';
          }
          return null;
        },
      );
    });

    // في main.dart:
    void main() {
      runApp(
        const ProviderScope( // يجب أن يكون التطبيق مغلفاً بـ ProviderScope
          child: MyAppWithRiverpod(),
        ),
      );
    }

    class MyAppWithRiverpod extends ConsumerWidget {
      const MyAppWithRiverpod({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final router = ref.watch(routerProvider); // قراءة الراوتر من Provider

        return MaterialApp.router(
          routerConfig: router,
          title: 'Flutter GoRouter with Riverpod',
          theme: ThemeData(primarySwatch: Colors.blue),
        );
      }
    }
    ```
    *   `ref.watch(authStateProvider)` سيؤدي إلى إعادة بناء `GoRouter` (وبالتالي إعادة تقييم `redirect`) كلما تغيرت حالة المصادقة.

---

## 9. ميزات متقدمة وأفضل الممارسات

يستمر `go_router` في تقديم ميزات قوية لسيناريوهات التنقل المعقدة، بالإضافة إلى أفضل الممارسات التي تضمن تطبيقات قابلة للتطوير والصيانة.

### 9.1. تحسين الأداء: التحميل الكسول (Lazy Loading) والتخزين المؤقت (Caching)

في التطبيقات الكبيرة، يمكن أن يؤثر تحميل جميع المسارات والويدجت المرتبطة بها مقدماً على وقت بدء التشغيل واستهلاك الذاكرة. يوفر `go_router` تقنيات لتحسين الأداء، مثل التحميل الكسول (lazy loading).

#### التحميل الكسول للمسارات (Lazy Loading Routes)

التحميل الكسول يعني تأجيل تحميل كود المسار والويدجت المرتبط به حتى يتم طلبه بالفعل. يمكن تحقيق ذلك باستخدام `deferred as` في Dart.

1.  **إنشاء ملفات منفصلة للمسارات:**
    ضع كل شاشة (أو مجموعة من الشاشات ذات الصلة) في ملف Dart منفصل.

2.  **استخدام `deferred as`:**
    في ملف تكوين الراوتر الرئيسي، استورد هذه الملفات باستخدام `deferred as`.

    ```dart
    // router_config.dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';

    // استيراد الشاشات بـ deferred as
    import 'package:your_app/screens/home_screen.dart' deferred as home_screen;
    import 'package:your_app/screens/settings_screen.dart' deferred as settings_screen;

    final GoRouter lazyLoadingRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => FutureBuilder<void>(
            future: home_screen.loadLibrary(), // تحميل المكتبة عند الطلب
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return home_screen.HomeScreen(); // بناء الويدجت بعد التحميل
              }
              return const Center(child: CircularProgressIndicator()); // عرض مؤشر تحميل
            },
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => FutureBuilder<void>(
            future: settings_screen.loadLibrary(), // تحميل المكتبة عند الطلب
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return settings_screen.SettingsScreen(); // بناء الويدجت بعد التحميل
              }
              return const Center(child: CircularProgressIndicator()); // عرض مؤشر تحميل
            },
          ),
        ),
      ],
    );
    ```
    *   `deferred as` يخبر Dart بعدم تضمين الكود من `settings_screen.dart` في ملف الإخراج الرئيسي.
    *   `settings_screen.loadLibrary()` هي دالة يتم إنشاؤها تلقائياً تقوم بتحميل الكود المؤجل عند استدعائها.
    *   يتم استخدام `FutureBuilder` لعرض مؤشر تحميل أثناء تحميل الكود، ثم بناء الويدجت بمجرد اكتمال التحميل.

**ملاحظة:** التحميل الكسول مفيد بشكل خاص في تطبيقات الويب لتقليل حجم الحزمة الأولية وتحسين وقت التحميل الأولي للصفحة.

#### التخزين المؤقت (Caching)

بينما لا يوفر `go_router` آلية تخزين مؤقت مدمجة للمسارات، يمكنك تحقيق التخزين المؤقت على مستوى البيانات أو الويدجت لتحسين الأداء وتجربة المستخدم.

*   **التخزين المؤقت للبيانات (Data Caching):**
    إذا كانت شاشاتك تعرض بيانات يتم جلبها من الشبكة، فيمكنك استخدام حلول إدارة الحالة (مثل `Bloc`, `Provider`, `Riverpod`) لتخزين هذه البيانات مؤقتاً. بهذه الطريقة، عندما يعود المستخدم إلى شاشة سبق له زيارتها، لا تحتاج إلى إعادة جلب البيانات من الخادم.

    ```dart
    // مثال باستخدام Provider (كما هو موضح في قسم إدارة الحالة)
    class ProductRepository extends ChangeNotifier {
      List<Product> _products = [];
      bool _isLoading = false;

      List<Product> get products => _products;
      bool get isLoading => _isLoading;

      Future<void> fetchProducts() async {
        if (_products.isNotEmpty && !_isLoading) return; // لا تجلب إذا كانت موجودة وغير محملة
        _isLoading = true;
        notifyListeners();

        // محاكاة جلب البيانات
        await Future.delayed(const Duration(seconds: 2));
        _products = [ /* بيانات المنتج */ ];
        _isLoading = false;
        notifyListeners();
      }
    }
    ```

*   **التخزين المؤقت للويدجت (Widget Caching):**
    في بعض الحالات، قد ترغب في الحفاظ على حالة ويدجت معين حتى عند إزالته مؤقتاً من شجرة الويدجت (widget tree). يمكن تحقيق ذلك باستخدام `AutomaticKeepAliveClientMixin` في `StatefulWidget`s التي تكون جزءاً من `PageView` أو `IndexedStack` داخل `ShellRoute` أو `StatefulShellRoute`.

    ```dart
    class MyTabScreen extends StatefulWidget {
      const MyTabScreen({super.key});

      @override
      State<MyTabScreen> createState() => _MyTabScreenState();
    }

    class _MyTabScreenState extends State<MyTabScreen> with AutomaticKeepAliveClientMixin {
      int _counter = 0;

      @override
      bool get wantKeepAlive => true; // الحفاظ على حالة الويدجت

      @override
      Widget build(BuildContext context) {
        super.build(context); // يجب استدعاء هذا في build
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Counter: $_counter'),
              ElevatedButton(
                onPressed: () => setState(() => _counter++),
                child: const Text('Increment'),
              ),
            ],
          ),
        );
      }
    }
    ```

### 9.2. الانتقالات المخصصة (`pageBuilder`): تجربة مستخدم فريدة

يتيح لك `go_router` تخصيص الرسوم المتحركة والانتقالات بين الصفحات باستخدام `pageBuilder` بدلاً من `builder` في `GoRoute`.

```dart
GoRoute(
  path: '/fade-in',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: FadeInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // يمكنك استخدام أي TransitionWidget هنا
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  },
),

class FadeInScreen extends StatelessWidget {
  const FadeInScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('شاشة التلاشي للداخل')), body: const Center(child: Text('هذه الشاشة تظهر بتأثير التلاشي للداخل')));}
```

*   **`CustomTransitionPage`:** يمنحك تحكماً كاملاً في كيفية بناء الصفحة والانتقال إليها.
*   **`transitionsBuilder`:** دالة تُرجع ويدجت انتقال (transition widget) (مثل `FadeTransition`, `SlideTransition`, `ScaleTransition`).
*   **`transitionDuration`:** يحدد مدة الرسوم المتحركة.

### 9.3. مراقبو المسار (`observers`): تتبع أحداث التنقل

يمكنك استخدام `GoRouterObserver` لمراقبة أحداث التنقل (مثل دفع المسارات، سحبها، أو استبدالها). هذا مفيد لتسجيل التحليلات (analytics)، أو تسجيل الدخول (logging)، أو تنفيذ منطق مخصص عند تغيير المسار.

1.  **إنشاء `GoRouterObserver` مخصص:**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';

    class MyGoRouterObserver extends GoRouterObserver {
      @override
      void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print('New route pushed: ${route.settings.name ?? route.settings.arguments ?? route.settings.toString()}');
      }

      @override
      void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print('Route popped: ${route.settings.name ?? route.settings.arguments ?? route.settings.toString()}');
      }

      @override
      void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
        print('Route replaced: ${oldRoute?.settings.name ?? oldRoute?.settings.arguments ?? oldRoute?.settings.toString()} with ${newRoute?.settings.name ?? newRoute?.settings.arguments ?? newRoute?.settings.toString()}');
      }

      @override
      void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print('Route removed: ${route.settings.name ?? route.settings.arguments ?? route.settings.toString()}');
      }

      @override
      void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print('User gesture started on route: ${route.settings.name ?? route.settings.arguments ?? route.settings.toString()}');
      }

      @override
      void didStopUserGesture() {
        print('User gesture stopped.');
      }
    }
    ```

2.  **إضافة المراقب إلى `GoRouter`:**
    ```dart
    final GoRouter routerWithObserver = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('الرئيسية')),
        GoRoute(path: '/details', builder: (context, state) => const Text('التفاصيل')),
      ],
      observers: [MyGoRouterObserver()], // إضافة المراقب هنا
    );
    ```

### 9.4. أفضل ممارسات الأمان: حماية المسارات والبيانات

يعد تأمين المسارات الحساسة أمراً بالغ الأهمية، خاصة في التطبيقات التي تتعامل مع بيانات المستخدم أو لديها أقسام إدارية.

*   **استخدام `redirect` للمصادقة والتخويل:** كما هو موضح في قسم إعادة التوجيه، استخدم `redirect` لفرض قواعد المصادقة (هل المستخدم مسجل الدخول؟) والتخويل (هل لدى المستخدم الدور الصحيح؟).
*   **عدم تمرير البيانات الحساسة في URL:** تجنب وضع البيانات الحساسة (مثل الرموز المميزة (tokens) أو كلمات المرور) في معاملات المسار أو الاستعلام، حيث يمكن أن يتم تسجيلها أو تخزينها مؤقتاً. استخدم `extra` أو حلول إدارة الحالة لتمرير هذه البيانات بشكل آمن.
*   **التحقق من صحة المعاملات:** تحقق دائماً من صحة المعاملات التي تتلقاها من `GoRouterState`. لا تثق أبداً في أن البيانات ستكون بالتنسيق المتوقع. على سبيل المثال، إذا كنت تتوقع معرفاً رقمياً، فتأكد من تحليله والتعامل مع الأخطاء المحتملة.
*   **فصل منطق التوجيه:** حافظ على منطق التوجيه الخاص بك (خاصة منطق إعادة التوجيه) منفصلاً عن واجهة المستخدم قدر الإمكان. هذا يجعله أسهل في الاختبار والمراجعة بحثاً عن الثغرات الأمنية.
*   **تصفية المدخلات (Input Sanitization):** إذا كنت تستخدم معاملات المسار أو الاستعلام لعرض المحتوى مباشرة في واجهة المستخدم (خاصة في تطبيقات الويب)، فتأكد من تصفية (sanitize) هذه المدخلات لمنع هجمات البرمجة النصية عبر المواقع (XSS).
*   **التحقق من التخويل على الخادم (Server-side Authorization):** لا تعتمد فقط على منطق العميل (client-side logic) للتحكم في الوصول. يجب أن يتم التحقق من التخويل دائماً على الخادم أيضاً، حيث يمكن تجاوز منطق العميل.
*   **استخدام HTTPS:** تأكد دائماً من استخدام HTTPS لجميع الاتصالات الشبكية لتشفير البيانات المنقولة، بما في ذلك أي بيانات حساسة قد تكون جزءاً من عناوين URL.

### 9.5. اختبار منطق التنقل في `GoRouter`

يعد اختبار منطق التنقل أمراً بالغ الأهمية لضمان سلوك التطبيق الصحيح. يمكن اختبار `go_router` باستخدام اختبارات الوحدة (unit tests) واختبارات الويدجت (widget tests).

#### اختبارات الوحدة لمنطق إعادة التوجيه (Unit Tests for Redirection Logic)

يمكنك اختبار دالة `redirect` بشكل منفصل عن واجهة المستخدم.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart'; // لإصلاح خطأ BuildContext

// Mock AuthService for testing
class MockAuthService extends Mock {
  bool isLoggedIn() => false;
}

void main() {
  group('GoRouter Redirection Tests', () {
    late MockAuthService mockAuthService;
    late GoRouter router;

    setUp(() {
      mockAuthService = MockAuthService();
      // تهيئة GoRouter مع دالة redirect التي تعتمد على MockAuthService
      router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Text('Home')),
          GoRoute(path: '/login', builder: (context, state) => const Text('Login')),
          GoRoute(path: '/dashboard', builder: (context, state) => const Text('Dashboard')),
        ],
        redirect: (context, state) {
          // يجب أن يكون MockAuthService متاحاً في السياق للاختبار
          // في بيئة الاختبار، يمكننا محاكاة ذلك أو تمرير الخدمة مباشرة
          final isLoggedIn = mockAuthService.isLoggedIn();
          final isLoggingIn = state.matchedLocation == '/login';

          if (!isLoggedIn && !isLoggingIn) return '/login';
          if (isLoggedIn && isLoggingIn) return '/';
          return null;
        },
      );
    });

    test('should redirect to login if not logged in and not on login page', () {
      when(mockAuthService.isLoggedIn()).thenReturn(false);
      final GoRouterState state = GoRouterState(location: '/dashboard', subloc: '/dashboard', path: '/dashboard', pageKey: const ValueKey('dashboard'));
      // نحتاج إلى BuildContext وهمي هنا. يمكن استخدام MaterialApp لتوفير واحد.
      final String? redirectPath = router.routerDelegate.redirect(FakeBuildContext(), state);
      expect(redirectPath, '/login');
    });

    test('should redirect to home if logged in and on login page', () {
      when(mockAuthService.isLoggedIn()).thenReturn(true);
      final GoRouterState state = GoRouterState(location: '/login', subloc: '/login', path: '/login', pageKey: const ValueKey('login'));
      final String? redirectPath = router.routerDelegate.redirect(FakeBuildContext(), state);
      expect(redirectPath, '/');
    });

    test('should not redirect if logged in and on dashboard page', () {
      when(mockAuthService.isLoggedIn()).thenReturn(true);
      final GoRouterState state = GoRouterState(location: '/dashboard', subloc: '/dashboard', path: '/dashboard', pageKey: const ValueKey('dashboard'));
      final String? redirectPath = router.routerDelegate.redirect(FakeBuildContext(), state);
      expect(redirectPath, isNull);
    });
  });
}

// فئة وهمية بسيطة لـ BuildContext
class FakeBuildContext extends Fake implements BuildContext {}
```

**ملاحظة:** ستحتاج إلى إضافة حزمة `mockito` إلى `dev_dependencies` في `pubspec.yaml`.

#### اختبارات الويدجت للتنقل (Widget Tests for Navigation)

يمكنك استخدام اختبارات الويدجت لمحاكاة تفاعلات المستخدم والتحقق من أن التنقل يحدث بشكل صحيح.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('GoRouter Widget Tests', () {
    testWidgets('should navigate to detail screen when button is tapped', (tester) async {
      final _router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (innerContext) => ElevatedButton(
                  onPressed: () => innerContext.go('/detail/123'),
                  child: const Text('Go to Detail'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/detail/:id',
            builder: (context, state) => Text('Detail Screen: ${state.pathParameters['id']!}'),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: _router));

      expect(find.text('Go to Detail'), findsOneWidget);
      expect(find.text('Detail Screen: 123'), findsNothing);

      await tester.tap(find.text('Go to Detail'));
      await tester.pumpAndSettle(); // انتظر حتى تكتمل الرسوم المتحركة للتنقل

      expect(find.text('Go to Detail'), findsNothing);
      expect(find.text('Detail Screen: 123'), findsOneWidget);
    });
  });
}
```

---

## 10. مشروع عملي: تطبيق تسوق

لتوضيح كيفية استخدام `go_router` في تطبيق حقيقي، سنقوم ببناء تطبيق تسوق بسيط. سيحتوي هذا التطبيق على قائمة بالمنتجات، شاشة تفاصيل المنتج، وشاشة شراء المنتج، مع استخدام `go_router` للتنقل بينها.

### 10.1. هيكل المشروع

سنتبع هيكلاً منظماً للمشروع للحفاظ على الكود نظيفاً وقابلاً للصيانة:

```text
go_router_project/
|-- lib/
| |-- main.dart
| |-- models/
| | |-- product.dart
| |-- controller/
| | |-- product_controller.dart
| |-- config/
| | |-- route_config.dart
| |-- screens/
| | |-- product_details_screen.dart
| | |-- product_list_screen.dart
| | |-- product_purchase_screen.dart
| |-- widgets/
| | |-- bottom_container.dart
| | |-- color_container.dart
| | |-- ratings.dart
| | |-- search_section.dart
| | |-- show_modal.dart
| | |-- single_product.dart
|-- pubspec.yaml
```

### 10.2. الكود الكامل للمشروع

#### `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router_project/config/route_config.dart'; // تأكد من المسار الصحيح

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp.router(
      title: 'Flutter GoRouter Shopping App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      routerConfig: router, // استخدام الراوتر المعرف في route_config.dart
    );
  }
}
```

#### Model (`models/product.dart`)

```dart
import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final double previousPrice;
  final String colors;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.previousPrice,
    required this.price,
    required this.colors,
  });

  factory Product.initial() => Product(
        id: '',
        name: '',
        imageUrl: '',
        description: '',
        previousPrice: 0.0,
        price: 0.0,
        colors: '',
      );
}
```

#### Controller (`controller/product_controller.dart`)

```dart
import '../models/product.dart';

class ProductController {
  Product findById(String? id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<Product> get products => _products;

  final List<Product> _products = [
    Product(
      id: 'p7',
      name: 'Leather BackPack',
      imageUrl:
          'https://images.unsplash.com/photo-1571689936114-b16146c9',
      description:
          'The stronger the better it is to load it with all that t',
      price: 30.9,
      previousPrice: 40.9,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p1',
      name: 'Smart Watch',
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6b',
      description: 'A white smart watch with good features and more',
      price: 29.99,
      previousPrice: 39.99,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p16',
      name: 'PowerBook',
      imageUrl:
          'https://get.pxhere.com/photo/laptop-computer-macbook-mac',
      description:
          'Awesome hardware, crappy keyboard and a hefty price. Buy',
      price: 2299.99,
      previousPrice: 3299.99,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p2',
      name: 'Red Sneakers',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27f',
      description:
          'Perfect for your joggers and black T-shirts and more. Th',
      price: 199.99,
      previousPrice: 299.99,
      colors: 'yellow,grey,black,red,teal',
    ),
    Product(
      id: 'p3',
      name: 'Nikon Camera',
      imageUrl:
          'https://images.unsplash.com/photo-1564466809058-bf4114d5',
      description:
          'You can only see clearer with your eyes but a camera sav',
      price: 89.9,
      previousPrice: 109.9,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p4',
      name: 'HeadSets',
      imageUrl:
          'https://images.unsplash.com/photo-1583394838336-acd97773',
      description:
          'The louder the sound, the better it feels inside with th',
      price: 120.1,
      previousPrice: 150.1,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p5',
      name: 'Amazon SoundBox',
      imageUrl:
          'https://images.unsplash.com/photo-1543512214-318c7553f23',
      description:
          'Automated soundbox with voice recognition and more. What',
      price: 78.19,
      previousPrice: 88.19,
      colors: 'red,grey,black,indigo,purple',
    ),
    Product(
      id: 'p6',
      name: 'Xbox 360 GamePads',
      imageUrl:
          'https://images.unsplash.com/photo-1600080972464-8e5f35f6',
      description:
          'You never know when it is time to touch it better except',
      price: 98.99,
      previousPrice: 108.99,
      colors: 'red,grey,black,indigo,purple',
    ),
  ];
}
```

#### Config (`config/route_config.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_project/controller/product_controller.dart';
import 'package:go_router_project/screens/product_details_screen.dart';
import 'package:go_router_project/screens/product_list_screen.dart';
import 'package:go_router_project/screens/product_purchase_screen.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const ProductListScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: ProductDetailsScreen.routeName,
          name: ProductDetailsScreen.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return ProductDetailsScreen(
              productId: state.uri.queryParameters['id'] ?? "",
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'product-purchase/:description',
              name: ProductPurchaseScreen.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return ProductPurchaseScreen(
                  productImage: state.uri.queryParameters['img']!,
                  productPrice: state.uri.queryParameters['price']!,
                  productName: state.uri.queryParameters['name']!,
                  description: state.pathParameters['description']!,
                );
              },
              onExit: (BuildContext context) async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      content: const Text('Are you sure to leave this page?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    );
                  },
                );
                return confirmed ?? false;
              },
            )
          ],
        )
      ],
    ),
  ],
);
```

#### Screens

##### `screens/product_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router_project/controller/product_controller.dart';
import 'package:go_router_project/screens/product_details_screen.dart';
import 'package:go_router_project/widgets/search_section.dart';
import 'package:go_router_project/widgets/single_product.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProductController productController = ProductController();
    TextEditingController searchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SearchSection(
              searchController: searchController,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: productController.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  Product product = productController.products[index];
                  return GestureDetector(
                    onTap: () => context.goNamed(
                      ProductDetailsScreen.routeName,
                      queryParameters: {'id': product.id},
                    ),
                    child: SingleProduct(product: product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

##### `screens/product_details_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_project/controller/product_controller.dart';
import 'package:go_router_project/models/product.dart';
import 'package:go_router_project/widgets/bottom_container.dart';
import 'package:go_router_project/widgets/color_container.dart';
import 'package:go_router_project/widgets/ratings.dart';
import 'package:go_router_project/widgets/show_modal.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = 'product-details';
  final String productId;
  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    late Color colored;
    // get color
    Color getColor(String color) {
      switch (color) {
        case 'red':
          colored = Colors.red;
          break;
        case 'purple':
          colored = Colors.purple;
          break;
        case 'grey':
          colored = Colors.grey;
          break;
        case 'black':
          colored = Colors.black;
          break;
        case 'orange':
          colored = Colors.orange;
          break;
        case 'indigo':
          colored = Colors.indigo;
          break;
        case 'yellow':
          colored = Colors.yellow;
          break;
        case 'blue':
          colored = Colors.blue;
          break;
        case 'brown':
          colored = Colors.brown;
          break;
        case 'teal':
          colored = Colors.teal;
          break;
        default:
      }
      return colored;
    }

    ProductController productController = ProductController();
    Product product = productController.findById(productId);
    List<String> availableColors = product.colors.split(',');
    // pay now
    void payNow() {
      context.goNamed(
        'pay-now',
        pathParameters: <String, String>{
          'description': product.description,
        },
        queryParameters: <String, String>{
          'img': product.imageUrl.toString(),
          'price': product.price.toString(),
          'name': product.name.toString(),
        },
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => showImageModal(context, product),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(50),
                ),
                child: Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ratings(),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toString()}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '\$${product.previousPrice.toString()}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Available in stocks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Out of stocks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Colors Available',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var color in availableColors)
                        buildContainer(
                          color,
                          getColor,
                        )
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: bottomContainer(product, payNow),
    );
  }
}
```

##### `screens/product_purchase_screen.dart`

```dart
import 'package:flutter/material.dart';

class ProductPurchaseScreen extends StatelessWidget {
  const ProductPurchaseScreen({
    super.key,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.description,
  });
  static const routeName = 'pay-now';
  final String productName;
  final String productPrice;
  final String productImage;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        child: Icon(
          Icons.check_circle,
        ),
      ),
      appBar: AppBar(
        title: const Text('Purchase Item'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(productImage),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '\$$productPrice',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Widgets

##### `widgets/bottom_container.dart`

```dart
// bottom container
import 'package:flutter/material.dart';
import '../models/product.dart';

Container bottomContainer(Product productDetails, Function payNow) {
  return Container(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18.0,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Price',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '\$${productDetails.price}',
                style: const TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              )
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.brown.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5),
                  ),
                ),
                child: const Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.white,
                      ),
                      SizedBox(width: 15),
                      Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => payNow(),
                child: Container(
                  height: 50,
                  width: 120,
                  decoration: const BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}
```

##### `widgets/ratings.dart`

```dart
import 'package:flutter/material.dart';

Widget ratings() => const Row(
      children: [
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        Icon(Icons.star, color: Colors.deepOrange, size: 15),
        SizedBox(width: 20),
        Text('(3400 Reviews)')
      ],
    );
```

##### `widgets/color_container.dart`

```dart
// build container for color
import 'package:flutter/cupertino.dart';

Widget buildContainer(String color, Function getColor) {
  return Container(
    height: 5,
    width: 40,
    decoration: BoxDecoration(
      color: getColor(color),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
```

##### `widgets/search_section.dart`

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          CupertinoIcons.search,
          color: Colors.black,
        ),
        hintText: 'Enter search keyword',
        label: const Text(
          'Search Here',
        ),
        fillColor: Colors.grey.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
```

##### `widgets/show_modal.dart`

```dart
// show modal for image
import 'package:flutter/material.dart';
import '../models/product.dart';

void showImageModal(BuildContext context, Product product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                width: double.infinity,
                fit: BoxFit.cover,
                image: NetworkImage(product.imageUrl),
              ),
            ),
            Positioned(
              right: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(product.name),
                      const SizedBox(width: 5),
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),
      );
    },
  );
}
```

##### `widgets/single_product.dart`

```dart
import 'package:flutter/material.dart';
import '../models/product.dart';

class SingleProduct extends StatelessWidget {
  const SingleProduct({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
            child: Hero(
              tag: product.id,
              child: Image.network(
                product.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${product.price}'),
                Text(
                  '\$${product.previousPrice}',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
```

---

## 11. الخاتمة والمراجع

### 11.1. الخاتمة (Conclusion)

`go_router` هي أداة قوية ومرنة بشكل لا يصدق في مجموعة أدوات مطور Flutter. من خلال تبسيط تعقيدات `Navigator 2.0` وتقديم واجهة برمجة تطبيقات نظيفة وقائمة على الروابط، فإنها تمكن المطورين من بناء هياكل تنقل معقدة بسهولة وثقة. سواء كنت تبني تطبيقاً بسيطاً للهاتف المحمول، أو تطبيق ويب معقداً، أو تطبيقاً متعدد المنصات، فإن `go_router` يوفر الأساس الذي تحتاجه لإنشاء تجربة مستخدم سلسة وقابلة للصيانة.

من خلال فهم المفاهيم الأساسية مثل المسارات، وإعادة التوجيه، و `ShellRoute`، و `StatefulShellRoute`، ودمجها مع حلول إدارة الحالة القوية، يمكنك الاستفادة الكاملة من إمكانات `go_router` وتركيز جهودك على بناء ميزات رائعة بدلاً من القلق بشأن إدارة مكدس التنقل.

### 11.2. المراجع (References)

1.  [الوثائق الرسمية لـ go_router على pub.dev](https://pub.dev/packages/go_router)
2.  [مستودع go_router على GitHub](https://github.com/flutter/packages/tree/main/packages/go_router)
3.  [فيديو: تعلم GoRouter (Flutter)](https://www.youtube.com/watch?v=ny__51K9o-k)
4.  [مقال: التنقل في Flutter باستخدام GoRouter](https://codewithandrea.com/articles/flutter-navigation-gorouter-go-vs-push/)
5.  [مقال: GoRouter: التنقل في Flutter بسهولة](https://medium.com/flutter-community/gorouter-navigation-in-flutter-with-ease-a67272223a6f)
6.  [وثائق Flutter الرسمية حول استعادة الحالة](https://docs.flutter.dev/ui/navigation/deep-linking#state-restoration)
7.  [وثائق Flutter الرسمية حول الروابط العميقة في Android](https://docs.flutter.dev/platform-integration/android/deep-linking)
8.  [وثائق Flutter الرسمية حول الروابط العميقة في iOS (Universal Links)](https://docs.flutter.dev/platform-integration/ios/universal-links)

**عن المؤلف:**
أتوها أنتوني هو مهندس برمجيات محمول أول (Senior Mobile Software Engineer) ولديه سجل حافل في بناء تطبيقات قابلة للتطوير وعالية الأداء عبر منصات مختلفة، بما في ذلك Android و iOS والويب وغيرها، باستخدام Flutter بشكل أساسي، إلى جانب Kotlin و Swift، والاستفادة من الذكاء الاصطناعي.

إذا قرأت هذا القدر، اشكر المؤلف لتظهر له اهتمامك.

[قل شكراً](https://www.freecodecamp.org/news/how-to-get-started-with-go-router-in-flutter/#say-thanks)

تعلم البرمجة مجاناً. ساعد منهج freeCodeCamp مفتوح المصدر أكثر من 40,000 شخص في الحصول على وظائف كمطورين.

[ابدأ](https://www.freecodecamp.org/)

freeCodeCamp هي منظمة خيرية معفاة من الضرائب بموجب المادة 501(c)(3) (الولايات المتحدة، رقم التعريف الضريبي الفيدرالي: 82-0779546) مدعومة من المتبرعين.
