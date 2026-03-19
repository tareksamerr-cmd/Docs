# موسوعة Flutter لتخزين البيانات: الدليل الهندسي والبرمجي الشامل (إصدار 2026)

تُعد إدارة البيانات محلياً (Local Data Management) في تطبيقات **Flutter** قراراً هندسياً محورياً يؤثر بشكل مباشر على أداء التطبيق، أمانه، وقابلية صيانته. لا يقتصر الأمر على اختيار مكتبة فحسب، بل يتطلب فهماً عميقاً للآليات الداخلية (Internals)، قيود كل حل، وكيفية موازنته مع متطلبات المشروع المحددة. يهدف هذا الدليل إلى تقديم تحليل معمق للمكتبات الأكثر شيوعاً لتخزين البيانات في Flutter، مع التركيز على الجوانب الهندسية المتقدمة والأمثلة البرمجية الشاملة.

---

## 1. التخزين البسيط والآمن: Key-Value Stores

تُستخدم حلول التخزين من نوع **مفتاح-قيمة** (Key-Value Store) لحفظ كميات صغيرة من البيانات غير المهيكلة (Unstructured Data) أو الإعدادات. تتميز بالبساطة والسرعة في الوصول، ولكنها تختلف بشكل كبير في مستوى الأمان والأداء.

### أ. `shared_preferences` (التخزين غير الحساس)

تُعد `shared_preferences` الخيار الافتراضي لحفظ الإعدادات البسيطة. هي في الأساس واجهة برمجية (Wrapper) موحدة للوصول إلى آليات التخزين الأصلية (Native Storage Mechanisms) لكل منصة.

#### الشرح التقني والمعماري
*   **المعمارية الداخلية (Internal Architecture):**
    *   **Android:** تعتمد على فئة `SharedPreferences` في Android SDK، والتي تخزن البيانات في ملفات XML داخل مجلد بيانات التطبيق الخاص (`/data/data/<package_name>/shared_prefs/`). يتم تحميل هذه الملفات بالكامل في الذاكرة عند بدء تشغيل التطبيق لسرعة الوصول. [1]
    *   **iOS/macOS:** تستخدم `NSUserDefaults` (أو `UserDefaults` في Swift)، والتي تخزن البيانات في ملفات `.plist` (Property List) في مجلد `Library/Preferences` الخاص بالتطبيق. [2]
    *   **Web:** تستخدم `localStorage` أو `sessionStorage` في متصفح الويب، والتي تخزن البيانات كسلاسل نصية (Strings).
*   **نموذج البيانات (Data Model):** تدعم أنواع البيانات الأساسية مثل `int`, `double`, `bool`, `String`, و `List<String>`. لا تدعم تخزين الكائنات المعقدة مباشرة.
*   **الأداء (Performance Characteristics):**
    *   **القراءة:** سريعة جداً لأن البيانات تُحمل في الذاكرة. عمليات القراءة متزامنة (Synchronous) في واجهة الـ API، مما يعني أنها تُرجع القيمة فوراً.
    *   **الكتابة:** تتم بشكل غير متزامن (Asynchronous) إلى القرص. عند استدعاء `set...()`، يتم تحديث القيمة في الذاكرة فوراً، ثم يتم جدولة عملية الكتابة إلى القرص في الخلفية. هذا يمنع حظر مؤشر الترابط الرئيسي (Main Thread) لواجهة المستخدم.
*   **الأمان (Security Considerations):**
    *   **نقطة ضعف حرجة:** جميع البيانات تُخزن كنص واضح (Plain Text) غير مشفر. هذا يعني أن أي مستخدم لديه وصول إلى نظام الملفات (مثل الأجهزة التي تمتلك صلاحيات Root أو Jailbreak) يمكنه قراءة هذه البيانات بسهولة. هذا يجعلها غير مناسبة تماماً لتخزين أي معلومات حساسة.
*   **حالات الاستخدام المثلى (Optimal Use Cases):**
    *   حفظ إعدادات واجهة المستخدم (Theme preferences, language settings).
    *   تفضيلات المستخدم غير الحساسة (مثل تفعيل الإشعارات).
    *   حالة تسجيل الدخول البسيطة (مثل `isLoggedIn: true/false`، ولكن ليس رمز الوصول).

#### العمليات البرمجية (CRUD)
```dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // 1. الحفظ (Create/Update)
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', 'Manus AI');
    await prefs.setInt('user_age', 25);
    await prefs.setBool('is_dark_mode', true);
    await prefs.setStringList('tags', ['flutter', 'dart', 'storage']);
  }

  // 2. القراءة (Read)
  Future<void> readData() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('user_name') ?? 'Guest';
    int age = prefs.getInt('user_age') ?? 0;
    bool isDark = prefs.getBool('is_dark_mode') ?? false;
    print('User: $name, Age: $age, DarkMode: $isDark');
  }

  // 3. الحذف (Delete)
  Future<void> removeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // 4. مسح الكل (Clear All)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

### ب. `flutter_secure_storage` (التخزين الحساس)

تُعد `flutter_secure_storage` الحل الأمثل لتخزين البيانات الحساسة التي تتطلب مستوى عالٍ من الأمان. هي أيضاً واجهة برمجية لآليات التخزين الآمنة الأصلية لكل منصة.

#### الشرح التقني والمعماري
*   **المعمارية الأمنية (Security Architecture):**
    *   **iOS/macOS:** تستخدم **Keychain Services**، وهي قاعدة بيانات مشفرة على مستوى النظام مصممة لتخزين البيانات الحساسة مثل كلمات المرور وشهادات الأمان. يتم تشفير البيانات باستخدام مفاتيح مشتقة من عتاد الجهاز (Hardware-backed keys)، مما يجعل فك تشفيرها صعباً للغاية حتى لو تم الوصول إلى الجهاز فعلياً. [3]
    *   **Android:** تستخدم **Android Keystore System** لتوليد وتخزين مفاتيح التشفير بشكل آمن. يتم بعد ذلك استخدام هذه المفاتيح لتشفير البيانات قبل تخزينها في `SharedPreferences` المشفرة (EncryptedSharedPreferences) أو في ملفات مشفرة أخرى. في الإصدارات الحديثة من Android، يمكن ربط المفاتيح بـ **StrongBox Keymaster** للحصول على حماية إضافية ضد الهجمات المادية. [4]
    *   **Web:** لا توفر `flutter_secure_storage` تشفيراً على الويب بشكل افتراضي لأن `localStorage` غير آمنة. قد تحتاج إلى حلول تشفير من جانب العميل (Client-side encryption) يدوياً أو استخدام خدمات خلفية (Backend Services) لتخزين البيانات الحساسة على الويب.
*   **الأداء (Performance Characteristics):**
    *   **البطء النسبي:** عمليات التشفير وفك التشفير تستهلك موارد المعالج وتستغرق وقتاً أطول بكثير مقارنة بـ `shared_preferences`. يجب تجنب استخدامها لتخزين كميات كبيرة من البيانات أو البيانات التي يتم الوصول إليها بشكل متكرر جداً.
    *   **العمليات غير المتزامنة:** جميع عمليات القراءة والكتابة غير متزامنة (Asynchronous) بطبيعتها، مما يضمن عدم حظر واجهة المستخدم.
*   **التحديات التقنية الشائعة (Common Pitfalls):**
    *   **فقدان المفاتيح (Key Loss):** في بعض إصدارات Android القديمة، قد يؤدي تغيير المستخدم لقفل الشاشة (PIN, Pattern, Fingerprint) إلى إبطال مفاتيح التشفير المخزنة في Keystore، مما يؤدي إلى فقدان البيانات المشفرة. يجب التعامل مع هذا السيناريو بشكل صريح في التطبيق.
    *   **الاستخدام المفرط:** استخدامها لتخزين بيانات غير حساسة يؤدي إلى تدهور الأداء دون داعٍ.
*   **حالات الاستخدام المثلى (Optimal Use Cases):**
    *   تخزين رموز الوصول (Access Tokens) ورموز التحديث (Refresh Tokens) لـ OAuth2.
    *   كلمات المرور المشفرة (Encrypted Passwords) أو مفاتيح API.
    *   المعلومات الشخصية الحساسة التي تتطلب حماية قصوى.

#### العمليات البرمجية (CRUD) مع معالجة الأخطاء
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // خيارات متقدمة لكل منصة
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );

  // 1. الكتابة الآمنة (Write)
  Future<void> writeSecureData(String key, String value) async {
    await _storage.write(
      key: key,
      value: value,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  // 2. القراءة الآمنة (Read)
  Future<String?> readSecureData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print('خطأ في فك التشفير: $e');
      return null;
    }
  }

  // 3. حذف مفتاح (Delete)
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  // 4. قراءة جميع البيانات (Read All)
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
```

---

## 2. قواعد البيانات الموجهة للكائنات (NoSQL Object Databases)

تُعد قواعد البيانات الموجهة للكائنات خياراً ممتازاً لتخزين البيانات المهيكلة (Structured Data) أو الكائنات المعقدة (Complex Objects) التي لا تتناسب بسهولة مع نموذج Key-Value، وتوفر أداءً عالياً مع مرونة في نموذج البيانات.

### أ. `hive` (السرعة الخام والكفاءة)

`hive` هي قاعدة بيانات NoSQL خفيفة الوزن وسريعة للغاية، مكتوبة بالكامل بلغة Dart. تم تصميمها لتحقيق أقصى قدر من الأداء مع سهولة الاستخدام.

#### الشرح التقني والمعماري
*   **المعمارية الداخلية (Internal Architecture):**
    *   **صناديق (Boxes):** البيانات تُخزن في مفهوم **الصناديق** (Boxes)، حيث كل صندوق يمثل مجموعة من البيانات من نوع معين. عند فتح صندوق، يتم تحميل محتوياته بالكامل في الذاكرة العشوائية (RAM).
    *   **تنسيق ثنائي مخصص:** تستخدم Hive تنسيقاً ثنائياً (Binary Format) خاصاً بها لتخزين البيانات، مما يقلل من حجم الملفات ويزيد من سرعة القراءة والكتابة مقارنة بـ JSON أو XML. [5]
    *   **مولد الكود (Code Generation):** تعتمد على مولد الكود لإنشاء `TypeAdapters` للكائنات المخصصة (Custom Objects)، مما يسمح بتحويل كائنات Dart إلى تنسيق Hive الثنائي والعكس.
*   **الأداء (Performance Characteristics):**
    *   **سرعة فائقة:** تُعرف Hive بسرعتها المذهلة في عمليات القراءة والكتابة، خاصة عند التعامل مع البيانات التي تتناسب مع الذاكرة. يعود ذلك إلى تحميل الصناديق في الذاكرة واستخدام التنسيق الثنائي. [6]
    *   **تأثير حجم البيانات:** الأداء قد يتأثر سلباً إذا كان حجم الصندوق كبيراً جداً بحيث لا يتناسب مع الذاكرة، مما يؤدي إلى عمليات قراءة وكتابة متكررة من القرص.
*   **الأمان (Security Considerations):**
    *   **التشفير:** تدعم Hive التشفير باستخدام مفتاح تشفير AES 256 بت. يتم تمرير هذا المفتاح عند فتح الصندوق، ويتم تشفير وفك تشفير البيانات تلقائياً. ومع ذلك، يجب على المطور إدارة هذا المفتاح بشكل آمن (مثلاً، تخزينه في `flutter_secure_storage`).
*   **التحديات التقنية الشائعة:**
    *   **التعامل مع البيانات الضخمة:** ليست الخيار الأمثل لتخزين مجموعات بيانات ضخمة جداً (مئات الميجابايتات أو الجيجابايتات) التي لا يمكن تحميلها بالكامل في الذاكرة، حيث قد يؤدي ذلك إلى استهلاك مفرط للذاكرة (OOM) وتدهور الأداء.
    *   **الاستعلامات المعقدة:** لا تدعم الاستعلامات المعقدة أو العلاقات بين الكائنات بشكل مباشر مثل قواعد البيانات العلائقية. يجب على المطور إدارة هذه العلاقات يدوياً.
*   **حالات الاستخدام المثلى:**
    *   التخزين المؤقت (Caching) للبيانات المستلمة من الإنترنت (مثل قائمة المنتجات، المقالات).
    *   تخزين الكائنات المعقدة التي لا تتطلب استعلامات معقدة أو علاقات متعددة.
    *   تطبيقات وضع عدم الاتصال (Offline-first applications) التي تحتاج إلى تخزين سريع وموثوق للبيانات.

#### العمليات البرمجية (CRUD) مع كائنات مخصصة
```dart
import 'package:hive_flutter/hive_flutter.dart';

// 1. تعريف الكائن (Model)
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  User({required this.name, required this.age});
}

// ملاحظة: يجب توليد UserAdapter() باستخدام build_runner
// flutter packages pub run build_runner build

class HiveService {
  static const String boxName = 'userBox';

  // تهيئة Hive
  Future<void> init() async {
    await Hive.initFlutter();
    // Hive.registerAdapter(UserAdapter()); // يتم توليده بواسطة build_runner
    await Hive.openBox<User>(boxName);
  }

  // 2. إضافة/تحديث (Create/Update)
  Future<void> addUser(User user) async {
    var box = Hive.box<User>(boxName);
    await box.add(user); // إضافة تلقائية بـ ID متزايد
    // أو التحديث باستخدام مفتاح معين
    // await box.put('user_1', user);
  }

  // 3. القراءة (Read)
  List<User> getAllUsers() {
    var box = Hive.box<User>(boxName);
    return box.values.toList();
  }

  // 4. الحذف (Delete)
  Future<void> deleteUser(int index) async {
    var box = Hive.box<User>(boxName);
    await box.deleteAt(index);
  }
}
```

### ب. `isar` (الجيل الجديد: الأداء، الأمان، والمرونة)

`isar` هي قاعدة بيانات NoSQL متطورة ومحسّنة بشكل كبير لـ Flutter، وتعتبر تطويراً طبيعياً لمفهوم Hive. تم تصميمها لتوفير أداء استثنائي، أمان، وقدرات استعلام قوية، مع الحفاظ على سهولة الاستخدام.

#### الشرح التقني والمعماري
*   **المعمارية الداخلية (Internal Architecture):**
    *   **نموذج بيانات مرن:** تدعم تخزين الكائنات (Objects) مع دعم للعلاقات (Relations) بينها (واحد لواحد، واحد لمتعدد، متعدد لمتعدد) بشكل أصيل.
    *   **ACID Compliance:** تضمن `isar` خصائص ACID (Atomicity, Consistency, Isolation, Durability)، مما يعني أن عمليات قاعدة البيانات موثوقة وتحافظ على سلامة البيانات حتى في حالة تعطل التطبيق. [7]
    *   **العمليات غير المتزامنة في Isolates:** جميع عمليات القراءة والكتابة تتم بشكل غير متزامن في `Isolates` منفصلة. هذا يضمن أن مؤشر الترابط الرئيسي (Main Thread) لواجهة المستخدم لا يتم حظره أبداً، مما يوفر تجربة مستخدم سلسة للغاية.
    *   **الفهرسة (Indexing):** تدعم الفهرسة على الخصائص (Properties) لتحسين أداء الاستعلامات بشكل كبير.
    *   **البحث النصي الكامل (Full-text Search - FTS):** توفر `isar` دعماً مدمجاً للبحث النصي الكامل، مما يسمح بالبحث الفعال عن الكلمات داخل حقول النص.
*   **الأداء (Performance Characteristics):**
    *   **أداء مذهل:** تتفوق `isar` على معظم قواعد البيانات المحلية الأخرى في Flutter من حيث السرعة، خاصة في عمليات القراءة والكتابة والاستعلامات المعقدة على مجموعات بيانات كبيرة. [8]
    *   **تحسين الذاكرة:** على عكس Hive التي تحمل الصناديق بالكامل في الذاكرة، تتعامل `isar` مع البيانات بكفاءة أكبر، مما يجعلها مناسبة لمجموعات البيانات الأكبر حجماً.
*   **الأمان (Security Considerations):**
    *   **التشفير:** تدعم `isar` تشفير قاعدة البيانات بالكامل باستخدام مفتاح تشفير AES 256 بت. يتم توفير المفتاح عند فتح قاعدة البيانات، ويتم التعامل مع التشفير وفك التشفير بشفافية.
*   **التحديات التقنية الشائعة:**
    *   **التعقيد النسبي:** على الرغم من سهولة استخدامها، إلا أنها أكثر تعقيداً قليلاً من Hive أو `shared_preferences` بسبب قدراتها المتقدمة.
    *   **مولد الكود:** تعتمد بشكل كبير على مولد الكود (Code Generator) لإنشاء مخططات قاعدة البيانات (Schema) والـ `IsarCollection`، مما يتطلب تشغيل أمر البناء (Build Runner) بانتظام.
*   **حالات الاستخدام المثلى:**
    *   تطبيقات وضع عدم الاتصال التي تتطلب تخزيناً قوياً للبيانات، استعلامات معقدة، وعلاقات بين الكائنات.
    *   تطبيقات إدارة المهام، تطبيقات الملاحظات، تطبيقات التجارة الإلكترونية التي تحتاج إلى تخزين كتالوجات المنتجات محلياً.
    *   أي تطبيق يتطلب أداءً عالياً جداً مع مجموعات بيانات كبيرة ومعقدة.

#### العمليات البرمجية المتقدمة (CRUD & Watchers)
```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// ملاحظة: يجب توليد TaskSchema باستخدام build_runner
// flutter packages pub run build_runner build

@collection
class Task {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  bool isCompleted = false;
}

class IsarService {
  late Isar isar;

  Future<void> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [TaskSchema],
      directory: dir.path,
    );
  }

  // 1. إضافة (Create)
  Future<void> addTask(String title) async {
    final newTask = Task()..title = title;
    await isar.writeTxn(() async {
      await isar.tasks.put(newTask);
    });
  }

  // 2. استعلام متقدم (Query)
  Future<List<Task>> searchTasks(String query) async {
    return await isar.tasks
        .filter()
        .titleContains(query, caseSensitive: false)
        .findAll();
  }

  // 3. مراقبة التغييرات (Watcher)
  Stream<List<Task>> watchTasks() {
    return isar.tasks.where().watch(fireImmediately: true);
  }

  // 4. حذف (Delete)
  Future<void> deleteTask(int id) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
  }
}
```

---

## 3. قواعد البيانات العلائقية (SQL Databases)

تُعد قواعد البيانات العلائقية الخيار الأمثل عندما تكون البيانات مهيكلة بشكل صارم، وتتطلب علاقات معقدة بين الجداول، واستعلامات SQL قوية، وضمانات سلامة البيانات (Data Integrity).

### أ. `sqflite` (التحكم المباشر في SQLite)

`sqflite` هي مكتبة Flutter الأكثر شيوعاً للتعامل مع قاعدة بيانات **SQLite**، وهي قاعدة بيانات علائقية خفيفة الوزن ومدمجة (Embedded) تعمل محلياً على الجهاز.

#### الشرح التقني والمعماري
*   **المعمارية الداخلية (Internal Architecture):**
    *   **SQLite Engine:** `sqflite` هي مجرد واجهة (Wrapper) حول محرك SQLite الأصلي الموجود في Android و iOS. تتواصل مع هذا المحرك عبر `Method Channels`.
    *   **مخطط قاعدة البيانات (Database Schema):** يجب على المطور تعريف مخطط قاعدة البيانات (الجداول، الأعمدة، المفاتيح الأساسية/الخارجية) يدوياً باستخدام أوامر SQL `CREATE TABLE`.
*   **نموذج البيانات (Data Model):** يعتمد على الجداول (Tables)، الصفوف (Rows)، والأعمدة (Columns)، مع دعم للعلاقات العلائقية (Relational Relationships) مثل المفاتيح الأساسية (Primary Keys) والمفاتيح الخارجية (Foreign Keys).
*   **الأداء (Performance Characteristics):**
    *   **متوسط:** أداء `sqflite` جيد بشكل عام، ولكنه ليس بنفس سرعة قواعد بيانات NoSQL المحسّنة مثل Hive أو Isar في عمليات القراءة والكتابة البسيطة. يعود ذلك إلى تكلفة التواصل عبر `Method Channels`، وتحليل استعلامات SQL، وعمليات القرص التقليدية.
    *   **تحسين الأداء:** يمكن تحسين الأداء بشكل كبير باستخدام الفهارس (Indexes) على الأعمدة المستخدمة في الاستعلامات، واستخدام المعاملات (Transactions) لتجميع عمليات الكتابة المتعددة في عملية قرص واحدة.
*   **الأمان (Security Considerations):**
    *   **التشفير:** لا توفر `sqflite` تشفيراً مدمجاً لقاعدة البيانات. لتشفير قاعدة بيانات SQLite، يجب استخدام مكتبات إضافية مثل `sqflite_sqlcipher`، والتي توفر تشفيراً قوياً باستخدام SQLCipher.
*   **التحديات التقنية الشائعة:**
    *   **كتابة SQL يدوياً:** تتطلب كتابة استعلامات SQL يدوياً، مما قد يكون عرضة للأخطاء (SQL Injection إذا لم يتم التعامل مع المدخلات بشكل صحيح) ويقلل من الأمان النوعي (Type Safety).
    *   **التعامل مع التغييرات في المخطط (Schema Migrations):** إدارة تحديثات مخطط قاعدة البيانات (إضافة أعمدة، تغيير أنواع البيانات) تتطلب كتابة كود `migration` يدوي، وهو أمر معقد وعرضة للأخطاء.
*   **حالات الاستخدام المثلى:**
    *   تطبيقات تتطلب علاقات بيانات معقدة واستعلامات SQL قوية.
    *   تطبيقات تتطلب ضمانات ACID صارمة.
    *   عندما يكون المطورون على دراية بـ SQL ويفضلون التحكم الكامل في قاعدة البيانات.

#### العمليات البرمجية (CRUD)
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Todo {
  final int? id;
  final String title;
  final bool isDone;

  Todo({this.id, required this.title, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
    );
  }
}

class SqliteService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)',
        );
      },
    );
  }

  // 1. إضافة (Create)
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 2. قراءة (Read)
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // 3. تحديث (Update)
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // 4. حذف (Delete)
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### ب. `drift` (Reactive SQL مع Type Safety)

`drift` (المعروفة سابقاً باسم Moor) هي مكتبة ORM (Object-Relational Mapper) قوية لـ Flutter، مبنية فوق `sqflite`. إنها تحول SQLite إلى قاعدة بيانات تفاعلية (Reactive) وآمنة من حيث النوع (Type-safe)، مما يقلل بشكل كبير من الكود المتكرر (Boilerplate Code) ويحسن تجربة المطور.

#### الشرح التقني والمعماري
*   **المعمارية الداخلية (Internal Architecture):**
    *   **Code Generation:** تعتمد `drift` بشكل كبير على مولد الكود. يكتب المطور تعريفات الجداول والاستعلامات بلغة Dart أو SQL، ويقوم مولد الكود بإنشاء كود Dart آمن من حيث النوع للتفاعل مع قاعدة البيانات.
    *   **Reactive Streams:** توفر `drift` دعماً أصيلاً لـ `Streams`، مما يسمح بمراقبة التغييرات في قاعدة البيانات وتحديث واجهة المستخدم تلقائياً.
*   **نموذج البيانات (Data Model):** تعتمد على الكائنات (Objects) التي تمثل الصفوف في الجداول، مع دعم قوي للعلاقات بين الكائنات.
*   **الأداء (Performance Characteristics):**
    *   **جيد جداً:** أداء `drift` ممتاز، خاصة في الاستعلامات المعقدة. على الرغم من أنها تستخدم SQLite في الخلفية، إلا أن تحسينات مولد الكود والتعامل مع `Streams` يقلل من التكلفة العامة.
    *   **تحسينات مدمجة:** تتضمن تحسينات مثل تجميع الاستعلامات (Batching) والمعاملات التلقائية (Automatic Transactions) لتحسين الأداء.
*   **الأمان (Security Considerations):**
    *   **Type Safety:** تقلل بشكل كبير من أخطاء SQL Injection وأخطاء أنواع البيانات لأن الاستعلامات يتم التحقق منها أثناء وقت البرمجة.
    *   **التشفير:** يمكن دمجها مع `sqflite_sqlcipher` لتوفير تشفير قاعدة البيانات.
*   **التحديات التقنية الشائعة:**
    *   **منحنى التعلم:** قد يكون لها منحنى تعلم أعلى قليلاً مقارنة بـ `sqflite` المباشرة بسبب مفهوم مولد الكود والواجهة التفاعلية.
    *   **حجم الكود:** مولد الكود قد ينتج كمية كبيرة من الكود، ولكن هذا الكود لا يتم تضمينه في حجم التطبيق النهائي (Binary Size) إذا تم تكوينه بشكل صحيح.
*   **حالات الاستخدام المثلى:**
    *   تطبيقات Flutter التي تتطلب قاعدة بيانات علائقية قوية مع واجهة برمجية حديثة وتفاعلية.
    *   المشاريع الكبيرة التي تستفيد من Type Safety وتقليل الكود المتكرر.
    *   تطبيقات تتطلب تحديثات واجهة المستخدم في الوقت الفعلي بناءً على تغييرات البيانات.

#### العمليات البرمجية المتقدمة (CRUD, Relations, Streams)
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

// ملاحظة: يجب توليد _$MyDatabase باستخدام build_runner
// flutter packages pub run build_runner build

// 1. تعريف الجداول (Tables)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  RealColumn get price => real()();
  IntColumn get categoryId => integer().references(Categories, #id)();
}

// 2. قاعدة البيانات (Database)
@DriftDatabase(tables: [Categories, Products])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // لإدارة الهجرة (Migrations)

  // 3. إضافة (Create)
  Future<int> addCategory(CategoriesCompanion entry) {
    return into(categories).insert(entry);
  }

  Future<int> addProduct(ProductsCompanion entry) {
    return into(products).insert(entry);
  }

  // 4. استعلام مع علاقات (Read with Join)
  Stream<List<ProductWithCategory>> watchAllProducts() {
    final query = select(products).join([
      innerJoin(categories, categories.id.equalsExp(products.categoryId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ProductWithCategory(
          product: row.readTable(products),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

  // 5. تحديث (Update)
  Future<bool> updateProduct(Product product) {
    return update(products).replace(product);
  }

  // 6. حذف (Delete)
  Future<int> deleteProduct(int id) {
    return (delete(products)..where((t) => t.id.equals(id))).go();
  }
}

// فئة مساعدة للبيانات المشتركة
class ProductWithCategory {
  final Product product;
  final Category category;
  ProductWithCategory({required this.product, required this.category});
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
```

---

## 4. إدارة نظام الملفات: `path_provider`

`path_provider` ليست مكتبة لتخزين البيانات بحد ذاتها، بل هي أداة مساعدة حيوية لتحديد المسارات الآمنة والمناسبة لتخزين الملفات على نظام التشغيل. إنها تعمل كواجهة موحدة للوصول إلى مجلدات النظام القياسية عبر المنصات المختلفة.

#### الشرح التقني والمعماري
*   **المعمارية الداخلية (Internal Architecture):**
    *   **Method Channels:** تستخدم `Method Channels` للتواصل مع واجهات برمجة التطبيقات الأصلية لكل منصة للحصول على مسارات المجلدات الخاصة.
    *   **التوافقية عبر المنصات:** توفر أسماء مجلدات منطقية (مثل `getApplicationDocumentsDirectory()`) وتترجمها إلى المسارات الفعلية الخاصة بكل نظام تشغيل (مثلاً، `/data/user/0/<package_name>/app_documents` في Android، و `/Users/<username>/Library/Application Support/<bundle_id>` في macOS).
*   **الأداء (Performance Characteristics):**
    *   عملياتها سريعة جداً وغير مكلفة، حيث أنها مجرد استدعاءات لنظام التشغيل للحصول على مسار. جميع الدوال غير متزامنة (Asynchronous) وتُرجع `Future<Directory>`.
*   **الأمان (Security Considerations):**
    *   **Sandbox Compliance:** تضمن أن التطبيق يعمل ضمن بيئة `Sandbox` الخاصة به، مما يمنع الوصول غير المصرح به إلى مجلدات النظام الأخرى ويحمي بيانات التطبيق من التطبيقات الأخرى.
    *   **الخصوصية:** تساعد في تحديد المجلدات المناسبة لتخزين البيانات الحساسة (مثل `getApplicationSupportDirectory()`) التي لا يمكن للمستخدم الوصول إليها بسهولة عبر متصفح الملفات العادي.
*   **حالات الاستخدام المثلى:**
    *   حفظ الملفات التي تم إنشاؤها بواسطة المستخدم (مثل الصور، المستندات، ملفات الصوت) باستخدام `dart:io`.
    *   تخزين ملفات قاعدة البيانات (مثل ملفات SQLite أو Isar).
    *   حفظ ملفات السجل (Log files) أو ملفات التكوين (Configuration files) الكبيرة.

#### العمليات البرمجية (File Operations)
```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  // 1. الحصول على مسار مجلد المستندات
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // 2. إنشاء مرجع للملف
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data_log.txt');
  }

  // 3. كتابة ملف (Write)
  Future<File> writeData(String data) async {
    final file = await _localFile;
    return file.writeAsString(data, mode: FileMode.append);
  }

  // 4. قراءة ملف (Read)
  Future<String> readData() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return 'خطأ في القراءة: $e';
    }
  }

  // 5. حذف ملف (Delete)
  Future<void> deleteFile() async {
    final file = await _localFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
```

---

## 5. مقارنة الأداء والقدرات التقنية المتقدمة (Advanced Performance & Technical Comparison)

| المعيار \ المكتبة | `shared_preferences` | `flutter_secure_storage` | `hive` | `isar` | `sqflite` / `drift` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **النوع** | Key-Value | Key-Value | NoSQL (Object) | NoSQL (Object) | SQL (Relational) |
| **المعمارية** | Wrapper حول Native APIs | Wrapper حول Native Secure APIs | Pure Dart, Binary Format | Pure Dart, Binary Format, ACID | Wrapper حول SQLite Native |
| **التشفير المدمج** | ❌ لا يوجد | ✅ نعم (Native) | ✅ نعم (AES 256) | ✅ نعم (AES 256) | ❌ لا يوجد (يتطلب `sqlcipher`) |
| **الأداء (قراءة)** | ⚡ فائقة (من الذاكرة) | 🐢 بطيئة (تشفير/فك تشفير) | ⚡ فائقة (من الذاكرة) | 🚀 مذهلة (Isolates) | ⚖️ متوسطة (SQL Parsing) |
| **الأداء (كتابة)** | ⚡ فائقة (غير متزامن) | 🐢 بطيئة (تشفير/فك تشفير) | ⚡ فائقة | 🚀 مذهلة (Isolates) | ⚖️ متوسطة (SQL Transactions) |
| **التعامل مع البيانات الضخمة** | ❌ غير مناسب | ❌ غير مناسب | ⚠️ قد يسبب OOM | ✅ ممتاز | ✅ ممتاز |
| **الاستعلامات المعقدة** | ❌ لا يوجد | ❌ لا يوجد | ❌ يدوية | ✅ قوية (Query Builder, FTS) | ✅ قوية (SQL) |
| **العلاقات بين الكائنات** | ❌ لا يوجد | ❌ لا يوجد | ❌ يدوية | ✅ مدمجة | ✅ مدمجة (عبر Foreign Keys) |
| **Type Safety** | ❌ لا يوجد | ❌ لا يوجد | ✅ عبر TypeAdapters | ✅ عبر Code Generation | ✅ عبر Code Generation (Drift) |
| **Reactive Programming** | ❌ لا يوجد | ❌ لا يوجد | ❌ لا يوجد | ✅ مدمج (Streams) | ✅ مدمج (Drift Streams) |
| **Concurrency (تعدد الخيوط)** | ❌ Main Thread | ❌ Main Thread | ❌ Main Thread | ✅ Isolates (تلقائي) | ✅ Isolates (يدوي/Drift) |
| **منحنى التعلم** | سهل جداً | سهل جداً | متوسط | متوسط | متوسط/عالي |

---

## 6. خارطة طريق الاختيار الهندسي (Advanced Decision Matrix)

عند اختيار مكتبة التخزين، يجب على المهندس المعماري (Architect) أو المطور أن يأخذ في الاعتبار المتطلبات الوظيفية وغير الوظيفية (Functional and Non-functional Requirements) للتطبيق:

1.  **حجم البيانات ونوعها:**
    *   **بيانات صغيرة، غير حساسة، إعدادات:** `shared_preferences` هي الخيار الأسرع والأبسط.
    *   **بيانات صغيرة، حساسة جداً (Tokens, Keys):** `flutter_secure_storage` هي الحل الوحيد الآمن.
    *   **بيانات متوسطة إلى كبيرة، كائنات معقدة، لا تتطلب علاقات SQL صارمة:** `isar` هي الخيار الأفضل للأداء والمرونة. `hive` بديل جيد للمشاريع الأبسط أو عندما يكون حجم البيانات أقل.
    *   **بيانات ضخمة، علاقات معقدة، استعلامات SQL قوية، ضمانات ACID:** `drift` (مع SQLite) هي الخيار المفضل، حيث توفر Type Safety و Reactive Programming فوق قوة SQLite.

2.  **متطلبات الأمان:**
    *   إذا كانت البيانات تتطلب تشفيراً على مستوى النظام، فإن `flutter_secure_storage` لا غنى عنها.
    *   لتشفير قواعد البيانات، توفر `hive` و `isar` تشفيراً مدمجاً، بينما تتطلب `sqflite`/`drift` استخدام `sqlcipher`.

3.  **الأداء وتجربة المستخدم:**
    *   للتطبيقات التي تتطلب واجهة مستخدم سلسة جداً وغير محظورة، فإن `isar` و `drift` هما الأفضل لأنهما تدعمان العمليات في `Isolates`.
    *   تجنب العمليات الثقيلة على مؤشر الترابط الرئيسي (Main Thread) قدر الإمكان، خاصة مع `shared_preferences` و `flutter_secure_storage`.

4.  **تعقيد الاستعلامات والعلاقات:**
    *   إذا كانت هناك حاجة لاستعلامات معقدة، تجميع (Aggregation)، أو علاقات متعددة بين الكائنات، فإن `isar` أو `drift` هما الخياران الأقوى.

5.  **منحنى التعلم وتجربة المطور:**
    *   `shared_preferences` و `flutter_secure_storage` سهلة الاستخدام للغاية.
    *   `hive` و `isar` توفران توازناً جيداً بين القوة وسهولة الاستخدام، مع منحنى تعلم متوسط.
    *   `sqflite` تتطلب معرفة بـ SQL، بينما `drift` تبسط التعامل مع SQL ولكنها تتطلب فهماً لمفاهيم ORM ومولد الكود.

---

## 7. استراتيجيات التخزين المتقدمة (Advanced Storage Strategies)

في التطبيقات الكبيرة والمعقدة، غالباً ما يتم استخدام مزيج من هذه المكتبات لتحقيق أفضل النتائج:

*   **نموذج التخزين متعدد الطبقات (Multi-layered Storage Model):**
    *   **الطبقة الأولى (Secure Layer):** `flutter_secure_storage` للبيانات الحساسة جداً (مثل مفاتيح API، رموز المصادقة).
    *   **الطبقة الثانية (Settings Layer):** `shared_preferences` للإعدادات العامة غير الحساسة (مثل تفضيلات واجهة المستخدم).
    *   **الطبقة الثالثة (Data Layer):** `isar` أو `drift` للبيانات الرئيسية للتطبيق (مثل بيانات المستخدم، المنتجات، الملاحظات). يتم هنا تخزين البيانات المهيكلة التي تتطلب استعلامات وعلاقات.
    *   **الطبقة الرابعة (File Layer):** `path_provider` مع `dart:io` لتخزين الملفات الكبيرة (مثل الصور، الفيديوهات، المستندات) التي لا تتناسب مع قواعد البيانات.

*   **فصل الاهتمامات (Separation of Concerns):**
    *   دائماً قم بتجريد (Abstract) طبقة التخزين خلف واجهات (Interfaces) أو مستودعات (Repositories). هذا يسمح لك بتغيير حل التخزين الأساسي دون التأثير على بقية أجزاء التطبيق. على سبيل المثال:

    ```dart
    abstract class AuthRepository {
      Future<void> saveAuthToken(String token);
      Future<String?> getAuthToken();
      Future<void> deleteAuthToken();
    }

    class AuthRepositoryImpl implements AuthRepository {
      final FlutterSecureStorage _secureStorage;

      AuthRepositoryImpl(this._secureStorage);

      @override
      Future<void> saveAuthToken(String token) => _secureStorage.write(key: 'auth_token', value: token);

      @override
      Future<String?> getAuthToken() => _secureStorage.read(key: 'auth_token');

      @override
      Future<void> deleteAuthToken() => _secureStorage.delete(key: 'auth_token');
    }
    ```

*   **معالجة الهجرة (Migration Handling):**
    *   عندما يتطور التطبيق، قد يتغير مخطط البيانات (Schema). يجب أن تكون المكتبة المختارة قادرة على التعامل مع الهجرة (Migrations) بشكل فعال. `drift` و `isar` توفران آليات قوية للهجرة، بينما تتطلب `sqflite` إدارة يدوية أكثر.

---

## 8. مثال شامل: دمج جميع المكتبات في مشروع واحد

تخيل تطبيقاً لإدارة المهام (Task Manager) يستخدم جميع تقنيات التخزين معاً:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // لعمليات الملفات مع path_provider

// ملاحظة: يجب توليد TaskSchema باستخدام build_runner لـ Isar
// flutter packages pub run build_runner build

@collection
class Task {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  bool isCompleted = false;
}

class AppStorageCoordinator {
  final _secureStorage = const FlutterSecureStorage();
  late Isar _isar;
  late SharedPreferences _prefs;

  // 1. التهيئة الشاملة عند بدء التطبيق
  Future<void> initAll() async {
    // تهيئة Shared Preferences للإعدادات
    _prefs = await SharedPreferences.getInstance();

    // تهيئة Isar للبيانات الضخمة
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([TaskSchema], directory: dir.path);
  }

  // 2. تسجيل الدخول (استخدام Secure Storage و Shared Prefs)
  Future<void> login(String token, String username) async {
    // حفظ الـ Token بشكل آمن
    await _secureStorage.write(key: 'auth_token', value: token);
    
    // حفظ اسم المستخدم للإعدادات البسيطة
    await _prefs.setString('current_user', username);
    await _prefs.setBool('is_logged_in', true);
  }

  // 3. إدارة المهام (استخدام Isar)
  Future<void> saveTask(String title) async {
    final newTask = Task()..title = title;
    await _isar.writeTxn(() async {
      await _isar.tasks.put(newTask);
    });
  }

  // 4. تصدير البيانات كملف (استخدام Path Provider و dart:io)
  Future<void> exportData() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/export.json');
    
    final tasks = await _isar.tasks.where().findAll();
    // تحويل المهام لـ JSON وكتابتها للملف (مثال مبسط)
    // في تطبيق حقيقي، ستحتاج إلى تحويل كائنات Isar إلى JSON بشكل صحيح
    await file.writeAsString(tasks.map((e) => e.title).toList().toString()); // مثال بسيط للتصدير
    print('تم تصدير البيانات إلى: ${file.path}');
  }

  // 5. تسجيل الخروج (مسح البيانات الحساسة)
  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _prefs.setBool('is_logged_in', false);
    // ملاحظة: لا نمسح قاعدة بيانات Isar إلا إذا طلب المستخدم ذلك
  }
}
```

---

## 9. الخلاصة والتوصيات النهائية

*   **`shared_preferences`**: للإعدادات البسيطة وغير الحساسة. سريعة جداً للقراءة.
*   **`flutter_secure_storage`**: للبيانات الحساسة جداً مثل رموز المصادقة ومفاتيح API. تستخدم التخزين الآمن الأصلي للمنصة.
*   **`hive`**: قاعدة بيانات NoSQL سريعة جداً ومناسبة للتخزين المؤقت للبيانات أو الكائنات التي لا تتطلب استعلامات معقدة.
*   **`isar`**: الجيل الجديد من قواعد بيانات NoSQL. توفر أداءً مذهلاً، دعم للعلاقات، استعلامات قوية، وتعمل في `Isolates`، مما يجعلها مثالية للبيانات الضخمة والتطبيقات المعقدة.
*   **`sqflite` / `drift`**: لقواعد البيانات العلائقية. `sqflite` تمنحك تحكماً مباشراً بـ SQL، بينما `drift` توفر واجهة Type-safe وتفاعلية مع مولد الكود، وهي الخيار المفضل للمشاريع الكبيرة التي تتطلب علاقات معقدة وهجرة بيانات منظمة.
*   **`path_provider`**: أداة أساسية لتحديد المسارات الآمنة والمناسبة لتخزين الملفات الكبيرة (صور، فيديوهات، مستندات) باستخدام `dart:io`.

**التوصية النهائية:** في معظم التطبيقات الحديثة، ستجد نفسك تستخدم مزيجاً من هذه المكتبات. على سبيل المثال، `flutter_secure_storage` للرموز، `shared_preferences` للإعدادات، و `isar` أو `drift` للبيانات الرئيسية للتطبيق، و `path_provider` لإدارة الملفات الكبيرة.

---

## المراجع (References)

[1] [Android Developers - SharedPreferences](https://developer.android.com/reference/android/content/SharedPreferences)
[2] [Apple Developer Documentation - UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults)
[3] [Apple Developer Documentation - Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
[4] [Android Developers - Android Keystore System](https://developer.android.com/training/articles/keystore)
[5] [Hive - Fast NoSQL database for Flutter and Dart](https://docs.hivedb.dev/)
[6] [Isar Database - The new generation of local databases for Flutter](https://isar.dev/)
[7] [Isar Database - ACID Compliance](https://isar.dev/docs/introduction.html#acid-compliance)
[8] [Isar Database - Benchmarks](https://isar.dev/docs/benchmarks.html)

*تم إعداد هذه الموسوعة الشاملة بواسطة **Manus AI** لتقديم مرجع متكامل ومفصل لمطوري Flutter المحترفين والمهندسين المعماريين لعام 2026، مع التركيز على التفاصيل التقنية العميقة، الأمثلة البرمجية المكثفة، وأفضل الممارسات الهندسية.*
