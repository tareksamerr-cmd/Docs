# شرح تفصيلي لكود إعداد shadcn_ui في Flutter (محدث)

**المؤلف:** Manus AI

## مقدمة

يقدم هذا المستند شرحًا مفصلاً وشاملاً لكود إعداد مكتبة `shadcn_ui` في Flutter، مع التركيز على كل سطر، خاصية، ومعامل (parameter) لفهم عميق لكيفية عمل هذه المكتبة ودمجها مع تطبيقات Flutter، سواء كانت تعتمد على Material Design أو Cupertino. تم تحديث هذا المستند ليشمل تفاصيل حول تخصيص الألوان، استخدام مكون `ShadSelect`، وتخصيص الثيمات بشكل أعمق.

تُعد `shadcn_ui` نقلًا لمكونات `shadcn/ui` الشهيرة من بيئة React إلى Flutter، وتهدف إلى توفير مكونات واجهة مستخدم (UI components) عالية الجودة والقابلة للتخصيص.

## تحليل الكود

لنقم بتحليل الكود المقدم جزءًا بجزء:

### 1. الاستيرادات (Imports)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/material.dart';
import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart'; // إضافة جديدة
```

*   `import 'package:shadcn_ui/shadcn_ui.dart';`: هذا السطر يستورد جميع المكونات والوظائف الأساسية لمكتبة `shadcn_ui`. وهو ضروري لاستخدام أي من ودجات (widgets) أو ثيمات (themes) المكتبة.
*   `import 'package:flutter/material.dart';`: هذا السطر يستورد مكتبة Material Design من Flutter. يتم استخدامه هنا لأن الكود يوضح كيفية دمج `shadcn_ui` مع `MaterialApp` ومكونات Material Design.
*   `import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';`: هذه إضافة جديدة. تستورد هذه المكتبة مجموعة من الامتدادات (extensions) المفيدة لـ Flutter، مثل `capitalizeFirst()` المستخدمة في مثال `ShadSelect` لتحويل الحرف الأول من السلسلة النصية إلى حرف كبير.

### 2. الدالة الرئيسية (main function)

```dart
void main() {
  runApp(const MyApp());
}
```

*   `void main()`: هذه هي نقطة الدخول (entry point) لأي تطبيق Flutter. يتم تنفيذ الكود داخل هذه الدالة عند بدء تشغيل التطبيق.
*   `runApp(const MyApp());`: هذه الدالة من Flutter تأخذ ودجت (widget) الجذر (root) للتطبيق وتبدأ عملية بناء واجهة المستخدم. في هذه الحالة، الودجت الجذر هو `MyApp`.

### 3. فئة التطبيق (MyApp Class)

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (الكود السابق لـ ShadApp و ShadApp.custom)
    return ShadApp(
      darkTheme: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadSlateColorScheme.dark(
            background: Colors.blue,
          ),
          primaryButtonTheme: const ShadButtonTheme(
            backgroundColor: Colors.cyan,
          ),
        ),
      child: ... // هنا يتم وضع الودجت الرئيسي لتطبيقك
    );
  }
}
```

*   `class MyApp extends StatelessWidget`: `MyApp` هو الودجت الجذر للتطبيق، وهو `StatelessWidget` لأنه لا يحتوي على حالة (state) تتغير بمرور الوقت. يتم تمرير `key` إلى الودجت الأب (parent widget) باستخدام `super.key`.
*   `@override Widget build(BuildContext context)`: هذه الدالة هي الجزء الأساسي لأي ودجت في Flutter، حيث تقوم ببناء واجهة المستخدم الخاصة بالودجت. `BuildContext` هو مقبض (handle) لموقع الودجت في شجرة الودجات (widget tree).

#### استخدام `ShadApp` و `ShadApp.custom` (مراجعة وتحديث)

الكود الأصلي كان يحتوي على سطرين `return`، ولكن في التطبيق الفعلي، يتم استخدام واحد فقط. لنركز على الأمثلة الأكثر تفصيلاً وتخصيصًا:

*   **`ShadApp.custom(...)`**: هذا هو البناء الأكثر مرونة لـ `ShadApp`، والذي يسمح بتخصيص الثيمات ودمج `shadcn_ui` مع `MaterialApp` أو `CupertinoApp`. خصائصه:
    *   `themeMode: ThemeMode.dark`: تحدد وضع الثيم (theme mode) للتطبيق. هنا تم تعيينه على `ThemeMode.dark`، مما يعني أن التطبيق سيعرض الثيم الداكن (dark theme) بشكل دائم. الخيارات الأخرى هي `ThemeMode.light` للثيم الفاتح (light theme) و `ThemeMode.system` لاستخدام إعدادات الثيم الخاصة بالنظام.
    *   `darkTheme: ShadThemeData(...)`: هذه الخاصية تحدد بيانات الثيم (theme data) التي سيتم استخدامها عندما يكون `themeMode` هو `ThemeMode.dark` أو عندما يكون وضع النظام داكنًا. `ShadThemeData` هو كائن يحتوي على جميع خصائص الثيم الخاصة بـ `shadcn_ui`.
        *   `brightness: Brightness.dark`: تحدد سطوع (brightness) الثيم كـ `dark`.
        *   `colorScheme: const ShadSlateColorScheme.dark()`: تحدد نظام الألوان (color scheme) للثيم الداكن. `ShadSlateColorScheme.dark()` يوفر مجموعة محددة مسبقًا من الألوان التي تتناسب مع الثيم الداكن لمكونات `shadcn_ui`.
    *   `appBuilder: (context) { ... }`: هذه الخاصية هي دالة بناء (builder function) تُستخدم لإنشاء الودجت الجذر الفعلي للتطبيق. هذا يسمح بدمج `shadcn_ui` مع `MaterialApp` أو `CupertinoApp`.
        *   `return MaterialApp(...)`: هنا يتم استخدام `MaterialApp` كودجت جذر للتطبيق، مما يعني أن التطبيق سيستخدم تصميم Material Design. خصائصه:
            *   `theme: Theme.of(context)`: هذه الخاصية تحدد الثيم الذي سيستخدمه `MaterialApp`. `Theme.of(context)` هنا يشير إلى الثيم الذي تم توفيره بواسطة `ShadApp.custom`، مما يضمن أن `MaterialApp` يستخدم إعدادات الثيم المتوافقة مع `shadcn_ui`.
            *   `localizationsDelegates: const [...]`: هذه الخاصية تحدد قائمة من مفوضي التوطين (localization delegates) التي تدعم اللغات المختلفة في التطبيق. تتضمن:
                *   `GlobalShadLocalizations.delegate`: مفوض التوطين الخاص بـ `shadcn_ui`.
                *   `GlobalMaterialLocalizations.delegate`: مفوض التوطين الخاص بـ Material Design.
                *   `GlobalCupertinoLocalizations.delegate`: مفوض التوطين الخاص بـ Cupertino Design.
                *   `GlobalWidgetsLocalizations.delegate`: مفوض التوطين العام للودجات.
            *   `builder: (context, child) { return ShadAppBuilder(child: child!); }`: هذه الدالة هي دالة بناء أخرى تسمح بدمج `ShadAppBuilder` مع `MaterialApp`. `ShadAppBuilder` هو ودجت من `shadcn_ui` يضمن أن مكونات `shadcn_ui` تعمل بشكل صحيح داخل شجرة الودجات الخاصة بـ `MaterialApp`.

*   **تخصيص `ShadApp` بشكل مباشر (Direct ShadApp Customization)**:
    يمكنك أيضًا تخصيص الثيمات مباشرة داخل `ShadApp` دون الحاجة إلى `ShadApp.custom` إذا كنت لا تدمج مع `MaterialApp` أو `CupertinoApp` بشكل صريح في هذا المستوى.
    ```dart
    return ShadApp(
      darkTheme: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadSlateColorScheme.dark(
            background: Colors.blue, // تخصيص لون الخلفية للثيم الداكن
          ),
          primaryButtonTheme: const ShadButtonTheme(
            backgroundColor: Colors.cyan, // تخصيص لون خلفية الأزرار الأساسية
          ),
        ),
      child: // ... الودجت الرئيسي لتطبيقك
    );
    ```
    *   `darkTheme: ShadThemeData(...)`: كما ذكرنا سابقًا، يحدد ثيم الوضع الداكن.
    *   `colorScheme: const ShadSlateColorScheme.dark(background: Colors.blue,)`: هنا، يتم إنشاء `ShadSlateColorScheme.dark` ولكن يتم **تجاوز (override)** لون الخلفية الافتراضي ليصبح `Colors.blue`. هذا يوضح كيفية تخصيص ألوان محددة داخل نظام الألوان الخاص بـ `shadcn_ui`.
    *   `primaryButtonTheme: const ShadButtonTheme(backgroundColor: Colors.cyan,)`: هذه الخاصية تسمح بتخصيص ثيم الأزرار الأساسية (primary buttons). هنا، يتم تعيين لون الخلفية للأزرار الأساسية إلى `Colors.cyan`.

### 4. تعريف `ThemeData` الافتراضي (Default ThemeData Definition)

هذا الجزء من الكود يوضح كيف يتم بناء `ThemeData` الافتراضي بواسطة `ShadApp` عند دمجه مع Material Design. هذه ليست جزءًا من الكود الذي تكتبه عادةً، بل هي تعريف داخلي يوضح كيف يتم تحويل `ShadThemeData` إلى `ThemeData`.

```dart
ThemeData(
  fontFamily: themeData.textTheme.family,
  extensions: themeData.extensions,
  colorScheme: ColorScheme(
    brightness: themeData.brightness,
    primary: themeData.colorScheme.primary,
    onPrimary: themeData.colorScheme.primaryForeground,
    secondary: themeData.colorScheme.secondary,
    onSecondary: themeData.colorScheme.secondaryForeground,
    error: themeData.colorScheme.destructive,
    onError: themeData.colorScheme.destructiveForeground,
    surface: themeData.colorScheme.background,
    onSurface: themeData.colorScheme.foreground,
  ),
  scaffoldBackgroundColor: themeData.colorScheme.background,
  brightness: themeData.brightness,
  dividerTheme: DividerThemeData(
    color: themeData.colorScheme.border,
    thickness: 1,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: themeData.colorScheme.primary,
    selectionColor: themeData.colorScheme.selection,
    selectionHandleColor: themeData.colorScheme.primary,
  ),
  iconTheme: IconThemeData(
    size: 16,
    color: themeData.colorScheme.foreground,
  ),
  scrollbarTheme: ScrollbarThemeData(
    crossAxisMargin: 1,
    mainAxisMargin: 1,
    thickness: const WidgetStatePropertyAll(8),
    radius: const Radius.circular(999),
    thumbColor: WidgetStatePropertyAll(themeData.colorScheme.border),
  ),
),
```

هنا، `themeData` يشير إلى كائن `ShadThemeData` الذي تم تكوينه مسبقًا. يتم استخدام خصائصه لملء خصائص `ThemeData` الخاصة بـ Material Design:

*   `fontFamily: themeData.textTheme.family`: يحدد عائلة الخط (font family) الافتراضية للتطبيق، مأخوذة من إعدادات `shadcn_ui`.
*   `extensions: themeData.extensions`: يسمح بتوسيع الثيم بخصائص مخصصة.
*   `colorScheme: ColorScheme(...)`: يحدد نظام الألوان العام للتطبيق، مع تعيين كل لون من `shadcn_ui` إلى نظيره في Material Design:
    *   `brightness`: سطوع الثيم (داكن/فاتح).
    *   `primary`: اللون الأساسي (primary color).
    *   `onPrimary`: اللون الذي يظهر فوق اللون الأساسي (on primary color).
    *   `secondary`: اللون الثانوي (secondary color).
    *   `onSecondary`: اللون الذي يظهر فوق اللون الثانوي (on secondary color).
    *   `error`: لون الخطأ (error color).
    *   `onError`: اللون الذي يظهر فوق لون الخطأ (on error color).
    *   `surface`: لون السطح (surface color)، وهو لون خلفية البطاقات (cards) والأوراق (sheets) والقوائم (menus).
    *   `onSurface`: اللون الذي يظهر فوق لون السطح (on surface color).
*   `scaffoldBackgroundColor: themeData.colorScheme.background`: يحدد لون خلفية `Scaffold`، وهو الودجت الذي يوفر هيكل تطبيق Material Design الأساسي.
*   `brightness: themeData.brightness`: يحدد سطوع الثيم العام.
*   `dividerTheme: DividerThemeData(...)`: يحدد خصائص الثيم الخاصة بالخطوط الفاصلة (dividers).
    *   `color: themeData.colorScheme.border`: لون الخط الفاصل، مأخوذ من لون الحدود (border color) في `shadcn_ui`.
    *   `thickness: 1`: سمك الخط الفاصل.
*   `textSelectionTheme: TextSelectionThemeData(...)`: يحدد خصائص الثيم الخاصة باختيار النص (text selection).
    *   `cursorColor: themeData.colorScheme.primary`: لون المؤشر (cursor color).
    *   `selectionColor: themeData.colorScheme.selection`: لون النص المحدد (selection color).
    *   `selectionHandleColor: themeData.colorScheme.primary`: لون مقبض التحديد (selection handle color).
*   `iconTheme: IconThemeData(...)`: يحدد خصائص الثيم الخاصة بالأيقونات (icons).
    *   `size: 16`: حجم الأيقونات الافتراضي.
    *   `color: themeData.colorScheme.foreground`: لون الأيقونات، مأخوذ من لون المقدمة (foreground color) في `shadcn_ui`.
*   `scrollbarTheme: ScrollbarThemeData(...)`: يحدد خصائص الثيم الخاصة بشريط التمرير (scrollbar).
    *   `crossAxisMargin: 1`: الهامش (margin) على المحور المتقاطع.
    *   `mainAxisMargin: 1`: الهامش على المحور الرئيسي.
    *   `thickness: const WidgetStatePropertyAll(8)`: سمك شريط التمرير.
    *   `radius: const Radius.circular(999)`: نصف قطر (radius) حواف شريط التمرير، مما يجعله مستديرًا بالكامل.
    *   `thumbColor: WidgetStatePropertyAll(themeData.colorScheme.border)`: لون مقبض شريط التمرير (thumb color)، مأخوذ من لون الحدود في `shadcn_ui`.

### 5. تعريف `CupertinoThemeData` الافتراضي (Default CupertinoThemeData Definition)

هذا الجزء يوضح كيف يتم بناء `CupertinoThemeData` الافتراضي بواسطة `ShadApp` عند دمجه مع Cupertino Design. مثل `ThemeData`، هذا ليس جزءًا من الكود الذي تكتبه عادةً.

```dart
CupertinoThemeData(
  primaryColor: themeData.colorScheme.primary,
  primaryContrastingColor: themeData.colorScheme.primaryForeground,
  scaffoldBackgroundColor: themeData.colorScheme.background,
  barBackgroundColor: themeData.colorScheme.primary,
  brightness: themeData.brightness,
),
```

هنا، `themeData` يشير أيضًا إلى كائن `ShadThemeData` الذي تم تكوينه مسبقًا. يتم استخدام خصائصه لملء خصائص `CupertinoThemeData` الخاصة بـ Cupertino Design:

*   `primaryColor: themeData.colorScheme.primary`: اللون الأساسي لتصميم Cupertino.
*   `primaryContrastingColor: themeData.colorScheme.primaryForeground`: اللون المتناقض مع اللون الأساسي، يستخدم عادة للنص أو الأيقونات التي تظهر فوق اللون الأساسي.
*   `scaffoldBackgroundColor: themeData.colorScheme.background`: لون خلفية `CupertinoPageScaffold`.
*   `barBackgroundColor: themeData.colorScheme.primary`: لون خلفية أشرطة التنقل (navigation bars) في Cupertino.
*   `brightness: themeData.brightness`: سطوع الثيم العام (داكن/فاتح).

### 6. تخصيص الألوان المتقدمة باستخدام `extension` و `custom`

#### 6.1. تعريف امتداد اللون المخصص (Custom Color Extension)

```dart
extension CustomColorExtension on ShadColorScheme {
  Color get myCustomColor => custom['myCustomColor']!;
}
```

*   **`extension CustomColorExtension on ShadColorScheme`**: هذا يعلن عن امتداد (extension) باسم `CustomColorExtension` على الفئة `ShadColorScheme`. يسمح هذا بإضافة وظائف جديدة (مثل getters أو methods) إلى `ShadColorScheme` دون تعديل الكود الأصلي للفئة.
*   **`Color get myCustomColor`**: هذا يحدد getter باسم `myCustomColor` يعيد كائن `Color`.
*   **`=> custom['myCustomColor']!`**: هذا هو تنفيذ الـ getter. يقوم بالوصول إلى الخريطة `custom` (وهي خاصية في `ShadColorScheme` حيث يتم تخزين الألوان المخصصة) ويسترد اللون المرتبط بالمفتاح `'myCustomColor'`. يتم استخدام عامل التشغيل `!` للتأكيد على أن القيمة ليست `null`، بافتراض أن `myCustomColor` سيكون موجودًا دائمًا في الخريطة `custom`.

#### 6.2. استخدام اللون المخصص في `ShadApp`

```dart
return ShadApp(
  theme: ShadThemeData(
    colorScheme: const ShadZincColorScheme.light(
      custom: {
        'myCustomColor': Color.fromARGB(255, 177, 4, 196),
      },
    ),
  ),
);
```

*   **`ShadApp(...)`**: الودجت الجذر لتطبيق `shadcn_ui`.
*   **`theme: ShadThemeData(...)`**: يحدد بيانات الثيم للتطبيق.
*   **`colorScheme: const ShadZincColorScheme.light(...)`**: ينشئ نظام ألوان فاتحًا يعتمد على لوحة 
ألوان `ShadZincColorScheme`. هنا، يتم تمرير خريطة `custom` لتحديد الألوان المخصصة.
*   **`custom: { 'myCustomColor': Color.fromARGB(255, 177, 4, 196), }`**: هذه هي الطريقة التي يتم بها تعريف الألوان المخصصة. يتم تمرير خريطة (map) حيث يكون المفتاح هو اسم اللون المخصص (في هذه الحالة `myCustomColor`) والقيمة هي كائن `Color` الخاص به. هذا اللون سيكون متاحًا عبر الامتداد `myCustomColor` الذي عرفناه سابقًا.

### 7. استخدام `ShadSelect` وقائمة الألوان المتاحة

```dart
// Somewhere in your app
ShadSelect<String>(
  initialValue: 'slate',
  maxHeight: 200,
  options: shadThemeColors.map(
    (option) => ShadOption(
      value: option,
      child: Text(
        option.capitalizeFirst(),
      ),
    ),
  ),
  selectedOptionBuilder: (context, value) {
    return Text(value.capitalizeFirst());
  },
  onChanged: (value) {
    // rebuild the app using your state management solution
  },
),
```

*   **`ShadSelect<String>(...)`**: هذا هو ودجت (widget) قائمة الاختيار (dropdown/select) من مكتبة `shadcn_ui`. يتم تحديد نوع البيانات التي سيتعامل معها (`String` في هذه الحالة).
*   **`initialValue: 'slate'`**: يحدد القيمة الأولية المختارة في قائمة الاختيار.
*   **`maxHeight: 200`**: يحدد أقصى ارتفاع لقائمة الخيارات عند فتحها.
*   **`options: shadThemeColors.map(...)`**: هذه الخاصية تحدد قائمة الخيارات التي ستظهر في `ShadSelect`. يتم استخدام الدالة `map` لتحويل قائمة `shadThemeColors` (التي سنشرحها لاحقًا) إلى قائمة من ودجات `ShadOption`.
    *   **`(option) => ShadOption(...)`**: لكل عنصر `option` في `shadThemeColors`، يتم إنشاء `ShadOption`.
        *   **`value: option`**: القيمة الفعلية المرتبطة بهذا الخيار (مثل `blue`, `gray`, إلخ).
        *   **`child: Text(option.capitalizeFirst(),)`**: الودجت الذي سيتم عرضه لكل خيار. هنا، يتم عرض النص الخاص باللون، ويتم استخدام امتداد `capitalizeFirst()` (من مكتبة `awesome_flutter_extensions`) لجعل الحرف الأول من اسم اللون كبيرًا (مثال: `Slate` بدلاً من `slate`).
*   **`selectedOptionBuilder: (context, value) { return Text(value.capitalizeFirst()); }`**: هذه الدالة تحدد كيفية بناء الودجت الذي يمثل الخيار المحدد حاليًا في `ShadSelect`. هنا، يتم عرض النص الخاص بالقيمة المحددة مع جعل الحرف الأول كبيرًا.
*   **`onChanged: (value) { ... }`**: هذه دالة رد نداء (callback function) يتم استدعاؤها عندما يختار المستخدم قيمة جديدة من القائمة. يمكنك استخدامها لتحديث حالة التطبيق (state management solution) بناءً على القيمة المختارة.

#### قائمة أسماء أنظمة الألوان المتاحة (`shadThemeColors`)

```dart
// available color scheme names
final shadThemeColors = [
  'blue',
  'gray',
  'green',
  'neutral',
  'orange',
  'red',
  'rose',
  'slate',
  'stone',
  'violet',
  'yellow',
  'zinc',
];
```

*   **`final shadThemeColors = [...]`**: هذه قائمة ثابتة (final list) تحتوي على أسماء أنظمة الألوان الافتراضية المتوفرة في `shadcn_ui`. هذه الأسماء تُستخدم لإنشاء `ShadColorScheme` من خلال `ShadColorScheme.fromName` أو لتحديد الألوان في مكونات مثل `ShadSelect`.

#### إنشاء أنظمة ألوان من الأسماء

```dart
final lightColorScheme = ShadColorScheme.fromName('blue');
final darkColorScheme = ShadColorScheme.fromName('slate', brightness: Brightness.dark);
```

*   **`final lightColorScheme = ShadColorScheme.fromName('blue');`**: ينشئ كائن `ShadColorScheme` باستخدام نظام الألوان المسمى `blue` مع السطوع الافتراضي (light).
*   **`final darkColorScheme = ShadColorScheme.fromName('slate', brightness: Brightness.dark);`**: ينشئ كائن `ShadColorScheme` باستخدام نظام الألوان المسمى `slate` ويحدد السطوع ليكون `Brightness.dark`، مما ينتج عنه نظام ألوان داكن.

### 8. تخصيص الثيمات العميقة في `ShadApp`

```dart
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/material.dart'; // تأكد من استيرادها إذا كنت تستخدم Colors.blue أو Colors.cyan

@override
Widget build(BuildContext context) {
  return ShadApp(
    darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(
          background: Colors.blue, // تخصيص لون الخلفية للثيم الداكن
        ),
        primaryButtonTheme: const ShadButtonTheme(
          backgroundColor: Colors.cyan, // تخصيص لون خلفية الأزرار الأساسية
        ),
      ),
    child: // ... الودجت الرئيسي لتطبيقك
  );
}
```

*   **`ShadApp(...)`**: الودجت الجذر لتطبيق `shadcn_ui`.
*   **`darkTheme: ShadThemeData(...)`**: يحدد الثيم الذي سيتم استخدامه عندما يكون التطبيق في الوضع الداكن.
    *   **`brightness: Brightness.dark`**: يحدد أن هذا الثيم هو للوضع الداكن.
    *   **`colorScheme: const ShadSlateColorScheme.dark(background: Colors.blue,)`**: هنا، يتم استخدام `ShadSlateColorScheme.dark` كنظام ألوان أساسي للوضع الداكن، ولكن يتم **تجاوز (override)** لون الخلفية الافتراضي (background) ليصبح `Colors.blue`. هذا يوضح كيف يمكنك تعديل ألوان محددة داخل نظام الألوان المدمج.
    *   **`primaryButtonTheme: const ShadButtonTheme(backgroundColor: Colors.cyan,)`**: هذه الخاصية تسمح بتخصيص الثيم الخاص بمكونات الأزرار الأساسية (primary buttons) في `shadcn_ui`. هنا، يتم تعيين لون الخلفية (backgroundColor) لجميع الأزرار الأساسية إلى `Colors.cyan`.
*   **`child: ...`**: هذا هو الودجت الرئيسي لتطبيقك الذي سيتم عرضه داخل `ShadApp`، وسيستفيد من الثيمات والتخصيصات التي تم تعريفها.

## الخلاصة (محدثة)

يوضح هذا الشرح التفصيلي كيفية إعداد تطبيق Flutter باستخدام `shadcn_ui`، مع التركيز على المرونة في دمجها مع أنظمة تصميم Material و Cupertino، بالإضافة إلى القدرة على تخصيص الثيمات والألوان بشكل عميق. من خلال `ShadApp.custom` أو التخصيص المباشر لـ `ShadApp`، يمكن للمطورين التحكم الكامل في الثيمات، بما في ذلك وضع الثيم، ألوان الثيم الداكن، وتوفير مفوضي التوطين اللازمين. كما تم توضيح كيفية إضافة ألوان مخصصة باستخدام الامتدادات (extensions) وخاصية `custom` في `ShadColorScheme`، وكيفية استخدام مكونات مثل `ShadSelect` مع قائمة الألوان المتاحة. هذه المرونة تجعل `shadcn_ui` أداة قوية لتطوير واجهات مستخدم جذابة ومخصصة في Flutter.

## المراجع

[1]: https://mariuti.com/flutter-shadcn-ui/ "Flutter Shadcn UI docs"
undColor: themeData.colorScheme.background`: لون خلفية `CupertinoPageScaffold`.
*   `barBackgroundColor: themeData.colorScheme.primary`: لون خلفية أشرطة التنقل (navigation bars) في Cupertino.
*   `brightness: themeData.brightness`: سطوع الثيم العام (داكن/فاتح).

### 6. تخصيص الألوان المتقدمة باستخدام `extension` و `custom`

#### 6.1. تعريف امتداد اللون المخصص (Custom Color Extension)

```dart
extension CustomColorExtension on ShadColorScheme {
  Color get myCustomColor => custom["myCustomColor"]!;
}
```

*   **`extension CustomColorExtension on ShadColorScheme`**: هذا يعلن عن امتداد (extension) باسم `CustomColorExtension` على الفئة `ShadColorScheme`. يسمح هذا بإضافة وظائف جديدة (مثل getters أو methods) إلى `ShadColorScheme` دون تعديل الكود الأصلي للفئة.
*   **`Color get myCustomColor`**: هذا يحدد getter باسم `myCustomColor` يعيد كائن `Color`.
*   **`=> custom["myCustomColor"]!`**: هذا هو تنفيذ الـ getter. يقوم بالوصول إلى الخريطة `custom` (وهي خاصية في `ShadColorScheme` حيث يتم تخزن الألوان المخصصة) ويسترد اللون المرتبط بالمفتاح `"myCustomColor"`. يتم استخدام عامل التشغيل `!` للتأكيد على أن القيمة ليست `null`، بافتراض أن `myCustomColor` سيكون موجودًا دائمًا في الخريطة `custom`.

#### 6.2. استخدام اللون المخصص في `ShadApp`

```dart
return ShadApp(
  theme: ShadThemeData(
    colorScheme: const ShadZincColorScheme.light(
      custom: {
        "myCustomColor": Color.fromARGB(255, 177, 4, 196),
      },
    ),
  ),
);
```

*   **`ShadApp(...)`**: الودجت الجذر لتطبيق `shadcn_ui`.
*   **`theme: ShadThemeData(...)`**: يحدد بيانات الثيم للتطبيق.
*   **`colorScheme: const ShadZincColorScheme.light(...)`**: ينشئ نظام ألوان فاتحًا يعتمد على لوحة ألوان `ShadZincColorScheme`. هنا، يتم تمرير خريطة `custom` لتحديد الألوان المخصصة.
*   **`custom: { "myCustomColor": Color.fromARGB(255, 177, 4, 196), }`**: هذه هي الطريقة التي يتم بها تعريف الألوان المخصصة. يتم تمرير خريطة (map) حيث يكون المفتاح هو اسم اللون المخصص (في هذه الحالة `myCustomColor`) والقيمة هي كائن `Color` الخاص به. هذا اللون سيكون متاحًا عبر الامتداد `myCustomColor` الذي عرفناه سابقًا.

### 7. استخدام `ShadSelect` وقائمة الألوان المتاحة

```dart
// Somewhere in your app
ShadSelect<String>(
  initialValue: 'slate',
  maxHeight: 200,
  options: shadThemeColors.map(
    (option) => ShadOption(
      value: option,
      child: Text(
        option.capitalizeFirst(),
      ),
    ),
  ),
  selectedOptionBuilder: (context, value) {
    return Text(value.capitalizeFirst());
  },
  onChanged: (value) {
    // rebuild the app using your state management solution
  },
),
```

*   **`ShadSelect<String>(...)`**: هذا هو ودجت (widget) قائمة الاختيار (dropdown/select) من مكتبة `shadcn_ui`. يتم تحديد نوع البيانات التي سيتعامل معها (`String` في هذه الحالة).
*   **`initialValue: 'slate'`**: يحدد القيمة الأولية المختارة في قائمة الاختيار.
*   **`maxHeight: 200`**: يحدد أقصى ارتفاع لقائمة الخيارات عند فتحها.
*   **`options: shadThemeColors.map(...)`**: هذه الخاصية تحدد قائمة الخيارات التي ستظهر في `ShadSelect`. يتم استخدام الدالة `map` لتحويل قائمة `shadThemeColors` (التي سنشرحها لاحقًا) إلى قائمة من ودجات `ShadOption`.
    *   **`(option) => ShadOption(...)`**: لكل عنصر `option` في `shadThemeColors`، يتم إنشاء `ShadOption`.
        *   **`value: option`**: القيمة الفعلية المرتبطة بهذا الخيار (مثل `blue`, `gray`, إلخ).
        *   **`child: Text(option.capitalizeFirst(),)`**: الودجت الذي سيتم عرضه لكل خيار. هنا، يتم عرض النص الخاص باللون، ويتم استخدام امتداد `capitalizeFirst()` (من مكتبة `awesome_flutter_extensions`) لجعل الحرف الأول من اسم اللون كبيرًا (مثال: `Slate` بدلاً من `slate`).
*   **`selectedOptionBuilder: (context, value) { return Text(value.capitalizeFirst()); }`**: هذه الدالة تحدد كيفية بناء الودجت الذي يمثل الخيار المحدد حاليًا في `ShadSelect`. هنا، يتم عرض النص الخاص بالقيمة المحددة مع جعل الحرف الأول كبيرًا.
*   **`onChanged: (value) { ... }`**: هذه دالة رد نداء (callback function) يتم استدعاؤها عندما يختار المستخدم قيمة جديدة من القائمة. يمكنك استخدامها لتحديث حالة التطبيق (state management solution) بناءً على القيمة المختارة.

#### قائمة أسماء أنظمة الألوان المتاحة (`shadThemeColors`)

```dart
// available color scheme names
final shadThemeColors = [
  'blue',
  'gray',
  'green',
  'neutral',
  'orange',
  'red',
  'rose',
  'slate',
  'stone',
  'violet',
  'yellow',
  'zinc',
];
```

*   **`final shadThemeColors = [...]`**: هذه قائمة ثابتة (final list) تحتوي على أسماء أنظمة الألوان الافتراضية المتوفرة في `shadcn_ui`. هذه الأسماء تُستخدم لإنشاء `ShadColorScheme` من خلال `ShadColorScheme.fromName` أو لتحديد الألوان في مكونات مثل `ShadSelect`.

#### إنشاء أنظمة ألوان من الأسماء

```dart
final lightColorScheme = ShadColorScheme.fromName('blue');
final darkColorScheme = ShadColorScheme.fromName('slate', brightness: Brightness.dark);
```

*   **`final lightColorScheme = ShadColorScheme.fromName('blue');`**: ينشئ كائن `ShadColorScheme` باستخدام نظام الألوان المسمى `blue` مع السطوع الافتراضي (light).
*   **`final darkColorScheme = ShadColorScheme.fromName('slate', brightness: Brightness.dark);`**: ينشئ كائن `ShadColorScheme` باستخدام نظام الألوان المسمى `slate` ويحدد السطوع ليكون `Brightness.dark`، مما ينتج عنه نظام ألوان داكن.

### 8. تخصيص الثيمات العميقة في `ShadApp`

```dart
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/material.dart'; // تأكد من استيرادها إذا كنت تستخدم Colors.blue أو Colors.cyan

@override
Widget build(BuildContext context) {
  return ShadApp(
    darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(
          background: Colors.blue, // تخصيص لون الخلفية للثيم الداكن
        ),
        primaryButtonTheme: const ShadButtonTheme(
          backgroundColor: Colors.cyan, // تخصيص لون خلفية الأزرار الأساسية
        ),
      ),
    child: // ... الودجت الرئيسي لتطبيقك
  );
}
```

*   **`ShadApp(...)`**: الودجت الجذر لتطبيق `shadcn_ui`.
*   **`darkTheme: ShadThemeData(...)`**: يحدد الثيم الذي سيتم استخدامه عندما يكون التطبيق في الوضع الداكن.
    *   **`brightness: Brightness.dark`**: يحدد أن هذا الثيم هو للوضع الداكن.
    *   **`colorScheme: const ShadSlateColorScheme.dark(background: Colors.blue,)`**: هنا، يتم استخدام `ShadSlateColorScheme.dark` كنظام ألوان أساسي للوضع الداكن، ولكن يتم **تجاوز (override)** لون الخلفية الافتراضي (background) ليصبح `Colors.blue`. هذا يوضح كيف يمكنك تعديل ألوان محددة داخل نظام الألوان المدمج.
    *   **`primaryButtonTheme: const ShadButtonTheme(backgroundColor: Colors.cyan,)`**: هذه الخاصية تسمح بتخصيص الثيم الخاص بمكونات الأزرار الأساسية (primary buttons) في `shadcn_ui`. هنا، يتم تعيين لون الخلفية (backgroundColor) لجميع الأزرار الأساسية إلى `Colors.cyan`.
*   **`child: ...`**: هذا هو الودجت الرئيسي لتطبيقك الذي سيتم عرضه داخل `ShadApp`، وسيستفيد من الثيمات والتخصيصات التي تم تعريفها.

### 9. نظام التخطيط المتجاوب (Responsive Layout)

تعتمد `shadcn_ui` على مبادئ التصميم المتجاوب (Responsive Design) لتوفير تجربة مستخدم متناسقة عبر مختلف أحجام الشاشات والأجهزة. على الرغم من أن `shadcn_ui` لا توفر ودجات تخطيط متجاوبة خاصة بها بشكل مباشر، إلا أنها مصممة للعمل بسلاسة مع آليات Flutter المدمجة للتخطيط المتجاوب، مثل `MediaQuery` و `LayoutBuilder` و `Expanded` و `Flexible`.

*   **`MediaQuery`**: يمكن استخدام `MediaQuery.of(context).size` للحصول على أبعاد الشاشة الحالية وتكييف واجهة المستخدم بناءً عليها. على سبيل المثال، يمكنك تغيير حجم الخطوط أو تباعد المكونات بناءً على عرض الشاشة.
*   **`LayoutBuilder`**: يسمح لك ببناء ودجات مختلفة بناءً على قيود المساحة المتاحة للودجت الأب. هذا مفيد لإنشاء تخطيطات تتغير بشكل كبير بين أحجام الشاشات الصغيرة والكبيرة.
*   **`Expanded` و `Flexible`**: تُستخدم هذه الودجات داخل `Row` و `Column` لتوزيع المساحة المتاحة بين الودجات الفرعية بشكل مرن، مما يساعد في إنشاء تخطيطات تتكيف مع المساحة المتاحة.

مثال على استخدام `MediaQuery` لتغيير حجم النص:

```dart
Text(
  'مرحباً بكم في shadcn_ui!',
  style: TextStyle(
    fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 16,
  ),
)
```

### 10. الـ Decorators (المُزخرفات)

في سياق `shadcn_ui`، يمكن فهم 
الـ Decorators (المُزخرفات) على أنها ودجات أو وظائف تساعد في تطبيق أنماط (styles) أو سلوكيات (behaviors) معينة على مكونات `shadcn_ui` أو أي ودجت آخر. هذه المزخرفات يمكن أن تكون بسيطة مثل `Padding` أو `Container`، أو أكثر تعقيدًا مثل تلك التي توفرها المكتبة نفسها لتطبيق تأثيرات بصرية أو تفاعلات محددة.

على سبيل المثال، قد توفر `shadcn_ui` ودجات مزخرفة لتطبيق تأثيرات الظل (shadows)، أو الحدود (borders)، أو حتى لتغيير شكل المكونات بطريقة معينة لتتناسب مع فلسفة تصميم `shadcn/ui`.

### 11. التعامل مع النماذج (Forms) والتحقق من صحتها (Validation)

توفر `shadcn_ui` مكونات نماذج (Form components) متكاملة تسهل بناء النماذج المعقدة والتعامل مع التحقق من صحة المدخلات (input validation). تعتمد هذه المكونات عادةً على `Form` و `FormField` من Flutter، ولكنها توفر ودجات مصممة مسبقًا تتوافق مع جمالية `shadcn/ui`.

#### مثال على استخدام `ShadForm`:

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MyFormPage extends StatefulWidget {
  const MyFormPage({super.key});

  @override
  State<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  final _formKey = GlobalKey<ShadFormState>();
  String _name = '';
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      child: Scaffold(
        appBar: AppBar(title: const Text('Shadcn Form Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ShadForm(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadInput(
                  placeholder: 'الاسم',
                  onChanged: (value) => _name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الاسم مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ShadInput(
                  placeholder: 'البريد الإلكتروني',
                  onChanged: (value) => _email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'البريد الإلكتروني مطلوب';
                    }
                    if (!value.contains('@')) {
                      return 'أدخل بريدًا إلكترونيًا صالحًا';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ShadButton(
                  text: const Text('إرسال'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // قم بمعالجة البيانات هنا
                      ShadToast.of(context).show(
                        title: const Text('تم الإرسال بنجاح'),
                        description: Text('الاسم: $_name, البريد الإلكتروني: $_email'),
                      );
                    }
                  },
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

*   **`ShadForm`**: هو ودجت نموذج (Form widget) من `shadcn_ui`، وهو يغلف مجموعة من حقول النموذج ويوفر وظائف للتحقق من صحة المدخلات وإدارة الحالة.
*   **`GlobalKey<ShadFormState>()`**: مفتاح عام (GlobalKey) يستخدم للوصول إلى حالة `ShadForm`، مما يسمح بالتحقق من صحة النموذج (مثل استدعاء `_formKey.currentState!.validate()`).
*   **`ShadInput`**: ودجت حقل إدخال نصي (text input field) من `shadcn_ui`.
    *   **`placeholder`**: نص يظهر داخل حقل الإدخال عندما يكون فارغًا.
    *   **`onChanged`**: دالة رد نداء تُستدعى عند تغيير قيمة حقل الإدخال.
    *   **`validator`**: دالة تُستخدم للتحقق من صحة المدخلات. إذا أعادت سلسلة نصية (String)، فهذا يعني وجود خطأ وسيتم عرض النص. إذا أعادت `null`، فالحقل صالح.
*   **`ShadButton`**: ودجت زر (button) من `shadcn_ui`.
    *   **`onPressed`**: دالة رد نداء تُستدعى عند الضغط على الزر. هنا، يتم استدعاء `_formKey.currentState!.validate()` للتحقق من صحة جميع حقول النموذج. إذا كانت جميع الحقول صالحة، يتم تنفيذ منطق معالجة البيانات.

### 12. مكونات التنبيهات والحوارات (Toast and Dialog Components)

توفر `shadcn_ui` مكونات جاهزة لعرض التنبيهات المؤقتة (toasts) والحوارات (dialogs) لتوفير ملاحظات للمستخدم أو طلب مدخلات إضافية.

#### 12.1. `ShadToast` (التنبيهات المؤقتة)

`ShadToast` هو ودجت يستخدم لعرض رسائل قصيرة ومؤقتة للمستخدم، غالبًا في الجزء السفلي من الشاشة، لتأكيد إجراء أو إبلاغ بمعلومة بسيطة.

```dart
ShadToast.of(context).show(
  title: const Text('تم الإرسال بنجاح'),
  description: Text('الاسم: $_name, البريد الإلكتروني: $_email'),
  duration: const Duration(seconds: 3), // مدة عرض التوست
);
```

*   **`ShadToast.of(context).show(...)`**: هذه هي الطريقة الشائعة لعرض `ShadToast`. يتم استدعاء `show` على كائن `ShadToastState` الذي يتم الحصول عليه من `BuildContext`.
*   **`title`**: الودجت الذي يمثل عنوان التوست (عادةً `Text`).
*   **`description`**: الودجت الذي يمثل وصفًا إضافيًا للتوست (عادةً `Text`).
*   **`duration`**: (اختياري) يحدد المدة التي سيظهر فيها التوست على الشاشة قبل أن يختفي تلقائيًا.

#### 12.2. `ShadDialog` (الحوارات)

`ShadDialog` هو ودجت يستخدم لعرض حوارات (dialogs) أو نوافذ منبثقة (modals) تتطلب تفاعل المستخدم، مثل تأكيد إجراء أو عرض معلومات مهمة.

```dart
ShadDialog.alert(
  title: const Text('تأكيد الحذف'),
  description: const Text('هل أنت متأكد أنك تريد حذف هذا العنصر؟ لا يمكن التراجع عن هذا الإجراء.'),
  actions: [
    ShadButton(
      text: const Text('إلغاء'),
      onPressed: () => Navigator.of(context).pop(),
      variant: ShadButtonVariant.outline,
    ),
    ShadButton(
      text: const Text('حذف'),
      onPressed: () {
        // منطق الحذف هنا
        Navigator.of(context).pop();
        ShadToast.of(context).show(
          title: const Text('تم الحذف'),
          description: const Text('تم حذف العنصر بنجاح.'),
        );
      },
      variant: ShadButtonVariant.destructive,
    ),
  ],
).show(context);
```

*   **`ShadDialog.alert(...)`**: طريقة ملائمة لإنشاء حوار تنبيه (alert dialog) بسيط. هناك أيضًا `ShadDialog` عادي لتخصيص أكبر.
*   **`title`**: عنوان الحوار.
*   **`description`**: وصف أو رسالة الحوار.
*   **`actions`**: قائمة من الودجات (عادةً `ShadButton`) التي تمثل الإجراءات التي يمكن للمستخدم اتخاذها في الحوار.
    *   **`Navigator.of(context).pop()`**: يستخدم لإغلاق الحوار.
    *   **`variant: ShadButtonVariant.outline` / `ShadButtonVariant.destructive`**: يحدد نمط الزر (مثل زر مخطط أو زر تحذيري).
*   **`.show(context)`**: دالة تُستخدم لعرض الحوار على الشاشة.

#### 12.3. `ShadSheet` (الأوراق الجانبية)

`ShadSheet` هو ودجت يستخدم لعرض لوحة (panel) تنزلق من أحد جوانب الشاشة (عادةً من الأسفل أو الجانب) لعرض محتوى إضافي أو نماذج.

```dart
ShadSheet.builder(
  title: const Text('إعدادات المستخدم'),
  description: const Text('تعديل تفضيلات حسابك.'),
  builder: (context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadInput(placeholder: 'اسم المستخدم'),
          const SizedBox(height: 16),
          ShadInput(placeholder: 'كلمة المرور'),
          const SizedBox(height: 16),
          ShadButton(text: const Text('حفظ التغييرات'), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  },
).show(context);
```

*   **`ShadSheet.builder(...)`**: طريقة لإنشاء `ShadSheet` حيث يتم توفير المحتوى عبر دالة `builder`.
*   **`title`**: عنوان الورقة الجانبية.
*   **`description`**: وصف للورقة الجانبية.
*   **`builder`**: دالة بناء تُستخدم لإنشاء محتوى الورقة الجانبية. يتم وضع الودجات داخلها.
*   **`.show(context)`**: دالة تُستخدم لعرض الورقة الجانبية على الشاشة.

### 13. مكونات إضافية (Additional Components)

تتضمن `shadcn_ui` العديد من المكونات الأخرى التي يمكن استخدامها لبناء واجهات مستخدم غنية. بعضها يشمل:

*   **`ShadAccordion`**: لعرض محتوى قابل للطي والتوسع.
*   **`ShadAvatar`**: لعرض صور المستخدمين أو الرموز.
*   **`ShadBadge`**: لعرض شارات صغيرة أو علامات.
*   **`ShadCalendar`**: لاختيار التواريخ.
*   **`ShadCard`**: لعرض محتوى في بطاقات منظمة.
*   **`ShadCheckbox`**: لمربعات الاختيار.
*   **`ShadInputOTP`**: لحقول إدخال رمز التحقق لمرة واحدة (OTP).
*   **`ShadMenubar`**: لقوائم التنقل العلوية.
*   **`ShadPopover`**: لعرض محتوى منبثق صغير.
*   **`ShadProgress`**: لعرض شريط التقدم.
*   **`ShadRadioGroup`**: لمجموعات أزرار الراديو.
*   **`ShadSlider`**: لأشرطة التمرير لاختيار قيمة من نطاق.
*   **`ShadSwitch`**: لمفاتيح التبديل (toggle switches).
*   **`ShadTable`**: لعرض البيانات في جداول.
*   **`ShadTabs`**: لعرض محتوى مقسم إلى علامات تبويب.
*   **`ShadTextarea`**: لحقول إدخال النص متعدد الأسطر.
*   **`ShadTooltip`**: لعرض تلميحات الأدوات (tooltips) عند التفاعل مع عنصر.

كل من هذه المكونات يأتي مع خيارات تخصيص واسعة ليتناسب مع احتياجات التصميم الخاصة بك. يوصى بالرجوع إلى [توثيق `shadcn_ui` لـ Flutter][1] للحصول على أمثلة استخدام مفصلة لكل مكون.

## الخلاصة (محدثة و موسعة)

يوضح هذا الشرح التفصيلي والموسع كيفية إعداد تطبيق Flutter باستخدام `shadcn_ui`، مع التركيز على المرونة في دمجها مع أنظمة تصميم Material و Cupertino، بالإضافة إلى القدرة على تخصيص الثيمات والألوان بشكل عميق. من خلال `ShadApp.custom` أو التخصيص المباشر لـ `ShadApp`، يمكن للمطورين التحكم الكامل في الثيمات، بما في ذلك وضع الثيم، ألوان الثيم الداكن، وتوفير مفوضي التوطين اللازمين. كما تم توضيح كيفية إضافة ألوان مخصصة باستخدام الامتدادات (extensions) وخاصية `custom` في `ShadColorScheme`، وكيفية استخدام مكونات مثل `ShadSelect` مع قائمة الألوان المتاحة. بالإضافة إلى ذلك، تم استعراض كيفية التعامل مع نظام التخطيط المتجاوب، وفهم الـ Decorators، وبناء النماذج المعقدة باستخدام `ShadForm` مع التحقق من صحة المدخلات، وعرض التنبيهات والحوارات باستخدام `ShadToast` و `ShadDialog` و `ShadSheet`. هذه المرونة والميزات الغنية تجعل `shadcn_ui` أداة قوية وشاملة لتطوير واجهات مستخدم جذابة ومخصصة في Flutter.

## المراجع

[1]: https://mariuti.com/flutter-shadcn-ui/ "Flutter Shadcn UI docs"
