# توثيق Layout Widgets في Flutter

## فهم نظام التخطيط في Flutter: القيود والأحجام (Constraints and Sizes)

لفهم كيفية عمل الـ Layout Widgets في Flutter بشكل فعال، من الضروري استيعاب المبادئ الأساسية لنظام التخطيط. يعتمد Flutter على نموذج تخطيط قوي ومحدد يُعرف باسم "القيود تذهب لأسفل، والأحجام تذهب لأعلى" (Constraints go down, Sizes go up). هذا المبدأ يحكم كيفية تحديد حجم وموضع الـ widgets في شجرة الـ widgets.

### مبدأ "Constraints go down, Sizes go up"

1.  **القيود تذهب لأسفل (Constraints go down):**
    *   عندما يقوم الـ widget الأصل (parent widget) بتخطيط عنصر فرعي (child widget)، فإنه يمرر مجموعة من القيود (constraints) إلى هذا العنصر الفرعي. هذه القيود تحدد الحد الأدنى والأقصى للعرض والارتفاع الذي يمكن للعنصر الفرعي أن يشغله.
    *   لا يمكن للعنصر الفرعي أن يتجاوز هذه القيود. يجب أن يختار حجمًا يقع ضمن النطاق المحدد بواسطة الأصل.

2.  **الأحجام تذهب لأعلى (Sizes go up):**
    *   بعد أن يتلقى العنصر الفرعي القيود من الأصل، يقوم هو نفسه بتحديد حجمه الخاص (size) بناءً على هذه القيود ومحتواه الخاص (إذا كان لديه محتوى).
    *   ثم يقوم العنصر الفرعي بإبلاغ الأصل بحجمه المختار. لا يمكن للعنصر الفرعي أن يفرض حجمًا على الأصل؛ بل يخبره فقط بالحجم الذي اختاره.

3.  **الموضع يحدده الأصل (Parent positions children):**
    *   بمجرد أن يعرف الأصل حجم العنصر الفرعي، يكون مسؤولاً عن تحديد موضع هذا العنصر الفرعي داخل مساحته الخاصة.

**الآثار المترتبة على هذا المبدأ:**

*   **التخطيط من الأعلى للأسفل:** يتم تحديد القيود من الأصل إلى العنصر الفرعي.
*   **تحديد الحجم من الأسفل للأعلى:** يتم تحديد الحجم من العنصر الفرعي إلى الأصل.
*   **التحكم في الحجم:** الـ widget الأصل هو الذي يحدد القيود، والعنصر الفرعي هو الذي يختار حجمه ضمن تلك القيود. لا يمكن للعنصر الفرعي أن يحدد حجمه بشكل مطلق دون مراعاة قيود الأصل.

**مثال توضيحي:**

تخيل `Container` (الأصل) يحتوي على `Text` (العنصر الفرعي):

*   `Container` يمرر قيودًا إلى `Text` (على سبيل المثال، الحد الأقصى للعرض هو 200 بكسل).
*   `Text` يختار حجمه بناءً على هذه القيود ومحتواه (على سبيل المثال، إذا كان النص قصيرًا، فقد يختار عرضًا أقل من 200 بكسل).
*   `Text` يبلغ `Container` بحجمه المختار.
*   `Container` يضع `Text` داخل مساحته.

فهم هذا المبدأ أمر بالغ الأهمية لتجنب الأخطاء الشائعة مثل "RenderFlex overflowed" أو "BoxConstraints has non-finite width/height"، ولتصميم تخطيطات مرنة ومتجاوبة.

---
هذا المستند يقدم توثيقًا شاملاً لـ Layout Widgets في Flutter، مع التركيز على الخصائص الرئيسية والأمثلة البرمجية للـ widgets الأكثر استخدامًا، بالإضافة إلى نظرة عامة على الـ widgets الأخرى.

## الـ Widgets الأساسية لتخطيط المحتوى

### 1. GridView

**الوصف:** `GridView` هي ويدجت تعرض عناصرها الفرعية (children) في شبكة ثنائية الأبعاد قابلة للتمرير. إنها واحدة من أكثر الـ widgets مرونة لعرض البيانات الشبكية، وتأتي مع مُحسِّنات أداء مدمجة للقوائم الطويلة.

#### أنواع `GridView`

1.  **`GridView.count`**: الأبسط استخدامًا. ينشئ شبكة بعدد ثابت من الأعمدة (`crossAxisCount`).
2.  **`GridView.extent`**: ينشئ شبكة حيث يكون لكل عنصر حد أقصى للعرض (`maxCrossAxisExtent`). يتغير عدد الأعمدة تلقائيًا بناءً على عرض الشاشة، مما يجعله مثاليًا للتخطيطات المتجاوبة.
3.  **`GridView.builder`**: الخيار الأكثر كفاءة للقوائم الكبيرة أو اللانهائية. يقوم ببناء العناصر عند الطلب (lazily) أثناء التمرير، مما يوفر الذاكرة ووقت المعالجة.
4.  **`GridView.custom`**: يمنحك أقصى درجات التحكم، حيث تستخدم `SliverChildDelegate` مخصصًا لتحديد كيفية بناء العناصر.

**الخواص الرئيسية (بتعمق):**

*   **`gridDelegate`**: (مطلوب) يحدد هندسة الشبكة. هذا هو قلب `GridView`.
    *   `SliverGridDelegateWithFixedCrossAxisCount`: يُستخدم مع `GridView.count` أو `GridView.builder`. يحدد عددًا ثابتًا من الأعمدة (`crossAxisCount`). يمكنك التحكم في نسبة العرض إلى الارتفاع (`childAspectRatio`) والمسافات (`mainAxisSpacing`, `crossAxisSpacing`).
    *   `SliverGridDelegateWithMaxCrossAxisExtent`: يُستخدم مع `GridView.extent` أو `GridView.builder`. يحدد أقصى عرض مسموح به لكل عنصر (`maxCrossAxisExtent`). يقوم Flutter بحساب عدد الأعمدة الذي يمكن وضعه في المساحة المتاحة.
*   **`scrollDirection`**: اتجاه التمرير، إما `Axis.vertical` (افتراضي) أو `Axis.horizontal`.
*   **`reverse`**: إذا كانت `true`، يتم عكس اتجاه التمرير ومحتوى الشبكة.
*   **`controller`**: `ScrollController` للتحكم في موضع التمرير برمجيًا.
*   **`primary`**: إذا كانت `true`، فإن `GridView` ستكون مرتبطة بـ `PrimaryScrollController` الخاص بالتطبيق. يجب أن يكون هناك `ScrollView` أساسي واحد فقط لكل `Scaffold`.
*   **`physics`**: تحدد فيزياء التمرير. على سبيل المثال، `BouncingScrollPhysics` (تأثير الارتداد على iOS) أو `ClampingScrollPhysics` (تأثير التوقف على Android).
*   **`shrinkWrap`**: إذا كانت `true`، فإن حجم `GridView` في اتجاه التمرير سيتحدد بمجموع أحجام عناصرها. هذا مفيد عند وضع `GridView` داخل `Column`، ولكنه يأتي على حساب الأداء لأنه يتطلب حساب حجم جميع العناصر مرة واحدة.
*   **`padding`**: مسافة بادئة حول منطقة التمرير بأكملها.
*   **`itemBuilder`**: (لـ `GridView.builder`) دالة تُستدعى لبناء كل عنصر في الشبكة. تتلقى `BuildContext` و `index`.
*   **`itemCount`**: (لـ `GridView.builder`) العدد الإجمالي للعناصر في الشبكة.
*   **`cacheExtent`**: يحدد مقدار المساحة خارج منفذ العرض (viewport) التي يجب أن يتم تخزينها مؤقتًا (caching). زيادة هذه القيمة يمكن أن تحسن أداء التمرير على حساب استخدام الذاكرة.

#### حالات الاستخدام (Use Cases)

*   **معارض الصور (Photo Galleries):** عرض الصور في شبكة متساوية.
*   **قوائم المنتجات (Product Catalogs):** عرض المنتجات مع صورها وأسعارها في تطبيقات التجارة الإلكترونية.
*   **لوحات التحكم (Dashboards):** عرض بطاقات معلومات أو إحصائيات مختلفة.
*   **تطبيقات الموسيقى/الفيديو:** عرض أغلفة الألبومات أو ملصقات الأفلام.

#### نصائح للأداء

*   **استخدم `GridView.builder` دائمًا** للقوائم التي تحتوي على أكثر من عدد قليل من العناصر. هذا يضمن أن العناصر التي تقع خارج الشاشة لا يتم بناؤها أو استهلاكها للذاكرة.
*   **تجنب `shrinkWrap: true`** مع القوائم الطويلة، لأنه يبطل ميزة البناء الكسول (lazy building) لـ `GridView.builder`.
*   **استخدم `const`** مع العناصر الفرعية (child widgets) التي لا تتغير لتمكين Flutter من إعادة استخدامها وتجنب إعادة بنائها بشكل غير ضروري.

**مثال:**

```dart
import 'package:flutter/material.dart';

class GridViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GridView Example')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // عدد الأعمدة
          crossAxisSpacing: 10.0, // المسافة بين الأعمدة
          mainAxisSpacing: 10.0, // المسافة بين الصفوف
          childAspectRatio: 1.0, // نسبة العرض إلى الارتفاع لكل عنصر
        ),
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.teal[100 * (index % 9)],
            child: Center(
              child: Text(
                'Item $index',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: GridViewExample()));
}
```

### 2. ListView

**الوصف:** `ListView` هي ويدجت تعرض قائمة خطية قابلة للتمرير من الـ widgets. إنها الـ widget الأكثر استخدامًا للتمرير في Flutter وتوفر طرقًا متعددة لإنشاء قوائم فعالة.

#### أنواع `ListView`

1.  **`ListView` (الافتراضي)**: ينشئ قائمة من الـ widgets الفرعية الصريحة. مناسب للقوائم القصيرة التي لا يتغير عدد عناصرها كثيرًا.
2.  **`ListView.builder`**: الخيار الأكثر كفاءة للقوائم الطويلة أو اللانهائية. يقوم ببناء العناصر عند الطلب (lazily) أثناء التمرير، مما يحسن الأداء ويقلل استهلاك الذاكرة.
3.  **`ListView.separated`**: ينشئ قائمة مع فاصل (separator) بين كل عنصر وآخر. مفيد لإضافة خطوط فاصلة أو مسافات بين عناصر القائمة.
4.  **`ListView.custom`**: يمنحك أقصى درجات التحكم، حيث تستخدم `SliverChildDelegate` مخصصًا لتحديد كيفية بناء العناصر.

**الخواص الرئيسية (بتعمق):**

*   **`scrollDirection`**: اتجاه التمرير، إما `Axis.vertical` (افتراضي) أو `Axis.horizontal`.
*   **`reverse`**: إذا كانت `true`، يتم عكس اتجاه التمرير ومحتوى القائمة.
*   **`controller`**: `ScrollController` للتحكم في موضع التمرير برمجيًا (مثل التمرير إلى عنصر معين أو الاستماع إلى أحداث التمرير).
*   **`primary`**: إذا كانت `true`، فإن `ListView` ستكون مرتبطة بـ `PrimaryScrollController` الخاص بالتطبيق. يجب أن يكون هناك `ScrollView` أساسي واحد فقط لكل `Scaffold`.
*   **`physics`**: تحدد فيزياء التمرير. على سبيل المثال، `BouncingScrollPhysics` (تأثير الارتداد على iOS) أو `ClampingScrollPhysics` (تأثير التوقف على Android). يمكن أيضًا استخدام `NeverScrollableScrollPhysics` لمنع التمرير.
*   **`shrinkWrap`**: إذا كانت `true`، فإن حجم `ListView` في اتجاه التمرير سيتحدد بمجموع أحجام عناصرها. هذا مفيد عند وضع `ListView` داخل `Column` أو `Row`، ولكنه يأتي على حساب الأداء لأنه يتطلب حساب حجم جميع العناصر مرة واحدة.
*   **`padding`**: مسافة بادئة حول منطقة التمرير بأكملها.
*   **`itemExtent`**: إذا تم تعيين هذه الخاصية، فإن جميع العناصر في القائمة سيكون لها نفس الارتفاع (أو العرض إذا كان `scrollDirection` أفقيًا). هذا يحسن الأداء بشكل كبير لأنه لا يتطلب من Flutter حساب حجم كل عنصر على حدة.
*   **`prototypeItem`**: بديل لـ `itemExtent`، حيث يتم استخدام `prototypeItem` لحساب حجم العناصر بشكل فعال دون الحاجة إلى تحديد `itemExtent` يدويًا.
*   **`itemBuilder`**: (لـ `ListView.builder` و `ListView.separated`) دالة تُستدعى لبناء كل عنصر في القائمة. تتلقى `BuildContext` و `index`.
*   **`separatorBuilder`**: (لـ `ListView.separated`) دالة تُستدعى لبناء الفاصل بين العناصر. تتلقى `BuildContext` و `index`.
*   **`itemCount`**: (لـ `ListView.builder` و `ListView.separated`) العدد الإجمالي للعناصر في القائمة.
*   **`cacheExtent`**: يحدد مقدار المساحة خارج منفذ العرض (viewport) التي يجب أن يتم تخزينها مؤقتًا (caching). زيادة هذه القيمة يمكن أن تحسن أداء التمرير على حساب استخدام الذاكرة.

#### حالات الاستخدام (Use Cases)

*   **قوائم الأخبار (News Feeds):** عرض مقالات الأخبار أو منشورات المدونات.
*   **قوائم الدردشة (Chat Lists):** عرض رسائل الدردشة.
*   **قوائم الإعدادات (Settings Menus):** عرض خيارات الإعدادات المختلفة.
*   **قوائم المهام (To-Do Lists):** عرض المهام القابلة للتمرير.

#### نصائح للأداء

*   **استخدم `ListView.builder` دائمًا** للقوائم التي تحتوي على عدد كبير من العناصر. هذا يضمن أن العناصر التي تقع خارج الشاشة لا يتم بناؤها أو استهلاكها للذاكرة.
*   **تجنب `shrinkWrap: true`** مع القوائم الطويلة، لأنه يبطل ميزة البناء الكسول (lazy building) لـ `ListView.builder`.
*   **استخدم `itemExtent` أو `prototypeItem`** إذا كانت جميع عناصر القائمة لها نفس الحجم أو حجم مماثل. هذا يقلل بشكل كبير من تعقيد حساب التخطيط.
*   **استخدم `const`** مع العناصر الفرعية (child widgets) التي لا تتغير لتمكين Flutter من إعادة استخدامها وتجنب إعادة بنائها بشكل غير ضروري.
*   **تحسين `itemBuilder`**: تأكد من أن دالة `itemBuilder` خفيفة قدر الإمكان ولا تقوم بعمليات حسابية معقدة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class ListViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ListView Example')),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            color: Colors.blue[100 * (index % 9)],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'List Item $index',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ListViewExample()));
}
```

### 3. Stack

**الوصف:** `Stack` هي ويدجت تسمح لك بتراكب (overlap) العديد من الـ widgets الفرعية فوق بعضها البعض. يتم وضع الـ widgets الفرعية في `Stack` بترتيب الرسم، حيث يتم رسم العنصر الأخير فوق العناصر السابقة. إنها مفيدة لإنشاء واجهات مستخدم معقدة تتطلب وضع عناصر فوق بعضها البعض، مثل أزرار الإجراءات العائمة (Floating Action Buttons) أو تراكبات الصور.

**الخواص الرئيسية (بتعمق):**

*   **`children`**: قائمة الـ widgets التي سيتم تراكبها. يمكن أن تكون هذه العناصر إما `Positioned` widgets (التي تحدد موضعها بدقة) أو `non-positioned` widgets (التي يتم محاذاتها بواسطة خاصية `alignment`).
*   **`alignment`**: تحدد كيفية محاذاة العناصر الفرعية غير الموضعة (non-positioned children) داخل الـ `Stack`. القيمة الافتراضية هي `AlignmentDirectional.topStart` (أعلى اليسار في اللغات من اليسار لليمين، وأعلى اليمين في اللغات من اليمين لليسار). يمكن استخدام قيم مثل `Alignment.center`, `Alignment.bottomRight`، أو أي `Alignment` مخصص.
*   **`textDirection`**: يحدد اتجاه النص للعناصر الفرعية. يؤثر على كيفية تفسير `alignment`.
*   **`fit`**: تحدد كيفية توسيع العناصر الفرعية غير الموضعة في الـ `Stack`.
    *   `StackFit.loose` (افتراضي): يسمح للعناصر بتحديد حجمها الخاص، ولكنها لا تتجاوز حدود الـ `Stack`.
    *   `StackFit.expand`: يجبر العناصر الفرعية غير الموضعة على ملء الـ `Stack` بالكامل.
*   **`clipBehavior`**: تحدد كيفية التعامل مع العناصر الفرعية التي تتجاوز حدود الـ `Stack`. `Clip.hardEdge` (افتراضي) يقص العناصر الزائدة. يمكن استخدام `Clip.none` للسماح للعناصر بالظهور خارج الحدود، ولكن يجب استخدامه بحذر لأنه قد يؤدي إلى مشاكل في التخطيط أو الأداء.

#### `Positioned` Widget

تُستخدم `Positioned` widget داخل `Stack` لتحديد موضع عنصر فرعي بدقة باستخدام إحداثيات (top, bottom, left, right) أو أبعاد (width, height). يمكنها أن تأخذ قيمًا مطلقة أو نسبية.

**الخواص الرئيسية لـ `Positioned`:**

*   `left`, `top`, `right`, `bottom`: تحدد المسافة من حافة الـ `Stack`.
*   `width`, `height`: تحدد عرض وارتفاع العنصر.

#### حالات الاستخدام (Use Cases)

*   **تراكب الصور والنصوص:** وضع نص أو أيقونات فوق صورة.
*   **أزرار الإجراءات العائمة (Floating Action Buttons):** وضع زر في زاوية الشاشة فوق المحتوى.
*   **الشارات (Badges):** وضع شارة صغيرة (مثل عدد الإشعارات) فوق أيقونة.
*   **تخطيطات البطاقات المعقدة:** إنشاء بطاقات تحتوي على عناصر متراكبة مثل صورة خلفية، نص عنوان، وأزرار.

#### نصائح للأداء

*   **استخدم `Positioned` بحكمة:** الإفراط في استخدام `Positioned` widgets يمكن أن يجعل التخطيط معقدًا ويصعب صيانته. حاول استخدام `alignment` لـ `Stack` قدر الإمكان للعناصر البسيطة.
*   **تجنب `Clip.none`** إلا إذا كنت متأكدًا من أن العناصر لن تتجاوز الحدود بشكل غير مرغوب فيه، حيث يمكن أن يؤثر على الأداء.
*   **استخدم `const`** مع العناصر الفرعية الثابتة لتمكين Flutter من تحسين الأداء.

**مثال:**

```dart
import 'package:flutter/material.dart';

class StackExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stack Example')),
      body: Center(
        child: Stack(
          alignment: Alignment.center, // محاذاة العناصر في المنتصف
          children: <Widget>[
            Container(
              width: 200,
              height: 200,
              color: Colors.red,
            ),
            Container(
              width: 150,
              height: 150,
              color: Colors.green,
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: Center(child: Text('Blue', style: TextStyle(color: Colors.white))),
              ),
            ),
            Text(
              'Hello Stack',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: StackExample()));
}
```

### 4. Column

**الوصف:** `Column` هي ويدجت تعرض قائمة من الـ widgets الفرعية في اتجاه عمودي. إنها مفيدة لترتيب العناصر واحدًا فوق الآخر وتعتبر أساسية في بناء معظم واجهات المستخدم الرأسية.

**الخواص الرئيسية (بتعمق):**

*   **`children`**: قائمة الـ widgets التي سيتم ترتيبها عموديًا. يمكن أن تحتوي على أي عدد من الـ widgets.
*   **`mainAxisAlignment`**: تحدد كيفية وضع العناصر الفرعية على المحور الرئيسي (main axis) (العمودي في هذه الحالة). تؤثر هذه الخاصية على توزيع المساحة الحرة على طول المحور الرئيسي.
    *   `MainAxisAlignment.start`: يبدأ وضع العناصر من بداية المحور الرئيسي.
    *   `MainAxisAlignment.end`: يبدأ وضع العناصر من نهاية المحور الرئيسي.
    *   `MainAxisAlignment.center`: يضع العناصر في منتصف المحور الرئيسي.
    *   `MainAxisAlignment.spaceBetween`: يوزع المساحة الحرة بالتساوي بين العناصر، مع ترك مسافة متساوية بين كل عنصر وآخر، ولا يترك مسافة قبل العنصر الأول أو بعد الأخير.
    *   `MainAxisAlignment.spaceAround`: يوزع المساحة الحرة بالتساوي حول العناصر، مع ترك مسافة متساوية قبل وبعد كل عنصر.
    *   `MainAxisAlignment.spaceEvenly`: يوزع المساحة الحرة بالتساوي بين العناصر وحولها، بحيث تكون المسافات متساوية تمامًا.
*   **`crossAxisAlignment`**: تحدد كيفية وضع العناصر الفرعية على المحور المتقاطع (cross axis) (الأفقي في هذه الحالة). تؤثر هذه الخاصية على محاذاة العناصر بالنسبة لبعضها البعض عبر المحور المتقاطع.
    *   `CrossAxisAlignment.start`: يحاذي العناصر إلى بداية المحور المتقاطع.
    *   `CrossAxisAlignment.end`: يحاذي العناصر إلى نهاية المحور المتقاطع.
    *   `CrossAxisAlignment.center`: يحاذي العناصر إلى منتصف المحور المتقاطع (افتراضي).
    *   `CrossAxisAlignment.stretch`: يمد العناصر لملء المحور المتقاطع بالكامل.
    *   `CrossAxisAlignment.baseline`: يحاذي العناصر بناءً على خط الأساس (baseline) الخاص بها (يتطلب `textBaseline`).
*   **`mainAxisSize`**: تحدد مقدار المساحة التي يجب أن يشغلها الـ `Column` على المحور الرئيسي.
    *   `MainAxisSize.max` (افتراضي): يجعل الـ `Column` يملأ المساحة المتاحة على المحور الرئيسي.
    *   `MainAxisSize.min`: يجعل الـ `Column` يأخذ فقط المساحة التي يحتاجها لعرض عناصره على المحور الرئيسي.
*   **`crossAxisSize`**: تحدد مقدار المساحة التي يجب أن يشغلها الـ `Column` على المحور المتقاطع.
    *   `CrossAxisSize.max` (افتراضي): يجعل الـ `Column` يملأ المساحة المتاحة على المحور المتقاطع.
*   **`textDirection`**: يحدد اتجاه النص للعناصر الفرعية. يؤثر على كيفية تفسير `crossAxisAlignment`.
*   **`verticalDirection`**: يحدد كيفية ترتيب العناصر الفرعية على المحور الرئيسي. `VerticalDirection.down` (افتراضي) يرتبها من الأعلى إلى الأسفل، و `VerticalDirection.up` يرتبها من الأسفل إلى الأعلى.

#### حالات الاستخدام (Use Cases)

*   **تخطيطات الشاشات العمودية:** بناء معظم واجهات المستخدم التي تتطلب ترتيب العناصر عموديًا.
*   **بطاقات المعلومات (Info Cards):** عرض عنوان، وصف، وأزرار بشكل عمودي.
*   **نماذج الإدخال (Forms):** ترتيب حقول الإدخال والأزرار بشكل منظم.
*   **القوائم ذات العناصر المتنوعة:** عندما تحتاج إلى عرض عناصر مختلفة لا تتناسب مع `ListView` البسيط.

#### نصائح للأداء

*   **تجنب `Column` داخل `SingleChildScrollView`** إذا كان `Column` يحتوي على عدد كبير من العناصر، فقد يؤدي ذلك إلى مشاكل في الأداء لأن `Column` يحاول بناء جميع عناصره مرة واحدة. في هذه الحالات، يفضل استخدام `ListView`.
*   **استخدم `mainAxisSize: MainAxisSize.min`** عندما لا تريد أن يشغل الـ `Column` المساحة العمودية الكاملة المتاحة، خاصة عند وضعه داخل `Row` أو `Stack`.
*   **استخدم `const`** مع العناصر الفرعية الثابتة لتمكين Flutter من تحسين الأداء.

**مثال:**

```dart
import 'package:flutter/material.dart';

class ColumnExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(color: Colors.red, width: 100, height: 50),
            Container(color: Colors.green, width: 150, height: 50),
            Container(color: Colors.blue, width: 80, height: 50),
            Text('Column Widget', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ColumnExample()));
}
```

### 5. Row

**الوصف:** `Row` هي ويدجت تعرض قائمة من الـ widgets الفرعية في اتجاه أفقي. إنها مفيدة لترتيب العناصر جنبًا إلى جنب وتعتبر أساسية في بناء معظم واجهات المستخدم الأفقية.

**الخواص الرئيسية (بتعمق):**

*   **`children`**: قائمة الـ widgets التي سيتم ترتيبها أفقيًا. يمكن أن تحتوي على أي عدد من الـ widgets.
*   **`mainAxisAlignment`**: تحدد كيفية وضع العناصر الفرعية على المحور الرئيسي (main axis) (الأفقي في هذه الحالة). تؤثر هذه الخاصية على توزيع المساحة الحرة على طول المحور الرئيسي.
    *   `MainAxisAlignment.start`: يبدأ وضع العناصر من بداية المحور الرئيسي.
    *   `MainAxisAlignment.end`: يبدأ وضع العناصر من نهاية المحور الرئيسي.
    *   `MainAxisAlignment.center`: يضع العناصر في منتصف المحور الرئيسي.
    *   `MainAxisAlignment.spaceBetween`: يوزع المساحة الحرة بالتساوي بين العناصر، مع ترك مسافة متساوية بين كل عنصر وآخر، ولا يترك مسافة قبل العنصر الأول أو بعد الأخير.
    *   `MainAxisAlignment.spaceAround`: يوزع المساحة الحرة بالتساوي حول العناصر، مع ترك مسافة متساوية قبل وبعد كل عنصر.
    *   `MainAxisAlignment.spaceEvenly`: يوزع المساحة الحرة بالتساوي بين العناصر وحولها، بحيث تكون المسافات متساوية تمامًا.
*   **`crossAxisAlignment`**: تحدد كيفية وضع العناصر الفرعية على المحور المتقاطع (cross axis) (العمودي في هذه الحالة). تؤثر هذه الخاصية على محاذاة العناصر بالنسبة لبعضها البعض عبر المحور المتقاطع.
    *   `CrossAxisAlignment.start`: يحاذي العناصر إلى بداية المحور المتقاطع.
    *   `CrossAxisAlignment.end`: يحاذي العناصر إلى نهاية المحور المتقاطع.
    *   `CrossAxisAlignment.center`: يحاذي العناصر إلى منتصف المحور المتقاطع (افتراضي).
    *   `CrossAxisAlignment.stretch`: يمد العناصر لملء المحور المتقاطع بالكامل.
    *   `CrossAxisAlignment.baseline`: يحاذي العناصر بناءً على خط الأساس (baseline) الخاص بها (يتطلب `textBaseline`).
*   **`mainAxisSize`**: تحدد مقدار المساحة التي يجب أن يشغلها الـ `Row` على المحور الرئيسي.
    *   `MainAxisSize.max` (افتراضي): يجعل الـ `Row` يملأ المساحة المتاحة على المحور الرئيسي.
    *   `MainAxisSize.min`: يجعل الـ `Row` يأخذ فقط المساحة التي يحتاجها لعرض عناصره على المحور الرئيسي.
*   **`crossAxisSize`**: تحدد مقدار المساحة التي يجب أن يشغلها الـ `Row` على المحور المتقاطع.
    *   `CrossAxisSize.max` (افتراضي): يجعل الـ `Row` يملأ المساحة المتاحة على المحور المتقاطع.
*   **`textDirection`**: يحدد اتجاه النص للعناصر الفرعية. يؤثر على كيفية تفسير `mainAxisAlignment` و `crossAxisAlignment`.
*   **`horizontalDirection`**: يحدد كيفية ترتيب العناصر الفرعية على المحور الرئيسي. `TextDirection.ltr` (افتراضي) يرتبها من اليسار إلى اليمين، و `TextDirection.rtl` يرتبها من اليمين إلى اليسار.

#### حالات الاستخدام (Use Cases)

*   **أشرطة الأدوات (Toolbars):** ترتيب الأيقونات والأزرار أفقيًا.
*   **عناصر القائمة (List Items):** عرض أيقونة، نص، وزر في صف واحد.
*   **رؤوس البطاقات (Card Headers):** عرض صورة ملف شخصي واسم المستخدم جنبًا إلى جنب.
*   **تخطيطات التنقل (Navigation Layouts):** ترتيب عناصر التنقل في شريط أفقي.

#### نصائح للأداء

*   **تجنب `Row` داخل `SingleChildScrollView`** إذا كان `Row` يحتوي على عدد كبير من العناصر، فقد يؤدي ذلك إلى مشاكل في الأداء لأن `Row` يحاول بناء جميع عناصره مرة واحدة. في هذه الحالات، يفضل استخدام `ListView` الأفقي أو `PageView`.
*   **استخدم `mainAxisSize: MainAxisSize.min`** عندما لا تريد أن يشغل الـ `Row` المساحة الأفقية الكاملة المتاحة، خاصة عند وضعه داخل `Column` أو `Stack`.
*   **استخدم `const`** مع العناصر الفرعية الثابتة لتمكين Flutter من تحسين الأداء.
*   **احذر من تجاوز المحتوى (Overflow):** إذا كانت العناصر في `Row` تتجاوز المساحة المتاحة، فستحصل على خطأ `RenderFlex overflowed`. استخدم `Expanded` أو `Flexible` أو `Wrap` للتعامل مع هذه الحالات بفعالية.
**مثال:**

```dart
import 'package:flutter/material.dart';

class RowExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Row Example')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(color: Colors.red, width: 50, height: 100),
            Container(color: Colors.green, width: 50, height: 150),
            Container(color: Colors.blue, width: 50, height: 80),
            Text('Row Widget', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: RowExample()));
}
```

## الـ Widgets المساعدة لتخطيط المحتوى

### 6. SizedBox

**الوصف:** `SizedBox` هي ويدجت بسيطة وفعالة تفرض على عنصرها الفرعي (child) أن يكون له حجم محدد (عرض و/أو ارتفاع). إذا لم يكن لها عنصر فرعي، فإنها تشغل المساحة المحددة بنفسها، مما يجعلها مفيدة لإنشاء مسافات فارغة (spacers) أو تحديد أبعاد ثابتة.

**الخواص الرئيسية (بتعمق):**

*   **`width`**: العرض المطلوب للـ `SizedBox`. إذا تم تحديده، فإن `SizedBox` ستحاول فرض هذا العرض على عنصرها الفرعي.
*   **`height`**: الارتفاع المطلوب للـ `SizedBox`. إذا تم تحديده، فإن `SizedBox` ستحاول فرض هذا الارتفاع على عنصرها الفرعي.
*   **`child`**: العنصر الفرعي الذي سيتم فرض الحجم عليه. إذا لم يتم توفير `child`، فإن `SizedBox` تعمل كـ spacer شفاف.

#### سلوك التخطيط (Layout Behavior)

*   **عندما يكون لها `child`**: تمرر `SizedBox` قيودًا صارمة (tight constraints) إلى عنصرها الفرعي بناءً على `width` و `height` المحددين. هذا يعني أن العنصر الفرعي سيُجبر على أن يكون بنفس حجم `SizedBox`.
*   **عندما لا يكون لها `child`**: تعمل `SizedBox` كصندوق فارغ بالحجم المحدد. يمكن استخدامها لإضافة مسافات أفقية أو عمودية ثابتة بين الـ widgets، وهي بديل شائع لـ `Padding` أو `Container` لهذا الغرض عندما لا تكون هناك حاجة لخصائص أخرى.

#### حالات الاستخدام (Use Cases)

*   **إضافة مسافات ثابتة:** إنشاء مسافات أفقية أو عمودية بين الـ widgets في `Row` أو `Column`.
*   **تحديد حجم ثابت:** فرض عرض وارتفاع محددين على ويدجت معينة، مثل صورة أو أيقونة.
*   **تحديد حجم `AppBar` أو `BottomNavigationBar`:** يمكن استخدام `SizedBox.fromHeight` أو `SizedBox.fromWidth` لتحديد أبعاد هذه العناصر.

#### نصائح للأداء

*   **استخدم `SizedBox` بدلاً من `Container` الفارغ** لإنشاء مسافات أو تحديد أحجام بسيطة، حيث أن `SizedBox` أخف وأكثر كفاءة في الأداء.
*   **استخدم `const SizedBox(...)`** عندما تكون الأبعاد ثابتة لتمكين Flutter من تحسين الأداء.

**مثال:**

```dart
import 'package:flutter/material.dart';

class SizedBoxExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SizedBox Example')),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 100,
              height: 100,
              child: Container(color: Colors.red, child: Center(child: Text('100x100'))),
            ),
            SizedBox(height: 20), // مسافة فارغة بين العناصر
            Container(
              color: Colors.blue,
              width: 50,
              height: 50,
              child: Center(child: Text('Blue Box')),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SizedBoxExample()));
}
```

### 7. Expanded

**الوصف:** `Expanded` هي ويدجت تستخدم داخل `Row` أو `Column` أو `Flex` لتوسيع عنصر فرعي بحيث يملأ المساحة المتاحة على المحور الرئيسي (main axis). إنها مفيدة لتوزيع المساحة بالتساوي أو بنسب محددة بين العناصر، وتعتبر حلاً أساسيًا للتعامل مع المساحات المرنة في التخطيطات الخطية.

**الخواص الرئيسية (بتعمق):**

*   **`flex`**: عامل المرونة (flex factor). يحدد مقدار المساحة المتاحة التي يجب أن يشغلها الـ `Expanded` مقارنة بالـ `Expanded` الأخرى. القيمة الافتراضية هي 1. على سبيل المثال، إذا كان لديك `Expanded` واحد بـ `flex: 1` وآخر بـ `flex: 2`، فإن الثاني سيشغل ضعف المساحة التي يشغلها الأول.
*   **`child`**: العنصر الفرعي الذي سيتم توسيعه. يتم فرض قيود صارمة على هذا العنصر الفرعي لملء المساحة المخصصة له بواسطة `Expanded`.

#### سلوك التخطيط (Layout Behavior)

*   **داخل `Row` أو `Column`**: عندما يتم وضع `Expanded` داخل `Row` أو `Column`، فإنها تأخذ المساحة المتبقية على المحور الرئيسي بعد أن يتم تحديد حجم العناصر غير المرنة (non-flexible children).
*   **القيود (Constraints)**: تمرر `Expanded` قيودًا صارمة إلى عنصرها الفرعي. على المحور الرئيسي، يتم إعطاء العنصر الفرعي الحد الأقصى للمساحة المتاحة. على المحور المتقاطع، يتم إعطاء العنصر الفرعي نفس قيود الأصل (أي `Row` أو `Column`).
*   **التجاوز (Overflow)**: استخدام `Expanded` يساعد على منع تجاوز المحتوى (overflow) في `Row` أو `Column` عن طريق السماح للعناصر بالتوسع لملء المساحة المتاحة بدلاً من تجاوزها.

#### الفرق بين `Expanded` و `Flexible`

*   **`Expanded`**: تجبر العنصر الفرعي على ملء المساحة المتاحة بالكامل على المحور الرئيسي. لا يمكن للعنصر الفرعي أن يكون أصغر من المساحة المخصصة له.
*   **`Flexible`**: تسمح للعنصر الفرعي بالتوسع لملء المساحة المتاحة، ولكنها لا تجبره على ذلك. يمكن للعنصر الفرعي أن يكون أصغر من المساحة المخصصة له إذا كان حجمه الجوهري (intrinsic size) أصغر. `Flexible` لديها خاصية `fit` التي يمكن أن تكون `FlexFit.tight` (مماثلة لـ `Expanded`) أو `FlexFit.loose` (تسمح للعنصر بأن يكون أصغر).

#### حالات الاستخدام (Use Cases)

*   **توزيع المساحة بالتساوي:** تقسيم المساحة المتاحة بين عدة عناصر في `Row` أو `Column`.
*   **منع تجاوز المحتوى:** التأكد من أن العناصر النصية الطويلة أو الصور الكبيرة لا تتجاوز حدود `Row` أو `Column`.
*   **إنشاء تخطيطات مرنة:** تصميم واجهات مستخدم تتكيف مع أحجام الشاشات المختلفة.

#### نصائح للأداء

*   **استخدم `Expanded` أو `Flexible`** دائمًا داخل `Row` أو `Column` عندما تحتاج إلى توزيع المساحة بشكل مرن. تجنب تحديد أحجام ثابتة بشكل مفرط.
*   **استخدم `const`** مع العناصر الفرعية الثابتة لتمكين Flutter من تحسين الأداء.
*   **فهم سلوك `flex`**: استخدم قيم `flex` بعناية لتحقيق التوزيع المطلوب للمساحة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class ExpandedExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expanded Example')),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(color: Colors.red, child: Center(child: Text('Flex 2'))),
            ),
            Expanded(
              flex: 1,
              child: Container(color: Colors.green, child: Center(child: Text('Flex 1'))),
            ),
            Container(color: Colors.blue, height: 50, child: Center(child: Text('Fixed Height'))),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ExpandedExample()));
}
```

### 8. Center

**الوصف:** `Center` هي ويدجت تقوم بتوسيط عنصرها الفرعي (child) داخل نفسها. إنها تحاول أن تكون كبيرة بقدر الإمكان في كلا الاتجاهين (تأخذ أكبر مساحة ممكنة من الأصل)، ثم تقوم بتوسيط العنصر الفرعي داخل تلك المساحة. إنها مفيدة جدًا لوضع عنصر واحد في منتصف الشاشة أو أي مساحة متاحة.

**الخواص الرئيسية (بتعمق):**

*   **`child`**: العنصر الفرعي الذي سيتم توسيطه. يمكن أن يكون أي ويدجت.

#### سلوك التخطيط (Layout Behavior)

*   **القيود (Constraints)**: عندما تتلقى `Center` قيودًا من الأصل، فإنها تمرر هذه القيود إلى عنصرها الفرعي. ثم يحدد العنصر الفرعي حجمه الخاص ضمن هذه القيود.
*   **تحديد الحجم**: بعد أن يحدد العنصر الفرعي حجمه، تقوم `Center` بتحديد حجمها الخاص ليكون بنفس حجم الأصل (أي أنها تحاول أن تكون كبيرة بقدر الإمكان). ثم تقوم بحساب الموضع المناسب للعنصر الفرعي ليكون في المنتصف تمامًا.
*   **الفرق مع `Align`**: بينما تقوم `Center` دائمًا بتوسيط العنصر الفرعي، فإن `Align` تسمح لك بتحديد محاذاة مخصصة (مثل `topLeft`, `bottomRight`, إلخ). `Center` هي في الأساس `Align` مع `alignment: Alignment.center`.

#### حالات الاستخدام (Use Cases)

*   **توسيط عنصر واحد:** وضع زر، نص، أو صورة في منتصف الشاشة.
*   **توسيط محتوى داخل `Container`:** إذا كان لديك `Container` بحجم معين وتريد توسيط محتوى داخله.
*   **توسيط رسائل الخطأ أو التحميل:** عرض رسالة "لا توجد بيانات" أو مؤشر تحميل في منتصف الشاشة.

#### نصائح للأداء

*   **لا تفرط في استخدام `Center`:** إذا كان لديك `Column` أو `Row` وتريد توسيط جميع العناصر، فمن الأفضل استخدام `mainAxisAlignment: MainAxisAlignment.center` و `crossAxisAlignment: CrossAxisAlignment.center` في الـ `Column` أو `Row` نفسها بدلاً من تغليف كل عنصر بـ `Center`.
*   **استخدم `const`** مع العناصر الفرعية الثابتة لتمكين Flutter من تحسين الأداء.
*   **فهم القيود:** تذكر أن `Center` تحاول أن تكون كبيرة بقدر الإمكان. إذا وضعتها داخل ويدجت لا تفرض قيودًا صارمة (مثل `UnconstrainedBox`)، فقد تتصرف بشكل غير متوقع.

**مثال:**

```dart
import 'package:flutter/material.dart';

class CenterExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Center Example')),
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.grey[300],
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.purple,
              child: Center(child: Text('Centered', style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CenterExample()));
}
```

### 9. Padding

**الوصف:** `Padding` هي ويدجت تقوم بإضافة مسافة بادئة (padding) حول عنصرها الفرعي (child). يتم استخدامها لإنشاء مساحة بيضاء حول الـ widgets، وهي ضرورية للتحكم في التباعد بين العناصر وتحسين قابلية القراءة وجمالية التصميم.

**الخواص الرئيسية (بتعمق):**

*   **`padding`**: (مطلوب) تحدد مقدار المسافة البادئة التي سيتم تطبيقها. هذه الخاصية تأخذ كائن `EdgeInsetsGeometry`، والذي يوفر عدة طرق لتحديد المسافة البادئة:
    *   `EdgeInsets.all(double value)`: يطبق مسافة بادئة متساوية من جميع الجوانب (أعلى، أسفل، يسار، يمين).
    *   `EdgeInsets.symmetric({double vertical = 0.0, double horizontal = 0.0})`: يطبق مسافة بادئة متساوية عموديًا وأفقيًا.
    *   `EdgeInsets.only({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0})`: يطبق مسافة بادئة لجوانب محددة فقط.
    *   `EdgeInsets.fromLTRB(double left, double top, double right, double bottom)`: يطبق مسافة بادئة من اليسار، الأعلى، اليمين، والأسفل بشكل منفصل.
    *   `EdgeInsetsDirectional.only(...)`: مشابه لـ `EdgeInsets.only` ولكنه يحترم اتجاه النص (مثل `start` بدلاً من `left`).
*   **`child`**: العنصر الفرعي الذي سيتم تطبيق المسافة البادئة عليه. يتم وضع هذا العنصر داخل المساحة التي تحددها `Padding`.

#### سلوك التخطيط (Layout Behavior)

*   **القيود (Constraints)**: تتلقى `Padding` قيودًا من الأصل، ثم تقوم بتقليص هذه القيود بمقدار المسافة البادئة المحددة قبل تمريرها إلى عنصرها الفرعي. هذا يعني أن العنصر الفرعي سيتم تخطيطه داخل المساحة المتبقية بعد تطبيق المسافة البادئة.
*   **تحديد الحجم**: بعد أن يحدد العنصر الفرعي حجمه، تقوم `Padding` بتحديد حجمها الخاص ليكون حجم العنصر الفرعي بالإضافة إلى المسافة البادئة المطبقة.

#### حالات الاستخدام (Use Cases)

*   **إضافة مسافات داخلية:** توفير مساحة حول النصوص، الأيقونات، أو الصور داخل بطاقة (Card) أو حاوية (Container).
*   **تحسين قابلية القراءة:** فصل الكتل النصية أو العناصر المرئية عن بعضها البعض.
*   **إنشاء تباعد موحد:** الحفاظ على تباعد ثابت بين عناصر واجهة المستخدم.

#### نصائح للأداء

*   **استخدم `const EdgeInsets`**: إذا كانت قيم المسافة البادئة ثابتة، استخدم `const` مع `EdgeInsets` لتمكين Flutter من تحسين الأداء وإعادة استخدام الكائن.
*   **تجنب `Padding` المتداخلة بشكل مفرط**: في بعض الحالات، قد يكون من الأفضل استخدام `Container` مع خاصية `padding` بدلاً من تغليف ويدجت بـ `Padding` ثم تغليفها بـ `Padding` أخرى، لتقليل عدد الـ widgets في شجرة التخطيط.
*   **فهم تأثير `Padding` على القيود**: تذكر أن `Padding` تقلل من القيود المتاحة للعنصر الفرعي. إذا كان العنصر الفرعي يحتاج إلى مساحة أكبر مما تسمح به القيود بعد تطبيق المسافة البادئة، فقد يحدث تجاوز (overflow).

**مثال:**

```dart
import 'package:flutter/material.dart';

class PaddingExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Padding Example')),
      body: Center(
        child: Container(
          color: Colors.blueGrey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              color: Colors.orange,
              width: 150,
              height: 150,
              child: Center(child: Text('Padded Content', style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: PaddingExample()));
}
```

### 10. Container

**الوصف:** `Container` هي ويدجت مريحة تجمع بين الـ widgets الشائعة للرسم، التموضع، وتحديد الحجم. إنها ويدجت متعددة الاستخدامات للغاية يمكن استخدامها لإنشاء مجموعة واسعة من التأثيرات المرئية والتخطيطات المعقدة. يمكنها أن تحتوي على لون، زخرفة (decoration)، هوامش (margin)، مسافة بادئة (padding)، قيود (constraints)، وتحويلات (transformations).

**الخواص الرئيسية (بتعمق):**

*   **`alignment`**: كيفية محاذاة العنصر الفرعي داخل الـ `Container`. تأخذ قيمة من نوع `AlignmentGeometry` (مثل `Alignment.center`, `Alignment.topLeft`).
*   **`padding`**: المسافة البادئة الداخلية (internal padding) داخل الـ `Container`، بين حدود الـ `Container` وعنصرها الفرعي. تأخذ قيمة من نوع `EdgeInsetsGeometry`.
*   **`color`**: لون خلفية الـ `Container`. **ملاحظة هامة:** لا يمكن استخدام `color` مع خاصية `decoration`. إذا كنت تستخدم `decoration` (مثل `BoxDecoration`)، فيجب تحديد اللون داخل الـ `BoxDecoration`.
*   **`decoration`**: زخرفة لتلوين أو تزيين الـ `Container` خلف العنصر الفرعي. غالبًا ما تستخدم `BoxDecoration` لإنشاء حدود، ألوان متدرجة، ظلال، أشكال، وصور خلفية.
*   **`foregroundDecoration`**: زخرفة يتم رسمها فوق العنصر الفرعي. مفيدة لإضافة تراكبات (overlays) أو تأثيرات على العنصر الفرعي دون التأثير على تخطيطه.
*   **`width`**: عرض الـ `Container` المطلوب. إذا لم يتم تحديده، سيحاول `Container` أن يكون كبيرًا بقدر الإمكان إذا كان غير مقيد، أو يأخذ حجم العنصر الفرعي إذا كان مقيدًا.
*   **`height`**: ارتفاع الـ `Container` المطلوب. نفس سلوك `width`.
*   **`constraints`**: قيود إضافية على حجم الـ `Container`. تأخذ قيمة من نوع `BoxConstraints`. يمكن استخدامها لتحديد الحد الأدنى/الأقصى للعرض والارتفاع بشكل أكثر دقة من `width` و `height`.
*   **`margin`**: الهوامش الخارجية (external margin) حول الـ `Container`، بين الـ `Container` والأصل (parent). تأخذ قيمة من نوع `EdgeInsetsGeometry`.
*   **`transform`**: تحويل (transformation) يتم تطبيقه على الـ `Container` قبل الرسم. يمكن استخدامه للتدوير، التحجيم، والإزاحة. يأخذ قيمة من نوع `Matrix4`.
*   **`transformAlignment`**: نقطة الأصل للتحويل (origin of the transform).
*   **`child`**: العنصر الفرعي للـ `Container`. يمكن أن يكون أي ويدجت.
*   **`clipBehavior`**: تحدد كيفية التعامل مع المحتوى الذي يتجاوز حدود الـ `Container` عند تطبيق `decoration` أو `transform`.

#### سلوك التخطيط (Layout Behavior)

`Container` هي ويدجت "تأخذ كل شيء" (greedy) في Flutter. سلوكها في التخطيط يعتمد بشكل كبير على الخصائص التي تم تعيينها:

1.  **إذا كان لديها `child` و `width`/`height` أو `constraints`**: ستحاول `Container` فرض هذه الأبعاد على العنصر الفرعي. إذا كانت القيود صارمة، سيأخذ العنصر الفرعي هذا الحجم.
2.  **إذا كان لديها `child` ولكن لا يوجد `width`/`height` أو `constraints`**: ستحاول `Container` أن تكون كبيرة بقدر الإمكان (إذا كانت غير مقيدة) ثم تطلب من العنصر الفرعي تحديد حجمه. بعد ذلك، ستقوم `Container` بتحديد حجمها ليكون بنفس حجم العنصر الفرعي.
3.  **إذا لم يكن لديها `child` ولكن لديها `width`/`height` أو `constraints`**: ستحاول `Container` أن تأخذ الحجم المحدد.
4.  **إذا لم يكن لديها `child` ولا `width`/`height` ولا `constraints`**: ستحاول `Container` أن تكون كبيرة بقدر الإمكان (إذا كانت غير مقيدة)، وإلا فإنها ستكون بحجم صفر.

#### حالات الاستخدام (Use Cases)

*   **تغليف الـ widgets:** إضافة خلفية، حدود، أو ظلال لأي ويدجت.
*   **إنشاء بطاقات (Cards):** استخدام `BoxDecoration` لإنشاء بطاقات ذات زوايا مستديرة وظلال.
*   **تحديد الأبعاد:** فرض عرض وارتفاع محددين على منطقة معينة في واجهة المستخدم.
*   **إضافة هوامش ومسافات بادئة:** التحكم في التباعد الخارجي والداخلي للعناصر.
*   **تطبيق التحويلات:** تدوير أو تحجيم أو إزاحة الـ widgets.

#### نصائح للأداء

*   **استخدم `Container` بحكمة:** نظرًا لأن `Container` تجمع العديد من الخصائص، فإنها قد تكون أثقل قليلاً من الـ widgets المتخصصة (مثل `SizedBox` للمسافات أو `Padding` للمسافات البادئة). استخدم الـ widgets الأكثر تخصصًا عندما يكون ذلك ممكنًا لتحسين الأداء.
*   **تجنب `color` و `decoration` معًا:** تذكر أن استخدام `color` و `decoration` في نفس `Container` سيؤدي إلى خطأ. حدد اللون داخل `BoxDecoration` إذا كنت تستخدمها.
*   **استخدم `const`** مع `Container` عندما تكون خصائصها ثابتة لتمكين Flutter من تحسين الأداء.

**مثال:**

```dart
import 'package:flutter/material.dart';

class ContainerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Container Example')),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(30),
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            'Hello from Container!',
            style: TextStyle(color: Colors.white, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ContainerExample()));
}
```

### 11. Align

**الوصف:** `Align` هي ويدجت تقوم بمحاذاة عنصرها الفرعي (child) داخل نفسها، ويمكنها اختياريًا تغيير حجمها بناءً على حجم العنصر الفرعي. إنها مفيدة لوضع عنصر فرعي في مكان معين داخل المساحة المتاحة، وتوفر تحكمًا دقيقًا في موضع العنصر الفرعي داخل المساحة المتاحة لها.

**الخواص الرئيسية (بتعمق):**

*   **`alignment`**: (مطلوب) تحدد كيفية محاذاة العنصر الفرعي. تأخذ قيمة من نوع `AlignmentGeometry`.
    *   يمكن استخدام قيم ثابتة مثل `Alignment.topLeft`, `Alignment.center`, `Alignment.bottomRight`.
    *   يمكن أيضًا تحديد محاذاة مخصصة باستخدام `Alignment(double x, double y)` حيث تتراوح قيم `x` و `y` من -1.0 (البداية) إلى 1.0 (النهاية). على سبيل المثال، `Alignment(0.0, 0.0)` هو `Alignment.center`.
*   **`widthFactor`**: إذا لم يكن `null`، فإن عرض الـ `Align` سيكون `widthFactor` مضروبًا في عرض العنصر الفرعي. هذا يعني أن `Align` ستأخذ فقط المساحة التي تحتاجها لعرض العنصر الفرعي مع عامل التحجيم هذا. إذا كان `null`، فإن `Align` ستحاول أن تكون كبيرة بقدر الإمكان.
*   **`heightFactor`**: إذا لم يكن `null`، فإن ارتفاع الـ `Align` سيكون `heightFactor` مضروبًا في ارتفاع العنصر الفرعي. نفس سلوك `widthFactor`.
*   **`child`**: العنصر الفرعي الذي سيتم محاذاته.

#### سلوك التخطيط (Layout Behavior)

*   **القيود (Constraints)**: تتلقى `Align` قيودًا من الأصل. إذا لم يتم تحديد `widthFactor` أو `heightFactor`، فإن `Align` ستحاول أن تكون كبيرة بقدر الإمكان ضمن هذه القيود. ثم تمرر `Align` هذه القيود إلى عنصرها الفرعي.
*   **تحديد الحجم**: بعد أن يحدد العنصر الفرعي حجمه، تقوم `Align` بتحديد حجمها الخاص. إذا تم تحديد `widthFactor` و/أو `heightFactor`، فإن حجم `Align` سيعتمد على حجم العنصر الفرعي وعامل التحجيم. وإلا، فإنها ستأخذ أكبر حجم ممكن ضمن قيود الأصل.
*   **المحاذاة**: تقوم `Align` بوضع العنصر الفرعي داخل مساحتها الخاصة وفقًا لقيمة `alignment` المحددة.

#### حالات الاستخدام (Use Cases)

*   **وضع عنصر في زاوية:** وضع أيقونة أو زر في زاوية معينة من حاوية.
*   **توسيط عنصر داخل مساحة غير منتظمة:** إذا كان لديك ويدجت أصل لا يوفر توسيطًا مباشرًا، يمكن استخدام `Align`.
*   **إنشاء تأثيرات تراكب دقيقة:** عند الحاجة إلى وضع عنصر بدقة فوق عنصر آخر في `Stack`، يمكن استخدام `Align` داخل `Positioned`.

#### نصائح للأداء

*   **استخدم `const`** مع `Align` عندما تكون خصائصها ثابتة لتمكين Flutter من تحسين الأداء.
*   **فهم `widthFactor` و `heightFactor`**: استخدم هذه الخصائص بحكمة لتجنب السلوكيات غير المتوقعة في التخطيط، خاصة إذا كنت تتعامل مع قيود مرنة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class AlignExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Align Example')),
      body: Center(
        child: Container(
          height: 200,
          width: 200,
          color: Colors.blueGrey[100],
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 50,
              width: 50,
              color: Colors.deepOrange,
              child: Center(child: Text('BR', style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: AlignExample()));
}
```

### 12. Wrap

**الوصف:** `Wrap` هي ويدجت تقوم بترتيب الـ widgets الفرعية في صفوف أو أعمدة، وعندما لا يكون هناك مساحة كافية في الاتجاه الرئيسي، فإنها تقوم بلف (wrap) الـ widgets إلى السطر التالي أو العمود التالي. إنها مفيدة لإنشاء تخطيطات مرنة حيث يمكن أن تتغير عدد العناصر في كل سطر أو عمود، وتعتبر بديلاً ممتازًا لـ `Row` أو `Column` عندما يكون هناك احتمال لتجاوز المحتوى.

**الخواص الرئيسية (بتعمق):**

*   **`direction`**: (افتراضي: `Axis.horizontal`) الاتجاه الرئيسي الذي يتم فيه ترتيب الـ widgets. يمكن أن يكون `Axis.horizontal` (من اليسار إلى اليمين أو اليمين إلى اليسار) أو `Axis.vertical` (من الأعلى إلى الأسفل أو الأسفل إلى الأعلى).
*   **`alignment`**: (افتراضي: `WrapAlignment.start`) تحدد كيفية محاذاة الـ widgets الفرعية على المحور الرئيسي داخل كل "لفة" (run). القيم المتاحة هي `start`, `end`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly`.
*   **`spacing`**: (افتراضي: `0.0`) المسافة (بالبكسل) بين الـ widgets على المحور الرئيسي. يتم تطبيق هذه المسافة بين كل عنصر وآخر داخل نفس "اللفة".
*   **`runAlignment`**: (افتراضي: `WrapAlignment.start`) تحدد كيفية محاذاة "اللفات" (runs) على المحور المتقاطع. "اللفة" هي مجموعة من الـ widgets التي تم لفها إلى سطر أو عمود جديد. القيم المتاحة هي `start`, `end`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly`.
*   **`runSpacing`**: (افتراضي: `0.0`) المسافة (بالبكسل) بين "اللفات" على المحور المتقاطع. يتم تطبيق هذه المسافة بين كل سطر أو عمود ملفوف وآخر.
*   **`crossAxisAlignment`**: (افتراضي: `WrapCrossAlignment.start`) تحدد كيفية محاذاة الـ widgets الفرعية داخل كل "لفة" على المحور المتقاطع. القيم المتاحة هي `start`, `end`, `center`.
*   **`textDirection`**: يحدد اتجاه النص للعناصر الفرعية. يؤثر على كيفية تفسير `direction` و `alignment`.
*   **`verticalDirection`**: يحدد كيفية ترتيب العناصر الفرعية على المحور الرئيسي. `VerticalDirection.down` (افتراضي) يرتبها من الأعلى إلى الأسفل، و `VerticalDirection.up` يرتبها من الأسفل إلى الأعلى.
*   **`children`**: قائمة الـ widgets الفرعية التي سيتم ترتيبها.

#### سلوك التخطيط (Layout Behavior)

*   **القيود (Constraints)**: تتلقى `Wrap` قيودًا من الأصل. تقوم `Wrap` بتخطيط عناصرها الفرعية واحدًا تلو الآخر على المحور الرئيسي. إذا تجاوز العنصر الفرعي المساحة المتاحة على المحور الرئيسي، فإن `Wrap` تقوم بلفه إلى "لفة" جديدة (سطر أو عمود جديد).
*   **تحديد الحجم**: حجم `Wrap` يعتمد على حجم عناصرها الفرعية والمسافات المحددة. ستحاول `Wrap` أن تكون كبيرة بما يكفي لاحتواء جميع عناصرها الفرعية مع المسافات البادئة والهوامش.
*   **المرونة في التخطيط**: على عكس `Row` و `Column` التي قد تسبب تجاوزًا (overflow) إذا كانت عناصرها الفرعية أكبر من المساحة المتاحة، فإن `Wrap` تتعامل مع هذه الحالات بمرونة عن طريق لف العناصر.

#### حالات الاستخدام (Use Cases)

*   **الكلمات المفتاحية (Tags) أو الشرائح (Chips):** عرض قائمة من الكلمات المفتاحية التي تلتف تلقائيًا إلى السطر التالي عند عدم وجود مساحة كافية.
*   **معرض الصور المتجاوب:** عرض مجموعة من الصور التي تتكيف مع عرض الشاشة.
*   **أزرار الإجراءات المتعددة:** ترتيب مجموعة من الأزرار التي قد تختلف في عددها أو حجمها.
*   **تخطيطات النماذج الديناميكية:** حيث قد تتغير عدد حقول الإدخال أو حجمها.

#### نصائح للأداء

*   **استخدم `const`** مع العناصر الفرعية الثابتة لتمكين Flutter من تحسين الأداء.
*   **فهم `spacing` و `runSpacing`**: استخدم هذه الخصائص للتحكم في التباعد بين العناصر واللفات بدلاً من استخدام `Padding` حول كل عنصر، مما يقلل من عدد الـ widgets في شجرة التخطيط.
*   **تجنب عدد كبير جدًا من العناصر**: على الرغم من أن `Wrap` مرنة، إلا أن وجود عدد كبير جدًا من العناصر قد يؤثر على الأداء، خاصة إذا كانت العناصر معقدة. في هذه الحالات، قد يكون `ListView` أو `GridView` مع `Wrap` كعنصر فرعي أكثر ملاءمة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class WrapExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wrap Example')),
      body: Center(
        child: Wrap(
          spacing: 8.0, // المسافة الأفقية بين العناصر
          runSpacing: 4.0, // المسافة العمودية بين الصفوف
          children: List.generate(10, (index) {
            return Chip(
              avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('${index + 1}')),
              label: Text('Item ${index + 1}'),
              backgroundColor: Colors.blue.shade100,
            );
          }),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: WrapExample()));
}
```

## الـ Widgets الأخرى لتخطيط المحتوى

### 13. AspectRatio

**الوصف:** `AspectRatio` هي ويدجت تحاول تحديد حجم العنصر الفرعي (child) بنسبة عرض إلى ارتفاع محددة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class AspectRatioExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AspectRatio Example')),
      body: Center(
        child: Container(
          color: Colors.grey[300],
          width: 200,
          child: AspectRatio(
            aspectRatio: 16 / 9, // نسبة العرض إلى الارتفاع
            child: Container(
              color: Colors.red,
              child: Center(child: Text('16:9 Aspect Ratio', style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: AspectRatioExample()));
}
```

### 14. Baseline

**الوصف:** `Baseline` هي ويدجت تضع عنصرها الفرعي (child) وفقًا لخط الأساس (baseline) الخاص بالعنصر الفرعي.

**مثال:**

```dart
import 'package:flutter/material.dart';

class BaselineExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baseline Example')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Baseline(
              baseline: 50,
              baselineType: TextBaseline.alphabetic,
              child: Text(
                'Hello',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Baseline(
              baseline: 80,
              baselineType: TextBaseline.alphabetic,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.blue,
              ),
            ),
            Baseline(
              baseline: 30,
              baselineType: TextBaseline.alphabetic,
              child: Text(
                'World',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: BaselineExample()));
}
```

### 15. ConstrainedBox

**الوصف:** `ConstrainedBox` هي ويدجت تفرض قيودًا إضافية على عنصرها الفرعي (child).

**مثال:**

```dart
import 'package:flutter/material.dart';

class ConstrainedBoxExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ConstrainedBox Example')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 100,
            minHeight: 100,
            maxWidth: 200,
            maxHeight: 200,
          ),
          child: Container(
            color: Colors.green,
            child: Text('Constrained Box', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ConstrainedBoxExample()));
}
```

### 16. CustomSingleChildLayout

**الوصف:** `CustomSingleChildLayout` هي ويدجت تؤجل تخطيط عنصرها الفرعي الوحيد إلى مفوض (delegate) مخصص.

**مثال:**

```dart
import 'package:flutter/material.dart';

class CustomSingleChildLayoutExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CustomSingleChildLayout Example')),
      body: Center(
        child: CustomSingleChildLayout(
          delegate: MySingleChildLayoutDelegate(),
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            child: Center(child: Text('Custom Layout', style: TextStyle(color: Colors.white))),
          ),
        ),
      ),
    );
  }
}

class MySingleChildLayoutDelegate extends SingleChildLayoutDelegate {
  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth / 2, height: constraints.maxHeight / 2);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(size.width / 4, size.height / 4);
  }

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => false;
}

void main() {
  runApp(MaterialApp(home: CustomSingleChildLayoutExample()));
}
```

### 17. FittedBox

**الوصف:** `FittedBox` تقوم بتحجيم ووضع عنصرها الفرعي (child) داخل نفسها وفقًا لخاصية `fit`.

**مثال:**

```dart
import 'package:flutter/material.dart';

class FittedBoxExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FittedBox Example')),
      body: Center(
        child: Container(
          width: 200,
          height: 100,
          color: Colors.grey[300],
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              'This is a long text that needs to fit.',
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: FittedBoxExample()));
}
```

### 18. FractionallySizedBox

**الوصف:** `FractionallySizedBox` هي ويدجت تحدد حجم عنصرها الفرعي (child) ككسر من إجمالي المساحة المتاحة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class FractionallySizedBoxExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FractionallySizedBox Example')),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          color: Colors.grey[300],
          child: FractionallySizedBox(
            widthFactor: 0.5, // 50% من عرض الأصل
            heightFactor: 0.75, // 75% من ارتفاع الأصل
            child: Container(
              color: Colors.orange,
              child: Center(child: Text('Fractional Size', style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: FractionallySizedBoxExample()));
}
```

### 19. IntrinsicHeight

**الوصف:** `IntrinsicHeight` هي ويدجت تحدد ارتفاع عنصرها الفرعي (child) بناءً على الارتفاع الجوهري (intrinsic height) للعنصر الفرعي.

**مثال:**

```dart
import 'package:flutter/material.dart';

class IntrinsicHeightExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('IntrinsicHeight Example')),
      body: Center(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Colors.red,
                width: 50,
                child: Center(child: Text('Short', style: TextStyle(color: Colors.white))),
              ),
              Container(
                color: Colors.green,
                width: 50,
                child: Center(child: Text('Very Long Text That Wraps', style: TextStyle(color: Colors.white))),
              ),
              Container(
                color: Colors.blue,
                width: 50,
                child: Center(child: Text('Medium', style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: IntrinsicHeightExample()));
}
```

### 20. IntrinsicWidth

**الوصف:** `IntrinsicWidth` هي ويدجت تحدد عرض عنصرها الفرعي (child) بناءً على العرض الجوهري (intrinsic width) للعنصر الفرعي.

**مثال:**

```dart
import 'package:flutter/material.dart';

class IntrinsicWidthExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('IntrinsicWidth Example')),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Colors.red,
                height: 50,
                child: Center(child: Text('Short', style: TextStyle(color: Colors.white))),
              ),
              Container(
                color: Colors.green,
                height: 50,
                child: Center(child: Text('Very Long Text That Needs Space', style: TextStyle(color: Colors.white))),
              ),
              Container(
                color: Colors.blue,
                height: 50,
                child: Center(child: Text('Medium', style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: IntrinsicWidthExample()));
}
```

### 21. LimitedBox

**الوصف:** `LimitedBox` هي ويدجت تحد من حجمها فقط عندما تكون غير مقيدة (unconstrained). إنها مفيدة لمنع الـ widgets من التوسع بشكل لا نهائي عندما تكون في بيئة غير مقيدة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class LimitedBoxExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LimitedBox Example')),
      body: ListView(
        children: <Widget>[
          LimitedBox(
            maxHeight: 100, // سيتم تطبيق هذا الحد الأقصى فقط إذا كان الأصل غير مقيد
            child: Container(
              color: Colors.amber,
              child: Text('This box will not exceed 100 height if unconstrained.', style: TextStyle(fontSize: 20)),
            ),
          ),
          Container(
            height: 200,
            color: Colors.blueGrey,
            child: Center(child: Text('Another Container', style: TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: LimitedBoxExample()));
}
```

### 22. Offstage

**الوصف:** `Offstage` هي ويدجت تقوم بتخطيط العنصر الفرعي (child) كما لو كان موجودًا في الشجرة، ولكن دون رسم أي شيء، ودون جعل العنصر الفرعي متاحًا للتفاعل (hit testing).

**مثال:**

```dart
import 'package:flutter/material.dart';

class OffstageExample extends StatefulWidget {
  @override
  _OffstageExampleState createState() => _OffstageExampleState();
}

class _OffstageExampleState extends State<OffstageExample> {
  bool _offstage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offstage Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Offstage(
              offstage: _offstage,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
                child: Center(child: Text('Hidden', style: TextStyle(color: Colors.white))),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _offstage = !_offstage;
                });
              },
              child: Text(_offstage ? 'Show Widget' : 'Hide Widget'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: OffstageExample()));
}
```

### 23. OverflowBox

**الوصف:** `OverflowBox` هي ويدجت تفرض قيودًا مختلفة على عنصرها الفرعي (child) عما تحصل عليه من الأصل (parent)، مما قد يسمح للعنصر الفرعي بالتجاوز (overflow) الأصل.

**مثال:**

```dart
import 'package:flutter/material.dart';

class OverflowBoxExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OverflowBox Example')),
      body: Center(
        child: Container(
          width: 100,
          height: 100,
          color: Colors.grey[300],
          child: OverflowBox(
            minWidth: 0.0,
            minHeight: 0.0,
            maxWidth: 200.0,
            maxHeight: 200.0,
            child: Container(
              color: Colors.blue,
              width: 150,
              height: 150,
              child: Center(child: Text('Overflowing Box', style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: OverflowBoxExample()));
}
```

### 24. SizedOverflowBox

**الوصف:** `SizedOverflowBox` هي ويدجت ذات حجم محدد ولكنها تمرر قيودها الأصلية إلى عنصرها الفرعي (child)، والذي قد يتجاوز (overflow) حدودها.

**مثال:**

```dart
import 'package:flutter/material.dart';

class SizedOverflowBoxExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SizedOverflowBox Example')),
      body: Center(
        child: Container(
          color: Colors.grey[300],
          width: 100,
          height: 100,
          child: SizedOverflowBox(
            size: Size(50, 50), // حجم الـ SizedOverflowBox نفسها
            child: Container(
              color: Colors.red,
              width: 150, // هذا سيتجاوز حجم الـ SizedOverflowBox
              height: 150,
              child: Center(child: Text('Overflow', style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SizedOverflowBoxExample()));
}
```

### 25. Transform

**الوصف:** `Transform` هي ويدجت تطبق تحويلاً (transformation) قبل رسم عنصرها الفرعي (child). يمكن استخدامها للتدوير، التحجيم، والإزاحة. (تم شرحها سابقًا في Painting widgets، ولكن يتم تضمينها هنا لأهميتها في التخطيط).

**مثال:**

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TransformLayoutExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transform Layout Example')),
      body: Center(
        child: Container(
          color: Colors.grey[300],
          width: 200,
          height: 200,
          child: Transform.rotate(
            angle: math.pi / 4, // يدور 45 درجة
            child: Container(
              width: 100,
              height: 100,
              color: Colors.purple,
              child: Center(child: Text('Rotated', style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: TransformLayoutExample()));
}
```

### 26. CustomMultiChildLayout

**الوصف:** `CustomMultiChildLayout` هي ويدجت تستخدم مفوضًا (delegate) لتحديد حجم وموضع العديد من العناصر الفرعية.

**مثال:**

```dart
import 'package:flutter/material.dart';

class CustomMultiChildLayoutExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CustomMultiChildLayout Example')),
      body: Center(
        child: CustomMultiChildLayout(
          delegate: MyMultiChildLayoutDelegate(),
          children: <Widget>[
            LayoutId(
              id: 1,
              child: Container(color: Colors.red, width: 50, height: 50),
            ),
            LayoutId(
              id: 2,
              child: Container(color: Colors.green, width: 70, height: 70),
            ),
          ],
        ),
      ),
    );
  }
}

class MyMultiChildLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    if (hasChild(1)) {
      layoutChild(1, BoxConstraints.tightFor(width: 50, height: 50));
      positionChild(1, Offset(0, 0));
    }
    if (hasChild(2)) {
      layoutChild(2, BoxConstraints.tightFor(width: 70, height: 70));
      positionChild(2, Offset(size.width - 70, size.height - 70));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}

void main() {
  runApp(MaterialApp(home: CustomMultiChildLayoutExample()));
}
```

### 27. CarouselView

**الوصف:** `CarouselView` هي ويدجت Material carousel تعرض قائمة قابلة للتمرير من العناصر، يمكن لكل منها تغيير حجمه ديناميكيًا بناءً على التخطيط المختار. (ملاحظة: `CarouselView` ليست ويدجت أساسية في Flutter SDK، وقد تشير إلى حزم خارجية أو أمثلة. سأقدم مثالًا عامًا لمفهوم الكاروسيل باستخدام `PageView`).

**مثال (باستخدام PageView كمفهوم مشابه):**

```dart
import 'package:flutter/material.dart';

class CarouselViewExample extends StatelessWidget {
  final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.purple];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CarouselView (PageView) Example')),
      body: Center(
        child: SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.all(8.0),
                color: colors[index],
                child: Center(
                  child: Text(
                    'Page ${index + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CarouselViewExample()));
}
```

### 28. Flow

**الوصف:** `Flow` هي ويدجت تنفذ خوارزمية تخطيط التدفق (flow layout algorithm). إنها فعالة للغاية ولكنها تتطلب فهمًا عميقًا لكيفية عمل التخطيطات.

**مثال:**

```dart
import 'package:flutter/material.dart';

class FlowExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flow Example')),
      body: Flow(
        delegate: MyFlowDelegate(margin: EdgeInsets.all(10.0)),
        children: List.generate(5, (index) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.primaries[index % Colors.primaries.length],
            child: Center(child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 20))),
          );
        }),
      ),
    );
  }
}

class MyFlowDelegate extends FlowDelegate {
  final EdgeInsets margin;

  MyFlowDelegate({required this.margin});

  @override
  void paintChildren(FlowPaintingContext context) {
    double x = margin.left;
    double y = margin.top;
    for (int i = 0; i < context.childCount; i++) {
      var w = context.getChildSize(i)!.width + margin.right + margin.left;
      if (x + w > context.size.width) {
        x = margin.left;
        y += context.getChildSize(i)!.height + margin.top + margin.bottom;
      }
      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0.0));
      x += w;
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}

void main() {
  runApp(MaterialApp(home: FlowExample()));
}
```

### 29. IndexedStack

**الوصف:** `IndexedStack` هي `Stack` تعرض عنصرًا فرعيًا واحدًا فقط من قائمة العناصر الفرعية الخاصة بها بناءً على فهرس (index) محدد.

**مثال:**

```dart
import 'package:flutter/material.dart';

class IndexedStackExample extends StatefulWidget {
  @override
  _IndexedStackExampleState createState() => _IndexedStackExampleState();
}

class _IndexedStackExampleState extends State<IndexedStackExample> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('IndexedStack Example')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: <Widget>[
                Container(color: Colors.red, child: Center(child: Text('Page 1', style: TextStyle(color: Colors.white, fontSize: 30)))),
                Container(color: Colors.green, child: Center(child: Text('Page 2', style: TextStyle(color: Colors.white, fontSize: 30)))),
                Container(color: Colors.blue, child: Center(child: Text('Page 3', style: TextStyle(color: Colors.white, fontSize: 30)))),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Business'),
              BottomNavigationBarItem(icon: Icon(Icons.school), label: 'School'),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: IndexedStackExample()));
}
```

### 30. LayoutBuilder

**الوصف:** `LayoutBuilder` هي ويدجت تبني شجرة ويدجت يمكن أن تعتمد على حجم الويدجت الأصلية (parent widget).

**مثال:**

```dart
import 'package:flutter/material.dart';

class LayoutBuilderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LayoutBuilder Example')),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          color: Colors.grey[300],
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 200) {
                return Container(
                  color: Colors.blue,
                  child: Center(child: Text('Wide Layout', style: TextStyle(color: Colors.white, fontSize: 20))),
                );
              } else {
                return Container(
                  color: Colors.red,
                  child: Center(child: Text('Narrow Layout', style: TextStyle(color: Colors.white, fontSize: 20))),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: LayoutBuilderExample()));
}
```

### 31. ListBody

**الوصف:** `ListBody` هي ويدجت ترتب عناصرها الفرعية بالتسلسل على طول محور معين، مما يجبرها على أن تكون بنفس بُعد الأصل على المحور الآخر.

**مثال:**

```dart
import 'package:flutter/material.dart';

class ListBodyExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ListBody Example')),
      body: Center(
        child: Container(
          width: 200,
          height: 300,
          color: Colors.grey[300],
          child: ListBody(
            mainAxis: Axis.vertical,
            children: <Widget>[
              Container(color: Colors.red, height: 50, child: Center(child: Text('Item 1', style: TextStyle(color: Colors.white)))),
              Container(color: Colors.green, height: 50, child: Center(child: Text('Item 2', style: TextStyle(color: Colors.white)))),
              Container(color: Colors.blue, height: 50, child: Center(child: Text('Item 3', style: TextStyle(color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ListBodyExample()));
}
```

### 32. Table

**الوصف:** `Table` تعرض الـ widgets الفرعية في صفوف وأعمدة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class TableExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Table Example')),
      body: Center(
        child: Table(
          border: TableBorder.all(),
          children: const <TableRow>[
            TableRow(
              children: <Widget>[
                Center(child: Text('Cell 1')), 
                Center(child: Text('Cell 2')),
                Center(child: Text('Cell 3')),
              ],
            ),
            TableRow(
              children: <Widget>[
                Center(child: Text('Cell 4')),
                Center(child: Text('Cell 5')),
                Center(child: Text('Cell 6')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: TableExample()));
}
```

## Sliver Widgets

الـ Sliver widgets هي ويدجت خاصة تُستخدم لإنشاء تأثيرات تمرير مخصصة وفعالة. يتم استخدامها عادةً داخل `CustomScrollView`.

### 33. CupertinoSliverNavigationBar

**الوصف:** شريط تنقل بتصميم iOS 11 مع عناوين كبيرة باستخدام الـ slivers.

**مثال:**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoSliverNavigationBarExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('My App'),
            middle: Text('Details'),
          ),
          SliverFillRemaining(
            child: Center(
              child: Text('Content Below Navigation Bar'),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CupertinoSliverNavigationBarExample()));
}
```

### 34. CupertinoSliverRefreshControl

**الوصف:** ويدجت sliver تنفذ التحكم في تحديث المحتوى بالسحب للأسفل على غرار iOS.

**مثال:**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoSliverRefreshControlExample extends StatelessWidget {
  Future<void> _handleRefresh() {
    return Future.delayed(Duration(seconds: 2)); // Simulate network call
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: 60,
                  color: Colors.blue[100 * (index % 9)],
                  child: Center(child: Text('Item $index')),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CupertinoSliverRefreshControlExample()));
}
```

### 35. CustomScrollView

**الوصف:** `CustomScrollView` هي `ScrollView` تنشئ تأثيرات تمرير مخصصة باستخدام الـ slivers.

**مثال:**

```dart
import 'package:flutter/material.dart';

class CustomScrollViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CustomScrollView Example')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Custom Scroll View'),
              background: Image.network(
                'https://picsum.photos/id/1084/400/200',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: 80,
                  color: Colors.amber[100 * (index % 9)],
                  child: Center(child: Text('Item $index')),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CustomScrollViewExample()));
}
```

### 36. SliverAppBar

**الوصف:** شريط تطبيق (app bar) بتصميم Material يتكامل مع `CustomScrollView`.

**مثال:** (مضمن في مثال `CustomScrollView` أعلاه)

### 37. SliverChildBuilderDelegate

**الوصف:** مفوض (delegate) يوفر عناصر فرعية للـ slivers باستخدام دالة بناء (builder callback).

**مثال:** (مضمن في أمثلة `CupertinoSliverRefreshControl` و `CustomScrollView`)

### 38. SliverChildListDelegate

**الوصف:** مفوض (delegate) يوفر عناصر فرعية للـ slivers باستخدام قائمة صريحة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class SliverChildListDelegateExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SliverChildListDelegate Example')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Container(color: Colors.red, height: 100, child: Center(child: Text('Item 1', style: TextStyle(color: Colors.white)))),
                Container(color: Colors.green, height: 100, child: Center(child: Text('Item 2', style: TextStyle(color: Colors.white)))),
                Container(color: Colors.blue, height: 100, child: Center(child: Text('Item 3', style: TextStyle(color: Colors.white)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SliverChildListDelegateExample()));
}
```

### 39. SliverFillRemaining

**الوصف:** sliver يحتوي على عنصر صندوقي واحد يملأ المساحة المتبقية في منفذ العرض (viewport).

**مثال:** (مضمن في مثال `CupertinoSliverNavigationBar`)

### 40. SliverFixedExtentList

**الوصف:** sliver يضع العديد من العناصر الصندوقية الفرعية بنفس الامتداد على المحور الرئيسي في قائمة خطية.

**مثال:**

```dart
import 'package:flutter/material.dart';

class SliverFixedExtentListExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SliverFixedExtentList Example')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverFixedExtentList(
            itemExtent: 50.0, // ارتفاع ثابت لكل عنصر
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: Text('Item $index'),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SliverFixedExtentListExample()));
}
```

### 41. SliverGrid

**الوصف:** sliver يضع العديد من العناصر الصندوقية الفرعية في ترتيب ثنائي الأبعاد.

**مثال:**

```dart
import 'package:flutter/material.dart';

class SliverGridExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SliverGrid Example')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.orange[100 * (index % 9)],
                  child: Text('Grid Item $index'),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SliverGridExample()));
}
```

### 42. SliverList

**الوصف:** sliver يضع العديد من العناصر الصندوقية الفرعية في قائمة خطية على طول المحور الرئيسي.

**مثال:** (مضمن في أمثلة `CupertinoSliverRefreshControl` و `CustomScrollView`)

### 43. SliverPadding

**الوصف:** sliver يطبق مسافة بادئة (padding) على كل جانب من sliver آخر.

**مثال:**

```dart
import 'package:flutter/material.dart';

class SliverPaddingExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SliverPadding Example')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    height: 50,
                    color: Colors.purple[100 * (index % 9)],
                    child: Center(child: Text('Padded Item $index')),
                  );
                },
                childCount: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SliverPaddingExample()));
}
```

### 44. SliverPersistentHeader

**الوصف:** sliver يتغير حجمه عندما يتم تمرير الـ sliver إلى حافة منفذ العرض (viewport) المقابلة لـ `GrowthDirection` الخاص بالـ sliver.

**مثال:**

```dart
import 'package:flutter/material.dart';

class SliverPersistentHeaderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SliverPersistentHeader Example')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            delegate: MySliverPersistentHeaderDelegate(
              minHeight: 60.0,
              maxHeight: 200.0,
              child: Container(
                color: Colors.lightGreen,
                child: Center(child: Text('Persistent Header', style: TextStyle(color: Colors.white, fontSize: 24))),
              ),
            ),
            pinned: true, // يجعل الرأس ثابتًا عند التمرير
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: 80,
                  color: Colors.grey[100 * (index % 9)],
                  child: Center(child: Text('List Item $index')),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  MySliverPersistentHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(MySliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

void main() {
  runApp(MaterialApp(home: SliverPersistentHeaderExample()));
}
```

### 45. SliverToBoxAdapter

**الوصف:** sliver يحتوي على ويدجت صندوقية واحدة.

**مثال:**

```dart
import 'package:flutter/material.dart';

class SliverToBoxAdapterExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SliverToBoxAdapter Example')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              height: 150,
              color: Colors.pink,
              child: Center(child: Text('Regular Box Widget in a Sliver', style: TextStyle(color: Colors.white, fontSize: 20))),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: 60,
                  color: Colors.blueGrey[100 * (index % 9)],
                  child: Center(child: Text('List Item $index')),
                );
              },
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SliverToBoxAdapterExample()));
}
```

### 46. SliverLayoutBuilder

**الوصف:** `SliverLayoutBuilder` هي ويدجت تبني شجرة ويدجت يمكن أن تعتمد على قيود الـ sliver الأصلية. إنها مفيدة لإنشاء slivers مخصصة تتفاعل مع بيئة التمرير.

**مثال:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverLayoutBuilderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SliverLayoutBuilder Example')),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverLayoutBuilder(
            builder: (BuildContext context, SliverConstraints constraints) {
              return SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  color: Colors.deepOrangeAccent,
                  child: Center(
                    child: Text(
                      'Sliver Constraints: ${constraints.viewportMainAxisExtent.toStringAsFixed(1)}',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              );
            },
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: 60,
                  color: Colors.indigo[100 * (index % 9)],
                  child: Center(child: Text('List Item $index')),
                );
              },
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SliverLayoutBuilderExample()));
}
```


## قسم خاص: التخطيط المتجاوب (Responsive Layout) وأفضل الممارسات

بناء واجهات مستخدم تتكيف بسلاسة مع مختلف أحجام الشاشات والاتجاهات (عمودي/أفقي) هو جزء أساسي من تطوير التطبيقات الحديثة. يوفر Flutter مجموعة قوية من الأدوات والتقنيات لتحقيق التخطيط المتجاوب بفعالية.

### 1. فهم أنواع الأجهزة وأحجام الشاشات

قبل البدء في بناء التخطيط المتجاوب، من المهم فهم الفئات المختلفة للأجهزة:

*   **الهواتف المحمولة (Mobile):** شاشات صغيرة، عادة ما تكون بعرض أقل من 600 بكسل منطقي (logical pixels).
*   **الأجهزة اللوحية (Tablets):** شاشات متوسطة، يتراوح عرضها بين 600 و 1200 بكسل منطقي.
*   **أجهزة سطح المكتب (Desktop):** شاشات كبيرة، بعرض يزيد عن 1200 بكسل منطقي.

### 2. الأدوات الأساسية للتخطيط المتجاوب

*   **`MediaQuery`**: هي الأداة الأساسية للحصول على معلومات حول الشاشة الحالية، مثل:
    *   `MediaQuery.of(context).size`: حجم الشاشة (العرض والارتفاع).
    *   `MediaQuery.of(context).orientation`: اتجاه الشاشة (`Orientation.portrait` أو `Orientation.landscape`).
    *   `MediaQuery.of(context).padding`: المساحات التي يشغلها نظام التشغيل (مثل شريط الحالة أو الـ notch).

*   **`LayoutBuilder`**: هي ويدجت قوية تقوم ببناء شجرة الـ widgets الخاصة بها بناءً على القيود (constraints) التي تتلقاها من الأصل. هذا يسمح لك بتغيير التخطيط بناءً على المساحة المتاحة للـ widget نفسها، وليس فقط حجم الشاشة بالكامل.

*   **`OrientationBuilder`**: ويدجت متخصصة تقوم بإعادة بناء واجهة المستخدم عندما يتغير اتجاه الشاشة.

### 3. أفضل الممارسات والاستراتيجيات

#### أ. استخدام الـ Widgets المرنة

*   **`Expanded` و `Flexible`**: استخدمهما دائمًا داخل `Row` و `Column` لتوزيع المساحة بشكل مرن بدلاً من استخدام أحجام ثابتة.
*   **`Wrap`**: استخدمها بدلاً من `Row` أو `Column` عندما يكون هناك احتمال لتجاوز المحتوى، مثل عرض قائمة من الكلمات المفتاحية.
*   **`FittedBox`**: تقوم بتحجيم وتحديد موضع عنصرها الفرعي داخل نفسها لتناسب المساحة المتاحة.

#### ب. التخطيطات التكيفية (Adaptive Layouts)

لا تكتفِ فقط بتغيير حجم العناصر، بل قم بتغيير التخطيط نفسه بناءً على حجم الشاشة. على سبيل المثال:

*   **في الهواتف:** قد تعرض قائمة (`ListView`) من العناصر.
*   **في الأجهزة اللوحية:** قد تعرض شبكة (`GridView`) من نفس العناصر، أو تخطيطًا من جزأين (master-detail layout).

يمكن تحقيق ذلك باستخدام `LayoutBuilder` للتحقق من العرض المتاح وتحديد الـ widget المناسبة.

#### ج. استخدام الوحدات النسبية بدلاً من المطلقة

*   **تجنب الأحجام الثابتة (Hardcoded Sizes):** بدلاً من تحديد `width: 200`، حاول استخدام نسب من عرض الشاشة، على سبيل المثال `width: MediaQuery.of(context).size.width * 0.5`.
*   **`FractionallySizedBox`**: ويدجت مفيدة لتحديد حجم عنصر فرعي كنسبة مئوية من المساحة المتاحة.

### 4. مثال عملي: تخطيط متجاوب

لنفترض أننا نريد عرض قائمة على الهواتف، وشبكة على الأجهزة اللوحية.

```dart
import 'package:flutter/material.dart';

class ResponsiveLayoutExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Responsive Layout')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            // عرض الشبكة للأجهزة اللوحية
            return _buildGridView();
          } else {
            // عرض القائمة للهواتف
            return _buildListView();
          }
        },
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Item $index'),
            subtitle: Text('This is a list item'),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 4,
      children: List.generate(20, (index) {
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.person, size: 40),
              SizedBox(height: 8),
              Text('Item $index'),
            ],
          ),
        );
      }),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ResponsiveLayoutExample()));
}
```

في هذا المثال، يستخدم `LayoutBuilder` للتحقق من `maxWidth`. إذا كان العرض أكبر من 600 بكسل، فإنه يعرض `GridView`؛ وإلا، فإنه يعرض `ListView`. هذا يضمن تجربة مستخدم مثالية على كلا النوعين من الأجهزة.
