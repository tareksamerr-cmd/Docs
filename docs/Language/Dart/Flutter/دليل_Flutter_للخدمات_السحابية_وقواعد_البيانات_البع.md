# دليل Flutter للخدمات السحابية وقواعد البيانات البعيدة: Supabase و Firebase (إصدار 2026)

في عام 2026، لم تعد الخدمات السحابية مجرد "خلفية" (Backend) للتطبيقات، بل أصبحت منصات متكاملة تدعم الذكاء الاصطناعي، التزامن الفوري، والأمان على مستوى المؤسسات. يركز هذا الدليل على أقوى منصتين في منظومة Flutter: **Supabase** و **Firebase**، مع شرح معماري دقيق وأمثلة برمجية مكثفة.

---

## 1. منصة Supabase (`supabase_flutter`)

تُعد Supabase البديل المفتوح المصدر لـ Firebase، وهي مبنية بالكامل فوق قاعدة بيانات **PostgreSQL**، مما يمنحها قوة هائلة في التعامل مع البيانات العلائقية والمعقدة.

### أ. المعمارية الهندسية (Architectural Deep Dive)
*   **PostgreSQL**: النواة الصلبة، تدعم العلاقات، الجداول، والعمليات المعقدة (Joins, Transactions).
*   **PostgREST**: أداة تقوم بإنشاء واجهة برمجة تطبيقات (REST API) تلقائياً بناءً على مخطط قاعدة البيانات.
*   **GoTrue**: محرك المصادقة (Auth) الذي يدعم JWT و Row-Level Security (RLS).
*   **Realtime**: نظام يعتمد على `Logical Replication` في PostgreSQL لإرسال التحديثات عبر WebSockets.
*   **Edge Functions**: دوال برمجية تعمل على بيئة **Deno** (أسرع وأخف من Node.js) وتعمل بالقرب من المستخدم (Edge).

### ب. المصادقة (Authentication)
تدعم Supabase أكثر من 18 مزوداً للمصادقة، مع دعم مدمج لـ **SAML SSO** للمؤسسات.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final _client = Supabase.instance.client;

  // 1. تسجيل الدخول بالبريد والرابط السحري (Magic Link)
  Future<void> signInWithMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  // 2. تسجيل الدخول بمزود خارجي (Google)
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  // 3. الحصول على المستخدم الحالي وجلسة العمل
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
}
```

### ج. قاعدة البيانات والأمان (PostgreSQL & RLS)
القوة الحقيقية لـ Supabase تكمن في **Row-Level Security (RLS)**، حيث يتم كتابة قواعد الأمان بلغة SQL مباشرة في قاعدة البيانات.

```sql
-- مثال لقاعدة RLS: السماح للمستخدمين بقراءة ملاحظاتهم فقط
create policy "Users can see their own notes"
  on notes for select
  using ( auth.uid() = user_id );
```

**عمليات CRUD المتقدمة في Flutter:**
```dart
class SupabaseDbService {
  final _client = Supabase.instance.client;

  // 1. استعلام مع علاقات (Joins)
  Future<List<Map<String, dynamic>>> getOrdersWithDetails() async {
    return await _client
        .from('orders')
        .select('id, total, profiles(username, avatar_url), order_items(*)')
        .order('created_at');
  }

  // 2. إدراج بيانات (Insert)
  Future<void> createOrder(Map<String, dynamic> data) async {
    await _client.from('orders').insert(data);
  }

  // 3. التحديث الفوري (Realtime Subscriptions)
  void watchMessages(String roomId) {
    _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .listen((List<Map<String, dynamic>> data) {
          print('New messages: $data');
        });
  }
}
```

---

## 2. منصة Firebase (`cloud_firestore` & `firebase_storage`)

تظل Firebase المنصة الأكثر تكاملاً مع نظام Google السحابي، وهي الخيار الأول للتطبيقات التي تتطلب مزامنة فورية فائقة ودعماً قوياً للعمل دون اتصال (Offline-first).

### أ. Cloud Firestore (NoSQL Document Store)
تعتمد Firestore على نموذج "المستندات والمجموعات" (Documents & Collections)، وهي مصممة للتوسع التلقائي الهائل.

#### ميزات 2026 المتقدمة:
*   **Vector Search**: دعم مدمج للبحث عن المتجهات لدعم تطبيقات الذكاء الاصطناعي (RAG).
*   **Count() Queries**: استعلامات العد المباشرة دون الحاجة لقراءة جميع المستندات (توفير في التكلفة).
*   **Passkeys Support**: دعم المصادقة البيومترية كبديل لكلمات المرور.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // 1. استعلام متقدم مع Pagination
  Future<List<DocumentSnapshot>> getProducts(DocumentSnapshot? lastDoc) async {
    var query = _db.collection('products')
        .orderBy('price', descending: true)
        .limit(20);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  // 2. استخدام التجميع (Aggregation Queries - توفير التكلفة)
  Future<int> getTotalOrdersCount() async {
    final query = _db.collection('orders');
    final aggregateQuery = query.count();
    final snapshot = await aggregateQuery.get();
    return snapshot.count ?? 0;
  }

  // 3. المزامنة الفورية مع الدعم دون اتصال (Offline Persistence)
  Stream<QuerySnapshot> watchUserNotifications(String userId) {
    return _db.collection('users').doc(userId).collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }
}
```

### ب. Firebase Storage (إدارة الملفات)
تُستخدم لتخزين الصور، الفيديوهات، والملفات الكبيرة، مع تكامل تام مع قواعد الأمان.

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseStorageService {
  final _storage = FirebaseStorage.instance;

  // 1. رفع ملف مع مراقبة التقدم
  Future<void> uploadProfileImage(String userId, File file) async {
    final ref = _storage.ref().child('users/$userId/profile.jpg');
    final uploadTask = ref.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = 100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
      print('Upload progress: $progress%');
    });

    await uploadTask;
  }

  // 2. الحصول على رابط التحميل (Download URL)
  Future<String> getFileUrl(String path) async {
    return await _storage.ref().child(path).getDownloadURL();
  }
}
```

---

## 3. مقارنة تقنية: Supabase vs Firebase (إصدار 2026)

| المعيار | Supabase (`supabase_flutter`) | Firebase (`cloud_firestore`) |
| :--- | :--- | :--- |
| **نموذج البيانات** | علائقي (SQL - PostgreSQL) | مستندات (NoSQL - Documents) |
| **قواعد الأمان** | Row-Level Security (SQL) | Security Rules (Proprietary DSL) |
| **العمل دون اتصال** | محدود (يتطلب Cache خارجي) | **قوي جداً ومدمج (Native)** |
| **العلاقات (Joins)** | مدعومة بقوة وسهولة | غير مدعومة (تتطلب Denormalization) |
| **الذكاء الاصطناعي** | `pgvector` مدمج في DB | `Vector Search` مدمج في Firestore |
| **التسعير** | بناءً على حجم الاستخدام والمثيلات | بناءً على عدد العمليات (Read/Write) |
| **قفل المورد (Lock-in)** | منخفض (مفتوح المصدر، يمكن نقله) | عالي (منصة مغلقة تابعة لـ Google) |

---

## 4. أفضل الممارسات الهندسية لعام 2026

1.  **استراتيجية "العميل النحيف" (Thin Client)**: تجنب كتابة منطق الأعمال المعقد داخل تطبيق Flutter. استخدم **Edge Functions** في Supabase أو **Cloud Run** في Firebase لمعالجة البيانات الحساسة.
2.  **أمان Zero-Trust**: لا تعتمد أبداً على التحقق من البيانات في واجهة التطبيق. تأكد من أن كل عملية كتابة يتم التحقق منها عبر **RLS** أو **Security Rules**.
3.  **تحسين التكلفة في Firestore**: استخدم استعلامات `count()` و `sum()` الجديدة بدلاً من جلب جميع المستندات لحساب القيم.
4.  **إدارة الحالة (State Management)**: اربط الـ `Streams` القادمة من Supabase أو Firebase بمزودات الحالة مثل **Riverpod** أو **BLoC** لضمان تحديث الواجهة بسلاسة.

---

## 5. مثال شامل: تطبيق "سوق ذكي" (Smart Marketplace)

يوضح هذا المثال كيف نختار التقنية المناسبة لكل جزء من التطبيق:

```dart
// استخدام Supabase للبيانات المعقدة والعلائقية (الطلبات، الفواتير)
class OrderRepository {
  final supabase = Supabase.instance.client;

  Future<void> placeOrder(List<CartItem> items) async {
    // استخدام PostgreSQL Transactions لضمان سلامة البيانات
    await supabase.rpc('process_order', params: {
      'items': items.map((e) => e.toJson()).toList(),
    });
  }
}

// استخدام Firebase للمحادثات الفورية (Chat) والإشعارات (FCM)
class ChatRepository {
  final firestore = FirebaseFirestore.instance;

  Stream<List<Message>> watchMessages(String chatId) {
    // الاستفادة من سرعة Firebase في المزامنة الفورية ودعم الـ Offline
    return firestore.collection('chats').doc(chatId).collection('messages')
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromDoc(doc)).toList());
  }
}
```

---

*تم إعداد هذا المرجع الهندسي بواسطة **Manus AI** ليكون الدليل النهائي للتعامل مع الخدمات السحابية في Flutter لعام 2026. يجمع هذا الدليل بين قوة SQL ومرونة NoSQL لمساعدتك في بناء تطبيقات عالمية المستوى.*
