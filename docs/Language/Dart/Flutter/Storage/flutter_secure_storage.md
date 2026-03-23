# الدليل الشامل لمكتبة `flutter_secure_storage` في Flutter

تُعد مكتبة `flutter_secure_storage` الخيار الأمثل لتخزين البيانات الحساسة (مثل رموز المصادقة Tokens، كلمات المرور، ومعلومات المستخدم) بشكل آمن في تطبيقات Flutter. تعتمد المكتبة على تقنيات التشفير الأصلية لكل نظام تشغيل لضمان أقصى درجات الحماية.

---

## 1. لماذا نستخدم `flutter_secure_storage`؟

على عكس `shared_preferences` التي تخزن البيانات في ملفات نصية بسيطة يمكن الوصول إليها بسهولة على الأجهزة التي تمتلك صلاحيات Root أو Jailbreak، تقوم هذه المكتبة بتشفير البيانات قبل تخزينها:
- **في iOS:** تستخدم **Keychain**.
- **في Android:** تستخدم **EncryptedSharedPreferences** (مع مكتبة Tink من Google).
- **في الويب:** تستخدم **Web Cryptography API**.

---

## 2. التثبيت والإعداد

أضف المكتبة إلى ملف `pubspec.yaml`:

```yaml
dependencies:
  flutter_secure_storage: ^9.2.2 # تأكد من استخدام أحدث إصدار
```

### إعدادات الأندرويد (Android)
في ملف `android/app/build.gradle` تأكد من أن `minSdkVersion` هي **18** على الأقل (أو **21** لاستخدام EncryptedSharedPreferences بشكل أفضل).

---

## 3. العمليات الأساسية (CRUD)

إليك كيفية تنفيذ العمليات الأساسية باستخدام المكتبة:

### إنشاء كائن التخزين
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// إنشاء نسخة من المكتبة
final storage = const FlutterSecureStorage();
```

### كتابة البيانات (Write)
```dart
await storage.write(key: 'auth_token', value: 'your_secure_token_here');
```

### قراءة البيانات (Read)
```dart
String? value = await storage.read(key: 'auth_token');
print(value); // سيطبع التوكن أو null إذا لم يكن موجوداً
```

### حذف قيمة معينة (Delete)
```dart
await storage.delete(key: 'auth_token');
```

### حذف جميع البيانات (Delete All)
```dart
await storage.deleteAll();
```

---

## 4. أمثلة تطبيقية متعددة

### المثال الأول: تخزين وقراءة كائن (JSON Object)
بما أن المكتبة تخزن النصوص فقط، يجب تحويل الكائنات إلى JSON:

```dart
import 'dart:convert';

Future<void> saveUser(Map<String, dynamic> userData) async {
  String jsonString = jsonEncode(userData);
  await storage.write(key: 'user_data', value: jsonString);
}

Future<Map<String, dynamic>?> getUser() async {
  String? jsonString = await storage.read(key: 'user_data');
  if (jsonString != null) {
    return jsonDecode(jsonString);
  }
  return null;
}
```

### المثال الثاني: قراءة جميع القيم المخزنة
```dart
Map<String, String> allValues = await storage.readAll();
allValues.forEach((key, value) {
  print('المفتاح: $key، القيمة: $value');
});
```

---

## 5. خيارات المنصات (Platform Options)

توفر المكتبة خيارات مخصصة لكل منصة لزيادة الأمان أو التحكم في سلوك التخزين.

### خيارات الأندرويد (`AndroidOptions`)
تسمح لك بتفعيل `EncryptedSharedPreferences` وهو الخيار الأكثر أماناً.

```dart
AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
      // خيارات إضافية مثل resetOnError لتجنب تعطل التطبيق عند فشل فك التشفير
      resetOnError: true,
    );
```

### خيارات الآيفون (`IOSOptions`)
تتحكم في متى يمكن الوصول إلى البيانات (مثلاً: فقط عندما يكون الجهاز مفتوحاً).

```dart
IOSOptions _getIOSOptions() => const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      // السماح بمزامنة البيانات مع iCloud (اختياري)
      synchronizable: true,
    );
```

---

## 6. مثال متكامل: استخدام المكتبة داخل Class

يُفضل دائماً تغليف المكتبة داخل كلاس (Service) لإدارة البيانات بشكل مركزي ومنظم.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // إنشاء نسخة خاصة مع إعدادات افتراضية لكل منصة
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // حفظ التوكن
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // جلب التوكن
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // حذف التوكن عند تسجيل الخروج
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  // التحقق من وجود بيانات
  Future<bool> hasToken() async {
    String? token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
```

---

## 7. شرح خصائص المكتبة (Properties)

فيما يلي جدول يوضح أهم الخصائص المتاحة في خيارات الإعداد:

| الخاصية | المنصة | الشرح |
| :--- | :--- | :--- |
| `encryptedSharedPreferences` | Android | عند تفعيلها (true)، يتم استخدام تشفير AES-256 المتقدم. |
| `resetOnError` | Android | إذا حدث خطأ في فك التشفير (مثلاً عند تغيير مفاتيح النظام)، يتم مسح البيانات بدلاً من تعطل التطبيق. |
| `accessibility` | iOS | تحدد مستوى الأمان (مثل `first_unlock` أو `when_unlocked`). |
| `synchronizable` | iOS | إذا كانت true، سيتم مزامنة البيانات مع iCloud Keychain للمستخدم. |
| `groupId` | iOS | تُستخدم لمشاركة البيانات بين التطبيق والـ Extensions الخاصة به. |
| `accountName` | iOS | اسم الحساب المرتبط ببيانات Keychain. |
| `dbName` | Web | اسم قاعدة البيانات المستخدمة في المتصفح (IndexedDB). |
| `publicKey` | Web | المفتاح العام المستخدم في تشفير الويب. |

---

### ملاحظات هامة:
1. **النسخ الاحتياطي (Android):** قد تواجه مشاكل عند استعادة التطبيق من نسخة احتياطية (Auto Backup) لأن مفاتيح التشفير تتغير. يُنصح بتعطيل النسخ الاحتياطي لبيانات التخزين الآمن في ملف `AndroidManifest.xml`.
2. **الأداء:** عمليات التشفير وفك التشفير تأخذ وقتاً أطول قليلاً من التخزين العادي، لذا لا تستخدمها لتخزين كميات ضخمة من البيانات غير الحساسة.