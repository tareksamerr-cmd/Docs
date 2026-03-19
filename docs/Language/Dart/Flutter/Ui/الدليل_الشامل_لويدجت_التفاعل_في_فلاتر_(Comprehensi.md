# الدليل الشامل لويدجت التفاعل في فلاتر (Comprehensive Guide to Interaction Widgets in Flutter)

يعد التفاعل جوهر تجربة المستخدم في تطبيقات الهواتف. يوفر إطار العمل **فلاتر** (Flutter) مجموعة غنية من **الويدجت** (Widgets) التي تتجاوز مجرد الأزرار البسيطة لتشمل السحب، الإيماءات المعقدة، والتفاعلات المتكيفة مع المنصة.

في هذا الدليل، قمنا بجمع 16 ويدجت تفاعلياً، مع تعزيز الشرح بمعلومات من الوثائق الرسمية ومجتمعات المطورين لتقديم أفضل الممارسات وأمثلة برمجية شاملة.

---

## 1. كاشف الإيماءات (GestureDetector)
يعد **GestureDetector** العمود الفقري للتفاعل في Flutter. على عكس الأزرار الجاهزة، يسمح لك هذا الويدجت بتحويل أي عنصر مرئي (مثل صورة أو نص) إلى عنصر تفاعلي يستجيب لأكثر من 25 نوعاً من الإيماءات.

### مثال متقدم:
```dart
GestureDetector(
  onTap: () => print('نقرة واحدة'),
  onDoubleTap: () => print('نقرة مزدوجة'),
  onLongPress: () => print('ضغط مطول'),
  onPanUpdate: (details) => print('يتم السحب في الإحداثيات: ${details.localPosition}'),
  child: Container(
    width: 200, height: 200,
    color: Colors.blue,
    child: Center(child: Text('تفاعل معي بكافة الطرق')),
  ),
)
```

---

## 2. عارض تفاعلي (InteractiveViewer)
أُضيف **InteractiveViewer** في إصدارات Flutter الحديثة لتسهيل بناء واجهات تدعم التكبير (Zoom) والتحريك (Pan). يُستخدم بكثرة في عارضي الصور، الخرائط، وحتى الجداول الضخمة.

### مثال:
```dart
InteractiveViewer(
  boundaryMargin: EdgeInsets.all(20.0),
  minScale: 0.5,
  maxScale: 5.0,
  child: Image.network('https://example.com/map.png'),
)
```

---

## 3. ويدجت قابل للسحب (Dismissible)
يُستخدم **Dismissible** لإنشاء نمط "السحب للحذف" المشهور في تطبيقات البريد. يدعم هذا الويدجت خلفيات مختلفة حسب اتجاه السحب (يمين/يسار) وتأكيدات قبل الحذف.

### مثال:
```dart
Dismissible(
  key: UniqueKey(),
  background: Container(color: Colors.green, child: Icon(Icons.archive)),
  secondaryBackground: Container(color: Colors.red, child: Icon(Icons.delete)),
  onDismissed: (direction) {
    if (direction == DismissDirection.endToStart) print('تم الحذف');
  },
  child: ListTile(title: Text('اسحب لليسار للحذف أو اليمين للأرشفة')),
)
```

---

## 4. ويدجت قابل للجر (Draggable) و هدف السحب (DragTarget)
هذا الثنائي يسمح ببناء واجهات "السحب والإسقاط" (Drag and Drop). **Draggable** هو العنصر الذي يتحرك، و **DragTarget** هو المكان الذي يستقبل البيانات.

### مثال:
```dart
// العنصر القابل للسحب
Draggable<Color>(
  data: Colors.red,
  child: Container(width: 50, height: 50, color: Colors.red),
  feedback: Container(width: 60, height: 60, color: Colors.red.withOpacity(0.5)),
  childWhenDragging: Container(width: 50, height: 50, color: Colors.grey),
)

// الهدف
DragTarget<Color>(
  onAccept: (color) => print('تم تغيير اللون إلى $color'),
  builder: (context, candidateData, rejectedData) => Container(width: 100, height: 100, color: Colors.black12),
)
```

---

## 5. ويدجت امتصاص المؤشر (AbsorbPointer)
يُستخدم **AbsorbPointer** لتعطيل التفاعل مع شجرة كاملة من الويدجت. الفرق بينه وبين الإغلاق العادي هو أنه يمنع اللمس من المرور حتى لو كان هناك عنصر تفاعلي خلفه.

### مثال:
```dart
AbsorbPointer(
  absorbing: true, // تغييرها لـ false لتمكين التفاعل
  child: ElevatedButton(onPressed: () {}, child: Text('لن أعمل حالياً')),
)
```

---

## 6. ويدجت تجاهل المؤشر (IgnorePointer)
يشبه السابق لكن مع فرق جوهري: **IgnorePointer** يجعل الويدجت "شفافاً" للمس، أي أن اللمسة ستمر من خلاله لتصيب الويدجت الذي يقع خلفه في طبقات الشاشة.

### مثال:
```dart
IgnorePointer(
  ignoring: true,
  child: FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
)
```

---

## 7. ورقة قابلة للسحب والتمرير (DraggableScrollableSheet)
تُستخدم لبناء "القوائم السفلية" (Bottom Sheets) التي تتوسع عند سحبها. هي مثالية لعرض تفاصيل إضافية دون مغادرة الشاشة الحالية.

### مثال:
```dart
DraggableScrollableSheet(
  initialChildSize: 0.3,
  minChildSize: 0.1,
  maxChildSize: 0.8,
  builder: (context, scrollController) => ListView.builder(
    controller: scrollController,
    itemCount: 50,
    itemBuilder: (context, index) => ListTile(title: Text('عنصر $index')),
  ),
)
```

---

## 8. ويدجت البطل (Hero)
يوفر **Hero** تجربة انتقال بصرية مذهلة بين الشاشات عن طريق ربط عنصرين بنفس الوسم (Tag). فلاتر يقوم تلقائياً بحساب مسار الحركة والحجم أثناء الانتقال.

### مثال:
```dart
// الشاشة أ
Hero(tag: 'user-avatar', child: CircleAvatar(radius: 20)),
// الشاشة ب
Hero(tag: 'user-avatar', child: CircleAvatar(radius: 80)),
```

---

## 9. الموجه (Navigator)
رغم أنه يُنظر إليه كأداة تنقل، إلا أن **Navigator** هو ويدجت تفاعلي يدير "كدسة" الشاشات. الإصدارات الحديثة (Navigator 2.0) تتيح تحكماً كاملاً مبنياً على الحالة (State-driven).

### مثال:
```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => DetailsPage()),
);
```

---

## 10. حقل النص (TextField)
أكثر ويدجت تفاعلي تعقيداً في فلاتر. يدعم **TextField** التحكم في لوحة المفاتيح، التنسيق التلقائي، والتحقق من البيانات.

### مثال:
```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'البريد الإلكتروني',
    prefixIcon: Icon(Icons.email),
  ),
  keyboardType: TextInputType.emailAddress,
)
```

---

## 11. زر الإجراء العائم (FloatingActionButton)
وفقاً لفلسفة تصميم Material، يمثل **FloatingActionButton** الإجراء الرئيسي في التطبيق. يمكن أن يكون دائرياً، ممتداً (Extended)، أو حتى صغيراً.

### مثال:
```dart
FloatingActionButton.extended(
  onPressed: () {},
  label: Text('إضافة طلب'),
  icon: Icon(Icons.add),
)
```

---

## 12. المنزلق (Slider)
يُستخدم **Slider** لاختيار قيم عددية ضمن نطاق. يمكن تخصيص شكله بالكامل باستخدام `SliderTheme`.

### مثال:
```dart
Slider(
  value: _currentValue,
  min: 0, max: 100,
  divisions: 10,
  label: _currentValue.round().toString(),
  onChanged: (value) => setState(() => _currentValue = value),
)
```

---

## 13. المفتاح (Switch)
ويدجت تفاعلي بسيط للتبديل بين حالتين. في فلاتر، يتوفر بنسختين: `Switch` (Material) و `CupertinoSwitch` (iOS).

### مثال:
```dart
Switch.adaptive( // يتغير شكله حسب نظام التشغيل
  value: _isDark,
  onChanged: (val) => setState(() => _isDark = val),
)
```

---

## 14. زر التجزئة (SegmentedButton)
بديل حديث لمربعات الاختيار والـ Radio Buttons، حيث يسمح باختيار خيار واحد أو أكثر من مجموعة أزرار متصلة.

### مثال:
```dart
SegmentedButton<int>(
  segments: [
    ButtonSegment(value: 1, label: Text('يومي')),
    ButtonSegment(value: 2, label: Text('شهري')),
  ],
  selected: {2},
  onSelectionChanged: (newSelection) => print(newSelection),
)
```

---

## 15. ويدجت القائمة المنزلقة (CupertinoPicker)
من مصادر تصميم iOS، يوفر **CupertinoPicker** عجلة تمرير تفاعلية لاختيار القيم، وهي تجربة مستخدم مفضلة في تطبيقات آيفون.

### مثال:
```dart
CupertinoPicker(
  itemExtent: 32.0,
  onSelectedItemChanged: (index) {},
  children: [Text('خيار 1'), Text('خيار 2')],
)
```

---

## 16. ويدجت السحب المطول (LongPressDraggable)
هذا الويدجت هو نسخة خاصة من **Draggable**، حيث لا يبدأ السحب إلا بعد ضغطة مطولة. يُستخدم بكثرة في إعادة ترتيب القوائم أو نقل الأيقونات في الشاشة الرئيسية.

### مثال:
```dart
LongPressDraggable<String>(
  data: 'item_1',
  child: Icon(Icons.grid_view),
  feedback: Icon(Icons.grid_view, size: 40, color: Colors.blue),
)
```
---
*تم إعداد هذا الدليل بناءً على توثيقات فلاتر الرسمية وأفضل الممارسات من مجتمعات المطورين (Medium, Dev.to).*
