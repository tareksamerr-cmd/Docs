# دليل ويدجت التمرير في Flutter (Scrolling Widgets in Flutter)

يعتبر التمرير (Scrolling) جزءاً أساسياً من تجربة المستخدم في تطبيقات الهاتف المحمول. توفر Flutter مجموعة واسعة من الويدجت (Widgets) التي تتيح عرض محتوى يتجاوز حجم الشاشة بكفاءة عالية.

---

## فهم آلية التمرير في Flutter (Underlying Scrolling Mechanism)

لفهم ويدجت التمرير بشكل أعمق، من المهم فهم المكونات الأساسية التي تشكل نظام التمرير في Flutter:

### 1. Viewport (منفذ العرض)
الـ `Viewport` هو المنطقة المرئية التي يتم فيها عرض المحتوى القابل للتمرير. هو الذي يحدد أي جزء من المحتوى يجب أن يكون مرئياً للمستخدم في أي لحظة. عندما تقوم بالتمرير، فإنك في الواقع تقوم بتحريك المحتوى داخل الـ `Viewport` [24].

### 2. RenderSliver (عنصر التمرير المرئي)
الـ `RenderSliver` هو الفئة الأساسية لعناصر الـ `RenderObject` التي تنفذ تأثيرات التمرير داخل الـ `Viewport`. كل `Sliver` (شريحة) هو جزء من منطقة التمرير يمكن أن يتصرف بطريقة خاصة. على سبيل المثال، `SliverAppBar` هو `Sliver` يتغير حجمه عند التمرير [25].

### 3. ScrollController (وحدة التحكم بالتمرير)
تسمح لك `ScrollController` بالتحكم يدوياً في موضع التمرير، والاستماع إلى أحداث التمرير، وتحديد موضع التمرير الأولي. يمكن ربطها بأي ويدجت قابل للتمرير [26].

### 4. ScrollPhysics (فيزياء التمرير)
تحدد `ScrollPhysics` كيفية استجابة الويدجت القابل للتمرير لتفاعلات المستخدم عندما يصل إلى حدود التمرير (بداية أو نهاية القائمة). تسمح بتخصيص سلوك التمرير ليشمل تأثيرات مثل الارتداد (bouncing) أو التثبيت (clamping) [27].

---

## 1. ListView (قائمة العرض)
تعتبر `ListView` الويدجت الأكثر استخداماً لعرض قوائم خطية من العناصر.

### خاصية البناء (builder)
تستخدم `ListView.builder` لإنشاء العناصر عند الحاجة فقط (**Lazy Loading**)، مما يحسن الأداء بشكل كبير في القوائم الطويلة [1]. هذا يعني أن Flutter لا يقوم ببناء جميع العناصر دفعة واحدة، بل يبني فقط العناصر المرئية على الشاشة وتلك القريبة منها، مما يوفر الذاكرة ويحسن سلاسة التمرير.

| الخاصية | الوصف |
| :--- | :--- |
| `itemBuilder` | دالة تعيد الويدجت لكل عنصر بناءً على الفهرس (index). هذه الدالة يتم استدعاؤها فقط للعناصر التي ستظهر على الشاشة. |
| `itemCount` | عدد العناصر الإجمالي. إذا كان `null` ستكون القائمة لانهائية، ويجب أن يكون `itemBuilder` قادراً على التعامل مع ذلك (مثل جلب المزيد من البيانات). |
| `findChildIndexCallback` | (متقدم) يساعد Flutter في إعادة استخدام العناصر عند تغيير ترتيب القائمة، خاصة في حالات القوائم الديناميكية التي تتغير فيها العناصر بشكل متكرر [2]. |

**مثال كود متقدم:**
```dart
ListView.builder(
  itemCount: 1000,
  cacheExtent: 100.0, // تحميل مسبق للعناصر خارج الشاشة بمسافة 100 بكسل
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text("$index")),
      title: Text("المستخدم رقم $index"),
      subtitle: Text("تفاصيل إضافية عن العنصر..."),
    );
  },
)
```

**الاستخدامات:**
- عرض خلاصات الأخبار (News Feeds).
- قوائم المحادثات في تطبيقات الدردشة.
- أي قائمة بيانات ديناميكية أو كبيرة الحجم.

---

## 2. GridView (عرض الشبكة)
تستخدم `GridView` لعرض العناصر في ترتيب ثنائي الأبعاد (صفوف وأعمدة).

### خاصية البناء (builder)
تستخدم `GridView.builder` لإنشاء شبكة من العناصر بكفاءة عالية، وتتطلب `gridDelegate` لتحديد هيكل الشبكة [3]. كما هو الحال مع `ListView.builder`، يتم بناء العناصر بشكل كسول (lazily) لتحسين الأداء.

| الخاصية | الوصف |
| :--- | :--- |
| `gridDelegate` | يتحكم في توزيع العناصر. أشهرها `SliverGridDelegateWithFixedCrossAxisCount` (عدد ثابت من الأعمدة) و `SliverGridDelegateWithMaxCrossAxisExtent` (أقصى عرض لكل عنصر). |
| `itemBuilder` | دالة بناء العنصر لكل خلية. |

**مثال كود:**
```dart
GridView.builder(
  padding: EdgeInsets.all(10),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3, // 3 أعمدة
    crossAxisSpacing: 10, // مسافة أفقية بين الأعمدة
    mainAxisSpacing: 10, // مسافة رأسية بين الصفوف
    childAspectRatio: 0.8, // نسبة العرض إلى الطول لكل عنصر
  ),
  itemCount: 30,
  itemBuilder: (context, index) {
    return Container(
      color: Colors.blue[(index % 9 + 1) * 100],
      child: Center(child: Text("عنصر $index")),
    );
  },
)
```

**الاستخدامات:**
- تطبيقات التجارة الإلكترونية لعرض المنتجات.
- معارض الصور والفيديوهات.
- أي عرض يتطلب ترتيباً شبكياً ديناميكياً.

---

## 3. PageView (عرض الصفحات)
تسمح `PageView` للمستخدم بالتنقل بين الصفحات عن طريق السحب (Swiping).

### خاصية البناء (builder)
تستخدم `PageView.builder` عندما يكون عدد الصفحات كبيراً أو ديناميكياً، حيث يتم بناء الصفحات عند الحاجة فقط [4].

**مثال كود متقدم (تأثير الكاروسيل):**
```dart
final PageController controller = PageController(viewportFraction: 0.8);

PageView.builder(
  controller: controller,
  itemBuilder: (context, index) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = 1.0;
        if (controller.position.haveDimensions) {
          value = controller.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 300,
            width: Curves.easeInOut.transform(value) * 400,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        color: index % 2 == 0 ? Colors.red : Colors.blue,
        child: Center(child: Text("صفحة $index", style: TextStyle(color: Colors.white))),
      ),
    );
  },
)
```

**الاستخدامات:**
- شاشات الترحيب (Onboarding).
- عرض القصص (Stories) كما في إنستغرام.
- عروض المنتجات أو الصور التي تتطلب التنقل بين الصفحات.

---

## 4. CustomScrollView & Slivers
تعتبر `CustomScrollView` العمود الفقري لتأثيرات التمرير المعقدة، حيث تسمح بدمج أنواع مختلفة من تأثيرات التمرير (Slivers) في منطقة تمرير واحدة [5]. الـ `Slivers` هي أجزاء من منطقة التمرير يمكن أن تتصرف بطرق فريدة، مما يتيح إنشاء واجهات مستخدم ديناميكية للغاية.

### خاصية البناء (SliverChildBuilderDelegate)
تستخدم الـ `Delegates` للتحكم الدقيق في كيفية بناء العناصر داخل الـ `Slivers`. `SliverChildBuilderDelegate` هو المكافئ لـ `builder` في الـ `Slivers`، حيث يقوم ببناء العناصر عند الطلب [6].

| النوع | الوصف |
| :--- | :--- |
| `SliverChildBuilderDelegate` | يبني العناصر عند الطلب (Lazy) باستخدام دالة `builder`، مما يجعله مثالياً للقوائم الكبيرة والديناميكية. |
| `SliverChildListDelegate` | يأخذ قائمة جاهزة من العناصر (أقل كفاءة للقوائم الطويلة جداً، ولكنه مناسب للقوائم الثابتة والصغيرة). |

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(title: Text("Sliver Header")),
      pinned: true, // يثبت الـ AppBar في الأعلى عند التمرير
    ),
    SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(color: Colors.teal[100 * (index % 9)]),
        childCount: 20,
      ),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text("عنصر قائمة $index")),
        childCount: 50,
      ),
    ),
  ],
)
```

**الاستخدامات:**
- دمج القوائم والشبكات ورؤوس الصفحات المتفاعلة في شاشة تمرير واحدة.
- إنشاء تأثيرات تمرير مخصصة ومعقدة مثل الرؤوس المرنة (flexible headers).

---

## 5. CarouselView (جديد في Flutter 3.22+)
ويدجت حديث من Material 3 لعرض العناصر بشكل دائري أو متتابع، ويوفر تجربة مستخدم غنية للتصفح الأفقي [7].

**مثال كود:**
```dart
CarouselView(
  itemExtent: 300, // عرض العنصر الواحد
  shrinkExtent: 200, // أقل عرض يصل إليه العنصر عند التمرير
  children: List.generate(10, (int index) {
    return UnconstrainedBox(
      child: Container(
        color: Colors.amber,
        child: Center(child: Text("عنصر $index")),
      ),
    );
  }),
)
```

**الاستخدامات:**
- عرض شرائح المنتجات أو الصور بشكل جذاب.
- واجهات المستخدم التي تتطلب تصفحاً دائرياً للعناصر.

---

## 6. DraggableScrollableSheet
حاوية تظهر من أسفل الشاشة ويمكن سحبها لتغيير حجمها، وتوفر `ScrollController` لربطه بويدجت تمرير داخلي [8].

### خاصية البناء (builder)
تأخذ دالة `builder` التي توفر `BuildContext` و `ScrollController`، مما يسمح بإنشاء محتوى قابل للتمرير داخل الورقة وتوجيه سلوك التمرير الخاص بها.

**مثال كود:**
```dart
DraggableScrollableSheet(
  initialChildSize: 0.3, // الحجم الأولي للورقة (30% من الشاشة)
  minChildSize: 0.1,    // الحد الأدنى للحجم (10%)
  maxChildSize: 0.9,    // الحد الأقصى للحجم (90%)
  expand: true,         // هل تتوسع الورقة لملء المساحة المتاحة؟
  builder: (context, scrollController) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        controller: scrollController, // ضروري لربط التمرير بالسحب
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(title: Text("عنصر $index")),
      ),
    );
  },
)
```

**الاستخدامات:**
- عرض تفاصيل إضافية عن عنصر محدد دون الانتقال إلى شاشة جديدة.
- لوحات سفلية تفاعلية (Interactive Bottom Sheets) يمكن للمستخدم التحكم في حجمها.

---

## 7. ReorderableListView (قائمة قابلة لإعادة الترتيب)
تسمح للمستخدم بتغيير ترتيب العناصر يدوياً عن طريق السحب والإفلات [9].

### خاصية البناء (builder)
تستخدم `ReorderableListView.builder` لإنشاء قائمة قابلة لإعادة الترتيب بكفاءة.

**ملاحظة حول builder:**
يجب توفير `key` فريد لكل عنصر لتمكين Flutter من تتبع العناصر أثناء إعادة الترتيب. هذا الـ `key` ضروري لـ Flutter ليعرف أي عنصر يتم سحبه وإعادة ترتيبه بشكل صحيح.

**مثال كود:**
```dart
// يجب تعريف هذه القائمة في StatefulWidget
List<String> items = List.generate(10, (index) => "العنصر ${index + 1}");

ReorderableListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index]), // مفتاح فريد إلزامي
      title: Text(items[index]),
      trailing: Icon(Icons.drag_handle),
    );
  },
  onReorder: (oldIndex, newIndex) {
    // يجب تحديث حالة القائمة هنا داخل setState
    // setState(() {
    //   if (oldIndex < newIndex) newIndex -= 1;
    //   final item = items.removeAt(oldIndex);
    //   items.insert(newIndex, item);
    // });
  },
)
```

**الاستخدامات:**
- قوائم المهام (To-Do Lists) التي يمكن إعادة ترتيبها.
- قوائم التشغيل (Playlists).
- أي قائمة تتطلب تفاعلاً من المستخدم لتغيير ترتيب العناصر.

---

## 8. NotificationListener
ويدجت يسمح لك بالاستماع إلى إشعارات التمرير (Scroll Notifications) التي تصدر من الويدجت الأبناء في الشجرة. هذه الإشعارات تنتشر للأعلى في شجرة الويدجت، مما يسمح للويدجت الأب بالاستجابة لأحداث التمرير دون الحاجة إلى `ScrollController` مباشر [10].

**مثال كود (للكشف عن الوصول لنهاية القائمة):**
```dart
NotificationListener<ScrollNotification>(
  onNotification: (scrollNotification) {
    if (scrollNotification is ScrollEndNotification &&
        scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
      print("وصلنا لنهاية القائمة! قم بتحميل المزيد...");
      return true; // يشير إلى أن الإشعار قد تم التعامل معه ومنع انتشاره لأعلى
    }
    return false; // يشير إلى أن الإشعار يجب أن يستمر في الانتشار
  },
  child: ListView.builder(
    itemCount: 20,
    itemBuilder: (context, index) => ListTile(title: Text("عنصر $index")),
  ),
)
```

**الاستخدامات:**
- تنفيذ التحميل اللانهائي (Infinite Scrolling) عند وصول المستخدم إلى نهاية القائمة.
- إظهار أو إخفاء عناصر واجهة المستخدم (مثل زر العودة للأعلى) بناءً على موضع التمرير.
- تتبع تقدم التمرير لأغراض التحليلات.

---

## 9. Scrollbar
يضيف شريط تمرير مرئي بجانب الويدجت القابل للتمرير، ويمكن أن يكون تفاعلياً، مما يسمح للمستخدم بسحب شريط التمرير للانتقال بسرعة عبر المحتوى [11].

**مثال كود:**
```dart
Scrollbar(
  thumbVisibility: true, // جعل الشريط مرئياً دائماً
  thickness: 8.0,         // سمك شريط التمرير
  radius: Radius.circular(10), // نصف قطر حواف شريط التمرير
  interactive: true,      // السماح بالتفاعل مع شريط التمرير (السحب والنقر)
  child: ListView.builder(
    itemCount: 100,
    itemBuilder: (context, index) => ListTile(title: Text("عنصر $index")),
  ),
)
```

**الاستخدامات:**
- تحسين تجربة المستخدم في القوائم الطويلة جداً، خاصة على أجهزة الكمبيوتر المكتبية.
- توفير مؤشر بصري واضح لموضع التمرير الحالي.

---

## 10. SingleChildScrollView
يستخدم لتمرير ويدجت واحد فقط عندما يتجاوز محتواه المساحة المتاحة. إنه مفيد جداً عندما يكون لديك محتوى ثابت قد يصبح أكبر من الشاشة (مثل نموذج إدخال بيانات مع لوحة مفاتيح افتراضية) [12].

**مثال كود:**
```dart
SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      TextField(decoration: InputDecoration(labelText: "الاسم")),
      SizedBox(height: 1000), // مساحة كبيرة لمحاكاة محتوى طويل
      TextField(decoration: InputDecoration(labelText: "البريد الإلكتروني")),
      ElevatedButton(onPressed: () {}, child: Text("إرسال")), 
    ],
  ),
)
```

**الاستخدامات:**
- النماذج (Forms) التي قد تتجاوز طول الشاشة عند ظهور لوحة المفاتيح.
- عرض نصوص طويلة أو محتوى ثابت لا يتطلب إعادة بناء كسولة.

---

## 11. RefreshIndicator
يوفر ميزة "السحب للتحديث" (Pull-to-Refresh) لتحديث المحتوى في الويدجت القابلة للتمرير. يظهر مؤشراً دائرياً عند السحب للأسفل [13].

**مثال كود:**
```dart
RefreshIndicator(
  onRefresh: () async {
    await Future.delayed(Duration(seconds: 2)); // محاكاة جلب بيانات من الشبكة
    // هنا يتم تحديث البيانات الفعلية في حالة التطبيق
  },
  child: ListView.builder(
    itemCount: 10,
    itemBuilder: (context, index) => ListTile(title: Text("عنصر $index")),
  ),
)
```

**الاستخدامات:**
- تحديث خلاصات الأخبار أو قوائم البريد الإلكتروني.
- جلب أحدث البيانات من الخادم في التطبيقات التي تتطلب تحديثاً دورياً.

---

## 12. SliverPersistentHeader
يستخدم لإنشاء رؤوس (Headers) تظل ثابتة أو يتغير حجمها عند التمرير داخل `CustomScrollView`. يتطلب `SliverPersistentHeaderDelegate` لتحديد سلوكه [14].

**مثال كود (تعريف Delegate):**
```dart
class MyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  MyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant MyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
           minHeight != oldDelegate.minHeight ||
           child != oldDelegate.child;
  }
}

// استخدامها داخل CustomScrollView
/*
CustomScrollView(
  slivers: [
    SliverPersistentHeader(
      pinned: true, // يثبت الرأس في الأعلى بعد أن يصل إلى الحد الأدنى لحجمه
      delegate: MyHeaderDelegate(
        minHeight: 60.0,
        maxHeight: 200.0,
        child: Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: Text("رأس ثابت/مرن", style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text("عنصر قائمة $index")),
        childCount: 50,
      ),
    ),
  ],
)
*/
```

**الاستخدامات:**
- رؤوس صفحات (AppBars) تتفاعل مع التمرير وتتغير في الحجم أو تختفي.
- أقسام ثابتة في واجهة المستخدم تظل مرئية أثناء التمرير.

---

## 13. SliverToBoxAdapter
ويدجت بسيط يسمح لك بوضع أي `BoxWidget` (مثل `Container`, `Column`, `Row`) داخل `CustomScrollView`. إنه مفيد لدمج الويدجت العادية التي لا تدعم الـ `Slivers` مباشرة مع بيئة `CustomScrollView` [15].

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(
      child: Container(
        height: 200,
        color: Colors.red,
        child: Center(child: Text("محتوى عادي داخل Sliver")), 
      ),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text("عنصر قائمة $index")),
        childCount: 20,
      ),
    ),
  ],
)
```

**الاستخدامات:**
- إضافة عناصر غير قابلة للتمرير بشكل مباشر (مثل إعلانات أو لافتات) إلى `CustomScrollView`.
- دمج الويدجت العادية مع الـ `Slivers` لإنشاء تخطيطات معقدة.

---

## 14. ScrollConfiguration
يتحكم في كيفية سلوك ويدجت التمرير في شجرة الويدجت الفرعية، مثل فيزياء التمرير (ScrollPhysics) أو سلوك السحب (drag behavior). يمكن استخدامه لتغيير السلوك الافتراضي للتمرير [16].

**مثال كود (لإزالة تأثير التوهج الزائد في Android):**
```dart
MaterialApp(
  builder: (context, child) {
    return ScrollConfiguration(
      behavior: MyScrollBehavior(),
      child: child!,
    );
  },
  home: Scaffold(
    appBar: AppBar(title: Text("Scroll Configuration")),
    body: ListView.builder(
      itemCount: 50,
      itemBuilder: (context, index) => ListTile(title: Text("عنصر $index")),
    ),
  ),
)

class MyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // يزيل تأثير التوهج الزائد (overscroll glow)
  }

  @override
  TargetPlatform get platform => TargetPlatform.android; // يمكن تحديد المنصة
}
```

**الاستخدامات:**
- تخصيص سلوك التمرير على مستوى التطبيق أو جزء منه.
- تغيير فيزياء التمرير لمنصات مختلفة (مثل iOS Bouncing أو Android Clamping).
- إزالة تأثيرات التمرير الزائدة (overscroll effects).

---

## 15. Scrollable
ويدجت منخفض المستوى يوفر نموذج التفاعل لويدجت قابل للتمرير، بما في ذلك التعرف على الإيماءات، ولكنه لا يوفر أي عرض مرئي. عادة ما يتم استخدامه من قبل الويدجت الأخرى مثل `ListView` و `GridView` كجزء من تركيبتها الداخلية [17].

**الاستخدامات:**
- بناء ويدجت تمرير مخصصة تماماً من الصفر (للمطورين المتقدمين).
- فهم كيفية عمل آليات التمرير الأساسية في Flutter.

---

## 16. CupertinoSliverNavigationBar
شريط تنقل بتصميم iOS 11 مع عناوين كبيرة (Large Titles) باستخدام الـ `Slivers`. يتفاعل هذا الشريط مع التمرير، حيث يتغير حجم العنوان من كبير إلى صغير عند التمرير [18].

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    CupertinoSliverNavigationBar(
      largeTitle: Text("العنوان الكبير"),
      middle: Text("العنوان الصغير"),
      leading: Icon(Icons.arrow_back_ios),
      trailing: Icon(Icons.settings),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text("عنصر $index")),
        childCount: 50,
      ),
    ),
  ],
)
```

**الاستخدامات:**
- بناء واجهات مستخدم بتصميم iOS أصيل.
- توفير تجربة مستخدم مألوفة لمستخدمي iOS مع رؤوس صفحات ديناميكية.

---

## 17. CupertinoSliverRefreshControl
ويدجت `Sliver` ينفذ ميزة السحب للتحديث (Pull-to-Refresh) بتصميم iOS. يوفر مؤشراً دائرياً يتفاعل مع السحب ويختفي بعد اكتمال عملية التحديث [19].

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    CupertinoSliverRefreshControl(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 2));
        // تحديث البيانات هنا
      },
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text("عنصر $index")),
        childCount: 50,
      ),
    ),
  ],
)
```

**الاستخدامات:**
- توفير تجربة سحب للتحديث متوافقة مع تصميم iOS.
- جلب البيانات الجديدة في تطبيقات iOS بشكل سلس.

---

## 18. NestedScrollView (عرض التمرير المتداخل)
يسمح بوجود مناطق تمرير متعددة متداخلة، حيث يتم ربط مواضع التمرير الخاصة بها. هذا مفيد لإنشاء تأثيرات تمرير معقدة حيث يتفاعل شريط التطبيق (AppBar) مع المحتوى القابل للتمرير [28].

### خاصية البناء (builder)
يحتوي على `headerSliverBuilder` لبناء الـ `Slivers` في الجزء العلوي، و `body` الذي يأخذ ويدجت قابلة للتمرير (مثل `ListView` أو `GridView`).

**مثال كود:**
```dart
NestedScrollView(
  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        title: Text('NestedScrollView'),
        floating: true,
        snap: true,
        expandedHeight: 200.0,
        forceElevated: innerBoxIsScrolled,
      ),
    ];
  },
  body: ListView.builder(
    itemCount: 100,
    itemBuilder: (BuildContext context, int index) {
      return ListTile(title: Text('عنصر داخلي $index'));
    },
  ),
)
```

**الاستخدامات:**
- واجهات المستخدم التي تحتوي على أشرطة تطبيقات قابلة للطي (collapsible AppBars).
- دمج قوائم متعددة أو شبكات مع رؤوس صفحات متفاعلة.

---

## 19. SliverFillRemaining
ويدجت `Sliver` يحتوي على ويدجت واحد يملأ المساحة المتبقية في منفذ العرض (Viewport) [29].

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('عنصر $index')),
        childCount: 5,
      ),
    ),
    SliverFillRemaining(
      hasScrollBody: false, // إذا كان المحتوى المتبقي لا يحتاج للتمرير
      child: Center(
        child: Text('هذا المحتوى يملأ المساحة المتبقية'),
      ),
    ),
  ],
)
```

**الاستخدامات:**
- عرض محتوى ثابت في نهاية قائمة قصيرة.
- ضمان أن جزءاً معيناً من واجهة المستخدم يملأ المساحة المتاحة بعد الـ `Slivers` الأخرى.

---

## 20. SliverFixedExtentList
ويدجت `Sliver` يضع العديد من الويدجت الأبناء ذات الحجم الثابت في مصفوفة خطية [30]. إنه أكثر كفاءة من `SliverList` عندما تكون جميع العناصر بنفس الحجم.

### خاصية البناء (delegate)
يستخدم `SliverChildBuilderDelegate` أو `SliverChildListDelegate` كـ `delegate`.

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    SliverFixedExtentList(
      itemExtent: 50.0, // يجب تحديد ارتفاع ثابت لكل عنصر
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Container(
            alignment: Alignment.center,
            color: Colors.lightBlue[100 * (index % 9)],
            child: Text('عنصر ثابت $index'),
          );
        },
        childCount: 20,
      ),
    ),
  ],
)
```

**الاستخدامات:**
- قوائم العناصر التي لها نفس الارتفاع (مثل قوائم الإعدادات).
- تحسين أداء التمرير في القوائم ذات العناصر المتجانسة.

---

## 21. SliverGrid
ويدجت `Sliver` يضع العديد من الويدجت الأبناء في ترتيب شبكي ثنائي الأبعاد [31].

### خاصية البناء (delegate)
يستخدم `SliverChildBuilderDelegate` أو `SliverChildListDelegate` كـ `delegate`.

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 4.0, // نسبة العرض إلى الطول
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Container(
            alignment: Alignment.center,
            color: Colors.teal[100 * (index % 9)],
            child: Text('شبكة $index'),
          );
        },
        childCount: 20,
      ),
    ),
  ],
)
```

**الاستخدامات:**
- عرض الصور أو المنتجات في تخطيط شبكي داخل `CustomScrollView`.
- إنشاء واجهات مستخدم شبكية مع تأثيرات تمرير مخصصة.

---

## 22. SliverList
ويدجت `Sliver` يضع العديد من الويدجت الأبناء في مصفوفة خطية [32]. إنه المكافئ لـ `ListView` داخل `CustomScrollView`.

### خاصية البناء (delegate)
يستخدم `SliverChildBuilderDelegate` أو `SliverChildListDelegate` كـ `delegate`.

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return ListTile(title: Text('عنصر قائمة $index'));
        },
        childCount: 20,
      ),
    ),
  ],
)
```

**الاستخدامات:**
- عرض قوائم خطية من العناصر داخل `CustomScrollView`.
- دمج القوائم مع الـ `Slivers` الأخرى لإنشاء تأثيرات تمرير مخصصة.

---

## 23. SliverPadding
ويدجت `Sliver` يطبق حشوة (padding) على كل جانب من جوانب `Sliver` آخر [33].

**مثال كود:**
```dart
CustomScrollView(
  slivers: [
    SliverPadding(
      padding: const EdgeInsets.all(20.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Container(
              height: 50,
              color: Colors.amber[100 * (index % 9)],
              child: Center(child: Text('عنصر $index')),
            );
          },
          childCount: 10,
        ),
      ),
    ),
  ],
)
```

**الاستخدامات:**
- إضافة مسافات داخلية حول الـ `Slivers`.
- التحكم في التباعد بين الـ `Slivers` والمحتوى المحيط.

---

## 24. ListWheelScrollView
ويدجت يعرض قائمة من العناصر في عجلة ثلاثية الأبعاد، مما يعطي تأثيراً بصرياً فريداً [34].

### خاصية البناء (builder)
يستخدم `ListWheelScrollView.builder` لإنشاء العناصر بشكل كسول.

**مثال كود:**
```dart
ListWheelScrollView.builder(
  itemExtent: 75, // ارتفاع كل عنصر
  itemBuilder: (context, index) {
    return ListTile(
      leading: Icon(Icons.star),
      title: Text('الخيار $index'),
    );
  },
  itemCount: 20,
)
```

**الاستخدامات:**
- اختيار التاريخ أو الوقت.
- قوائم الخيارات ذات التأثير البصري الجذاب.

---

## 25. TwoDimensionalScrollView (تجريبي)
ويدجت جديد (تجريبي) يسمح بالتمرير في اتجاهين (أفقي ورأسي) في نفس الوقت [35].

**مثال كود (مفهوم):**
```dart
// هذا الويدجت لا يزال تجريبياً وقد تتغير واجهة برمجة التطبيقات الخاصة به.
// TwoDimensionalScrollView(
//   delegate: TwoDimensionalChildBuilderDelegate(
//     builder: (context, xIndex, yIndex) {
//       return Container(
//         width: 100,
//         height: 100,
//         color: Colors.primaries[(xIndex + yIndex) % Colors.primaries.length],
//         child: Center(child: Text('($xIndex, $yIndex)')),
//       );
//     },
//     maxXIndex: 10,
//     maxYIndex: 10,
//   ),
// )
```

**الاستخدامات:**
- جداول البيانات الكبيرة.
- الخرائط التفاعلية أو لوحات الرسم.

---

## 26. ScrollablePositionedList
ويدجت من حزمة `scrollable_positioned_list` يسمح بالتمرير إلى عنصر معين في القائمة وتحديد موقعه بدقة [36].

### خاصية البناء (builder)
يستخدم `ScrollablePositionedList.builder` لإنشاء العناصر بشكل كسول.

**مثال كود:**
```dart
// يجب إضافة حزمة scrollable_positioned_list إلى pubspec.yaml
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// ItemScrollController itemScrollController = ItemScrollController();
// ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

// ScrollablePositionedList.builder(
//   itemCount: 500,
//   itemBuilder: (context, index) => ListTile(title: Text('عنصر $index')),
//   itemScrollController: itemScrollController,
//   itemPositionsListener: itemPositionsListener,
// )
```

**الاستخدامات:**
- تطبيقات الدردشة التي تحتاج إلى التمرير إلى رسالة معينة.
- قوائم المحتوى الطويلة التي تتطلب التنقل السريع إلى أقسام محددة.

---

## 27. ExtendedGridView / ExtendedListView
هذه الويدجت تأتي من حزمة `extended_image` أو `extended_list` وتوفر ميزات إضافية مثل التحميل المسبق للصور، أو تأثيرات التمرير المخصصة [37].

**مثال كود (مفهوم):**
```dart
// يجب إضافة حزمة extended_list إلى pubspec.yaml
// import 'package:extended_list/extended_list.dart';

// ExtendedListView.builder(
//   extendedListDelegate: ExtendedListDelegate(
//     collectGarbage: (List<int> garbages) {
//       // منطق تنظيف الذاكرة
//     },
//     // ... خصائص أخرى
//   ),
//   itemBuilder: (context, index) => ListTile(title: Text('عنصر $index')),
//   itemCount: 100,
// )
```

**الاستخدامات:**
- تحسين أداء القوائم التي تحتوي على صور أو محتوى معقد.
- إضافة ميزات متقدمة لإدارة الذاكرة والتحميل.

---

## 28. SliverAnimatedList
ويدجت `Sliver` يسمح بإضافة أو إزالة العناصر من القائمة مع تأثيرات حركية (animations) [38].

### خاصية البناء (builder)
يستخدم `itemBuilder` لإنشاء الويدجت لكل عنصر، و `AnimatedListState` للتحكم في الإضافات والإزالات.

**مثال كود (مفهوم):**
```dart
// final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
// List<String> _data = ['Item 1', 'Item 2', 'Item 3'];

// CustomScrollView(
//   slivers: [
//     SliverAnimatedList(
//       key: _listKey,
//       initialItemCount: _data.length,
//       itemBuilder: (context, index, animation) {
//         return SizeTransition(
//           sizeFactor: animation,
//           child: ListTile(title: Text(_data[index])),
//         );
//       },
//     ),
//   ],
// )

// // لإضافة عنصر:
// _listKey.currentState?.insertItem(index);
// // لإزالة عنصر:
// _listKey.currentState?.removeItem(index, (context, animation) => SizeTransition(...));
```

**الاستخدامات:**
- قوائم المهام أو الإشعارات التي تتطلب تحديثات مرئية سلسة.
- أي قائمة تحتاج إلى إضافة أو إزالة عناصر مع تأثيرات حركية.

---

## 29. SliverPrototypeExtentList
ويدجت `Sliver` يضع العديد من الويدجت الأبناء في مصفوفة خطية، ويستخدم `prototypeItem` لتحديد حجم العناصر بدلاً من `itemExtent` الثابت [39]. هذا مفيد عندما تكون العناصر ذات أحجام مختلفة ولكنها تتبع نمطاً معيناً.

### خاصية البناء (delegate)
يستخدم `SliverChildBuilderDelegate` أو `SliverChildListDelegate` كـ `delegate`.

**مثال كود (مفهوم):**
```dart
// CustomScrollView(
//   slivers: [
//     SliverPrototypeExtentList(
//       prototypeItem: const ListTile(title: Text('Prototype Item')),
//       delegate: SliverChildBuilderDelegate(
//         (BuildContext context, int index) {
//           return ListTile(title: Text('عنصر $index'));
//         },
//         childCount: 20,
//       ),
//     ),
//   ],
// )
```

**الاستخدامات:**
- قوائم العناصر التي تختلف في المحتوى ولكن لها نفس التخطيط الأساسي.
- تحسين أداء التمرير عندما يكون حساب حجم كل عنصر مكلفاً.

---

## 30. ScrollableListFilter
ويدجت من حزمة `scrollable_list_filter` يوفر قائمة قابلة للتمرير مع خيارات تصفية (filtering) مدمجة [40].

**مثال كود (مفهوم):**
```dart
// يجب إضافة حزمة scrollable_list_filter إلى pubspec.yaml
// import 'package:scrollable_list_filter/scrollable_list_filter.dart';

// ScrollableListFilter(
//   filters: [
//     ListFilterItem(label: 'Filter 1', id: '1'),
//     ListFilterItem(label: 'Filter 2', id: '2'),
//   ],
//   onItemSelected: (selected) {
//     print('Selected: $selected');
//   },
//   listChild: ListView.builder(
//     itemCount: 50,
//     itemBuilder: (context, index) => ListTile(title: Text('عنصر $index')),
//   ),
// )
```

**الاستخدامات:**
- قوائم المنتجات أو البيانات التي تتطلب خيارات تصفية متعددة.
- واجهات المستخدم التي تحتاج إلى تصفية ديناميكية للمحتوى.

---

## أنواع ScrollPhysics (فيزياء التمرير) [27]

تحدد `ScrollPhysics` كيفية تصرف التمرير عند الوصول إلى حدود المحتوى. يمكن دمجها أو تخصيصها لإنشاء سلوكيات فريدة.

| النوع | الوصف | الاستخدامات |
| :--- | :--- | :--- |
| `AlwaysScrollableScrollPhysics` | يسمح بالتمرير دائماً، حتى لو كان المحتوى أصغر من الـ `Viewport`. | مفيد عندما تريد تمكين السحب للتحديث حتى لو كانت القائمة قصيرة. |
| `NeverScrollableScrollPhysics` | يمنع التمرير تماماً. | لتعطيل التمرير في ويدجت معين، أو عندما يكون التمرير يتم التحكم فيه بواسطة ويدجت أب. |
| `BouncingScrollPhysics` | يوفر تأثير الارتداد (bounce) عند الوصول إلى حدود التمرير، وهو السلوك الافتراضي في iOS. | لتطبيقات iOS أو لتقليد سلوك iOS. |
| `ClampingScrollPhysics` | يمنع التمرير بعد حدود المحتوى، وهو السلوك الافتراضي في Android. | لتطبيقات Android أو لتقليد سلوك Android. |
| `FixedExtentScrollPhysics` | يستخدم مع `FixedExtentScrollController` لضمان أن كل عنصر يحتل نفس المساحة بالضبط. | في `PageView` أو `ListWheelScrollView` حيث تكون العناصر ذات حجم ثابت. |
| `PageScrollPhysics` | يضمن أن التمرير يتوقف دائماً عند حدود الصفحة، وهو السلوك الافتراضي لـ `PageView`. | يستخدم تلقائياً مع `PageView`، ويمكن استخدامه لتطبيق سلوك الصفحات على ويدجت تمرير أخرى. |
| `ScrollPhysics.applyTo` | طريقة لدمج أنواع مختلفة من `ScrollPhysics`. | لإنشاء سلوك تمرير مخصص يجمع بين خصائص متعددة. |

**مثال على استخدام ScrollPhysics:**
```dart
ListView.builder(
  physics: BouncingScrollPhysics(), // تطبيق فيزياء الارتداد
  itemCount: 20,
  itemBuilder: (context, index) => ListTile(title: Text("عنصر $index")),
)
```

---

## نصائح للأداء (Performance Tips)
1. **استخدم `builder` دائماً:** للقوائم التي تزيد عن 20 عنصراً، تجنب استخدام `ListView(children: [])` أو `Column` مع قائمة كبيرة من الويدجت. استخدام `builder` يضمن بناء العناصر بشكل كسول (lazily) [1].
2. **تحديد `itemExtent`:** إذا كانت جميع العناصر بنفس الطول، فإن تحديد `itemExtent` في `ListView` يحسن سرعة التمرير بشكل كبير لأن Flutter لن يحتاج لحساب طول كل عنصر، مما يقلل من عمليات التخطيط (layout calculations) [20].
3. **تجنب `ShrinkWrap: true`:** حاول تجنب استخدام `shrinkWrap: true` في `ListView` أو `GridView` لأنه يعطل ميزة التمرير الفعال ويجبر Flutter على حساب حجم جميع العناصر دفعة واحدة، مما يؤثر على الأداء بشكل سلبي [21]. استخدم `CustomScrollView` مع `Slivers` بدلاً من ذلك إذا كنت بحاجة إلى دمج قوائم متعددة.
4. **استخدم `RepaintBoundary`:** للعناصر المعقدة داخل القائمة لتقليل عمليات إعادة الرسم غير الضرورية. `RepaintBoundary` يقوم بعزل جزء من شجرة الويدجت، مما يعني أن تغييرات الرسم داخل هذا الجزء لا تتسبب في إعادة رسم الأجزاء الأخرى [22].
5. **التحكم في `cacheExtent`:** لزيادة سلاسة التمرير عن طريق تحميل العناصر قبل ظهورها على الشاشة بمسافة معينة. القيمة الافتراضية هي 250 بكسل، ولكن يمكن تعديلها لتحسين التجربة بناءً على حجم العناصر [23].
6. **استخدام `const` قدر الإمكان:** إذا كانت عناصر القائمة ثابتة ولا تتغير، استخدم `const` مع الويدجت داخل `itemBuilder` لتحسين الأداء عن طريق منع إعادة بناء الويدجت غير الضرورية.
7. **تحسين `itemBuilder`:** اجعل دالة `itemBuilder` خفيفة قدر الإمكان. تجنب إجراء عمليات حسابية معقدة أو جلب بيانات داخلها مباشرة.
8. **استخدام `Key`s:** استخدم `Key`s فريدة للعناصر في القوائم الديناميكية (خاصة في `ReorderableListView`) لمساعدة Flutter على تحديد العناصر وإعادة استخدامها بكفاءة [9].

---

## المراجع (References)
[1] [ListView.builder vs ListView: Is There a Difference? - dev.to](https://dev.to/gguedes/listviewbuilder-vs-listview-is-there-a-difference-plh)
[2] [SliverChildBuilderDelegate class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverChildBuilderDelegate-class.html)
[3] [GridView class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/GridView-class.html)
[4] [A Deep Dive Into PageView Widget in Flutter - Medium](https://medium.com/@knoo/a-deep-dive-into-pageview-widget-in-flutter-489532b9b5b6)
[5] [Building scrolling experiences in Flutter - YouTube](https://www.youtube.com/watch?v=YY-_yrZdjGc)
[6] [SliverChildListDelegate class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverChildListDelegate-class.html)
[7] [CarouselView - Flutter documentation](https://docs.flutter.dev/ui/widgets/scrolling#carouselview)
[8] [DraggableScrollableSheet class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/DraggableScrollableSheet-class.html)
[9] [ReorderableListView class - material library - Dart API](https://api.flutter.dev/flutter/material/ReorderableListView-class.html)
[10] [NotificationListener Widget in Flutter - GeeksforGeeks](https://www.geeksforgeeks.org/flutter/notificationlistener-widget-in-flutter/)
[11] [Scrollbar class - material library - Dart API](https://api.flutter.dev/flutter/material/Scrollbar-class.html)
[12] [SingleChildScrollView class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html)
[13] [RefreshIndicator class - material library - Dart API](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html)
[14] [SliverPersistentHeader class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverPersistentHeader-class.html)
[15] [SliverToBoxAdapter class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html)
[16] [ScrollConfiguration class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/ScrollConfiguration-class.html)
[17] [Scrollable class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/Scrollable-class.html)
[18] [CupertinoSliverNavigationBar class - cupertino library - Dart API](https://api.flutter.dev/flutter/cupertino/CupertinoSliverNavigationBar-class.html)
[19] [CupertinoSliverRefreshControl class - cupertino library - Dart API](https://api.flutter.dev/flutter/cupertino/CupertinoSliverRefreshControl-class.html)
[20] [Flutter Performance Tip: ListView vs ListView.builder Performance Impact - LinkedIn](https://www.linkedin.com/posts/talha-saleem-55176b44_flutter-mobiledevelopment-performanceoptimization-activity-7424051157859192833-vWuR)
[21] [Why ListView Can Hurt Your App\'s Performance (and What to Use Instead) - Medium](https://medium.com/@bestaouiaymene/why-listview-can-hurt-your-apps-performance-and-what-to-use-instead-c0f4f560f45c)
[22] [Flutter: Understanding RepaintBoundary - Medium](https://medium.com/@sarvesh.m.mishra/flutter-understanding-repaintboundary-1e4a2e1c2e1c)
[23] [Flutter ListView.builder cacheExtent - Stack Overflow](https://stackoverflow.com/questions/54328666/flutter-pageview-show-preview-of-page-on-left-and-right)
[24] [RenderViewport class - rendering library - Dart API](https://api.flutter.dev/flutter/rendering/RenderViewport-class.html)
[25] [RenderSliver class - rendering library - Dart API](https://api.flutter.dev/flutter/rendering/RenderSliver-class.html)
[26] [ScrollController class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/ScrollController-class.html)
[27] [ScrollPhysics class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/ScrollPhysics-class.html)
[28] [NestedScrollView class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html)
[29] [SliverFillRemaining class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverFillRemaining-class.html)
[30] [SliverFixedExtentList class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverFixedExtentList-class.html)
[31] [SliverGrid class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverGrid-class.html)
[32] [SliverList class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverList-class.html)
[33] [SliverPadding class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverPadding-class.html)
[34] [ListWheelScrollView class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/ListWheelScrollView-class.html)
[35] [TwoDimensionalScrollView class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/TwoDimensionalScrollView-class.html)
[36] [scrollable_positioned_list | Flutter Package](https://pub.dev/packages/scrollable_positioned_list)
[37] [extended_list | Flutter Package](https://pub.dev/packages/extended_list)
[38] [SliverAnimatedList class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverAnimatedList-class.html)
[39] [SliverPrototypeExtentList class - widgets library - Dart API](https://api.flutter.dev/flutter/widgets/SliverPrototypeExtentList-class.html)
[40] [scrollable_list_filter | Flutter Package](https://pub.dev/packages/scrollable_list_filter)
