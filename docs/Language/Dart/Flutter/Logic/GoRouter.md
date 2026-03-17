# الدليل الشامل لـ GoRouter في Flutter

**بقلم: أتوها أنتوني (Atuoha Anthony) مع إضافات من Manus AI**
*تاريخ التحديث: 17 مارس 2026*

يعد التنقل بين الشاشات في Flutter أمراً بالغ الأهمية لأي تطبيق. وبينما توفر واجهة برمجة تطبيقات Navigator المدمجة الوظائف اللازمة، إلا أنها قد تصبح معقدة في المشاريع الكبيرة. هنا يأتي دور **go_router**، حيث يقدم نظام تنقل أكثر تصريحاً (declarative)، يعتمد على الروابط (URLs)، وغني بالميزات. يتناول هذا المقال كل تفاصيل go_router، ويرشدك من الإعداد إلى الميزات المتقدمة مثل إعادة التوجيه (redirection) والمسارات المتداخلة (nested routes)، بالإضافة إلى استكشاف حالات الاستخدام المتقدمة وأفضل الممارسات.

go_router هي مكتبة توجيه (routing library) مرنة وخفيفة الوزن لـ Flutter تبسط عملية التنقل وتوفر واجهة برمجة تطبيقات (API) نظيفة لإدارة المسارات (routes)، وتمرير المعاملات (parameters)، والتعامل مع عمليات إعادة التوجيه. لقد صُممت لتكون سهلة الاستخدام مع توفير ميزات متقدمة لمتطلبات التنقل الأكثر تعقيداً.

يلعب التنقل دوراً حاسماً في صياغة تجارب مستخدم سلسة. وبينما يوفر Navigator 2.0 المدمج تعدد الاستخدامات، إلا أنه يمكن أن يصبح معقداً في المشاريع الكبيرة. هنا يتدخل go_router ويساعد في تبسيط العملية بشكل كبير.

---

## جدول المحتويات
1.  مقدمة إلى GoRouter
2.  مقارنة بين حلول التنقل في Flutter
    *   Navigator 1.0
    *   Navigator 2.0 (Router API)
    *   GoRouter: المزايا والعيوب
3.  المتطلبات الأساسية (Prerequisites)
4.  ما سنقوم ببنائه (What We'll Build)
5.  التثبيت (Installation)
6.  كيفية تعريف المسارات (How to Define Routes)
7.  كيفية إنشاء الراوتر (How to Create the Router)
8.  كيفية التنقل بين الشاشات (How to Navigate Between Screens)
9.  كيفية تمرير المعاملات (How to Pass Parameters)
    *   معاملات الاستعلام (Query Parameters)
    *   معاملات المسار (Path Parameters)
10. المسارات الفرعية و ShellRoute (Sub-Routes and ShellRoute)
11. إعادة التوجيه والحماية (Redirection and Guards)
12. التعامل مع الأخطاء (Error Handling) في GoRouter
    *   صفحات 404 المخصصة
13. التنقل في الويب (Web Navigation) والروابط العميقة (Deep Linking)
14. إدارة الحالة (State Management) مع GoRouter
    *   دمج GoRouter مع Bloc/Cubit
    *   دمج GoRouter مع Provider
    *   دمج GoRouter مع Riverpod
15. تحسين الأداء (Performance Optimization)
    *   التحميل الكسول للمسارات (Lazy Loading Routes)
    *   التخزين المؤقت (Caching)
16. أفضل ممارسات الأمان (Security Best Practices)
17. كيفية إعداد مشروع Flutter حقيقي باستخدام GoRouter
    *   هيكل المشروع (Project Structure)
    *   `main.dart`
    *   Model (`product.dart`)
    *   Controller (`product_controller.dart`)
    *   Config (`route_config.dart`)
    *   Screens (`product_list_screen.dart`, `product_details_screen.dart`, `product_purchase_screen.dart`)
    *   Widgets (`bottom_container.dart`, `color_container.dart`, `ratings.dart`, `search_section.dart`, `show_modal.dart`, `single_product.dart`)
18. الخاتمة (Conclusion)
19. المراجع (References)

---

## 1. مقدمة إلى GoRouter

في عالم تطوير تطبيقات Flutter، يعد التنقل الفعال والسلس بين الشاشات أمراً حيوياً لتجربة المستخدم. تاريخياً، قدم Flutter آليتين رئيسيتين للتنقل: `Navigator 1.0` و `Navigator 2.0` (المعروف أيضاً باسم Router API). ومع ذلك، فإن تعقيد `Navigator 2.0` في المشاريع الكبيرة دفع المجتمع نحو حلول أكثر بساطة وقوة، وهنا يبرز `go_router` كخيار ممتاز.

`go_router` هي مكتبة توجيه (routing library) مصممة خصيصاً لتبسيط عملية التنقل في تطبيقات Flutter. تعتمد هذه المكتبة على مفهوم التنقل القائم على الروابط (URL-based navigation)، مما يجعلها مثالية لتطبيقات الويب وتطبيقات الهاتف المحمول التي تتطلب روابط عميقة (deep linking) وإدارة حالة التنقل بشكل تصريحي (declarative). توفر `go_router` واجهة برمجة تطبيقات نظيفة وبديهية (clean and intuitive API) لإدارة المسارات، وتمرير البيانات بين الشاشات، والتعامل مع سيناريوهات التنقل المعقدة مثل إعادة التوجيه (redirection) والمسارات المتداخلة (nested routes).

يهدف هذا الدليل إلى تقديم فهم شامل لـ `go_router`، بدءاً من أساسياته وصولاً إلى ميزاته المتقدمة، مع التركيز على أفضل الممارسات وكيفية دمجه بفعالية في مشاريع Flutter الحقيقية.

## 2. مقارنة بين حلول التنقل في Flutter

لفهم قيمة `go_router` بشكل كامل، من الضروري مقارنته بحلول التنقل الأخرى المتاحة في Flutter.

### Navigator 1.0

`Navigator 1.0` هو الحل الأصلي للتنقل في Flutter، ويعتمد على مفهوم مكدس (stack) من الصفحات. يتم التنقل باستخدام دوال مثل `Navigator.push()` و `Navigator.pop()`.

**المزايا:**
*   **البساطة:** سهل التعلم والاستخدام للمشاريع الصغيرة والبسيطة.
*   **مباشر:** يوفر واجهة برمجة تطبيقات واضحة لدفع وسحب الصفحات.

**العيوب:**
*   **غير تصريحي (Imperative):** يعتمد على الأوامر (commands) بدلاً من وصف الحالة، مما يجعل إدارة مكدس التنقل معقداً في السيناريوهات المعقدة.
*   **صعوبة في الروابط العميقة (Deep Linking):** لا يدعم الروابط العميقة بشكل طبيعي، ويتطلب حلولاً مخصصة.
*   **صعوبة في الويب:** لا يتكيف جيداً مع التنقل القائم على URL في تطبيقات الويب.
*   **إدارة الحالة:** يمكن أن يصبح تحدياً عند الحاجة إلى تمرير البيانات بين الصفحات أو إعادة بناء مكدس التنقل.

### Navigator 2.0 (Router API)

قدم `Navigator 2.0`، المعروف أيضاً باسم Router API، نهجاً تصريحياً (declarative) للتنقل. يعتمد على مفهوم `RouterDelegate` و `RouteInformationParser`، مما يمنح المطورين تحكماً كاملاً في مكدس التنقل وكيفية تفاعله مع الروابط.

**المزايا:**
*   **تصريحي (Declarative):** يسمح بوصف حالة التنقل، مما يسهل إدارة مكدس التنقل المعقد.
*   **دعم الروابط العميقة والويب:** مصمم لدعم الروابط العميقة والتنقل القائم على URL في تطبيقات الويب بشكل فعال.
*   **تحكم كامل:** يوفر تحكماً دقيقاً في كل جانب من جوانب التنقل.

**العيوب:**
*   **التعقيد:** منحنى تعلم حاد جداً، ويتطلب كتابة الكثير من الكود المعقد حتى للسيناريوهات البسيطة.
*   **الكود المطول (Boilerplate Code):** يتطلب قدراً كبيراً من الكود المتكرر لإعداد Router API.
*   **صعوبة في الصيانة:** يمكن أن يصبح الكود صعب القراءة والصيانة بسبب تعقيده.

### GoRouter: المزايا والعيوب

`go_router` هي مكتبة مبنية فوق `Navigator 2.0`، تهدف إلى تبسيط تعقيداته مع الاحتفاظ بفوائده التصريحية. إنها توفر واجهة برمجة تطبيقات أكثر بساطة وفعالية لإدارة التنقل.

**المزايا:**
*   **تصريحي ومبسط:** يجمع بين قوة `Navigator 2.0` وبساطة واجهة برمجة تطبيقات سهلة الاستخدام.
*   **دعم الروابط العميقة والويب:** يدعم الروابط العميقة وتغيير URL في المتصفح بشكل طبيعي.
*   **إدارة الحالة:** يسهل تمرير المعاملات وإدارة حالة التنقل.
*   **المسارات المتداخلة (Nested Routes):** يدعم تنظيم المسارات في هياكل هرمية معقدة باستخدام `ShellRoute`.
*   **إعادة التوجيه والحماية (Redirection and Guards):** يوفر آليات قوية للتحكم في الوصول وإعادة توجيه المستخدمين بناءً على الشروط.
*   **مجتمع نشط:** يتم صيانته وتطويره بنشاط من قبل فريق Flutter.

**العيوب:**
*   **لا يزال يتطلب فهماً لـ Navigator 2.0:** على الرغم من تبسيطه، فإن فهم المفاهيم الأساسية لـ `Navigator 2.0` يمكن أن يكون مفيداً لحل المشكلات المعقدة.
*   **قد يكون مبالغاً فيه للمشاريع الصغيرة جداً:** للمشاريع التي تحتوي على عدد قليل جداً من الشاشات، قد يكون `Navigator 1.0` كافياً وأبسط.

| الميزة / الحل      | Navigator 1.0 | Navigator 2.0 (Router API) | GoRouter                                  |
| :----------------- | :------------ | :------------------------- | :---------------------------------------- |
| **النموذج**         | إلزامي (Imperative) | تصريحي (Declarative)       | تصريحي (Declarative) ومبسط                |
| **سهولة الاستخدام** | سهل للمبتدئين | صعب جداً                   | متوسط إلى سهل (بعد فهم المفاهيم)         |
| **الروابط العميقة** | ضعيف           | ممتاز                     | ممتاز                                    |
| **دعم الويب**       | ضعيف           | ممتاز                     | ممتاز                                    |
| **الكود المطول**    | قليل           | كثير جداً                  | متوسط (أقل بكثير من Navigator 2.0 الخام) |
| **المسارات المتداخلة** | لا يدعم       | يدعم                       | يدعم بقوة (ShellRoute)                    |
| **إعادة التوجيه**   | يدوي           | يدعم                       | يدعم بقوة                                 |
| **إدارة الحالة**    | تحدي           | معقد                       | مبسط وفعال                                |

---

## 3. المتطلبات الأساسية (Prerequisites)
للمتابعة مع هذا المقال وبناء التطبيق المثال، ستحتاج إلى:
*   **Flutter SDK:** تأكد من تثبيت Flutter وتهيئته على جهاز التطوير الخاص بك. يمكنك العثور على تعليمات التثبيت على [الموقع الرسمي لـ Flutter](https://flutter.dev/docs/get-started/install).
*   **معرفة أساسية بـ Flutter:** الإلمام بويدجت (widgets) Flutter، وإدارة الحالة (state management) (حتى `setState` الأساسية)، ومفاهيم تطوير التطبيقات العامة سيكون مفيداً.
*   **أساسيات لغة Dart:** فهم جيد لبناء جملة (syntax) Dart، والأصناف (classes)، والوظائف (functions) أمر ضروري.
*   **بيئة تطوير متكاملة (IDE):** مثل Visual Studio Code أو Android Studio مع تثبيت إضافات Flutter و Dart.

## 4. ما سنقوم ببنائه (What We'll Build)
بحلول نهاية هذا المقال، سنكون قد بنينا تطبيق تسوق بسيطاً يستعرض الوظائف الأساسية لـ go_router. سيحتوي هذا التطبيق على الميزات التالية:
1.  شاشة قائمة المنتجات (Product Listing screen) تعرض شبكة من المنتجات.
2.  شاشة تفاصيل المنتج (Product Details screen) تعرض معلومات مفصلة حول منتج محدد.
3.  شاشة شراء المنتج (Product Purchase screen) تؤكد شراء المنتج.
4.  التنقل بين هذه الشاشات باستخدام go_router، بما في ذلك تمرير البيانات عبر معاملات الاستعلام (query parameters) ومعاملات المسار (path parameters).
5.  إعادة توجيه المسار (Route Redirection) وحراس الخروج (Exit Guards) للتحكم المحسن في التنقل.

## 5. التثبيت (Installation)
للبدء، أضف `go_router` إلى ملف `pubspec.yaml` الخاص بك:

```yaml
dependencies:
  go_router: ^13.0.0
```

يضيف هذا حزمة `go_router` كاعتماد (dependency) لمشروعك، مما يتيح لك استخدام وظائفها.

ثم قم بتشغيل `flutter pub get` في الطرفية (terminal) لجلب التبعية.

استوردها في ملفات Dart الخاصة بك حيث تحتاج إلى استخدام وظائف `go_router`:

```dart
import 'package:go_router/go_router.dart';
```

يجعل هذا البيان جميع الأصناف (classes) والوظائف (functions) التي توفرها حزمة `go_router` متاحة للاستخدام في ملف Dart الخاص بك.

## 6. كيفية تعريف المسارات (How to Define Routes)

تعتمد `go_router` على تعريف المسارات بشكل تصريحي (declarative). يتم ذلك عادةً بإنشاء قائمة من كائنات `GoRoute`، حيث يمثل كل كائن مساراً فريداً في تطبيقك.

```dart
final routes = [
  GoRoute(
    path: '/', // المسار الجذري (root path)
    builder: (context, state) => const HomeScreen(), // الويدجت الذي سيتم عرضه لهذا المسار
  ),
  GoRoute(
    path: '/products/:id', // مسار ديناميكي مع معامل مسار (path parameter) يسمى 'id'
    builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!), // استخدام المعامل
  ),
  // ... يمكن إضافة المزيد من المسارات هنا
];
```

**شرح تفصيلي لمكونات `GoRoute`:**

*   `path`: هذه الخاصية تحدد نمط URL للمسار. يمكن أن يكون مساراً ثابتاً (مثل `/home`) أو يحتوي على معاملات مسار ديناميكية (مثل `/products/:id`).
    *   **المسارات الثابتة:** تطابق URL بالضبط.
    *   **معاملات المسار (Path Parameters):** تبدأ بـ `:` (مثل `:id`). يتم استخراج القيمة المقابلة في URL وتخزينها في `state.pathParameters`.
*   `builder`: هذه الدالة هي المسؤولة عن بناء الويدجت (widget) الذي سيتم عرضه عندما يكون هذا المسار نشطاً. تستقبل `BuildContext` و `GoRouterState`.
    *   `context`: يوفر سياق البناء المعتاد في Flutter.
    *   `state`: كائن `GoRouterState` يوفر معلومات حول المسار الحالي، بما في ذلك `pathParameters` و `queryParameters` و `uri` وغيرها.
*   `name`: (اختياري) يمكن تعيين اسم فريد للمسار. يتيح لك ذلك التنقل إلى المسار باستخدام اسمه بدلاً من مساره الكامل، مما يجعل الكود أكثر قابلية للصيانة وأقل عرضة للأخطاء عند تغيير المسارات.
    ```dart
    GoRoute(
      path: '/settings',
      name: 'settingsRoute', // اسم المسار
      builder: (context, state) => const SettingsScreen(),
    ),
    // التنقل باستخدام الاسم:
    context.goNamed('settingsRoute');
    ```
*   `routes`: (اختياري) يسمح بتعريف مسارات فرعية (sub-routes) متداخلة تحت هذا المسار الأب. هذا مفيد لتنظيم هياكل التنقل المعقدة.
    ```dart
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'edit', // المسار الكامل سيكون '/profile/edit'
          builder: (context, state) => const EditProfileScreen(),
        ),
      ],
    ),
    ```

## 7. كيفية إنشاء الراوتر (How to Create the Router)

بعد تعريف المسارات، تحتاج إلى إنشاء مثيل (instance) من `GoRouter` ودمجه مع تطبيق Flutter الخاص بك. يتم ذلك عادةً في ويدجت `MaterialApp.router` أو `CupertinoApp.router`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// تعريف المسارات (كما في القسم السابق)
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router, // دمج GoRouter مع التطبيق
      title: 'GoRouter Example',
    );
  }
}
```

**شرح `MaterialApp.router`:**

*   `MaterialApp.router`: هذا المُنشئ (constructor) الخاص بـ `MaterialApp` مصمم للعمل مع Router API (و `go_router` الذي يبني عليه). بدلاً من استخدام `home` أو `routes` التقليدية، فإنه يأخذ `routerConfig`.
*   `routerConfig`: هذه الخاصية تتوقع كائناً من نوع `RouterConfig<Object>`. مثيل `GoRouter` الذي أنشأته يفي بهذا المتطلب.

**ملاحظات هامة:**
*   يجب أن يكون مثيل `GoRouter` واحداً (singleton) في تطبيقك. عادةً ما يتم تعريفه كمتغير `final` على المستوى الأعلى (top-level) أو كجزء من نظام إدارة الحالة الخاص بك.
*   تأكد من استيراد `package:go_router/go_router.dart`.

## 8. كيفية التنقل بين الشاشات (How to Navigate Between Screens)

يوفر `go_router` عدة طرق للتنقل بين الشاشات، مما يمنحك المرونة لاختيار الأنسب لسيناريو معين.

### 1. التنقل باستخدام المسار (Path-based Navigation)

هذه هي الطريقة الأكثر شيوعاً للتنقل، حيث تحدد المسار الكامل الذي تريد الانتقال إليه.

*   **`context.go(path)`:** ينتقل إلى المسار المحدد ويستبدل مكدس التنقل الحالي بالمسار الجديد. هذا يعني أن زر العودة (back button) لن يعيدك إلى المسار السابق.
    ```dart
    // الانتقال إلى الشاشة الرئيسية
    context.go('/');

    // الانتقال إلى صفحة تفاصيل المنتج 123
    context.go('/products/123');
    ```
*   **`context.push(path)`:** يدفع المسار المحدد إلى مكدس التنقل. هذا يعني أنه يمكنك العودة إلى المسار السابق باستخدام زر العودة أو `context.pop()`.
    ```dart
    // دفع صفحة الإعدادات إلى المكدس
    context.push('/settings');
    ```
*   **`context.replace(path)`:** يستبدل المسار الحالي في مكدس التنقل بالمسار الجديد. على عكس `go()`، فإنه لا يمسح المكدس بأكمله، بل يستبدل العنصر العلوي فقط.
    ```dart
    // استبدال الشاشة الحالية بشاشة تسجيل الدخول بعد تسجيل الخروج
    context.replace('/login');
    ```

### 2. التنقل باستخدام الاسم (Named-based Navigation)

إذا قمت بتعيين أسماء للمسارات الخاصة بك، يمكنك التنقل باستخدام هذه الأسماء، مما يجعل الكود أكثر وضوحاً وأسهل في الصيانة.

*   **`context.goNamed(name, {pathParameters, queryParameters, extra})`:** ينتقل إلى المسار المسمى ويستبدل مكدس التنقل.
*   **`context.pushNamed(name, {pathParameters, queryParameters, extra})`:** يدفع المسار المسمى إلى مكدس التنقل.
*   **`context.replaceNamed(name, {pathParameters, queryParameters, extra})`:** يستبدل المسار الحالي بالمسار المسمى.

```dart
// تعريف مسار مسمى
GoRoute(
  path: '/products/:id',
  name: 'productDetailsRoute',
  builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!),
),

// التنقل باستخدام الاسم
context.goNamed(
  'productDetailsRoute',
  pathParameters: {'id': '456'},
  queryParameters: {'source': 'homepage'},
  extra: {'productObject': someProduct},
);
```

**متى تستخدم `go()` مقابل `push()`؟**

*   **`go()`:** استخدمها عندما تريد الانتقال إلى مسار جديد وتعتبر المسار السابق غير ذي صلة أو لا تريد أن يتمكن المستخدم من العودة إليه. مثال: بعد تسجيل الدخول، تنتقل إلى الشاشة الرئيسية ولا تريد أن يتمكن المستخدم من العودة إلى شاشة تسجيل الدخول باستخدام زر العودة.
*   **`push()`:** استخدمها عندما تريد إضافة شاشة جديدة فوق الشاشة الحالية وتتوقع أن يتمكن المستخدم من العودة إلى الشاشة السابقة. مثال: فتح صفحة تفاصيل منتج من قائمة المنتجات.

## 9. كيفية تمرير المعاملات (How to Pass Parameters)

يعد تمرير البيانات بين الشاشات جانباً أساسياً في أي تطبيق. يوفر `go_router` طرقاً قوية ومرنة لتمرير المعاملات (parameters) بين المسارات.

### 1. معاملات الاستعلام (Query Parameters)

معاملات الاستعلام هي أزواج مفتاح-قيمة (key-value pairs) تُضاف إلى URL بعد علامة الاستفهام (`?`). إنها مفيدة للبيانات الاختيارية، أو عوامل التصفية، أو المعرفات التي لا تغير بشكل أساسي بنية المسار.

**إرسال معاملات الاستعلام:**

```dart
// عند التنقل
context.goNamed(
  'productDetailsRoute',
  queryParameters: {
    'id': product.id,
    'category': 'electronics',
  },
);
// سيؤدي هذا إلى URL مثل: /products?id=abc123&category=electronics
```

**استقبال معاملات الاستعلام:**

في ويدجت الشاشة المستهدفة، يمكنك الوصول إلى معاملات الاستعلام من كائن `GoRouterState`:

```dart
GoRoute(
  path: '/products',
  name: 'productDetailsRoute',
  builder: (context, state) {
    final productId = state.uri.queryParameters['id'];
    final category = state.uri.queryParameters['category'];
    return ProductDetailsScreen(productId: productId, category: category);
  },
)
```

**متى تستخدم معاملات الاستعلام؟**
*   عندما تكون المعاملات اختيارية.
*   عندما تريد السماح بمعاملات متعددة دون تغيير المسار الأساسي.
*   عندما لا تغير البيانات بشكل أساسي بنية المسار (مثل عوامل التصفية، أرقام الصفحات).

### 2. معاملات المسار (Path Parameters)

معاملات المسار هي أجزاء من المسار نفسه، وعادة ما تكون مطلوبة لجعل المسار منطقياً. يتم تحديدها في تعريف المسار باستخدام بادئة النقطتين (`:`).

**إرسال معاملات المسار:**

```dart
// عند التنقل
context.goNamed(
  'productPurchaseRoute',
  pathParameters: {
    'description': product.description,
  },
);
// سيؤدي هذا إلى URL مثل: /product-purchase/AwesomeProduct
```

**استقبال معاملات المسار:**

في ويدجت الشاشة المستهدفة، يمكنك الوصول إلى معاملات المسار من كائن `GoRouterState`:

```dart
GoRoute(
  path: '/product-purchase/:description',
  name: 'productPurchaseRoute',
  builder: (context, state) {
    final description = state.pathParameters['description']!;
    return ProductPurchaseScreen(description: description);
  },
)
```

**متى تستخدم معاملات المسار؟**
*   عندما تكون القيمة مطلوبة لجعل المسار فريداً وذا معنى (مثل معرف المنتج، اسم المستخدم، slug).
*   عندما يجب ألا يوجد المسار بدون هذه القيمة.

### 3. تمرير كائنات معقدة باستخدام `extra`

بالإضافة إلى معاملات الاستعلام والمسار، يوفر `go_router` خاصية `extra` لتمرير كائنات Dart معقدة مباشرة بين المسارات. هذه الطريقة مفيدة عندما لا ترغب في تسلسل (serialize) الكائن إلى سلسلة نصية لـ URL.

**إرسال كائن باستخدام `extra`:**

```dart
// عند التنقل
context.pushNamed(
  'productDetailsRoute',
  pathParameters: {'id': product.id},
  extra: product, // تمرير كائن المنتج مباشرة
);
```

**استقبال كائن باستخدام `extra`:**

في ويدجت الشاشة المستهدفة، يمكنك الوصول إلى الكائن من كائن `GoRouterState`:

```dart
GoRoute(
  path: '/products/:id',
  name: 'productDetailsRoute',
  builder: (context, state) {
    final product = state.extra as Product; // استعادة الكائن
    return ProductDetailsScreen(product: product);
  },
)
```

**ملاحظات حول `extra`:**
*   `extra` لا يظهر في URL، لذا فهو غير مناسب للروابط العميقة أو التنقل عبر الويب إذا كنت تعتمد على URL فقط.
*   يجب أن يكون الكائن الذي يتم تمريره عبر `extra` قابلاً للتسلسل (serializable) إذا كنت تخطط لاستخدامه مع استعادة الحالة (state restoration) أو في سيناريوهات معينة.

## 10. المسارات الفرعية و ShellRoute (Sub-Routes and ShellRoute)

مع نمو التطبيقات، يصبح تنظيم المسارات أمراً بالغ الأهمية. يوفر `go_router` آليتين قويتين لتنظيم المسارات في هياكل هرمية والحفاظ على عناصر واجهة المستخدم الثابتة.

### 1. المسارات الفرعية (Sub-Routes)

تسمح لك المسارات الفرعية بتعريف مسارات متداخلة تحت مسار أب (parent route). هذا يساعد في تجميع المسارات ذات الصلة معاً ويجعل تعريف المسارات أكثر تنظيمًا.

**مثال:** ملف تعريف المستخدم وإعداداته.

```dart
GoRoute(
  path: '/profile', // المسار الأب
  builder: (context, state) => ProfileScreen(),
  routes: [
    // المسار الفرعي 'edit' تحت '/profile'
    GoRoute(
      path: 'edit', // المسار الكامل سيكون '/profile/edit'
      builder: (context, state) => EditProfileScreen(),
    ),
    // المسار الفرعي 'settings' تحت '/profile'
    GoRoute(
      path: 'settings', // المسار الكامل سيكون '/profile/settings'
      builder: (context, state) => SettingsScreen(),
    ),
  ],
),
```

*   عند التنقل إلى `/profile`، سيتم عرض `ProfileScreen`.
*   عند التنقل إلى `/profile/edit`، سيتم عرض `EditProfileScreen` فوق `ProfileScreen` (أو داخلها، اعتماداً على كيفية بناء `ProfileScreen`).

**متى تستخدم المسارات الفرعية؟**
*   لتجميع الشاشات ذات الصلة منطقياً تحت مسار أب واحد.
*   لإنشاء تسلسل هرمي واضح للتنقل.

### 2. ShellRoute

`ShellRoute` هي ميزة قوية في `go_router` تُستخدم عندما تحتاج إلى غلاف واجهة مستخدم ثابت (persistent UI wrapper) يظل مرئياً أثناء التبديل بين المسارات الفرعية. هذا شائع جداً في التطبيقات التي تحتوي على شريط تنقل سفلي (BottomNavigationBar)، أو قائمة جانبية (Drawer)، أو شريط علوي (AppBar) مشترك.

**مثال:** تطبيق بشريط تنقل سفلي.

```dart
ShellRoute(
  builder: (context, state, child) {
    // 'child' هو الويدجت الخاص بالمسار الفرعي النشط حالياً
    return MainScaffold(child: child); // MainScaffold يحتوي على BottomNavigationBar
  },
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => FavoritesScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileScreen(),
    ),
  ],
),
```

في هذا المثال، `MainScaffold` هو الويدجت الذي يحتوي على `BottomNavigationBar` وأي عناصر واجهة مستخدم مشتركة أخرى. عندما ينتقل المستخدم بين `/home` و `/favorites` و `/profile`، يظل `MainScaffold` مرئياً، ويتغير فقط المحتوى داخل `child`.

**متى تستخدم ShellRoute؟**
*   عندما تحتاج إلى شريط تنقل سفلي (BottomNavigationBar) أو علامات تبويب (tabs).
*   عندما يكون لديك تخطيط (layout) مشترك (مثل شريط علوي، قائمة جانبية) يجب أن يظل موجوداً بينما يتغير المحتوى الداخلي فقط.
*   للحفاظ على حالة (state) الويدجت الأب (parent widget) أثناء التنقل بين المسارات الفرعية.

**ملاحظة:** يمكن تداخل `ShellRoute`s لإنشاء هياكل واجهة مستخدم أكثر تعقيداً، على سبيل المثال، `ShellRoute` لشريط التنقل السفلي، وداخله `ShellRoute` آخر لقائمة جانبية.

## 11. إعادة التوجيه والحماية (Redirection and Guards)

تعد آليات إعادة التوجيه والحماية ضرورية للتحكم في تدفق المستخدمين داخل التطبيق، وضمان الوصول المصرح به، وتوجيه المستخدمين إلى المسارات الصحيحة بناءً على شروط معينة.

### 1. إعادة التوجيه (Redirection)

تسمح لك إعادة التوجيه بتغيير المسار الذي يحاول المستخدم الوصول إليه تلقائياً بناءً على منطق معين. يمكن استخدامها لفرض المصادقة، أو إعادة توجيه المسارات القديمة، أو توجيه المستخدمين بناءً على أدوارهم.

**أمثلة على إعادة التوجيه:**

*   **إعادة توجيه مسار قديم إلى مسار جديد:**
    ```dart
    GoRoute(
      path: '/old-path',
      redirect: (context, state) => '/new-path', // إعادة توجيه دائمة
    ),
    ```
*   **فرض المصادقة (Authentication):** إعادة توجيه المستخدمين غير المسجلين إلى شاشة تسجيل الدخول.
    ```dart
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardScreen(),
      redirect: (context, state) {
        final isLoggedIn = AuthService.isLoggedIn(); // دالة للتحقق من حالة تسجيل الدخول
        return isLoggedIn ? null : '/login'; // إذا لم يكن مسجلاً، أعد التوجيه إلى '/login'
      },
    ),
    ```
    *   إذا كانت دالة `redirect` تُرجع `null`، فسيتم السماح بالوصول إلى المسار الأصلي.
    *   إذا كانت تُرجع سلسلة نصية (string)، فسيتم إعادة توجيه المستخدم إلى هذا المسار.

*   **إعادة التوجيه على مستوى الراوتر (Router-level Redirection):** يمكنك تعريف دالة إعادة توجيه عامة لـ `GoRouter` بأكمله، والتي يتم تشغيلها قبل أي إعادة توجيه خاصة بالمسار.
    ```dart
    final _router = GoRouter(
      routes: [...],
      redirect: (context, state) {
        // منطق إعادة التوجيه العام هنا
        final isLoggedIn = AuthService.isLoggedIn();
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/';

        return null; // لا توجد إعادة توجيه
      },
    );
    ```
    *   هذا مفيد لفرض قواعد المصادقة أو التخويل (authorization) على مستوى التطبيق.

### 2. الحراس (Guards)

الحراس هم في الأساس منطق يتم تنفيذه قبل أو بعد الدخول/الخروج من مسار معين. في `go_router`، يتم تحقيق ذلك بشكل أساسي من خلال دالة `redirect` نفسها، ولكن يمكن أيضاً استخدام `onExit`.

*   **`onExit`:** هذه الدالة يتم تشغيلها عندما يحاول المستخدم مغادرة مسار معين. يمكن استخدامها لطلب تأكيد من المستخدم قبل المغادرة، أو حفظ البيانات غير المحفوظة.
    ```dart
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => EditProfileScreen(),
      onExit: (context) async {
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('تأكيد'),
            content: const Text('هل أنت متأكد من مغادرة هذه الصفحة؟ قد تفقد التغييرات غير المحفوظة.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('مغادرة')),
            ],
          ),
        );
        return confirmed ?? false; // إذا لم يتم التأكيد، يتم منع المغادرة
      },
    ),
    ```
    *   إذا أعادت `onExit` قيمة `false`، فسيتم منع المستخدم من مغادرة المسار.
    *   إذا أعادت `true`، فسيتم السماح بالمغادرة.

**استخدامات إعادة التوجيه والحراس:**
*   **تدفقات المصادقة (Authentication flows):** توجيه المستخدمين إلى شاشات تسجيل الدخول/الخروج.
*   **الوصول المستند إلى الدور (Role-based access):** السماح فقط للمستخدمين ذوي الأدوار المحددة بالوصول إلى مسارات معينة (مثل مسارات المسؤول).
*   **التحقق من البيانات:** منع المستخدمين من مغادرة صفحة إذا كانت هناك بيانات غير صالحة أو غير محفوظة.
*   **إدارة المسارات القديمة/المتغيرة:** إعادة توجيه المستخدمين بسلاسة من عناوين URL القديمة إلى الجديدة.

## 12. التعامل مع الأخطاء (Error Handling) في GoRouter

يعد التعامل مع الأخطاء، مثل محاولة المستخدم الوصول إلى مسار غير موجود، جزءاً أساسياً من بناء تطبيق قوي. يوفر `go_router` آليات مدمجة للتعامل مع هذه السيناريوهات، أبرزها عرض صفحة 404 مخصصة.

### صفحات 404 المخصصة (Custom 404 Pages)

عندما يحاول المستخدم الوصول إلى مسار غير معرف في تكوين `GoRouter` الخاص بك، سيقوم `go_router` تلقائياً بتشغيل دالة `errorBuilder` إذا تم توفيرها. يتيح لك ذلك عرض صفحة خطأ مخصصة بدلاً من السلوك الافتراضي.

```dart
final _router = GoRouter(
  routes: [
    // ... تعريف المسارات الخاصة بك
  ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error), // شاشة الخطأ المخصصة
);

// تعريف شاشة الخطأ
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'عذراً، الصفحة غير موجودة!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (error != null) Text(error.toString()),
            ElevatedButton(
              onPressed: () => context.go('/'), // العودة إلى الشاشة الرئيسية
              child: const Text('العودة إلى الرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**شرح `errorBuilder`:**
*   `errorBuilder`: هذه الخاصية في `GoRouter` تتوقع دالة تُرجع ويدجت (widget) سيتم عرضه عندما يحدث خطأ في التنقل (مثل مسار غير موجود).
*   `state.error`: كائن `GoRouterState` الذي يتم تمريره إلى `errorBuilder` يحتوي على خاصية `error`، والتي يمكن أن توفر تفاصيل حول الخطأ الذي حدث.

**أفضل الممارسات للتعامل مع الأخطاء:**
*   **توفير رسالة واضحة:** أخبر المستخدم بوضوح أن الصفحة غير موجودة أو أن هناك خطأ ما.
*   **خيارات التنقل:** قدم خيارات للمستخدم، مثل العودة إلى الشاشة الرئيسية أو الاتصال بالدعم.
*   **تسجيل الأخطاء:** في بيئات الإنتاج، تأكد من تسجيل هذه الأخطاء (باستخدام أدوات مثل Firebase Crashlytics) لمساعدتك في تحديد المشكلات وحلها.
*   **التعامل مع الأخطاء الأخرى:** يمكن أيضاً استخدام `errorBuilder` للتعامل مع أنواع أخرى من الأخطاء التي قد تحدث أثناء تحليل المسار أو بناء الويدجت.

## 13. التنقل في الويب (Web Navigation) والروابط العميقة (Deep Linking)

إحدى نقاط القوة الرئيسية لـ `go_router` هي دعمه الممتاز لتطبيقات الويب والروابط العميقة (deep linking) في تطبيقات الهاتف المحمول. هذا يعني أن تطبيقك يمكنه الاستجابة لعناوين URL الخارجية أو الداخلية بطريقة متسقة.

### التنقل في الويب

عند استخدام `go_router` في تطبيق Flutter للويب، فإنه يتعامل تلقائياً مع تغييرات URL في المتصفح. عندما ينتقل المستخدم بين المسارات في تطبيقك، سيتم تحديث URL في شريط عنوان المتصفح ليعكس المسار الحالي. وبالمثل، إذا قام المستخدم بتعديل URL يدوياً في المتصفح أو استخدم أزرار العودة/الأمام في المتصفح، فسيقوم `go_router` بتحديث واجهة المستخدم لتتناسب مع المسار الجديد.

**لا يتطلب إعداداً خاصاً:** بمجرد تكوين `GoRouter` في `MaterialApp.router`، يتم التعامل مع سلوك الويب هذا تلقائياً.

### الروابط العميقة (Deep Linking)

الروابط العميقة هي عناوين URL التي توجه المستخدمين مباشرة إلى محتوى معين داخل تطبيق الهاتف المحمول، بدلاً من مجرد فتح التطبيق على شاشته الرئيسية. يدعم `go_router` الروابط العميقة بشكل طبيعي.

**كيف يعمل الروابط العميقة مع GoRouter؟**

عندما يتم فتح رابط عميق (سواء من متصفح ويب، أو تطبيق آخر، أو إشعار)، يقوم نظام التشغيل بتمرير URL إلى تطبيقك. يقوم `go_router` بعد ذلك بتحليل هذا URL ومطابقته مع المسارات المعرفة لديك، ثم يقوم ببناء مكدس التنقل المناسب وعرض الشاشة الصحيحة.

**إعداد الروابط العميقة:**

يتطلب إعداد الروابط العميقة خطوات خاصة بالمنصة (platform-specific) بالإضافة إلى تكوين `go_router`:

*   **Android:**
    *   تحتاج إلى إضافة `intent-filter` إلى ملف `AndroidManifest.xml` الخاص بك لتحديد مخططات (schemes) المخصصة أو نطاقات (domains) الويب التي سيتعامل معها تطبيقك.
    ```xml
    <activity ...>
        <intent-filter>
            <action android:name=
android.intent.action.VIEW
"/>
            <category android:name="android.intent.category.DEFAULT"/>
            <category android:name="android.intent.category.BROWSABLE"/>
            <data android:scheme="myapp" android:host="products"/>
        </intent-filter>
    </activity>
    ```

*   **iOS:**
    *   تحتاج إلى إضافة `CFBundleURLTypes` إلى ملف `Info.plist` الخاص بك لتحديد مخططات URL المخصصة.
    ```xml
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.example.myapp</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>myapp</string>
            </array>
        </dict>
    </array>
    ```

بمجرد تكوين هذه الإعدادات الخاصة بالمنصة، سيتعامل `go_router` مع بقية العملية. على سبيل المثال، إذا تم فتح الرابط `myapp://products/123`، فسيقوم `go_router` بمطابقته مع المسار `/products/:id` وعرض `ProductDetailsScreen` مع `id` الصحيح.

## 14. إدارة الحالة (State Management) مع GoRouter

على الرغم من أن `go_router` يركز على التنقل، إلا أنه يتكامل بسلاسة مع حلول إدارة الحالة الشائعة في Flutter. هذا التكامل ضروري لسيناريوهات مثل إعادة التوجيه بناءً على حالة المصادقة، أو تحديث واجهة المستخدم بناءً على التغييرات في الحالة.

### دمج GoRouter مع Bloc/Cubit

Bloc هو حل شائع لإدارة الحالة يفصل منطق الأعمال عن واجهة المستخدم. يمكن استخدامه مع `go_router` لإدارة حالة المصادقة والتحكم في التنقل.

**مثال: إعادة التوجيه بناءً على حالة المصادقة في Bloc**

1.  **`AuthBloc`:**
    ```dart
    // auth_state.dart
    enum AuthStatus { unknown, authenticated, unauthenticated }

    class AuthState extends Equatable {
      final AuthStatus status;
      final User? user;

      const AuthState._({this.status = AuthStatus.unknown, this.user});

      const AuthState.unknown() : this._();
      const AuthState.authenticated(User user) : this._(status: AuthStatus.authenticated, user: user);
      const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

      @override
      List<Object?> get props => [status, user];
    }
    ```

2.  **تكوين `GoRouter` مع `refreshListenable`:**
    خاصية `refreshListenable` في `GoRouter` تسمح لك بتوفير `Listenable` (مثل `ChangeNotifier` أو `Stream`) الذي سيؤدي إلى إعادة تقييم منطق إعادة التوجيه عند حدوث تغيير.

    ```dart
    // router.dart
    final _router = GoRouter(
      refreshListenable: GoRouterRefreshStream(context.read<AuthBloc>().stream), // الاستماع إلى تغييرات AuthBloc
      routes: [...],
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isLoggedIn = authState.status == AuthStatus.authenticated;
        final isLoggingIn = state.matchedLocation == 
'/login
';

        if (!isLoggedIn && !isLoggingIn) return 
'/login
';
        if (isLoggedIn && isLoggingIn) return 
'/
';

        return null;
      },
    );
    ```
    *   `GoRouterRefreshStream` هي فئة مساعدة (helper class) تحول `Stream` إلى `Listenable`.
    *   عندما يصدر `AuthBloc` حالة جديدة، سيتم تشغيل دالة `redirect` مرة أخرى، مما يضمن أن المستخدم يتم توجيهه إلى المسار الصحيح بناءً على حالة المصادقة الجديدة.

### دمج GoRouter مع Provider

Provider هو حل بسيط لإدارة الحالة يعتمد على `InheritedWidget`. يمكن استخدامه أيضاً مع `go_router` لإدارة حالة التنقل.

**مثال: إعادة التوجيه باستخدام `ChangeNotifier`**

1.  **`AuthNotifier`:**
    ```dart
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
    ```

2.  **تكوين `GoRouter` مع `refreshListenable`:**
    ```dart
    // router.dart
    final authNotifier = AuthNotifier(); // يجب توفيره عبر Provider

    final _router = GoRouter(
      refreshListenable: authNotifier, // AuthNotifier هو Listenable
      routes: [...],
      redirect: (context, state) {
        final isLoggedIn = authNotifier.isLoggedIn;
        final isLoggingIn = state.matchedLocation == 
'/login
';

        if (!isLoggedIn && !isLoggingIn) return 
'/login
';
        if (isLoggedIn && isLoggingIn) return 
'/
';

        return null;
      },
    );
    ```
    *   بما أن `ChangeNotifier` يطبق `Listenable`، يمكنك تمريره مباشرة إلى `refreshListenable`.
    *   عندما يتم استدعاء `notifyListeners()` في `AuthNotifier`، سيتم إعادة تقييم دالة `redirect`.

### دمج GoRouter مع Riverpod

Riverpod هو حل حديث لإدارة الحالة يوفر مرونة وأماناً أكبر من Provider. التكامل مع `go_router` بسيط وفعال.

**مثال: إعادة التوجيه باستخدام `StateNotifierProvider`**

1.  **`AuthNotifier` و `Provider`:**
    ```dart
    // auth_provider.dart
    final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
      return AuthNotifier();
    });

    class AuthNotifier extends StateNotifier<AuthState> {
      AuthNotifier() : super(const AuthState.unauthenticated());

      void login(User user) {
        state = AuthState.authenticated(user);
      }

      void logout() {
        state = const AuthState.unauthenticated();
      }
    }
    ```

2.  **تكوين `GoRouter`:**
    في Riverpod، لا تحتاج عادةً إلى `refreshListenable` إذا قمت بتكوين الراوتر بطريقة تراقب حالة المصادقة.

    ```dart
    // router_provider.dart
    final routerProvider = Provider<GoRouter>((ref) {
      final authState = ref.watch(authStateProvider);

      return GoRouter(
        routes: [...],
        redirect: (context, state) {
          final isLoggedIn = authState.status == AuthStatus.authenticated;
          final isLoggingIn = state.matchedLocation == 
'/login
';

          if (!isLoggedIn && !isLoggingIn) return 
'/login
';
          if (isLoggedIn && isLoggingIn) return 
'/
';

          return null;
        },
      );
    });
    ```
    *   في `ConsumerWidget` أو `ConsumerStatefulWidget` الرئيسي، يمكنك قراءة `routerProvider` وتمريره إلى `MaterialApp.router`.
    *   `ref.watch(authStateProvider)` سيؤدي إلى إعادة بناء `GoRouter` (وبالتالي إعادة تقييم `redirect`) كلما تغيرت حالة المصادقة.

## 15. تحسين الأداء (Performance Optimization)

في التطبيقات الكبيرة، يمكن أن يؤثر تحميل جميع المسارات والويدجت المرتبطة بها مقدماً على وقت بدء التشغيل واستهلاك الذاكرة. يوفر `go_router` تقنيات لتحسين الأداء، مثل التحميل الكسول (lazy loading).

### التحميل الكسول للمسارات (Lazy Loading Routes)

التحميل الكسول يعني تأجيل تحميل كود المسار والويدجت المرتبط به حتى يتم طلبه بالفعل. يمكن تحقيق ذلك باستخدام `deferred as` في Dart.

1.  **إنشاء ملفات منفصلة للمسارات:**
    ضع كل شاشة (أو مجموعة من الشاشات ذات الصلة) في ملف Dart منفصل.

2.  **استخدام `deferred as`:**
    في ملف تكوين الراوتر الرئيسي، استورد هذه الملفات باستخدام `deferred as`.

    ```dart
    // router.dart
    import 
'screens/home_screen.dart
' deferred as home;
    import 
'screens/settings_screen.dart
' deferred as settings;

    final _router = GoRouter(
      routes: [
        GoRoute(
          path: 
'/
',
          builder: (context, state) => home.HomeScreen(),
        ),
        GoRoute(
          path: 
'/settings
',
          builder: (context, state) => FutureBuilder<void>(
            future: settings.loadLibrary(), // تحميل المكتبة عند الطلب
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return settings.SettingsScreen(); // بناء الويدجت بعد التحميل
              }
              return const Center(child: CircularProgressIndicator()); // عرض مؤشر تحميل
            },
          ),
        ),
      ],
    );
    ```
    *   `deferred as` يخبر Dart بعدم تضمين الكود من `settings_screen.dart` في ملف الإخراج الرئيسي.
    *   `settings.loadLibrary()` هي دالة يتم إنشاؤها تلقائياً تقوم بتحميل الكود المؤجل عند استدعائها.
    *   يتم استخدام `FutureBuilder` لعرض مؤشر تحميل أثناء تحميل الكود، ثم بناء الويدجت بمجرد اكتمال التحميل.

**ملاحظة:** التحميل الكسول مفيد بشكل خاص في تطبيقات الويب لتقليل حجم الحزمة الأولية وتحسين وقت التحميل الأولي للصفحة.

### التخزين المؤقت (Caching)

على الرغم من أن `go_router` لا يوفر آلية تخزين مؤقت مدمجة للمسارات، إلا أنه يمكنك تنفيذها باستخدام حلول إدارة الحالة الخاصة بك. على سبيل المثال، يمكنك تخزين البيانات التي يتم جلبها من الشبكة في `Bloc` أو `Provider`، بحيث لا تحتاج إلى إعادة جلبها في كل مرة يتم فيها زيارة المسار.

## 16. أفضل ممارسات الأمان (Security Best Practices)

يعد تأمين المسارات الحساسة أمراً بالغ الأهمية، خاصة في التطبيقات التي تتعامل مع بيانات المستخدم أو لديها أقسام إدارية.

*   **استخدام `redirect` للمصادقة والتخويل:** كما هو موضح في قسم إعادة التوجيه، استخدم `redirect` لفرض قواعد المصادقة (هل المستخدم مسجل الدخول؟) والتخويل (هل لدى المستخدم الدور الصحيح؟).
*   **عدم تمرير البيانات الحساسة في URL:** تجنب وضع البيانات الحساسة (مثل الرموز المميزة (tokens) أو كلمات المرور) في معاملات المسار أو الاستعلام، حيث يمكن أن يتم تسجيلها أو تخزينها مؤقتاً. استخدم `extra` أو حلول إدارة الحالة لتمرير هذه البيانات.
*   **التحقق من صحة المعاملات:** تحقق دائماً من صحة المعاملات التي تتلقاها من `GoRouterState`. لا تثق أبداً في أن البيانات ستكون بالتنسيق المتوقع. على سبيل المثال، إذا كنت تتوقع معرفاً رقمياً، فتأكد من تحليله والتعامل مع الأخطاء المحتملة.
*   **فصل منطق التوجيه:** حافظ على منطق التوجيه الخاص بك (خاصة منطق إعادة التوجيه) منفصلاً عن واجهة المستخدم قدر الإمكان. هذا يجعله أسهل في الاختبار والمراجعة بحثاً عن الثغرات الأمنية.

## 17. كيفية إعداد مشروع Flutter حقيقي باستخدام GoRouter

(هذا القسم مطابق للقسم الموجود في المقال الأصلي، ويوفر مثالاً عملياً كاملاً لتطبيق تسوق بسيط باستخدام `go_router`.)

(سيتم إدراج الكود الكامل للمشروع هنا كما في النسخة السابقة...)

## 18. الخاتمة (Conclusion)

`go_router` هي أداة قوية ومرنة بشكل لا يصدق في مجموعة أدوات مطور Flutter. من خلال تبسيط تعقيدات `Navigator 2.0` وتقديم واجهة برمجة تطبيقات نظيفة وقائمة على الروابط، فإنها تمكن المطورين من بناء هياكل تنقل معقدة بسهولة وثقة. سواء كنت تبني تطبيقاً بسيطاً للهاتف المحمول، أو تطبيق ويب معقداً، أو تطبيقاً متعدد المنصات، فإن `go_router` يوفر الأساس الذي تحتاجه لإنشاء تجربة مستخدم سلسة وقابلة للصيانة.

من خلال فهم المفاهيم الأساسية مثل المسارات، وإعادة التوجيه، و `ShellRoute`، ودمجها مع حلول إدارة الحالة القوية، يمكنك الاستفادة الكاملة من إمكانات `go_router` وتركيز جهودك على بناء ميزات رائعة بدلاً من القلق بشأن إدارة مكدس التنقل.

## 19. المراجع (References)
1.  [الوثائق الرسمية لـ go_router على pub.dev](https://pub.dev/packages/go_router)
2.  [مستودع go_router على GitHub](https://github.com/flutter/packages/tree/main/packages/go_router)
3.  [فيديو: تعلم GoRouter (Flutter)](https://www.youtube.com/watch?v=ny__51K9o-k)
4.  [مقال: التنقل في Flutter باستخدام GoRouter](https://codewithandrea.com/articles/flutter-navigation-gorouter-go-vs-push/)

### 17.1. هيكل المشروع (Project Structure)

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

### 17.2. `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it_auto_router_go_router/go_router/config/route_config.dart';

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
      routerConfig: router, // go router
    );
  }
}
```

### 17.3. Model (`product.dart`)

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

### 17.4. Controller (`product_controller.dart`)

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

### 17.5. Config (`route_config.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:get_it_auto_router_go_router/go_router/controllers/product_controller.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../screens/product_details_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/product_purchase_screen.dart';

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
                      content: const Text('Are you sure to leave th'),
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

### 17.6. Screens

#### `product_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get_it_auto_router_go_router/go_router/controllers/product_controller.dart';
import 'package:get_it_auto_router_go_router/go_router/screens/product_details_screen.dart';
import 'package:get_it_auto_router_go_router/go_router/widgets/search_section.dart';
import 'package:get_it_auto_router_go_router/go_router/widgets/single_product.dart';
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

#### `product_details_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../widgets/bottom_container.dart';
import '../widgets/color_container.dart';
import '../widgets/ratings.dart';
import '../widgets/show_modal.dart';

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

#### `product_purchase_screen.dart`

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

### 17.7. Widgets

#### `bottom_container.dart`

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

#### `ratings.dart`

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

#### `color_container.dart`

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

#### `search_section.dart`

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

#### `show_modal.dart`

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

#### `single_product.dart`

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

## 18. الخاتمة (Conclusion)

`go_router` هي أداة قوية ومرنة بشكل لا يصدق في مجموعة أدوات مطور Flutter. من خلال تبسيط تعقيدات `Navigator 2.0` وتقديم واجهة برمجة تطبيقات نظيفة وقائمة على الروابط، فإنها تمكن المطورين من بناء هياكل تنقل معقدة بسهولة وثقة. سواء كنت تبني تطبيقاً بسيطاً للهاتف المحمول، أو تطبيق ويب معقداً، أو تطبيقاً متعدد المنصات، فإن `go_router` يوفر الأساس الذي تحتاجه لإنشاء تجربة مستخدم سلسة وقابلة للصيانة.

من خلال فهم المفاهيم الأساسية مثل المسارات، وإعادة التوجيه، و `ShellRoute`، ودمجها مع حلول إدارة الحالة القوية، يمكنك الاستفادة الكاملة من إمكانات `go_router` وتركيز جهودك على بناء ميزات رائعة بدلاً من القلق بشأن إدارة مكدس التنقل.

## 19. المراجع (References)
1.  [الوثائق الرسمية لـ go_router على pub.dev](https://pub.dev/packages/go_router)
2.  [مستودع go_router على GitHub](https://github.com/flutter/packages/tree/main/packages/go_router)
3.  [فيديو: تعلم GoRouter (Flutter)](https://www.youtube.com/watch?v=ny__51K9o-k)
4.  [مقال: التنقل في Flutter باستخدام GoRouter](https://codewithandrea.com/articles/flutter-navigation-gorouter-go-vs-push/)

## 10.1. خصائص GoRoute المتقدمة

بالإضافة إلى الخصائص الأساسية مثل `path` و `builder` و `name`، يوفر `GoRoute` العديد من الخصائص المتقدمة التي تتيح تحكماً أدق في سلوك المسار.

*   **`pageBuilder`:** بدلاً من `builder`، يمكنك استخدام `pageBuilder` لتوفير كائن `Page` مخصص. هذا يمنحك تحكماً كاملاً في نوع الصفحة (مثل `MaterialPage` أو `CupertinoPage`) والانتقالات (transitions) المرتبطة بها. إذا لم يتم توفيره، سيقوم `go_router` بإنشاء `MaterialPage` افتراضية.
    ```dart
    GoRoute(
      path: 
'/custom-transition

',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: CustomTransitionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // بناء انتقال مخصص هنا
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    ```

*   **`parentNavigatorKey`:** في السيناريوهات التي تستخدم فيها `ShellRoute` أو عدة `Navigator`s، قد تحتاج إلى تحديد أي `Navigator` يجب أن يدفع المسار إليه. تسمح لك هذه الخاصية بتوفير `GlobalKey<NavigatorState>` لـ `Navigator` الأب المستهدف.
    ```dart
    final _shellNavigatorKey = GlobalKey<NavigatorState>();

    ShellRoute(
      navigatorKey: _shellNavigatorKey, // مفتاح لـ Navigator الخاص بـ ShellRoute
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: 
'/home

',
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: 
'/settings

',
          parentNavigatorKey: _shellNavigatorKey, // يدفع إلى Navigator الخاص بـ ShellRoute
          builder: (context, state) => SettingsScreen(),
        ),
      ],
    ),
    ```

*   **`restorationId`:** هذه الخاصية مفيدة لاستعادة حالة التنقل (navigation state) عبر عمليات إعادة تشغيل التطبيق أو تغييرات التكوين. يوفر `restorationId` معرفاً فريداً للمسار يمكن استخدامه بواسطة نظام استعادة الحالة في Flutter.
    ```dart
    GoRoute(
      path: 
'/detail/:id

',
      restorationId: 
'detailRoute

',
      builder: (context, state) => DetailScreen(id: state.pathParameters[
'id

']!),
    ),
    ```

## 10.2. استخدامات ShellRoute المتطورة

يمكن أن تكون `ShellRoute` أكثر قوة مما تبدو عليه في البداية، خاصة عند التعامل مع سيناريوهات واجهة المستخدم المعقدة.

### تداخل ShellRoute (Nested ShellRoutes)

يمكنك تداخل `ShellRoute`s لإنشاء هياكل واجهة مستخدم متعددة المستويات. على سبيل المثال، قد يكون لديك `ShellRoute` رئيسي لشريط التنقل السفلي، وداخله `ShellRoute` آخر لقائمة جانبية أو شريط علوي مختلف.

```dart
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey, // Navigator الخاص بـ ShellRoute الداخلي
      builder: (context, state, child) {
        return MainScaffoldWithBottomNav(child: child); // يحتوي على BottomNavigationBar
      },
      routes: [
        GoRoute(
          path: 
'/a

',
          builder: (context, state) => ScreenA(),
          routes: [
            GoRoute(
              path: 
'details

',
              builder: (context, state) => DetailsScreenA(),
            ),
          ],
        ),
        GoRoute(
          path: 
'/b

',
          builder: (context, state) => ScreenB(),
        ),
      ],
    ),
    // مسار يفتح فوق كل ShellRoutes (مثل شاشة تسجيل الدخول)
    GoRoute(
      path: 
'/login

',
      builder: (context, state) => LoginScreen(),
      parentNavigatorKey: _rootNavigatorKey, // يدفع إلى Navigator الجذري
    ),
  ],
);
```

في هذا المثال، `LoginScreen` سيتم دفعها فوق `MainScaffoldWithBottomNav`، بينما `DetailsScreenA` سيتم دفعها داخل `MainScaffoldWithBottomNav`.

### الحفاظ على حالة BottomNavigationBar (Preserving BottomNavigationBar State)

عند استخدام `ShellRoute` مع `BottomNavigationBar`، قد ترغب في الحفاظ على حالة كل علامة تبويب (tab) عند التبديل بينها. هذا يعني أنك إذا انتقلت إلى علامة تبويب، ثم انتقلت إلى شاشة داخل تلك العلامة، ثم بدلت إلى علامة تبويب أخرى وعدت، يجب أن تظل الشاشة الداخلية مرئية.

`go_router` يدعم هذا السلوك تلقائياً عند استخدام `ShellRoute` بشكل صحيح. كل فرع (branch) من `ShellRoute` يحافظ على مكدس التنقل الخاص به. ومع ذلك، قد تحتاج إلى إدارة مؤشر `BottomNavigationBar` يدوياً.

```dart
class MainScaffoldWithBottomNav extends StatefulWidget {
  final Widget child;
  const MainScaffoldWithBottomNav({super.key, required this.child});

  @override
  State<MainScaffoldWithBottomNav> createState() => _MainScaffoldWithBottomNavState();
}

class _MainScaffoldWithBottomNavState extends State<MainScaffoldWithBottomNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // التنقل إلى المسار الصحيح بناءً على الفهرس
          switch (index) {
            case 0:
              context.go(
'/a

');
              break;
            case 1:
              context.go(
'/b

');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 
'Home

'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 
'Settings

'),
        ],
      ),
    );
  }
}
```

**ملاحظة:** لضمان عمل `BottomNavigationBar` بشكل صحيح مع `go_router`، يجب أن تستخدم `context.go()` للانتقال بين الفروع الرئيسية، وليس `context.push()`، للحفاظ على مكدس التنقل لكل فرع.

## 8.1. المزيد من طرق التنقل في GoRouter

بالإضافة إلى `go()` و `push()` و `goNamed()` و `pushNamed()`، يوفر `go_router` طرقاً أخرى للتحكم في مكدس التنقل.

*   **`context.pop()`:** تزيل المسار العلوي من مكدس التنقل. تعادل `Navigator.pop()`.
    ```dart
    // العودة إلى الشاشة السابقة
    context.pop();
    ```

*   **`context.popToNamed(name)`:** تزيل جميع المسارات من المكدس حتى تصل إلى المسار المسمى المحدد. إذا لم يتم العثور على المسار، فلن يحدث شيء.
    ```dart
    // العودة إلى الشاشة الرئيسية المسمّاة 
'homeRoute

'
    context.popToNamed(
'homeRoute

');
    ```

*   **`context.replace(path)` / `context.replaceNamed(name)`:** تستبدل المسار الحالي في مكدس التنقل بالمسار الجديد. على عكس `go()`، فإنه لا يمسح المكدس بأكمله، بل يستبدل العنصر العلوي فقط. هذا مفيد عندما لا تريد أن يتمكن المستخدم من العودة إلى الشاشة التي استبدلتها.
    ```dart
    // استبدال الشاشة الحالية بشاشة تسجيل الدخول بعد تسجيل الخروج
    context.replace(
'/login

');
    ```

*   **`context.pushReplacement(path)` / `context.pushReplacementNamed(name)`:** يدفع مساراً جديداً إلى المكدس ويزيل المسار الحالي. هذا يختلف عن `replace()` في أنه لا يزال يضيف إلى المكدس، ولكنه يضمن أن الشاشة السابقة غير قابلة للوصول عبر زر العودة.
    ```dart
    // بعد إكمال عملية الشراء، انتقل إلى شاشة التأكيد واستبدل شاشة الشراء
    context.pushReplacement(
'/order-confirmation

');
    ```

*   **`context.goBranch(index)`:** هذه الطريقة خاصة بـ `ShellRoute` وتُستخدم للانتقال بين فروع `ShellRoute` المختلفة (عادةً ما تكون علامات تبويب `BottomNavigationBar`).
    ```dart
    // الانتقال إلى الفرع الثاني (الفهرس 1) من ShellRoute
    context.goBranch(1);
    ```

## 12.1. التعامل مع أخطاء تحليل المسار (Route Parsing Errors)

بالإضافة إلى الأخطاء 404 (المسار غير الموجود)، قد تحدث أخطاء أثناء تحليل المسار إذا كانت المعاملات غير صالحة أو مفقودة. يمكن لـ `errorBuilder` التعامل مع هذه الحالات أيضاً.

```dart
final _router = GoRouter(
  routes: [
    GoRoute(
      path: 
'/product/:id

',
      builder: (context, state) {
        final id = state.pathParameters[
'id

'];
        if (id == null || int.tryParse(id) == null) {
          // يمكن رمي استثناء هنا أو إعادة توجيه إلى صفحة خطأ محددة
          throw Exception(
'Invalid product ID

');
        }
        return ProductScreen(productId: int.parse(id));
      },
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);
```

في هذا المثال، إذا كان `id` غير رقمي، فسيتم رمي استثناء، وسيتم التقاطه بواسطة `errorBuilder` لعرض `ErrorScreen`.

## 15.1. التخزين المؤقت (Caching) في GoRouter

بينما لا يوفر `go_router` آلية تخزين مؤقت مدمجة للمسارات، يمكنك تحقيق التخزين المؤقت على مستوى البيانات أو الويدجت لتحسين الأداء وتجربة المستخدم.

### التخزين المؤقت للبيانات (Data Caching)

إذا كانت شاشاتك تعرض بيانات يتم جلبها من الشبكة، فيمكنك استخدام حلول إدارة الحالة (مثل Bloc, Provider, Riverpod) لتخزين هذه البيانات مؤقتاً. بهذه الطريقة، عندما يعود المستخدم إلى شاشة سبق له زيارتها، لا تحتاج إلى إعادة جلب البيانات من الخادم.

**مثال باستخدام Provider:**

```dart
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

// في ProductListScreen:
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepository = Provider.of<ProductRepository>(context);

    if (productRepository.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: productRepository.products.length,
      itemBuilder: (context, index) {
        final product = productRepository.products[index];
        return ListTile(title: Text(product.name));
      },
    );
  }
}
```

### التخزين المؤقت للويدجت (Widget Caching)

في بعض الحالات، قد ترغب في الحفاظ على حالة ويدجت معين حتى عند إزالته مؤقتاً من شجرة الويدجت (widget tree). يمكن تحقيق ذلك باستخدام `AutomaticKeepAliveClientMixin` في `StatefulWidget`s التي تكون جزءاً من `PageView` أو `IndexedStack` داخل `ShellRoute`.

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
          Text(
'Counter: $_counter

'),
          ElevatedButton(
            onPressed: () => setState(() => _counter++),
            child: const Text(
'Increment

'),
          ),
        ],
      ),
    );
  }
}
```

## 16.1. أفضل ممارسات الأمان الإضافية

*   **تصفية المدخلات (Input Sanitization):** إذا كنت تستخدم معاملات المسار أو الاستعلام لعرض المحتوى مباشرة في واجهة المستخدم (خاصة في تطبيقات الويب)، فتأكد من تصفية (sanitize) هذه المدخلات لمنع هجمات البرمجة النصية عبر المواقع (XSS).
*   **التحقق من التخويل على الخادم (Server-side Authorization):** لا تعتمد فقط على منطق العميل (client-side logic) للتحكم في الوصول. يجب أن يتم التحقق من التخويل دائماً على الخادم أيضاً، حيث يمكن تجاوز منطق العميل.
*   **استخدام HTTPS:** تأكد دائماً من استخدام HTTPS لجميع الاتصالات الشبكية لتشفير البيانات المنقولة، بما في ذلك أي بيانات حساسة قد تكون جزءاً من عناوين URL.

## 20. اختبار GoRouter (Testing GoRouter)

يعد اختبار منطق التنقل أمراً بالغ الأهمية لضمان سلوك التطبيق الصحيح. يمكن اختبار `go_router` باستخدام اختبارات الوحدة (unit tests) واختبارات الويدجت (widget tests).

### اختبارات الوحدة لمنطق إعادة التوجيه (Unit Tests for Redirection Logic)

يمكنك اختبار دالة `redirect` بشكل منفصل عن واجهة المستخدم.

```dart
import 
'package:flutter_test/flutter_test.dart

';
import 
'package:go_router/go_router.dart

';
import 
'package:mockito/mockito.dart

';

// Mock AuthService for testing
class MockAuthService extends Mock implements AuthService {}

void main() {
  group(
'GoRouter Redirection Tests

', () {
    late MockAuthService mockAuthService;
    late GoRouter router;

    setUp(() {
      mockAuthService = MockAuthService();
      // تهيئة GoRouter مع دالة redirect التي تعتمد على MockAuthService
      router = GoRouter(
        routes: [
          GoRoute(path: 
'/

', builder: (context, state) => const Text(
'Home

')),
          GoRoute(path: 
'/login

', builder: (context, state) => const Text(
'Login

')),
          GoRoute(path: 
'/dashboard

', builder: (context, state) => const Text(
'Dashboard

')),
        ],
        redirect: (context, state) {
          final isLoggedIn = mockAuthService.isLoggedIn();
          final isLoggingIn = state.matchedLocation == 
'/login

';

          if (!isLoggedIn && !isLoggingIn) return 
'/login

';
          if (isLoggedIn && isLoggingIn) return 
'/

';
          return null;
        },
      );
    });

    test(
'should redirect to login if not logged in and not on login page

', () {
      when(mockAuthService.isLoggedIn()).thenReturn(false);
      final GoRouterState state = GoRouterState(location: 
'/dashboard

', subloc: 
'/dashboard

', path: 
'/dashboard

', pageKey: const ValueKey(
'dashboard

'));
      final String? redirectPath = router.routerDelegate.redirect(null, state);
      expect(redirectPath, 
'/login

');
    });

    test(
'should redirect to home if logged in and on login page

', () {
      when(mockAuthService.isLoggedIn()).thenReturn(true);
      final GoRouterState state = GoRouterState(location: 
'/login

', subloc: 
'/login

', path: 
'/login

', pageKey: const ValueKey(
'login

'));
      final String? redirectPath = router.routerDelegate.redirect(null, state);
      expect(redirectPath, 
'/

');
    });

    test(
'should not redirect if logged in and on dashboard page

', () {
      when(mockAuthService.isLoggedIn()).thenReturn(true);
      final GoRouterState state = GoRouterState(location: 
'/dashboard

', subloc: 
'/dashboard

', path: 
'/dashboard

', pageKey: const ValueKey(
'dashboard

'));
      final String? redirectPath = router.routerDelegate.redirect(null, state);
      expect(redirectPath, isNull);
    });
  });
}
```

**ملاحظة:** ستحتاج إلى إضافة حزمة `mockito` إلى `dev_dependencies` في `pubspec.yaml`.

### اختبارات الويدجت للتنقل (Widget Tests for Navigation)

يمكنك استخدام اختبارات الويدجت لمحاكاة تفاعلات المستخدم والتحقق من أن التنقل يحدث بشكل صحيح.

```dart
import 
'package:flutter/material.dart

';
import 
'package:flutter_test/flutter_test.dart

';
import 
'package:go_router/go_router.dart

';

void main() {
  group(
'GoRouter Widget Tests

', () {
    testWidgets(
'should navigate to detail screen when button is tapped

', (tester) async {
      final _router = GoRouter(
        routes: [
          GoRoute(
            path: 
'/

',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (innerContext) => ElevatedButton(
                  onPressed: () => innerContext.go(
'/detail/123

'),
                  child: const Text(
'Go to Detail

'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: 
'/detail/:id

',
            builder: (context, state) => Text(
'Detail Screen: ${state.pathParameters[
'id

']!}

'),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: _router));

      expect(find.text(
'Go to Detail

'), findsOneWidget);
      expect(find.text(
'Detail Screen: 123

'), findsNothing);

      await tester.tap(find.text(
'Go to Detail

'));
      await tester.pumpAndSettle(); // انتظر حتى تكتمل الرسوم المتحركة للتنقل

      expect(find.text(
'Go to Detail

'), findsNothing);
      expect(find.text(
'Detail Screen: 123

'), findsOneWidget);
    });
  });
}
```

## 21. الرسوم المتحركة والانتقالات المخصصة (Custom Animations and Transitions)

يتيح لك `go_router` تخصيص الرسوم المتحركة والانتقالات بين الصفحات باستخدام `pageBuilder`.

```dart
GoRoute(
  path: 
'/fade-in

',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: FadeInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  },
),
```

*   **`CustomTransitionPage`:** يمنحك تحكماً كاملاً في كيفية بناء الصفحة والانتقال إليها.
*   **`transitionsBuilder`:** دالة تُرجع ويدجت انتقال (transition widget) (مثل `FadeTransition`, `SlideTransition`, `ScaleTransition`).
*   **`transitionDuration`:** يحدد مدة الرسوم المتحركة.

## 22. مراقبو المسار (Route Observers)

يمكنك استخدام `GoRouterObserver` لمراقبة أحداث التنقل (مثل دفع المسارات، سحبها، أو استبدالها). هذا مفيد لتسجيل التحليلات (analytics)، أو تسجيل الدخول (logging)، أو تنفيذ منطق مخصص عند تغيير المسار.

1.  **إنشاء `GoRouterObserver` مخصص:**
    ```dart
    class MyGoRouterObserver extends GoRouterObserver {
      @override
      void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print(
'New route pushed: ${route.settings.name}

');
      }

      @override
      void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
        print(
'Route popped: ${route.settings.name}

');
      }

      @override
      void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
        print(
'Route replaced: ${oldRoute?.settings.name} with ${newRoute?.settings.name}

');
      }
      // يمكنك تجاوز المزيد من الدوال هنا
    }
    ```

2.  **إضافة المراقب إلى `GoRouter`:**
    ```dart
    final _router = GoRouter(
      routes: [...],
      observers: [MyGoRouterObserver()], // إضافة المراقب هنا
    );
    ```

## 23. إدارة المسارات لبيئات مختلفة (Managing Routes for Different Environments)

في التطبيقات الكبيرة، قد تحتاج إلى تكوينات مسار مختلفة لبيئات مختلفة (مثل التطوير، الاختبار، الإنتاج). يمكنك تحقيق ذلك عن طريق فصل تعريفات المسار واستخدام متغيرات البيئة.

```dart
// config/app_router.dart
import 
'package:flutter/material.dart

';
import 
'package:go_router/go_router.dart

';

enum AppEnvironment { dev, prod }

class AppRouter {
  static GoRouter createRouter(AppEnvironment environment) {
    return GoRouter(
      routes: [
        GoRoute(path: 
'/

', builder: (context, state) => const HomeScreen()),
        if (environment == AppEnvironment.dev) // مسارات خاصة بالتطوير فقط
          GoRoute(path: 
'/dev-tools

', builder: (context, state) => const DevToolsScreen()),
        // ... المزيد من المسارات
      ],
      // ...
    );
  }
}

// في main.dart:
void main() {
  const currentEnvironment = AppEnvironment.dev; // أو AppEnvironment.prod
  final router = AppRouter.createRouter(currentEnvironment);
  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      // ...
    );
  }
}
```

## 24. اعتبارات إمكانية الوصول (Accessibility Considerations)

عند تصميم التنقل في تطبيقك، من المهم مراعاة إمكانية الوصول للمستخدمين ذوي الإعاقة. `go_router`، كونه مبنياً على Router API في Flutter، يرث العديد من ميزات إمكانية الوصول.

*   **معاني التنقل (Navigation Semantics):** تأكد من أن عناصر التنقل الخاصة بك (مثل أزرار `BottomNavigationBar` أو `Drawer` items) تحتوي على `Semantics` مناسبة لوصف الغرض منها، مما يساعد قارئات الشاشة.
*   **ترتيب التركيز (Focus Order):** عند التنقل إلى شاشة جديدة، تأكد من أن التركيز الأولي (initial focus) يقع على العنصر الأكثر أهمية في الشاشة الجديدة.
*   **الروابط العميقة:** يمكن أن تكون الروابط العميقة مفيدة جداً للمستخدمين الذين يستخدمون تقنيات مساعدة، حيث تسمح لهم بالوصول مباشرة إلى المحتوى المطلوب دون الحاجة إلى التنقل عبر عدة شاشات.


---

## 25. لقطات شاشة قليلة (A Few Screenshots)

*(ملاحظة: لا يمكنني عرض الصور مباشرة هنا، ولكن الملف الأصلي يحتوي على لقطات شاشة توضيحية للتطبيق.)*


---

## 26. الخاتمة (Conclusion)

`go_router` هي أداة قوية ومرنة بشكل لا يصدق في مجموعة أدوات مطور Flutter. من خلال تبسيط تعقيدات `Navigator 2.0` وتقديم واجهة برمجة تطبيقات نظيفة وقائمة على الروابط، فإنها تمكن المطورين من بناء هياكل تنقل معقدة بسهولة وثقة. سواء كنت تبني تطبيقاً بسيطاً للهاتف المحمول، أو تطبيق ويب معقداً، أو تطبيقاً متعدد المنصات، فإن `go_router` يوفر الأساس الذي تحتاجه لإنشاء تجربة مستخدم سلسة وقابلة للصيانة.

من خلال فهم المفاهيم الأساسية مثل المسارات، وإعادة التوجيه، و `ShellRoute`، ودمجها مع حلول إدارة الحالة القوية، يمكنك الاستفادة الكاملة من إمكانات `go_router` وتركيز جهودك على بناء ميزات رائعة بدلاً من القلق بشأن إدارة مكدس التنقل.


---

## 27. المراجع (References)
1.  [الوثائق الرسمية لـ go_router على pub.dev](https://pub.dev/packages/go_router)
2.  [مستودع go_router على GitHub](https://github.com/flutter/packages/tree/main/packages/go_router)
3.  [فيديو: تعلم GoRouter (Flutter)](https://www.youtube.com/watch?v=ny__51K9o-k)
4.  [مقال: التنقل في Flutter باستخدام GoRouter](https://codewithandrea.com/articles/flutter-navigation-gorouter-go-vs-push/)
5.  [مقال: GoRouter: التنقل في Flutter بسهولة](https://medium.com/flutter-community/gorouter-navigation-in-flutter-with-ease-a67272223a6f)
6.  [وثائق Flutter الرسمية حول استعادة الحالة](https://docs.flutter.dev/ui/navigation/deep-linking#state-restoration)

**عن المؤلف:**
أتوها أنتوني هو مهندس برمجيات محمول أول (Senior Mobile Software Engineer) ولديه سجل حافل في بناء تطبيقات قابلة للتطوير وعالية الأداء عبر منصات مختلفة، بما في ذلك Android و iOS والويب وغيرها، باستخدام Flutter بشكل أساسي، إلى جانب Kotlin و Swift، والاستفادة من الذكاء الاصطناعي.

إذا قرأت هذا القدر، اشكر المؤلف لتظهر له اهتمامك.

[قل شكراً](https://www.freecodecamp.org/news/how-to-get-started-with-go-router-in-flutter/#say-thanks)

تعلم البرمجة مجاناً. ساعد منهج freeCodeCamp مفتوح المصدر أكثر من 40,000 شخص في الحصول على وظائف كمطورين.

[ابدأ](https://www.freecodecamp.org/)

freeCodeCamp هي منظمة خيرية معفاة من الضرائب بموجب المادة 501(c)(3) (الولايات المتحدة، رقم التعريف الضريبي الفيدرالي: 82-0779546) مدعومة من المتبرعين.

## 28. شرح معمق لمعاملات GoRouter الإنشائية (GoRouter Constructor Parameters)

عند تهيئة `GoRouter`، هناك العديد من المعاملات التي تمنحك تحكماً دقيقاً في سلوك الراوتر. فهم هذه المعاملات أمر بالغ الأهمية لإنشاء تجربة تنقل قوية ومخصصة.

*   **`routes` (مطلوب):** قائمة كائنات `RouteBase` (عادةً `GoRoute` أو `ShellRoute`) التي تحدد جميع المسارات الممكنة في تطبيقك. هذا هو جوهر تكوين الراوتر.

*   **`initialLocation` (اختياري):** المسار الأولي الذي يجب أن يعرضه التطبيق عند بدء التشغيل. إذا لم يتم تحديده، فسيتم استخدام `/` كمسار افتراضي. يمكن أن يكون مفيداً لتحديد نقطة دخول مختلفة لتطبيقات الويب أو اختبار سيناريوهات معينة.
    ```dart
    final _router = GoRouter(
      routes: [...],
      initialLocation: 
'/splash


', // يبدأ التطبيق بشاشة البداية
    );
    ```

*   **`initialExtra` (اختياري):** كائن يمكن تمريره كـ `extra` إلى المسار الأولي المحدد بواسطة `initialLocation`. مفيد لتمرير بيانات التهيئة الأولية.

*   **`debugLogDiagnostics` (اختياري، افتراضياً `false`):** إذا تم تعيينه على `true`، فسيقوم `go_router` بتسجيل معلومات تشخيصية مفصلة إلى وحدة التحكم (console) حول عملية التنقل، مثل مطابقة المسار، وإعادة التوجيه، وتغييرات مكدس التنقل. هذا مفيد جداً لتصحيح الأخطاء.

*   **`refreshListenable` (اختياري):** كائن `Listenable` (مثل `ChangeNotifier` أو `Stream`) الذي، عند إرسال إشعار، سيؤدي إلى إعادة تقييم دالة `redirect` الخاصة بالراوتر. هذا أمر بالغ الأهمية لسيناريوهات مثل إعادة التوجيه بناءً على حالة المصادقة التي تتغير بمرور الوقت.
    ```dart
    final _router = GoRouter(
      routes: [...],
      refreshListenable: authService, // authService هو ChangeNotifier
      redirect: (context, state) {
        // منطق إعادة التوجيه بناءً على authService.isLoggedIn
        return null;
      },
    );
    ```

*   **`redirect` (اختياري):** دالة `GoRouterRedirect` يتم استدعاؤها قبل كل عملية تنقل. تسمح لك بتنفيذ منطق إعادة التوجيه الشرطي (مثل حماية المسارات غير المصرح بها أو إعادة توجيه المستخدمين غير المصادق عليهم إلى صفحة تسجيل الدخول). يجب أن تُرجع `null` إذا لم يكن هناك إعادة توجيه، أو سلسلة (string) تمثل المسار الجديد.

*   **`redirectLimit` (اختياري، افتراضياً `5`):** يحدد الحد الأقصى لعدد عمليات إعادة التوجيه المتتالية المسموح بها قبل أن يرمي `go_router` خطأ `GoRouterRedirectLimitExceededException`. هذا يمنع حلقات إعادة التوجيه اللانهائية.

*   **`redirectCancelPop` (اختياري، افتراضياً `false`):** إذا تم تعيينه على `true`، فسيتم إلغاء عملية `pop` (العودة إلى الشاشة السابقة) إذا أدت إلى إعادة توجيه. هذا يمكن أن يكون مفيداً في سيناريوهات معينة لمنع المستخدمين من العودة إلى حالة غير صالحة.

*   **`errorBuilder` (اختياري):** دالة `GoRouterWidgetBuilder` تُستخدم لبناء ويدجت شاشة الخطأ عندما لا يمكن مطابقة مسار أو يحدث خطأ أثناء تحليل المسار. إذا لم يتم توفيره، فسيتم عرض شاشة خطأ افتراضية.
    ```dart
    final _router = GoRouter(
      routes: [...],
      errorBuilder: (context, state) => ErrorScreen(errorMessage: state.error.toString()),
    );
    ```

*   **`observers` (اختياري):** قائمة من `NavigatorObserver`s التي يمكن استخدامها لمراقبة أحداث التنقل (مثل دفع المسارات، سحبها، أو استبدالها). مفيد لتسجيل التحليلات أو تنفيذ منطق مخصص.

*   **`navigatorKey` (اختياري):** `GlobalKey<NavigatorState>` يمكن توفيره للتحكم في `Navigator` الجذري. هذا مفيد بشكل خاص عند استخدام `ShellRoute`s أو عندما تحتاج إلى التفاعل مع `Navigator` الجذري برمجياً.

*   **`debugEither` (اختياري، افتراضياً `false`):** يستخدم لتصحيح الأخطاء المتعلقة بـ `Navigator 1.0` و `Navigator 2.0` في نفس الوقت. لا يُنصح بتعيينه على `true` في الإنتاج.

*   **`urlPathStrategy` (مهمل):** كان يستخدم لتحديد استراتيجية مسار URL لتطبيقات الويب. تم إهماله لصالح `UrlPathStrategy.path` الذي أصبح السلوك الافتراضي.

## 29. التنقل البرمجي: `BuildContext` مقابل `GoRouter.of(context)`

في `go_router`، هناك طريقتان رئيسيتان للتنقل برمجياً: استخدام امتدادات `BuildContext` (مثل `context.go()`, `context.push()`) أو استخدام `GoRouter.of(context)` مباشرة. بينما يؤدي كلاهما إلى نفس النتيجة، هناك اختلافات دقيقة في الاستخدام الموصى به.

*   **امتدادات `BuildContext` (`context.go()`, `context.push()`, إلخ.):**
    *   **الميزة:** هذه هي الطريقة الأكثر شيوعاً والموصى بها للتنقل. إنها موجزة وسهلة القراءة.
    *   **الاستخدام:** استخدمها عندما تكون داخل ويدجت (widget) ولديك `BuildContext` متاح. هذا هو الحال في معظم الأوقات.
    *   **مثال:**
        ```dart
        ElevatedButton(
          onPressed: () => context.go(
'/home


'),
          child: const Text(
'Go Home


'),
        );
        ```

*   **`GoRouter.of(context)`:**
    *   **الميزة:** يمنحك وصولاً مباشراً إلى مثيل `GoRouter` نفسه. هذا مفيد عندما تحتاج إلى الوصول إلى خصائص أو دوال `GoRouter` التي لا تتوفر كامتدادات لـ `BuildContext` (على سبيل المثال، `router.routerDelegate.currentConfiguration`).
    *   **الاستخدام:** أقل شيوعاً للتنقل المباشر، ولكن مفيد لسيناريوهات أكثر تقدماً أو عندما تحتاج إلى الوصول إلى كائن `GoRouter` نفسه.
    *   **مثال:**
        ```dart
        final router = GoRouter.of(context);
        // استخدام router.routerDelegate.currentConfiguration أو خصائص أخرى
        router.go(
'/settings


');
        ```

**الخلاصة:** في معظم الحالات، استخدم امتدادات `BuildContext` (`context.go()`, `context.push()`) لأنها أبسط وأكثر وضوحاً. احتفظ بـ `GoRouter.of(context)` للسيناريوهات التي تتطلب وصولاً أعمق إلى كائن `GoRouter` نفسه.

## 30. استخدام `extra` لتمرير كائنات معقدة

بالإضافة إلى `pathParameters` و `queryParameters`، يوفر `go_router` طريقة قوية لتمرير كائنات Dart معقدة بين المسارات باستخدام المعامل `extra`.

*   **الميزة:** يسمح لك بتمرير أي كائن Dart (وليس فقط سلاسل أو أرقام) بين الشاشات دون الحاجة إلى تسلسل (serialize) أو إلغاء تسلسل (deserialize) يدوياً. هذا مفيد بشكل خاص لتمرير كائنات النموذج (model objects) أو البيانات المعقدة.
*   **القيود:** لا يتم تضمين البيانات التي يتم تمريرها عبر `extra` في URL، مما يعني أنها لن تكون مرئية في شريط عنوان المتصفح (لتطبيقات الويب) ولن يتم الحفاظ عليها عند تحديث الصفحة أو مشاركة الرابط. لذلك، يجب استخدامها للبيانات المؤقتة أو التي لا تحتاج إلى أن تكون جزءاً من حالة URL.

### تمرير كائن باستخدام `extra`

```dart
// عند التنقل
context.go(
'/product-details


', extra: Product(id: 
'p1


', name: 
'Smart Watch


', ...));

// أو مع goNamed
context.goNamed(
'productDetails


', pathParameters: {
'id


': 
'p1


'}, extra: Product(id: 
'p1


', name: 
'Smart Watch


', ...));
```

### استلام الكائن في الشاشة الوجهة

يمكنك استلام الكائن من `GoRouterState` في دالة `builder` الخاصة بالمسار:

```dart
GoRoute(
  path: 
'/product-details


',
  builder: (context, state) {
    final product = state.extra as Product?; // يتم إرجاعها كـ Object?، لذا تحتاج إلى cast
    if (product == null) {
      return const Text(
'Product not found!


');
    }
    return ProductDetailsScreen(product: product);
  },
),
```

**أفضل الممارسات لـ `extra`:**
*   **استخدمها للبيانات غير الدائمة:** البيانات التي لا تحتاج إلى أن تكون جزءاً من URL أو التي لا تحتاج إلى أن تكون قابلة للمشاركة أو الإشارة إليها.
*   **تجنب تمرير الكائنات الكبيرة جداً:** على الرغم من أنها تسمح بتمرير أي كائن، إلا أن تمرير كائنات ضخمة قد يؤثر على الأداء.
*   **التحقق من النوع (Type Checking):** دائماً قم بالتحقق من نوع الكائن الذي تم تمريره عبر `extra` أو استخدم `as Type?` للتعامل مع الحالات التي قد يكون فيها `extra` من نوع مختلف أو `null`.

## 31. Middleware و Guards المتقدمة باستخدام `redirect`

تعد دالة `redirect` في `GoRouter` أداة قوية لتنفيذ منطق Middleware أو Guards. يمكنها اعتراض أي محاولة تنقل وتغيير الوجهة بناءً على شروط معينة. يمكن استخدامها لسيناريوهات تتجاوز مجرد المصادقة، مثل التحقق من الأدوار، أو قبول شروط الخدمة، أو إكمال ملف التعريف.

### 31.1. حماية المسارات بناءً على الأدوار (Role-Based Access Control)

يمكنك استخدام `redirect` لضمان أن المستخدمين لديهم الأدوار الصحيحة للوصول إلى مسارات معينة.

```dart
enum UserRole { guest, user, admin }

class AuthService extends ChangeNotifier {
  UserRole _currentRole = UserRole.guest;
  UserRole get currentRole => _currentRole;

  void login(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }
  // ...
}

final _router = GoRouter(
  refreshListenable: authService, // افترض أن authService هو ChangeNotifier
  routes: [
    GoRoute(path: 
'/


', builder: (context, state) => HomeScreen()),
    GoRoute(path: 
'/admin


', builder: (context, state) => AdminDashboardScreen()),
    GoRoute(path: 
'/profile


', builder: (context, state) => ProfileScreen()),
    GoRoute(path: 
'/login


', builder: (context, state) => LoginScreen()),
  ],
  redirect: (context, state) {
    final authService = context.read<AuthService>(); // افترض استخدام Provider
    final isLoggedIn = authService.currentRole != UserRole.guest;
    final isAdmin = authService.currentRole == UserRole.admin;

    final isLoggingIn = state.matchedLocation == 
'/login


';
    final tryingToAccessAdmin = state.matchedLocation.startsWith(
'/admin


');

    // إذا لم يكن مسجلاً الدخول ويحاول الوصول إلى أي صفحة غير تسجيل الدخول
    if (!isLoggedIn && !isLoggingIn) {
      return 
'/login


';
    }

    // إذا كان مسجلاً الدخول ويحاول الوصول إلى صفحة تسجيل الدخول
    if (isLoggedIn && isLoggingIn) {
      return 
'/


';
    }

    // إذا كان يحاول الوصول إلى صفحة المسؤول وليس مسؤولاً
    if (tryingToAccessAdmin && !isAdmin) {
      return 
'/


'; // أو صفحة خطأ 
