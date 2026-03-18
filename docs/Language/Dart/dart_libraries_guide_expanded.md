# دليل مكتبات Dart: شرح موسع لمكتبتي `dart:io` و `dart:convert`

تعتبر لغة **Dart** بيئة تطوير قوية ومرنة، وتستمد جزءاً كبيراً من قوتها من مكتباتها الأساسية (Core Libraries) التي توفر وظائف حيوية للتعامل مع مختلف جوانب التطوير. في هذا الدليل الموسع، سنتعمق في شرح اثنتين من أهم هذه المكتبات: مكتبة **الإدخال والإخراج** (Input and Output - `dart:io`) ومكتبة **التحويل** (Conversion - `dart:convert`)، مع التركيز على حالات الاستخدام المتقدمة وأفضل الممارسات.

---

## أولاً: مكتبة `dart:io` - التفاعل مع نظام التشغيل

توفر مكتبة `dart:io` مجموعة شاملة من واجهات برمجة التطبيقات (APIs) التي تسمح لتطبيقات Dart بالتفاعل مع نظام التشغيل (Operating System) بشكل مباشر. تشمل هذه التفاعلات التعامل مع الملفات (Files)، الأدلة (Directories)، العمليات (Processes)، المقابس (Sockets)، وبروتوكولات HTTP. هذه المكتبة ضرورية لتطوير تطبيقات الخادم (Server-side applications)، تطبيقات سطر الأوامر (Command-line Interface - CLI)، وتطبيقات Flutter على أنظمة التشغيل المختلفة (سطح المكتب والهواتف المحمولة).

> **ملاحظة هامة:** لا يمكن استخدام مكتبة `dart:io` في تطبيقات الويب التي تعمل في المتصفح (Browser-based web applications) لأنها تتطلب الوصول المباشر إلى نظام التشغيل، وهو ما لا تسمح به بيئة المتصفح لأسباب أمنية. لتطبيقات الويب، يتم استخدام واجهات برمجة التطبيقات الخاصة بالمتصفح (Browser APIs) أو مكتبات مثل `dart:html`.

### 1. إدارة الملفات والأدلة (File and Directory Management)

تعتبر إدارة الملفات والأدلة من الوظائف الأساسية التي توفرها `dart:io`. يمكن للتطبيقات قراءة وكتابة الملفات، إنشاء وحذف الأدلة، وسرد محتوياتها. تتميز معظم عمليات `dart:io` بأنها غير متزامنة (Asynchronous)، مما يضمن عدم حظر واجهة المستخدم (User Interface - UI) أو الخادم أثناء عمليات الإدخال/الإخراج (I/O operations) التي قد تستغرق وقتاً طويلاً.

#### أ. قراءة الملفات (Reading Files)

يمكن قراءة الملفات بطريقتين رئيسيتين:

1.  **القراءة الكاملة دفعة واحدة (Read All at Once):** مناسبة للملفات الصغيرة حيث يتم تحميل المحتوى بأكمله في الذاكرة. توفر هذه الطريقة سهولة في التعامل ولكنها قد تستهلك الكثير من الذاكرة للملفات الكبيرة.
    *   `readAsString()`: لقراءة الملف كنص (String). يمكن تحديد ترميز (Encoding) معين، والافتراضي هو UTF-8.
    *   `readAsBytes()`: لقراءة الملف كسلسلة من البايتات (List<int>).
    *   `readAsLines()`: لقراءة الملف كقائمة من الأسطر النصية (List<String>).

    ```dart
    import 'dart:io';
    import 'dart:convert'; // لاستخدام utf8.decoder

    void main() async {
      final file = File('data.txt');

      // التحقق مما إذا كان الملف موجودًا قبل القراءة
      if (await file.exists()) {
        try {
          // قراءة الملف كنص
          String content = await file.readAsString(encoding: utf8);
          print('محتوى الملف النصي:\n$content');

          // قراءة الملف كقائمة من الأسطر
          List<String> lines = await file.readAsLines();
          print('\nعدد الأسطر: ${lines.length}');
          lines.forEach((line) => print('السطر: $line'));

          // قراءة الملف كبايتات
          List<int> bytes = await file.readAsBytes();
          print('\nحجم الملف بالبايت: ${bytes.length}');
        } on FileSystemException catch (e) {
          print('خطأ في نظام الملفات: ${e.message}');
        } catch (e) {
          print('حدث خطأ غير متوقع: $e');
        }
      } else {
        print('الملف data.txt غير موجود.');
      }
    }
    ```

2.  **القراءة عبر التدفق (Streaming):** الطريقة المفضلة للملفات الكبيرة أو عند الحاجة لمعالجة البيانات أثناء قراءتها. يتم قراءة أجزاء صغيرة من الملف بشكل مستمر، مما يقلل من استهلاك الذاكرة.
    *   `openRead()`: تُرجع كائن `Stream<List<int>>` يمثل تدفق البايتات من الملف.

    ```dart
    import 'dart:io';
    import 'dart:convert';

    void main() async {
      final file = File('large_data.txt');
      if (!await file.exists()) {
        // إنشاء ملف كبير للاختبار
        await file.writeAsString(List.generate(10000, (i) => 'This is line $i.').join('\n'));
      }

      try {
        Stream<List<int>> inputStream = file.openRead();

        // تحويل تدفق البايتات إلى تدفق نصوص باستخدام utf8.decoder و LineSplitter
        var lines = inputStream
            .transform(utf8.decoder) // تحويل البايتات إلى نصوص UTF-8
            .transform(const LineSplitter()); // تقسيم النصوص إلى أسطر

        int lineCount = 0;
        await for (var line in lines) {
          lineCount++;
          // معالجة كل سطر على حدة
          if (lineCount <= 5) { // طباعة أول 5 أسطر فقط للمثال
            print('السطر $lineCount: $line');
          }
        }
        print('\nتم قراءة $lineCount سطرًا من الملف.');
      } on FileSystemException catch (e) {
        print('خطأ في نظام الملفات: ${e.message}');
      } catch (e) {
        print('حدث خطأ غير متوقع: $e');
      }
    }
    ```

#### ب. كتابة الملفات (Writing Files)

لكتابة البيانات إلى ملف، يمكن استخدام `openWrite()` التي تُرجع كائن `IOSink`. يمكن الكتابة إلى الملف كنص أو بايتات.

*   `FileMode.write`: الوضع الافتراضي، يقوم بمسح محتوى الملف الحالي وكتابة البيانات الجديدة.
*   `FileMode.append`: إضافة البيانات إلى نهاية الملف دون مسح المحتوى الحالي.
*   `FileMode.writeOnly`: يفتح الملف للكتابة فقط، ويقوم بمسح المحتوى الحالي.
*   `FileMode.writeOnlyAppend`: يفتح الملف للكتابة فقط، ويضيف البيانات إلى النهاية.

```dart
import 'dart:io';

void main() async {
  final logFile = File('app_log.txt');

  // الكتابة إلى الملف (مسح المحتوى القديم إن وجد)
  var sink = logFile.openWrite();
  sink.write('بدء تشغيل التطبيق: ${DateTime.now()}\n');
  await sink.flush(); // التأكد من كتابة البيانات إلى القرص
  await sink.close(); // إغلاق التدفق وتحرير الموارد

  // إضافة محتوى جديد إلى نهاية الملف
  sink = logFile.openWrite(mode: FileMode.append);
  sink.write('حدث مهم: تم تسجيل دخول المستخدم في ${DateTime.now()}\n');
  await sink.flush();
  await sink.close();

  print('تم كتابة السجلات إلى app_log.txt');
}
```

#### ج. إدارة الأدلة (Directory Management)

تتيح لك فئة `Directory` إنشاء، حذف، وسرد محتويات الأدلة.

```dart
import 'dart:io';

void main() async {
  final newDir = Directory('my_data_folder');

  // إنشاء دليل جديد إذا لم يكن موجودًا
  if (!await newDir.exists()) {
    await newDir.create();
    print('تم إنشاء الدليل: ${newDir.path}');
  }

  // إنشاء ملف داخل الدليل الجديد
  final dataFile = File('${newDir.path}/config.json');
  await dataFile.writeAsString('{"setting": "value"}');
  print('تم إنشاء الملف: ${dataFile.path}');

  // سرد محتويات الدليل
  print('\nمحتويات الدليل ${newDir.path}:');
  await for (var entity in newDir.list()) {
    if (entity is File) {
      print('  ملف: ${entity.path}');
    } else if (entity is Directory) {
      print('  دليل فرعي: ${entity.path}');
    }
  }

  // حذف الدليل ومحتوياته (recursive: true)
  // await newDir.delete(recursive: true);
  // print('\nتم حذف الدليل: ${newDir.path}');
}
```

### 2. التعامل مع الشبكات (Networking)

تعتبر `dart:io` حجر الزاوية في بناء تطبيقات الشبكات في Dart، سواء كانت خوادم (Servers) أو عملاء (Clients) لبروتوكولات مختلفة مثل HTTP، TCP، و UDP.

#### أ. خادم HTTP (HTTP Server)

يمكنك بناء خوادم ويب قوية باستخدام `HttpServer`، والتي توفر تحكماً دقيقاً في معالجة الطلبات والاستجابات.

```dart
import 'dart:io';

void main() async {
  final port = 8080;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('الخادم يعمل على http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    handleRequest(request);
  }
}

void handleRequest(HttpRequest request) {
  try {
    if (request.method == 'GET' && request.uri.path == '/') {
      request.response
        ..headers.contentType = ContentType.html
        ..write('<h1>أهلاً بك في خادم Dart!</h1><p>المسار: ${request.uri.path}</p>')
        ..close();
    } else if (request.method == 'GET' && request.uri.path == '/api/data') {
      request.response
        ..headers.contentType = ContentType.json
        ..write('{"message": "بيانات من الخادم", "timestamp": "${DateTime.now()}"}')
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('404 - الصفحة غير موجودة')
        ..close();
    }
  } catch (e) {
    print('خطأ في معالجة الطلب: $e');
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write('500 - خطأ داخلي في الخادم')
      ..close();
  }
}
```

#### ب. عميل HTTP (HTTP Client)

على الرغم من أن `dart:io` توفر فئة `HttpClient`، إلا أنه **يوصى بشدة** باستخدام مكتبات أعلى مستوى مثل `package:http` [1] للتعامل مع طلبات HTTP في معظم التطبيقات. `HttpClient` في `dart:io` هي مكتبة منخفضة المستوى وتتطلب إدارة يدوية للعديد من التفاصيل، بينما `package:http` توفر واجهة أبسط وأكثر قوة.

**مثال باستخدام `package:http` (الطريقة الموصى بها):**

```dart
// يجب إضافة http إلى ملف pubspec.yaml:
// dependencies:
//   http: ^1.0.0

import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('تم استلام البيانات بنجاح:\n${response.body}');
    } else {
      print('فشل في جلب البيانات. رمز الحالة: ${response.statusCode}');
    }
  } catch (e) {
    print('حدث خطأ أثناء الاتصال: $e');
  }
}
```

### 3. العمليات (Processes)

تسمح `dart:io` بتشغيل عمليات خارجية (External Processes) والتفاعل معها، مما يتيح لتطبيقات Dart تنفيذ أوامر نظام التشغيل أو برامج أخرى.

```dart
import 'dart:io';

void main() async {
  // تشغيل أمر 'ls -l' (أو 'dir' في Windows)
  final result = await Process.run('ls', ['-l']);

  if (result.exitCode == 0) {
    print('الناتج القياسي:\n${result.stdout}');
  } else {
    print('خطأ:\n${result.stderr}');
  }
}
```

### 4. المقابس (Sockets) ومقابس الويب (WebSockets)

توفر `dart:io` دعماً للمقابس الخام (Raw Sockets) مثل TCP و UDP، بالإضافة إلى مقابس الويب (WebSockets) التي تسمح بالاتصال ثنائي الاتجاه (Bidirectional Communication) المستمر بين العميل والخادم.

#### أ. مقابس TCP (TCP Sockets)

```dart
import 'dart:io';
import 'dart:convert';

void main() async {
  // مثال على خادم TCP بسيط
  ServerSocket.bind(InternetAddress.loopbackIPv4, 4567)
      .then((server) {
    print('خادم TCP يعمل على المنفذ ${server.port}');
    server.listen((Socket client) {
      client.transform(utf8.decoder).listen((message) {
        print('استلمت من العميل: $message');
        client.write('تم استلام رسالتك: $message');
      });
    });
  });

  // مثال على عميل TCP بسيط
  Socket.connect(InternetAddress.loopbackIPv4, 4567)
      .then((socket) {
    print('عميل TCP متصل.');
    socket.write('مرحباً من العميل!');
    socket.listen((data) {
      print('استلمت من الخادم: ${utf8.decode(data)}');
      socket.destroy();
    });
  });
}
```

#### ب. مقابس الويب (WebSockets)

تستخدم `WebSocket` للاتصالات التفاعلية في الوقت الفعلي (Real-time interactive communications).

```dart
import 'dart:io';

void main() async {
  // مثال على خادم WebSocket بسيط
  HttpServer.bind(InternetAddress.loopbackIPv4, 8081).then((server) {
    server.listen((HttpRequest request) async {
      if (WebSocket.isWebSocket(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
          websocket.listen((message) {
            print('استلمت رسالة WebSocket: $message');
            websocket.add('تم استلام رسالتك عبر WebSocket: $message');
          });
        });
      } else {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.close();
      }
    });
    print('خادم WebSocket يعمل على http://${server.address.host}:${server.port}');
  });

  // مثال على عميل WebSocket بسيط
  try {
    final ws = await WebSocket.connect('ws://127.0.0.1:8081');
    print('عميل WebSocket متصل.');
    ws.listen((message) {
      print('استلمت من WebSocket: $message');
      ws.close();
    }, onDone: () => print('WebSocket مغلق.'), onError: (error) => print('خطأ WebSocket: $error'));
    ws.add('مرحباً من عميل WebSocket!');
  } catch (e) {
    print('فشل الاتصال بـ WebSocket: $e');
  }
}
```

### أفضل الممارسات عند استخدام `dart:io`:

*   **التعامل غير المتزامن (Asynchronous Handling):** دائماً استخدم الدوال غير المتزامنة (Async/Await, Futures, Streams) لتجنب حظر مؤشر الترابط الرئيسي (Main Thread) لتطبيقك، خاصة في تطبيقات الخادم أو واجهة المستخدم.
*   **إدارة الموارد (Resource Management):** تأكد دائماً من إغلاق الموارد (مثل الملفات والمقابس) بعد الانتهاء منها باستخدام `close()` أو `destroy()` لتحرير الذاكرة ومنع تسرب الموارد (Resource Leaks).
*   **معالجة الأخطاء (Error Handling):** استخدم كتل `try-catch` للتعامل مع الاستثناءات (Exceptions) المحتملة أثناء عمليات الإدخال/الإخراج، مثل عدم وجود ملف أو فشل الاتصال بالشبكة.
*   **اختيار المكتبة المناسبة:** لتطبيقات الويب، استخدم `dart:html`. لطلبات HTTP المعقدة، فضل `package:http` على `HttpClient` المباشر.

---

## ثانياً: مكتبة `dart:convert` - تحويل البيانات

تُعد مكتبة `dart:convert` أداة أساسية لمعالجة البيانات في Dart، حيث توفر وظائف لتحويل البيانات بين تنسيقات مختلفة. وهي ضرورية للتعامل مع البيانات المستلمة من الشبكة أو المخزنة في الملفات، خاصة عندما تكون هذه البيانات بتنسيقات قياسية مثل JSON أو UTF-8.

### 1. تشفير وفك تشفير JSON (JSON Encoding and Decoding)

**JSON** (JavaScript Object Notation) هو تنسيق خفيف الوزن لتبادل البيانات، وهو الأكثر شيوعاً في تطبيقات الويب وخدمات الويب (Web Services). توفر `dart:convert` دوال بسيطة وفعالة للتعامل معه.

*   `jsonDecode(String source)`: تحويل سلسلة نصية بتنسيق JSON إلى كائن Dart (عادةً `Map<String, dynamic>` أو `List<dynamic>`).
*   `jsonEncode(Object? object)`: تحويل كائن Dart (مثل `Map` أو `List`) إلى سلسلة نصية بتنسيق JSON.

#### أ. فك تشفير JSON (Decoding JSON)

```dart
import 'dart:convert';

void main() {
  String jsonString = '''
    {
      
      "name": "Dart Programming",
      "version": 3.11,
      "features": ["Sound Null Safety", "Records", "Patterns"],
      "released": true
    }
  ' '';

  try {
    Map<String, dynamic> dartInfo = jsonDecode(jsonString);
    print('اسم اللغة: ${dartInfo['name']}');
    print('الإصدار: ${dartInfo['version']}');
    print('الميزات: ${dartInfo['features'].join(', ')}');
    print('تم الإصدار: ${dartInfo['released'] ? 'نعم' : 'لا'}');

    // مثال على فك تشفير قائمة من الكائنات
    String jsonArrayString = '[{"id": 1, "item": "تفاحة"}, {"id": 2, "item": "موزة"}]';
    List<dynamic> items = jsonDecode(jsonArrayString);
    print('\nالعناصر:');
    items.forEach((item) => print('  ${item['item']} (ID: ${item['id']})'));

  } on FormatException catch (e) {
    print('خطأ في تنسيق JSON: ${e.message}');
  } catch (e) {
    print('حدث خطأ غير متوقع: $e');
  }
}
```

#### ب. تشفير إلى JSON (Encoding to JSON)

```dart
import 'dart:convert';

void main() {
  // تشفير كائن Map إلى JSON
  Map<String, dynamic> product = {
    'id': 'P001',
    'name': 'كمبيوتر محمول',
    'price': 1200.00,
    'inStock': true,
    'tags': ['إلكترونيات', 'حاسوب', 'محمول']
  };

  String jsonProduct = jsonEncode(product);
  print('المنتج المشفر إلى JSON:\n$jsonProduct');

  // تشفير قائمة من الكائنات إلى JSON
  List<Map<String, dynamic>> users = [
    {'username': 'ali', 'email': 'ali@example.com'},
    {'username': 'sara', 'email': 'sara@example.com'}
  ];

  String jsonUsers = jsonEncode(users);
  print('\nقائمة المستخدمين المشفرة إلى JSON:\n$jsonUsers');

  // التعامل مع الكائنات غير القابلة للتحويل مباشرة
  // يمكن تمرير دالة reviver أو استخدام toJson() في الكائن
  class MyCustomObject {
    String value;
    MyCustomObject(this.value);

    Map<String, dynamic> toJson() => {'customValue': value};
  }

  var customObject = MyCustomObject('بيانات مخصصة');
  String customJson = jsonEncode(customObject);
  print('\nكائن مخصص مشفر إلى JSON:\n$customJson');
}
```

### 2. تشفير وفك تشفير UTF-8 (UTF-8 Encoding and Decoding)

**UTF-8** هو ترميز (Encoding) شائع يستخدم لتمثيل النصوص في أنظمة الكمبيوتر، ويدعم مجموعة واسعة من الأحرف بما في ذلك الأحرف العربية. تُستخدم `dart:convert` للتحويل بين سلاسل النصوص (Strings) وقوائم البايتات (List<int>) التي تمثل هذه النصوص.

*   `utf8.encode(String source)`: تحويل سلسلة نصية إلى قائمة من البايتات المرمزة بـ UTF-8 (`List<int>`).
*   `utf8.decode(List<int> bytes)`: تحويل قائمة من البايتات المرمزة بـ UTF-8 إلى سلسلة نصية.

```dart
import 'dart:convert';
import 'dart:typed_data'; // لاستخدام Uint8List

void main() {
  String originalText = 'مرحباً بالعالم! هذه رسالة باللغة العربية.';
  print('النص الأصلي: $originalText');

  // تشفير النص إلى بايتات UTF-8
  List<int> encodedBytes = utf8.encode(originalText);
  print('البايتات المشفرة (UTF-8): $encodedBytes');
  print('طول البايتات: ${encodedBytes.length}');

  // فك تشفير البايتات مرة أخرى إلى نص
  String decodedText = utf8.decode(encodedBytes);
  print('النص بعد فك التشفير: $decodedText');

  // التحقق من أن النص الأصلي والمفكك متطابقان
  assert(originalText == decodedText);

  // مثال على التعامل مع تدفق البايتات (Stream of bytes)
  // هذا مفيد عند قراءة بيانات كبيرة من الشبكة أو الملفات
  Stream<List<int>> byteStream = Stream.fromIterable([
    Uint8List.fromList([216, 170, 217, 132, 216, 176, 216, 169]), // 'مرحباً'
    Uint8List.fromList([32, 216, 152, 216, 162, 216, 176, 216, 177]), // 'بالعالم'
  ]);

  byteStream
      .transform(utf8.decoder) // تحويل تدفق البايتات إلى تدفق نصوص
      .listen((data) {
    print('بيانات مستلمة من التدفق: $data');
  });
}
```

### 3. محولات أخرى (Other Converters)

بالإضافة إلى JSON و UTF-8، توفر `dart:convert` محولات (Converters) أخرى مثل:

*   `ascii`: لتشفير وفك تشفير نصوص ASCII.
*   `latin1`: لتشفير وفك تشفير نصوص ISO-8859-1.
*   `base64`: لتشفير وفك تشفير البيانات باستخدام ترميز Base64، وهو مفيد لنقل البيانات الثنائية عبر البروتوكولات النصية.

```dart
import 'dart:convert';

void main() {
  String original = 'Hello, Dart!';

  // Base64 Encoding
  String encoded = base64Encode(utf8.encode(original));
  print('Base64 Encoded: $encoded'); // Output: SGVsbG8sIERhcnQh

  // Base64 Decoding
  String decoded = utf8.decode(base64Decode(encoded));
  print('Base64 Decoded: $decoded'); // Output: Hello, Dart!

  assert(original == decoded);
}
```

### أفضل الممارسات عند استخدام `dart:convert`:

*   **التعامل مع الأخطاء (Error Handling):** استخدم `try-catch` عند فك تشفير JSON أو UTF-8 للتعامل مع `FormatException` في حال كانت البيانات المدخلة غير صالحة.
*   **الكفاءة مع التدفقات (Stream Efficiency):** عند التعامل مع كميات كبيرة من البيانات (مثل ملفات JSON كبيرة أو تدفقات الشبكة)، استخدم المحولات مع `Stream.transform()` بدلاً من قراءة كل البيانات دفعة واحدة ثم تحويلها. هذا يقلل من استهلاك الذاكرة ويحسن الأداء.
*   **تحديد الترميز (Specify Encoding):** دائماً حدد الترميز (مثل `utf8`) بشكل صريح عند التعامل مع النصوص والبايتات لتجنب المشاكل المتعلقة بالأحرف غير المتوقعة، خاصة عند التعامل مع لغات متعددة.
*   **تجنب `jsonDecode` على بيانات غير موثوقة:** عند استلام بيانات JSON من مصادر غير موثوقة، كن حذراً. `jsonDecode` يمكن أن يُرجع `Map<String, dynamic>` أو `List<dynamic>`، وقد تحتاج إلى التحقق من أنواع البيانات يدوياً أو استخدام مكتبات تسلسل (Serialization) مثل `json_serializable` لضمان السلامة النوعية (Type Safety).

---

## ثالثاً: الجمع بين المكتبتين - تطبيقات عملية متقدمة

تتجلى قوة Dart الحقيقية عند دمج المكتبات معاً لحل مشكلات معقدة. يعتبر دمج `dart:io` و `dart:convert` سيناريو شائعاً جداً في تطبيقات الخادم، تطبيقات سطر الأوامر، وتطبيقات Flutter التي تتفاعل مع البيانات المحلية أو الشبكة.

### 1. قراءة وكتابة ملفات JSON معقدة

تخيل أن لديك تطبيقاً يحتاج إلى قراءة إعدادات معقدة من ملف JSON، أو حفظ حالة التطبيق في ملف JSON.

```dart
import 'dart:io';
import 'dart:convert';

// تعريف نموذج بيانات للإعدادات
class AppSettings {
  final String appName;
  final int themeId;
  final bool notificationsEnabled;
  final List<String> recentFiles;

  AppSettings({
    required this.appName,
    required this.themeId,
    required this.notificationsEnabled,
    required this.recentFiles,
  });

  // تحويل كائن AppSettings إلى Map (للتشفير إلى JSON)
  Map<String, dynamic> toJson() => {
        'appName': appName,
        'themeId': themeId,
        'notificationsEnabled': notificationsEnabled,
        'recentFiles': recentFiles,
      };

  // إنشاء كائن AppSettings من Map (لفك تشفير JSON)
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      appName: json['appName'] as String,
      themeId: json['themeId'] as int,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      recentFiles: List<String>.from(json['recentFiles'] as List),
    );
  }
}

void main() async {
  final settingsFile = File('app_settings.json');

  // 1. حفظ الإعدادات إلى ملف JSON
  final defaultSettings = AppSettings(
    appName: 'My Dart App',
    themeId: 1,
    notificationsEnabled: true,
    recentFiles: ['file1.txt', 'image.png'],
  );

  try {
    String jsonContent = jsonEncode(defaultSettings.toJson());
    await settingsFile.writeAsString(jsonContent);
    print('تم حفظ الإعدادات إلى app_settings.json');

    // 2. قراءة الإعدادات من ملف JSON
    if (await settingsFile.exists()) {
      String fileContent = await settingsFile.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(fileContent);
      AppSettings loadedSettings = AppSettings.fromJson(jsonMap);

      print('\nالإعدادات المحملة:');
      print('  اسم التطبيق: ${loadedSettings.appName}');
      print('  معرف المظهر: ${loadedSettings.themeId}');
      print('  الإشعارات مفعلة: ${loadedSettings.notificationsEnabled}');
      print('  الملفات الأخيرة: ${loadedSettings.recentFiles.join(', ')}');
    }
  } on FileSystemException catch (e) {
    print('خطأ في نظام الملفات: ${e.message}');
  } on FormatException catch (e) {
    print('خطأ في تنسيق JSON: ${e.message}');
  } catch (e) {
    print('حدث خطأ غير متوقع: $e');
  }
}
```

### 2. معالجة تدفقات HTTP JSON (Processing HTTP JSON Streams)

في تطبيقات الخادم، قد تحتاج إلى استقبال بيانات JSON كبيرة عبر طلبات HTTP. هنا، يمكن دمج `dart:io` (لاستقبال الطلب) مع `dart:convert` (لمعالجة JSON) بكفاءة.

```dart
import 'dart:io';
import 'dart:convert';

void main() async {
  final port = 8082;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('خادم JSON HTTP يعمل على http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    if (request.method == 'POST' && request.uri.path == '/data') {
      try {
        // قراءة جسم الطلب كتدفق من البايتات
        String content = await utf8.decoder.bind(request).join();
        Map<String, dynamic> jsonData = jsonDecode(content);

        print('\nتم استلام بيانات JSON: $jsonData');

        request.response
          ..headers.contentType = ContentType.json
          ..statusCode = HttpStatus.ok
          ..write(jsonEncode({'status': 'success', 'receivedData': jsonData}))
          ..close();
      } on FormatException catch (e) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('خطأ في تنسيق JSON: ${e.message}')
          ..close();
      } catch (e) {
        print('خطأ في معالجة طلب POST: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('خطأ داخلي في الخادم')
          ..close();
      }
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('404 - المسار غير موجود أو طريقة الطلب غير مدعومة')
        ..close();
    }
  }
}
```

### 3. تحليل ملفات CSV كبيرة (Parsing Large CSV Files)

يمكن استخدام `dart:io` لقراءة ملفات CSV كبيرة كتدفق، و `dart:convert` (مع بعض المعالجة اليدوية أو مكتبة خارجية) لتحليلها سطراً بسطر.

```dart
import 'dart:io';
import 'dart:convert';

void main() async {
  final csvFile = File('data.csv');
  if (!await csvFile.exists()) {
    // إنشاء ملف CSV للاختبار
    await csvFile.writeAsString('Name,Age,City\nAlice,30,New York\nBob,24,London\nCharlie,35,Paris');
  }

  try {
    Stream<List<int>> inputStream = csvFile.openRead();

    // تحويل البايتات إلى نصوص ثم تقسيمها إلى أسطر
    var lines = inputStream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    List<List<String>> parsedData = [];
    await for (var line in lines) {
      // تقسيم كل سطر حسب الفاصلة (CSV)
      parsedData.add(line.split(','));
    }

    if (parsedData.isNotEmpty) {
      print('الرؤوس: ${parsedData[0]}');
      for (int i = 1; i < parsedData.length; i++) {
        print('البيانات: ${parsedData[i]}');
      }
    }
  } on FileSystemException catch (e) {
    print('خطأ في نظام الملفات: ${e.message}');
  } catch (e) {
    print('حدث خطأ غير متوقع: $e');
  }
}
```

### ملخص الفروقات والاستخدام المشترك (Summary of Differences and Joint Usage)

| الميزة | `dart:io` | `dart:convert` | الاستخدام المشترك |
| :--- | :--- | :--- | :--- |
| **الهدف الأساسي** | التفاعل مع نظام التشغيل (ملفات، شبكة، عمليات). | تحويل البيانات بين التنسيقات (JSON, UTF-8, Base64). | معالجة البيانات المستلمة من/المرسلة إلى نظام التشغيل/الشبكة. |
| **بيئة التشغيل** | تطبيقات الخادم، CLI، Flutter (سطح المكتب/الهاتف). | جميع بيئات Dart (الخادم، CLI، Flutter، الويب). | حيثما تتطلب بيئة التشغيل تفاعلاً مع نظام التشغيل ومعالجة للبيانات. |
| **التعامل مع النصوص** | قراءة/كتابة النصوص كـ `String` أو `List<int>` (بايتات). | تشفير/فك تشفير النصوص إلى/من بايتات (UTF-8) أو تنسيقات أخرى. | قراءة ملف نصي (io)، فك تشفيره (convert)، ثم معالجته.
| **التعامل مع البيانات المهيكلة** | لا تتعامل مباشرة مع تنسيقات مثل JSON. | تشفير/فك تشفير JSON إلى/من كائنات Dart. | قراءة ملف JSON (io)، تحويله إلى كائن Dart (convert)، ثم التعامل معه برمجياً. |
| **التعامل مع التدفقات** | توفر تدفقات للبايتات من الملفات والشبكة (`Stream<List<int>>`). | توفر محولات للتدفقات (`StreamTransformer`) لتحويل البايتات إلى نصوص أو العكس. | قراءة تدفق من البايتات (io)، تحويله إلى نصوص (convert)، ثم تحويله إلى JSON (convert). |

---

## خاتمة

تُعد مكتبتا `dart:io` و `dart:convert` ركيزتين أساسيتين في منظومة Dart البيئية، حيث توفران الأدوات اللازمة للتفاعل مع العالم الخارجي (عبر `dart:io`) ومعالجة البيانات الداخلية (عبر `dart:convert`). الفهم العميق لكيفية عمل كل منهما، وكيفية دمجهما بفعالية، يفتح آفاقاً واسعة لتطوير تطبيقات Dart قوية، مرنة، وذات أداء عالٍ في مختلف البيئات.

--- 

## المراجع

[1] [package:http - Pub.dev](https://pub.dev/packages/http)

*تم إعداد هذا الدليل الموسع بواسطة **Manus AI** بناءً على التوثيق الرسمي لـ Dart لعام 2026 وأفضل الممارسات البرمجية.*
