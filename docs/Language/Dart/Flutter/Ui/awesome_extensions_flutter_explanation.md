# شرح مكتبة `awesome_extensions` لـ Flutter (شرح موسع)

## 1. مقدمة

تُعد مكتبة `awesome_extensions` حزمة امتدادات (extension package) شاملة ومفيدة لـ Flutter، تهدف إلى تقليل الكود المتكرر (boilerplate code) بشكل كبير، وتحسين قابلية القراءة (readability) للكود، وإضافة طرق مساعدة (helpful methods) إلى الودجات (widgets) وأنواع البيانات الأساسية. تمكّن هذه المكتبة المطورين من إنشاء تصاميم متجاوبة (responsive designs) بسهولة وفعالية، وتقدم حلولاً أنيقة للعديد من المهام الشائعة في تطوير تطبيقات Flutter. توفر الحزمة امتدادات للودجات، الثيمات (themes)، التنقل (navigation)، الألوان (colors)، النصوص (strings)، التواريخ (dates)، الأرقام (numbers)، القوائم (lists)، الخرائط (maps)، وغيرها الكثير، مما يجعلها أداة لا غنى عنها في ترسانة أي مطور Flutter [1].

## 2. التثبيت

لتثبيت مكتبة `awesome_extensions` في مشروع Flutter الخاص بك، اتبع الخطوات التالية:

1.  افتح ملف `pubspec.yaml` في مشروعك.
2.  أضف `awesome_extensions` ضمن قسم `dependencies`، مع تحديد أحدث إصدار. يفضل دائمًا استخدام أحدث إصدار متاح لضمان الحصول على أحدث الميزات وإصلاحات الأخطاء:

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      awesome_extensions: ^2.1.0 # استخدم أحدث إصدار متاح، تحقق من pub.dev
    ```

3.  احفظ الملف ثم قم بتشغيل الأمر التالي في الطرفية (terminal) للحصول على الحزم:

    ```bash
    flutter pub get
    ```

4.  للاستفادة من الامتدادات، تأكد من استيراد المكتبة في ملفاتك:

    ```dart
    import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
    ```

## 3. ميزات رئيسية ومجالات التطبيق

توفر `awesome_extensions` مجموعة واسعة من الامتدادات المصنفة كالتالي، وكل منها يخدم غرضًا محددًا لتبسيط عملية التطوير:

*   **Theme Extensions (امتدادات الثيم):** تتيح الوصول السهل والمباشر إلى خصائص الثيم (Theme) من أي `BuildContext`، مما يقلل من الكود المتكرر عند تطبيق الأنماط.
*   **Media Query Extensions (امتدادات استعلام الوسائط):** تبسط عملية الحصول على معلومات حول حجم الشاشة والاتجاه (orientation) وكثافة البكسل (pixel density)، مما يسهل بناء واجهات مستخدم متجاوبة (responsive UIs) تتكيف مع مختلف الأجهزة.
*   **Navigation Extensions (امتدادات التنقل):** توفر طرقًا مختصرة ومبسطة لعمليات التنقل الشائعة بين الشاشات، مثل الدفع (push)، الاستبدال (pushReplacement)، والعودة (pop).
*   **Widget Extensions (امتدادات الودجات):** تضيف طرقًا مساعدة مباشرة إلى الودجات لتطبيق خصائص شائعة مثل الهوامش (padding)، الشفافية (opacity)، وتأثيرات التحميل (shimmer effects)، مما يجعل بناء الودجات أكثر إيجازًا ووضوحًا.
*   **List Extensions (امتدادات القوائم):** لمعالجة كائنات `List` بفعالية، مثل تصفية العناصر غير الفارغة أو إضافة فواصل بين العناصر.
*   **Map Extensions (امتدادات الخرائط):** توفر وظائف متقدمة للتعامل مع كائنات `Map`، بما في ذلك الوصول الآمن للقيم، التصفية، التحويل، والعمليات المتداخلة.
*   **Date Extensions (امتدادات التاريخ):** لتبسيط التعامل مع كائنات `DateTime`، مثل مقارنة التواريخ أو التحقق من كون التاريخ هو اليوم أو الأمس.
*   **Number Extensions (امتدادات الأرقام):** تضيف وظائف مفيدة للأرقام، مثل تأخير تنفيذ دالة (delaying function execution) أو إنشاء كائنات `Duration` بسهولة.
*   **String Extensions (امتدادات النصوص):** لمعالجة النصوص (strings) بشكل فعال، مثل تحويل الحروف، إزالة المسافات البيضاء، والتحقق من أنماط معينة.
*   **Async Extensions (امتدادات غير المتزامنة):** تساعد في التعامل مع حالات `AsyncSnapshot` في `StreamBuilder` و `FutureBuilder` بطريقة أكثر تنظيمًا وإيجازًا، مما يقلل من الكود المتكرر المرتبط بالتعامل مع الحالات المختلفة للبيانات غير المتزامنة.
*   **Color Extensions (امتدادات الألوان):** لتعديل الألوان بسهولة، مثل تغميق (darken) أو تفتيح (lighten) لون، أو تعيين شفافيته (alpha percentage).
*   **Url Strategy (استراتيجية الروابط):** لتكوين استراتيجية الروابط لتطبيقات الويب في Flutter، مما يسمح بإزالة علامة `#` من الروابط لتحسين تجربة المستخدم ومحركات البحث.
*   **Avatar Image (صورة الأفاتار):** ودجت مخصص لعرض صور الأفاتار مع خيارات واسعة للتخصيص من حيث الحجم والشكل والخلفية.

## 4. شرح مفصل للامتدادات مع أمثلة متقدمة

### 4.1. Theme Extensions (امتدادات الثيم)

تتيح هذه الامتدادات الوصول المباشر إلى خصائص `ThemeData` من خلال `BuildContext`، مما يقلل من الحاجة إلى كتابة `Theme.of(context)` بشكل متكرر ويجعل الكود أكثر إيجازًا ووضوحًا.

**أمثلة عملية:**

```dart
// قبل استخدام الامتدادات
Text(
  Text(
    'Hello World',
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).primaryColor,
    ),
  ),
)

// بعد استخدام الامتدادات
Text(
  'Hello World',
  style: context.textTheme.bodyLarge?.copyWith(
    color: context.primaryColor,
  ),
)
```

**خصائص شائعة يمكن الوصول إليها:**

*   **`context.theme`**: للوصول إلى كائن `ThemeData` كاملاً.
*   **`context.textTheme`**: للوصول إلى `TextTheme`، والذي يحتوي على أنماط النصوص المعرفة في الثيم.
*   **`context.primaryColor`**: للوصول إلى اللون الأساسي (primary color) للثيم.
*   **`context.scaffoldBackgroundColor`**: للوصول إلى لون خلفية `Scaffold`.
*   **`context.appBarTheme`**: للوصول إلى ثيم شريط التطبيق (App Bar).
*   **`context.bottomAppBarTheme`**: للوصول إلى ثيم شريط التطبيق السفلي (Bottom App Bar).
*   **`context.dividerColor`**: للوصول إلى لون الفواصل (dividers).

### 4.2. Media Query Extensions for Responsive Layout (امتدادات استعلام الوسائط للتخطيط المتجاوب)

تبسط هذه الامتدادات عملية الحصول على معلومات `MediaQuery`، مما يسهل بناء واجهات مستخدم متجاوبة تتكيف مع مختلف أحجام الشاشات والاتجاهات.

**أمثلة متقدمة:**

```dart
// استخدام context.width و context.height لتحديد أبعاد ودجت
Container(
  width: context.width * 0.8, // 80% من عرض الشاشة
  height: context.height / 2, // نصف ارتفاع الشاشة
  color: Colors.blue,
  child: Text(
    'حجم الشاشة: ${context.width.toStringAsFixed(0)}x${context.height.toStringAsFixed(0)}',
    style: TextStyle(fontSize: context.isMobile ? 16 : 24, color: Colors.white),
  ),
)

// استخدام context.responsiveValue لتغيير الودجت بالكامل بناءً على حجم الشاشة
Widget buildResponsiveContent(BuildContext context) {
  return context.responsiveValue(
    mobile: Center(child: Text('محتوى الجوال', style: context.textTheme.headlineSmall)),
    tablet: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) => Card(child: Center(child: Text('عنصر $index'))),
      itemCount: 4,
    ),
    desktop: Row(
      children: [
        Expanded(child: Container(color: Colors.red, child: Center(child: Text('لوحة 1')))),
        Expanded(child: Container(color: Colors.green, child: Center(child: Text('لوحة 2')))),
      ],
    ),
  );
}

// التحقق من اتجاه الشاشة
if (context.isLandscape) {
  print('الشاشة في الوضع الأفقي');
} else {
  print('الشاشة في الوضع العمودي');
}

// الوصول إلى الهوامش الآمنة (safe area insets)
Padding(
  padding: context.mqViewInsets,
  child: Text('محتوى داخل المنطقة الآمنة'),
)
```

**خصائص إضافية مفيدة:**

*   **`context.mqSize`**: تُرجع `Size` (العرض والارتفاع) للشاشة.
*   **`context.mqPadding`**: تُرجع `EdgeInsets` للهوامش من `MediaQuery`.
*   **`context.mqViewInsets`**: تُرجع `EdgeInsets` للمناطق التي تغطيها واجهة المستخدم للنظام (مثل لوحة المفاتيح).
*   **`context.mqOrientation`**: تُرجع `Orientation` (عمودي أو أفقي).
*   **`context.alwaysUse24HourFormat`**: قيمة منطقية تشير إلى ما إذا كان الجهاز يستخدم تنسيق 24 ساعة.
*   **`context.devicePixelRatio`**: نسبة البكسل للجهاز.
*   **`context.platformBrightness`**: سطوع المنصة (فاتح أو داكن).
*   **`context.textScaleFactor`**: عامل قياس النص.
*   **`context.isLandscape`**: قيمة منطقية تشير إلى ما إذا كانت الشاشة في الوضع الأفقي.
*   **`context.isPortrait`**: قيمة منطقية تشير إلى ما إذا كانت الشاشة في الوضع العمودي.
*   **`context.isSmallTablet`**: `true` إذا كان أقصر جانب للشاشة أكبر من 600 بكسل.
*   **`context.isLargeTablet`**: `true` إذا كان أقصر جانب للشاشة أكبر من 720 بكسل.
*   **`context.showNavbar`**: `true` إذا كان أقصر جانب للشاشة أكبر من 800 بكسل (يمكن استخدامه لتحديد ما إذا كان يجب عرض شريط التنقل الجانبي).
*   **`context.isIPhone`**: `true` إذا كان أقصر جانب للشاشة أصغر من 600 بكسل (يمكن استخدامه للتمييز بين الهواتف والأجهزة اللوحية).

### 4.3. Navigation Extensions (امتدادات التنقل)

توفر طرقًا مختصرة ومبسطة لعمليات التنقل الشائعة في Flutter، مما يجعل الكود المتعلق بالتنقل أكثر نظافة وسهولة في القراءة.

**أمثلة متقدمة:**

```dart
// التنقل مع تمرير البيانات
context.push(SecondScreen(data: 'Hello from Home!'));

// التنقل إلى مسار مسمى مع تمرير الوسائط
context.pushNamed('/details', arguments: {'id': 123, 'name': 'Product A'});

// في الشاشة الثانية، لاستقبال الوسائط
// final args = context.routeArguments as Map<String, dynamic>?;
// final id = args?['id'];

// استبدال الشاشة الحالية بشاشة جديدة ومنع العودة إليها
context.pushReplacement(AnotherScreen());

// العودة إلى الشاشة الرئيسية (أو أي شاشة محددة) وإزالة جميع الشاشات فوقها
context.popUntil('/home');

// التنقل باستخدام rootNavigator (للتنقل خارج Navigator الحالي، مثل إغلاق صفحة Modal)
context.push(FullScreenModal(), rootNavigator: true);
```

**خصائص إضافية:**

*   **`context.routeSettings`**: للوصول إلى `RouteSettings` الخاصة بالمسار الحالي.
*   **`context.routeName`**: اسم المسار الحالي.
*   **`context.routeArguments`**: الوسائط التي تم تمريرها إلى المسار الحالي.

### 4.4. Widget Extensions (امتدادات الودجات)

تضيف طرقًا مساعدة مباشرة إلى الودجات لتطبيق خصائص شائعة، مما يقلل من تداخل الودجات (widget nesting) ويجعل بناء واجهة المستخدم أكثر سلاسة.

**أمثلة متقدمة:**

```dart
// دمج عدة امتدادات للودجات
Text('مرحباً بكم في Awesome Extensions!')
    .paddingAll(16.0)
    .withRoundCorners(radius: 10.0, backgroundColor: Colors.blue.lighten(10))
    .withShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5.0, offset: Offset(2, 2))
    .toCenter()
    .onTap(() => print('تم النقر على النص!'))
    .withTooltip('هذا نص ترحيبي');

// استخدام applyShimmer مع تخصيص الألوان
Container(
  height: 100,
  width: double.infinity,
  color: Colors.grey[300],
).applyShimmer(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  direction: ShimmerDirection.ltr, // اتجاه تأثير الشيمر
);

// استخدام .nil() للتحكم الشرطي في عرض الودجات
bool showWidget = false;
Widget myConditionalWidget = showWidget
    ? Text('هذا الودجت يظهر فقط عند الحاجة').paddingAll(8.0)
    : null.nil(); // بدلاً من SizedBox.shrink() أو Container()

// تحويل ودجت عادي إلى SliverToBoxAdapter
CustomScrollView(
  slivers: [
    Text('عنوان القائمة').paddingAll(16.0).sliver,
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('عنصر $index')),
        childCount: 10,
      ),
    ),
  ],
);

// عرض حوار تنبيه يتكيف مع النظام
context.showAlertDialog(
  title: 'تنبيه هام',
  message: 'هذه رسالة تنبيه من Awesome Extensions.',
  actions: [
    TextButton(
      onPressed: () => context.pop(),
      child: Text('موافق'),
    ),
  ],
);
```

**امتدادات ودجات إضافية:**

*   **`20.0.heightBox` / `20.0.widthBox`**: لإنشاء `SizedBox` بأبعاد محددة.
*   **`.paddingOnly(left: 8, top: 4)` / `.paddingSymmetric(horizontal: 16)`**: لتطبيق هوامش محددة.
*   **`.opacity(0.7)`**: لتغيير شفافية الودجت.
*   **`.expanded()` / `.flexible()`**: للتحكم في كيفية تمدد الودجت داخل `Row` أو `Column`.
*   **`.onTap(() => ...)` / `.onLongPress(() => ...)`**: لإضافة مستمعي الأحداث (event listeners) للنقر والضغط المطول.
*   **`.withTooltip('نص التلميح')`**: لإضافة تلميح أداة (tooltip).

### 4.5. List Extensions (امتدادات القوائم)

توفر طرقًا لمعالجة القوائم (Lists) بفعالية، مما يسهل عمليات التصفية، التحويل، وإعادة الترتيب.

**أمثلة متقدمة:**

```dart
List<Widget?> widgets = [
  Text('الودجت الأول'),
  null,
  Text('الودجت الثاني'),
  null,
  Text('الودجت الثالث'),
];

// تصفية الودجات غير الفارغة
Column(
  children: widgets.notNullWidget(),
);

// إضافة فواصل بين عناصر القائمة
List<String> items = ['تفاحة', 'برتقالة', 'موزة'];
Column(
  children: items.map((item) => Text(item)).toList().separatedBy(
    const Text(' | '),
  ),
);

// مثال معقد: قائمة من الودجات مع فواصل وتصفية
List<String?> data = ['Item A', null, 'Item B', 'Item C', null];
Column(
  children: data
      .whereType<String>() // تصفية العناصر غير الفارغة من النوع String
      .map((item) => Text(item.capitalizeFirst()))
      .toList()
      .separatedBy(const Divider()),
);
```

### 4.6. Map Extensions (امتدادات الخرائط)

توفر طرقًا لمعالجة كائنات `Map`، مثل الوصول الآمن للقيم، التصفية، التحويل، والعمليات المتداخلة، مما يجعل التعامل مع البيانات المنظمة أكثر سهولة.

**أمثلة متقدمة:**

```dart
Map<String, dynamic> userProfile = {
  'id': 1,
  'name': 'John Doe',
  'email': 'john.doe@example.com',
  'settings': {
    'theme': 'dark',
    'notifications': true,
  },
  'preferences': null,
};

// الوصول الآمن للقيم مع قيمة افتراضية
String userName = userProfile.getOrDefault('name', 'Guest'); // John Doe
int age = userProfile.getOrDefault('age', 30); // 30 (لأن 'age' غير موجود)

// الوصول إلى القيم المتداخلة
String? userTheme = userProfile.getNested('settings.theme'); // dark
bool? notifications = userProfile.getNested('settings.notifications'); // true
String? unknownKey = userProfile.getNested('settings.unknown'); // null

// تعيين قيم متداخلة
userProfile.setNested('settings.notifications', false);
userProfile.setNested('address.city', 'New York'); // سيتم إنشاء 'address' إذا لم يكن موجودًا

// تصفية الخريطة
Map<String, dynamic> filteredMap = userProfile.filterKeys((key) => key.startsWith('s'));
// { 'settings': { 'theme': 'dark', 'notifications': false } }

Map<String, dynamic> filteredByValue = userProfile.filterValues((value) => value is String && value.contains('@'));
// { 'email': 'john.doe@example.com' }

// تحويل الخريطة إلى سلسلة استعلام URL
Map<String, String> queryParams = {'user': 'john_doe', 'page': '2'};
String queryString = queryParams.toQueryString(); // user=john_doe&page=2

// دمج خريطتين
Map<String, int> map1 = {'a': 1, 'b': 2};
Map<String, int> map2 = {'c': 3, 'b': 4};
Map<String, int> mergedMap = map1.merge(map2); // { 'a': 1, 'b': 4, 'c': 3 } (map2 تتجاوز القيم المتطابقة)
```

### 4.7. Date Extensions (امتدادات التاريخ)

تضيف طرقًا مساعدة للتعامل مع كائنات `DateTime`، مما يسهل مقارنة التواريخ والتحقق من خصائصها.

**أمثلة متقدمة:**

```dart
DateTime today = DateTime.now();
DateTime yesterday = today.subtract(const Duration(days: 1));
DateTime tomorrow = today.add(const Duration(days: 1));
DateTime specificDate = DateTime(2023, 10, 26);

// مقارنة التواريخ (تجاهل الوقت)
print(today.isSameDate(today)); // true
print(today.isSameDate(yesterday)); // false

// التحقق من اليوم
print(today.isToday); // true
print(yesterday.isToday); // false

// التحقق من الأمس
print(yesterday.isYesterday); // true
print(today.isYesterday); // false

// التحقق من الغد (مثال إضافي)
print(tomorrow.isTomorrow); // true (هذا امتداد افتراضي قد لا يكون موجودًا، ولكن يمكن إنشاؤه بسهولة)

// الحصول على بداية ونهاية اليوم/الأسبوع/الشهر (مثال على امتدادات ممكنة)
// print(today.startOfDay); // DateTime في بداية اليوم
// print(today.endOfWeek); // DateTime في نهاية الأسبوع
```

### 4.8. Number Extensions (امتدادات الأرقام)

تضيف وظائف مفيدة للأرقام، مثل تأخير تنفيذ دالة أو إنشاء `Duration` بسهولة، بالإضافة إلى مقارنات بسيطة.

**أمثلة متقدمة:**

```dart
// تأخير تنفيذ دالة
print('بدء التأخير...');
3.delay(() => print('انتهى التأخير بعد 3 ثوانٍ'));
print('البرنامج مستمر...');

// إنشاء Duration بسهولة
Duration fiveSeconds = 5.seconds;
Duration oneAndHalfHours = 1.5.hours;
Duration combinedDuration = 1.minutes + 30.seconds; // 90 ثانية

// مقارنات الأرقام
int num1 = 10;
int num2 = 5;

print(num1.isLowerThan(num2)); // false
print(num1.isGreaterThan(num2)); // true
print(num1.isEqualTo(10)); // true
print(num1.isBetween(5, 15)); // true
```

### 4.9. String Extensions (امتدادات النصوص)

توفر طرقًا لمعالجة النصوص (strings) بشكل فعال، مما يسهل عمليات التحويل، التنسيق، والتحقق من أنماط معينة.

**أمثلة متقدمة:**

```dart
String sentence = 'hello world from flutter';
String mixedCase = 'This Is A Test String';
String numericString = '12345';
String alphaString = 'abcdef';
String boolString = 'true';

// تحويل الحروف
print(sentence.capitalize()); // Hello World From Flutter
print(sentence.capitalizeFirst()); // Hello world from flutter
print(mixedCase.toLowerCase()); // this is a test string
print(mixedCase.toUpperCase()); // THIS IS A TEST STRING

// إزالة المسافات البيضاء
print('  leading and trailing  '.trimAll()); // leading and trailing
print('hello   world'.removeAllWhitespace()); // helloworld

// التحقق من أنماط معينة
print(numericString.isNumericOnly()); // true
print(alphaString.isAlphabetOnly()); // true
print(mixedCase.hasCapitalLetter()); // true
print(boolString.isBool()); // true
print('false'.isBool()); // true
print('not_a_bool'.isBool()); // false

// التحقق من البريد الإلكتروني (مثال على امتداد regex)
print('test@example.com'.isEmail()); // true (إذا كان الامتداد متوفرًا)

// استخراج الأرقام من سلسلة نصية
print('Product ID: 12345'.extractNumbers()); // [12345] (إذا كان الامتداد متوفرًا)
```

### 4.10. Async Extensions (امتدادات غير المتزامنة)

تساعد في التعامل مع حالات `AsyncSnapshot` في `StreamBuilder` و `FutureBuilder`، مما يقلل من الكود المتكرر (boilerplate code) ويجعل منطق معالجة الحالات المختلفة (تحميل، بيانات، خطأ) أكثر وضوحًا وإيجازًا.

**أمثلة متقدمة مع `FutureBuilder`:**

```dart
Future<String> fetchData() async {
  await Future.delayed(const Duration(seconds: 2));
  // throw Exception('Failed to load data'); // لاختبار حالة الخطأ
  return 'Data loaded successfully!';
}

class MyFutureWidget extends StatelessWidget {
  const MyFutureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchData(),
      builder: (context, snapshot) {
        return snapshot.when(
          data: (data) => Center(child: Text('البيانات: $data')),
          error: (error, stackTrace) => Center(child: Text('خطأ: ${error.toString()}')),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// استخدام maybeWhen (إذا كنت لا تريد التعامل مع جميع الحالات)
// return snapshot.maybeWhen(
//   data: (data) => Center(child: Text('البيانات: $data')),
//   orElse: () => const Center(child: Text('في انتظار البيانات أو حدث خطأ')),
// );
```

*   **`snapshot.when(...)`**: توفر طريقة أنيقة للتعامل مع حالات `AsyncSnapshot` المختلفة (`data`, `error`, `loading`) بدلاً من استخدام `if` و `else if` المتعددة. كل حالة تأخذ دالة رد نداء خاصة بها.
*   **`maybeWhen`**: مشابهة لـ `when` ولكن تسمح بأن تكون دوال رد النداء اختيارية. إذا لم يتم توفير دالة لحالة معينة، يتم استدعاء دالة `orElse` (إذا كانت موجودة) أو لا يحدث شيء.

### 4.11. Color Extensions (امتدادات الألوان)

تضيف طرقًا لتعديل الألوان بسهولة، مما يتيح تخصيصًا ديناميكيًا للألوان في تطبيقك.

**أمثلة متقدمة:**

```dart
Color originalColor = Colors.blue;

// تغميق اللون
Color darkerBlue = originalColor.darken(30); // تغميق بنسبة 30%
print('اللون الأصلي: $originalColor, اللون الأغمق: $darkerBlue');

// تفتيح اللون
Color lighterBlue = originalColor.lighten(20); // تفتيح بنسبة 20%
print('اللون الأصلي: $originalColor, اللون الأفتح: $lighterBlue');

// تعيين الشفافية
Color semiTransparentBlue = originalColor.alphaPercent(50); // 50% شفافية
print('اللون الأصلي: $originalColor, اللون شبه الشفاف: $semiTransparentBlue');

// تحويل من/إلى سداسي عشري (مثال على امتدادات ممكنة)
// Color fromHex = '#FF0000'.toColor(); // تحويل سلسلة سداسية عشرية إلى لون
// String toHex = Colors.green.toHex(); // تحويل لون إلى سلسلة سداسية عشرية
```

### 4.12. Url Strategy (استراتيجية الروابط)

تساعد في تكوين استراتيجية الروابط لتطبيقات الويب في Flutter لإزالة علامة `#` من الروابط، مما يجعل عناوين URL تبدو أنظف وأكثر صداقة لمحركات البحث.

**مثال:**

```dart
import 'package:flutter/material.dart';
import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';

void main() {
  // هنا نقوم بتعيين استراتيجية الروابط لتطبيق الويب الخاص بنا.
  // من الآمن استدعاء هذا فقط عند تشغيل أو تعيين استراتيجية المسار.
  // يجب استدعاء هذه الدالة قبل runApp().
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Web App')), 
        body: Center(child: Text('مرحباً بتطبيق الويب الخاص بك!'))
      ),
    );
  }
}
```

### 4.13. Avatar Image (صورة الأفاتار)

ودجت مخصص لعرض صور الأفاتار مع خيارات واسعة للتخصيص من حيث الحجم والشكل والخلفية، مما يجعله مرنًا للاستخدام في مختلف سياقات واجهة المستخدم.

**أمثلة متقدمة:**

```dart
Column(
  children: [
    // أفاتار دائري مع صورة شبكة ونص
    AvatarImage(
      backgroundImage: NetworkImage('https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250'),
      size: ImageSize.LARGE, // حجم كبير
      shape: AvatarImageShape.circle, // شكل دائري
      child: Text('JD', style: TextStyle(color: Colors.white)), // نص يظهر إذا لم يتم تحميل الصورة
      backgroundColor: Colors.blueAccent, // لون خلفية الأفاتار
      radius: 50.0, // نصف قطر مخصص
    ),
    const SizedBox(height: 20),
    // أفاتار مربع مع نص فقط ولون خلفية مخصص
    AvatarImage(
      shape: AvatarImageShape.standard, // شكل مربع
      size: ImageSize.MEDIUM, // حجم متوسط
      child: Text('AI', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.yellow,
      borderRadius: BorderRadius.circular(8.0), // حواف دائرية مخصصة للمربع
    ),
    const SizedBox(height: 20),
    // أفاتار صغير مع أيقونة
    AvatarImage(
      shape: AvatarImageShape.circle,
      size: ImageSize.SMALL,
      child: Icon(Icons.person, color: Colors.white, size: 20),
      backgroundColor: Colors.green,
    ),
  ],
)
```

**الخصائص الرئيسية (موسعة):**

*   **`backgroundImage`**: (اختياري) صورة الخلفية للأفاتار. يمكن أن تكون `NetworkImage`، `AssetImage`، `FileImage`، أو أي `ImageProvider` آخر.
*   **`size`**: (اختياري) يحدد حجم الأفاتار من خلال تعداد `ImageSize` (مثل `ImageSize.LARGE`, `ImageSize.MEDIUM`, `ImageSize.SMALL`). هذه الأحجام توفر قيمًا افتراضية للحجم.
*   **`shape`**: (اختياري) يحدد شكل الأفاتار من خلال تعداد `AvatarImageShape` (مثل `AvatarImageShape.standard` للمربع، `AvatarImageShape.circle` للدائرة)..
*   **`child`**: (اختياري) ودجت يظهر داخل الأفاتار. غالبًا ما يستخدم لعرض الأحرف الأولى من الاسم أو أيقونة إذا لم تكن هناك صورة خلفية أو فشل تحميلها.
*   **`backgroundColor`**: (اختياري) لون خلفية الأفاتار. مفيد عندما لا تكون هناك صورة خلفية أو كخلفية احتياطية.
*   **`radius`**: (اختياري) نصف قطر الأفاتار إذا كان شكله دائريًا (`AvatarImageShape.circle`). يتجاوز قيمة `size` إذا تم تحديده.
*   **`minRadius`**: (اختياري) الحد الأدنى لنصف قطر الأفاتار.
*   **`maxRadius`**: (اختياري) الحد الأقصى لنصف قطر الأفاتار.
*   **`borderRadius`**: (اختياري) `BorderRadius` مخصص للأفاتار ذي الشكل القياسي (`AvatarImageShape.standard`)، يسمح بتحديد درجة استدارة الحواف.
*   **`foregroundColor`**: (اختياري) لون النص أو الأيقونة داخل الأفاتار.

## 5. حالات الاستخدام المتقدمة وأفضل الممارسات

تكمن قوة `awesome_extensions` في قدرتها على دمج الامتدادات المختلفة لإنشاء حلول قوية وموجزة. فيما يلي بعض حالات الاستخدام المتقدمة وأفضل الممارسات:

### 5.1. بناء واجهات مستخدم متجاوبة معقدة

يمكن دمج `Media Query Extensions` مع `Widget Extensions` لإنشاء تخطيطات تتكيف بشكل ديناميكي.

```dart
Widget buildComplexResponsiveLayout(BuildContext context) {
  return context.responsiveValue(
    mobile: Column(
      children: [
        Text('مرحباً بالهاتف').paddingAll(8.0).toCenter(),
        Container(height: 100, color: Colors.red).expanded(),
      ],
    ),
    tablet: Row(
      children: [
        Container(width: context.width * 0.4, color: Colors.green).paddingAll(16.0),
        Container(width: context.width * 0.6, color: Colors.blue).paddingAll(16.0),
      ],
    ),
    desktop: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) => Card(
        child: Text('عنصر سطح المكتب $index').toCenter().paddingAll(8.0),
      ),
      itemCount: 6,
    ).paddingAll(24.0),
  );
}
```

### 5.2. إدارة حالة التحميل والخطأ بكفاءة

باستخدام `Async Extensions`، يمكنك إدارة حالات `FutureBuilder` أو `StreamBuilder` بشكل مركزي، مما يقلل من تكرار الكود.

```dart
Future<List<String>> fetchItems() async {
  await 2.seconds.delay(); // تأخير لمدة ثانيتين
  // throw Exception('فشل جلب العناصر');
  return ['عنصر 1', 'عنصر 2', 'عنصر 3'];
}

class ItemsListWidget extends StatelessWidget {
  const ItemsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchItems(),
      builder: (context, snapshot) {
        return snapshot.when(
          data: (items) => ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(title: Text(items[index])),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('حدث خطأ: ${error.toString()}').paddingAll(16.0),
          ),
        );
      },
    );
  }
}
```

### 5.3. تبسيط معالجة البيانات المعقدة

يمكن لـ `Map Extensions` و `List Extensions` تبسيط التعامل مع هياكل البيانات المعقدة.

```dart
Map<String, dynamic> complexData = {
  'products': [
    {'id': 1, 'name': 'Laptop', 'price': 1200.0, 'inStock': true},
    {'id': 2, 'name': 'Mouse', 'price': 25.0, 'inStock': false},
    {'id': 3, 'name': 'Keyboard', 'price': 75.0, 'inStock': true},
  ],
  'user': {'id': 101, 'username': 'dev_user'},
  'settings': null,
};

// الحصول على أسماء المنتجات المتوفرة فقط
List<String> availableProductNames = (complexData.getNested('products') as List<dynamic>)
    .where((product) => product['inStock'] == true)
    .map((product) => (product['name'] as String).capitalizeFirst())
    .toList();
print('المنتجات المتوفرة: $availableProductNames'); // [Laptop, Keyboard]

// تحديث إعدادات المستخدم
complexData.setNested('user.username', 'new_dev_user');
print('اسم المستخدم الجديد: ${complexData.getNested('user.username')}');

// دمج بيانات إضافية للمنتجات
Map<String, dynamic> newProduct = {'id': 4, 'name': 'Monitor', 'price': 300.0, 'inStock': true};
(complexData.getNested('products') as List<dynamic>).add(newProduct);
print('عدد المنتجات بعد الإضافة: ${(complexData.getNested('products') as List<dynamic>).length}');
```

### 5.4. أفضل الممارسات

*   **الاستيراد الشامل:** قم دائمًا باستيراد `package:awesome_flutter_extensions/awesome_flutter_extensions.dart` في الملفات التي تستخدم الامتدادات لضمان توفر جميع الوظائف.
*   **الوضوح على الإيجاز:** على الرغم من أن الامتدادات تجعل الكود أكثر إيجازًا، تأكد من أن الكود يظل واضحًا ومفهومًا، خاصة عند دمج عدة امتدادات في سطر واحد.
*   **الاستخدام الانتقائي:** استخدم الامتدادات حيثما تضيف قيمة حقيقية (مثل تقليل الكود المتكرر أو تحسين قابلية القراءة). لا تفرط في استخدامها إذا كان الكود الأصلي أكثر وضوحًا في سياق معين.
*   **التحقق من القيم الفارغة:** على الرغم من أن بعض الامتدادات توفر وصولاً آمنًا (مثل `getOrDefault` في `Map Extensions`)، إلا أنه لا يزال من المهم التعامل مع القيم الفارغة (null) بشكل صحيح في الكود الخاص بك، خاصة عند التعامل مع البيانات التي قد تكون غائبة.
*   **الأداء:** بشكل عام، لا تؤثر الامتدادات على الأداء بشكل كبير. ومع ذلك، كن حذرًا عند استخدام العمليات المعقدة داخل الحلقات الكبيرة أو الودجات التي يتم إعادة بنائها بشكل متكرر.

## 6. الخلاصة (محدثة و موسعة)

تُعد مكتبة `awesome_extensions` أداة قوية ومتعددة الاستخدامات تعمل على تحويل تجربة تطوير Flutter من خلال توفير مجموعة غنية من الامتدادات التي تبسط الكود، وتحسن قابلية القراءة، وتسرع عملية التطوير بشكل ملحوظ. من خلال تقديم طرق مختصرة للتعامل مع الثيمات، التنقل، الودجات، البيانات المعقدة، التواريخ، الأرقام، النصوص، والعمليات غير المتزامنة، تمكن المطورين من التركيز على بناء الميزات الأساسية وتقديم تجربة مستخدم ممتازة، بدلاً من قضاء الوقت في كتابة الكود المتكرر. إن قدرتها على دعم التصميم المتجاوب بفعالية، وتوفير حلول أنيقة للمهام الشائعة والمعقدة، وإدارة حالات `AsyncSnapshot` بكفاءة، تجعلها إضافة لا غنى عنها في ترسانة أي مطور Flutter يسعى لكتابة كود نظيف، فعال، وقابل للصيانة. هذا الشرح الموسع يوضح ليس فقط كيفية استخدام هذه الامتدادات، بل أيضًا كيفية دمجها في حالات استخدام متقدمة لإنشاء تطبيقات Flutter أكثر قوة ومرونة.

## 7. المراجع

[1]: https://pub.dev/packages/awesome_extensions "awesome_extensions | Flutter Package"
