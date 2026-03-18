# الرسوم المتحركة (Animations) في Flutter

تعتبر الرسوم المتحركة جزءًا أساسيًا من تجربة المستخدم الحديثة، حيث تضفي حيوية وتفاعلية على التطبيقات. يوفر Flutter إطار عمل غنيًا ومرنًا لإنشاء رسوم متحركة سلسة وجميلة. يمكن تقسيم الرسوم المتحركة في Flutter إلى نوعين رئيسيين: الرسوم المتحركة الضمنية (Implicit Animations) والرسوم المتحركة الصريحة (Explicit Animations).

## 1. الفرق بين الرسوم المتحركة الضمنية (Implicit) والصريحة (Explicit)

لفهم كيفية عمل الرسوم المتحركة في Flutter بشكل فعال، من الضروري التمييز بين هذين النوعين:

### الرسوم المتحركة الضمنية (Implicit Animations)

تُعد الرسوم المتحركة الضمنية هي الأسهل في الاستخدام والتطبيق، وهي مثالية للحالات التي تحتاج فيها إلى تحريك خاصية واحدة أو أكثر (مثل الحجم، اللون، التعتيم) من قيمة إلى أخرى تلقائيًا. في هذا النوع، لا تحتاج إلى إدارة دورة حياة الرسوم المتحركة يدويًا.

**المفهوم:** عندما تتغير قيمة خاصية معينة في `Widget` يدعم الرسوم المتحركة الضمنية، يقوم `Flutter` تلقائيًا بتحريك هذه الخاصية من قيمتها الحالية إلى القيمة الجديدة خلال فترة زمنية محددة.

**المميزات:**
*   **سهولة الاستخدام:** تتطلب الحد الأدنى من الكود، حيث لا تحتاج إلى التعامل مع `AnimationController` أو `Tween` بشكل مباشر.
*   **تلقائية:** تبدأ الرسوم المتحركة وتُدار تلقائيًا عند تغيير الخصائص.
*   **مناسبة للحالات البسيطة:** مثالية للتحولات البسيطة والمباشرة.

**العيوب:**
*   **تحكم محدود:** توفر تحكمًا أقل في دورة حياة الرسوم المتحركة (مثل التكرار، الإيقاف المؤقت، العكس).
*   **غير مناسبة للرسوم المتحركة المعقدة:** لا يمكن استخدامها لإنشاء رسوم متحركة متسلسلة أو متزامنة أو معقدة تتطلب منطقًا مخصصًا.

### الرسوم المتحركة الصريحة (Explicit Animations)

تُعد الرسوم المتحركة الصريحة أكثر قوة ومرونة، وتوفر تحكمًا كاملاً في دورة حياة الرسوم المتحركة. تتطلب هذه الرسوم المتحركة إدارة يدوية لـ `AnimationController` و `Tween`، مما يمنح المطور القدرة على إنشاء رسوم متحركة معقدة ومتخصصة.

**المفهوم:** في هذا النوع، تقوم بإنشاء `AnimationController` للتحكم في تقدم الرسوم المتحركة، و `Tween` لتحديد نطاق القيم التي ستتحرك بينها الخاصية. يمكنك بعد ذلك ربط هذه الأدوات بـ `Widget` لإنشاء الرسوم المتحركة.

**المميزات:**
*   **تحكم كامل:** توفر تحكمًا دقيقًا في كل جانب من جوانب الرسوم المتحركة، بما في ذلك البدء، الإيقاف، الإيقاف المؤقت، العكس، والتكرار.
*   **مرونة عالية:** يمكن استخدامها لإنشاء رسوم متحركة معقدة، متسلسلة، متزامنة، أو رسوم متحركة تعتمد على إيماءات المستخدم.
*   **إعادة الاستخدام:** يمكن إعادة استخدام `AnimationController` و `Tween` لرسوم متحركة متعددة.

**العيوب:**
*   **أكثر تعقيدًا:** تتطلب كتابة المزيد من الكود وفهمًا أعمق لمفاهيم الرسوم المتحركة في Flutter.
*   **إدارة يدوية:** تحتاج إلى إدارة دورة حياة `AnimationController` يدويًا (مثل التخلص منها عند عدم الحاجة).

### مقارنة سريعة

| الميزة             | الرسوم المتحركة الضمنية (Implicit Animations) | الرسوم المتحركة الصريحة (Explicit Animations) |
| :----------------- | :------------------------------------------- | :------------------------------------------- |
| **سهولة الاستخدام** | عالية جدًا                                    | متوسطة إلى منخفضة                            |
| **التحكم**         | محدود                                         | كامل                                         |
| **التعقيد**         | منخفض                                         | عالٍ                                         |
| **الاستخدام الأمثل** | التحولات البسيطة والمباشرة                   | الرسوم المتحركة المعقدة، المتسلسلة، المتزامنة |
| **الأدوات الرئيسية** | `ImplicitlyAnimatedWidget`s                  | `AnimationController`, `Tween`, `AnimatedBuilder` |


---
## 2. الرسوم المتحركة الضمنية (Implicit Animation Widgets)

تعتمد الرسوم المتحركة الضمنية في Flutter على مجموعة من الـ Widgets التي تبدأ الرسوم المتحركة تلقائيًا عند تغيير خصائصها. هذه الـ Widgets هي امتداد لـ `ImplicitlyAnimatedWidget` وتوفر طريقة سهلة لإنشاء تأثيرات بصرية سلسة دون الحاجة إلى إدارة دورة حياة الرسوم المتحركة يدويًا. فيما يلي شرح لأبرز هذه الـ Widgets مع أمثلة:

### 2.1. `AnimatedContainer`

يُستخدم `AnimatedContainer` لتحريك التغييرات في خصائص `Container` مثل العرض، الارتفاع، اللون، الهوامش (margins)، الحشوة (padding)، المحاذاة (alignment)، والديكور (decoration). عندما تتغير أي من هذه الخصائص، يقوم `AnimatedContainer` بتحريك الانتقال بين القيم القديمة والجديدة بسلاسة.

**الخصائص الرئيسية:**
*   `duration`: المدة الزمنية للرسوم المتحركة.
*   `curve`: منحنى الرسوم المتحركة الذي يحدد سرعة التغيير بمرور الوقت.
*   `onEnd`: دالة يتم استدعاؤها عند انتهاء الرسوم المتحركة.

**مثال:**
```dart
import 'package:flutter/material.dart';

class AnimatedContainerExample extends StatefulWidget {
  @override
  _AnimatedContainerExampleState createState() => _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  double _width = 100.0;
  double _height = 100.0;
  Color _color = Colors.blue;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(8.0);

  void _updateContainer() {
    setState(() {
      _width = _width == 100.0 ? 200.0 : 100.0;
      _height = _height == 100.0 ? 200.0 : 100.0;
      _color = _color == Colors.blue ? Colors.red : Colors.blue;
      _borderRadius = _borderRadius == BorderRadius.circular(8.0)
          ? BorderRadius.circular(50.0)
          : BorderRadius.circular(8.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedContainer Example')),
      body: Center(
        child: AnimatedContainer(
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: _borderRadius,
          ),
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
          child: MaterialButton(
            onPressed: _updateContainer,
            child: Text(
              'Tap to Animate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2.2. `AnimatedOpacity`

يُستخدم `AnimatedOpacity` لتحريك مستوى شفافية (opacity) الـ Widget التابع له. عندما تتغير قيمة `opacity`، يقوم الـ Widget بتحريك التغيير بسلاسة من القيمة القديمة إلى الجديدة.

**الخصائص الرئيسية:**
*   `opacity`: مستوى الشفافية (من 0.0 إلى 1.0).
*   `duration`: المدة الزمنية للرسوم المتحركة.
*   `curve`: منحنى الرسوم المتحركة.

**مثال:**
```dart
import 'package:flutter/material.dart';

class AnimatedOpacityExample extends StatefulWidget {
  @override
  _AnimatedOpacityExampleState createState() => _AnimatedOpacityExampleState();
}

class _AnimatedOpacityExampleState extends State<AnimatedOpacityExample> {
  double _opacity = 1.0;

  void _toggleOpacity() {
    setState(() {
      _opacity = _opacity == 1.0 ? 0.0 : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedOpacity Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.green,
                child: Center(child: Text('Fade Me', style: TextStyle(color: Colors.white, fontSize: 24))),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleOpacity,
              child: Text('Toggle Opacity'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.3. `AnimatedCrossFade`

يُستخدم `AnimatedCrossFade` للتحريك بين Widgetين مختلفين عن طريق التلاشي المتقاطع (cross-fading). يتم عرض أحد الـ Widgets بينما يتلاشى الآخر، مما يخلق انتقالًا سلسًا بينهما.

**الخصائص الرئيسية:**
*   `firstChild`: الـ Widget الأول.
*   `secondChild`: الـ Widget الثاني.
*   `crossFadeState`: الحالة الحالية (إما `CrossFadeState.showFirst` أو `CrossFadeState.showSecond`).
*   `duration`: المدة الزمنية للرسوم المتحركة.
*   `curve`: منحنى الرسوم المتحركة.

**مثال:**
```dart
import 'package:flutter/material.dart';

class AnimatedCrossFadeExample extends StatefulWidget {
  @override
  _AnimatedCrossFadeExampleState createState() => _AnimatedCrossFadeExampleState();
}

class _AnimatedCrossFadeExampleState extends State<AnimatedCrossFadeExample> {
  bool _showFirst = true;

  void _toggleCrossFade() {
    setState(() {
      _showFirst = !_showFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedCrossFade Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedCrossFade(
              firstChild: Container(
                width: 200,
                height: 200,
                color: Colors.purple,
                child: Center(child: Text('First Widget', style: TextStyle(color: Colors.white, fontSize: 24))),
              ),
              secondChild: Container(
                width: 200,
                height: 200,
                color: Colors.orange,
                child: Center(child: Text('Second Widget', style: TextStyle(color: Colors.white, fontSize: 24))),
              ),
              crossFadeState: _showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: Duration(seconds: 1),
              curve: Curves.easeInCubic,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleCrossFade,
              child: Text('Toggle Widgets'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.4. `AnimatedPositioned`

يُستخدم `AnimatedPositioned` لتحريك موضع الـ Widget داخل `Stack`. عندما تتغير خصائص الموضع (مثل `left`, `top`, `right`, `bottom`, `width`, `height`)، يقوم الـ Widget بتحريك الانتقال بسلاسة.

**الخصائص الرئيسية:**
*   `left`, `top`, `right`, `bottom`: لتحديد موضع الـ Widget.
*   `width`, `height`: لتحديد أبعاد الـ Widget.
*   `duration`: المدة الزمنية للرسوم المتحركة.
*   `curve`: منحنى الرسوم المتحركة.

**مثال:**
```dart
import 'package:flutter/material.dart';

class AnimatedPositionedExample extends StatefulWidget {
  @override
  _AnimatedPositionedExampleState createState() => _AnimatedPositionedExampleState();
}

class _AnimatedPositionedExampleState extends State<AnimatedPositionedExample> {
  bool _moved = false;

  void _togglePosition() {
    setState(() {
      _moved = !_moved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedPositioned Example')),
      body: Stack(
        children: <Widget>[
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            curve: Curves.elasticOut,
            top: _moved ? 50 : 200,
            left: _moved ? 50 : 100,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.teal,
              child: Center(child: Text('Move Me', style: TextStyle(color: Colors.white))),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _togglePosition,
                child: Text('Toggle Position'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.5. `AnimatedSwitcher`

يُستخدم `AnimatedSwitcher` للتحريك بين Widgetين مختلفين عن طريق تأثيرات انتقال مخصصة (مثل التلاشي، التحريك، أو التكبير/التصغير). عندما يتغير الـ Widget التابع له، يقوم `AnimatedSwitcher` بتحريك الانتقال بين الـ Widget القديم والجديد.

**الخصائص الرئيسية:**
*   `child`: الـ Widget الحالي الذي سيتم عرضه.
*   `duration`: المدة الزمنية للرسوم المتحركة.
*   `transitionBuilder`: دالة لإنشاء تأثير الانتقال المخصص.
*   `switchInCurve`, `switchOutCurve`: منحنيات الرسوم المتحركة للـ Widget الجديد والقديم على التوالي.

**مثال:**
```dart
import 'package:flutter/material.dart';

class AnimatedSwitcherExample extends StatefulWidget {
  @override
  _AnimatedSwitcherExampleState createState() => _AnimatedSwitcherExampleState();
}

class _AnimatedSwitcherExampleState extends State<AnimatedSwitcherExample> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedSwitcher Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '$_count',
                key: ValueKey<int>(_count),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _count += 1;
                });
              },
              child: Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.6. `AnimatedDefaultTextStyle`

يُستخدم `AnimatedDefaultTextStyle` لتحريك التغييرات في خصائص نمط النص (TextStyle) مثل اللون، حجم الخط، ووزن الخط. عندما تتغير هذه الخصائص، يقوم الـ Widget بتحريك الانتقال بسلاسة.

**الخصائص الرئيسية:**
*   `style`: نمط النص الجديد.
*   `duration`: المدة الزمنية للرسوم المتحركة.
*   `curve`: منحنى الرسوم المتحركة.

**مثال:**
```dart
import 'package:flutter/material.dart';

class AnimatedDefaultTextStyleExample extends StatefulWidget {
  @override
  _AnimatedDefaultTextStyleExampleState createState() => _AnimatedDefaultTextStyleExampleState();
}

class _AnimatedDefaultTextStyleExampleState extends State<AnimatedDefaultTextStyleExample> {
  bool _isLarge = false;

  void _toggleTextStyle() {
    setState(() {
      _isLarge = !_isLarge;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedDefaultTextStyle Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedDefaultTextStyle(
              style: TextStyle(
                fontSize: _isLarge ? 48.0 : 24.0,
                color: _isLarge ? Colors.blue : Colors.black,
                fontWeight: _isLarge ? FontWeight.bold : FontWeight.normal,
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Text('Hello Flutter'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleTextStyle,
              child: Text('Toggle Text Style'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.7. `AnimatedPadding`

يُستخدم `AnimatedPadding` لتحريك التغييرات في الحشوة (padding) حول الـ Widget التابع له. عندما تتغير قيمة `padding`، يقوم الـ Widget بتحريك الانتقال بسلاسة.

**الخصائص الرئيسية:**
*   `padding`: قيمة الحشوة الجديدة.
*   `duration`: المدة الزمنية للرسوم المتحركة.
*   `curve`: منحنى الرسوم المتحركة.

**مثال:**
```dart
import 'package:flutter/material.dart';

class AnimatedPaddingExample extends StatefulWidget {
  @override
  _AnimatedPaddingExampleState createState() => _AnimatedPaddingExampleState();
}

class _AnimatedPaddingExampleState extends State<AnimatedPaddingExample> {
  double _padding = 10.0;

  void _togglePadding() {
    setState(() {
      _padding = _padding == 10.0 ? 50.0 : 10.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedPadding Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedPadding(
              padding: EdgeInsets.all(_padding),
              duration: const Duration(seconds: 1),
              curve: Curves.bounceOut,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.indigo,
                child: Center(child: Text('Padded Content', style: TextStyle(color: Colors.white, fontSize: 20))),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _togglePadding,
              child: Text('Toggle Padding'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---
## 3. مفاهيم أساسية للرسوم المتحركة الصريحة (Explicit Animations)

قبل الغوص في الـ Widgets التي تعتمد على الرسوم المتحركة الصريحة، من الضروري فهم ثلاثة مفاهيم أساسية تشكل العمود الفقري لهذا النوع من الرسوم المتحركة في Flutter:

### 3.1. `AnimationController`

`AnimationController` هو الكائن الذي يدير الرسوم المتحركة. إنه مسؤول عن بدء الرسوم المتحركة، إيقافها، إيقافها مؤقتًا، عكسها، وتحديد مدتها. يمكن التفكير فيه كـ "محرك" الرسوم المتحركة.

**الخصائص الرئيسية:**
*   **`duration`**: تحدد المدة الإجمالية للرسوم المتحركة. على سبيل المثال، إذا كانت المدة ثانية واحدة، فإن الرسوم المتحركة ستستغرق ثانية واحدة للانتقال من 0.0 إلى 1.0.
*   **`vsync`**: يتطلب `AnimationController` كائن `TickerProvider` (عادةً `SingleTickerProviderStateMixin` أو `TickerProviderStateMixin`) لمنع الرسوم المتحركة من استهلاك الموارد عندما لا تكون مرئية على الشاشة. يضمن `vsync` أن الرسوم المتحركة لا تبني إطارات خارج الشاشة.
*   **`value`**: يمثل القيمة الحالية للرسوم المتحركة، والتي تتراوح عادةً من 0.0 إلى 1.0. هذه القيمة تتغير بمرور الوقت بناءً على `duration` و `curve`.

**الاستخدامات الشائعة:**
*   `forward()`: يبدأ الرسوم المتحركة من البداية إلى النهاية.
*   `reverse()`: يعكس الرسوم المتحركة من النهاية إلى البداية.
*   `repeat()`: يكرر الرسوم المتحركة بشكل لا نهائي.
*   `stop()`: يوقف الرسوم المتحركة.
*   `dispose()`: يجب استدعاؤها للتخلص من `AnimationController` عند عدم الحاجة إليه لمنع تسرب الذاكرة.

**مثال على التهيئة:**
```dart
class MyAnimationWidget extends StatefulWidget {
  @override
  _MyAnimationWidgetState createState() => _MyAnimationWidgetState();
}

class _MyAnimationWidgetState extends State<MyAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ... rest of the widget
}
```

### 3.2. `Tween`

`Tween` (اختصار لـ "between") يحدد نطاق القيم التي ستتحرك بينها الرسوم المتحركة. لا يقوم `Tween` نفسه بالرسوم المتحركة، بل يحدد فقط كيفية "ترجمة" قيمة `AnimationController` (التي تتراوح من 0.0 إلى 1.0) إلى قيمة أخرى (مثل حجم، لون، أو موضع).

**الخصائص الرئيسية:**
*   **`begin`**: القيمة الأولية للرسوم المتحركة.
*   **`end`**: القيمة النهائية للرسوم المتحركة.

**الاستخدامات الشائعة:**
*   `animate(Animation parent)`: ينشئ كائن `Animation` جديد يربط `Tween` بـ `AnimationController`. هذا الكائن `Animation` هو الذي ستستخدمه لتطبيق القيم المتحركة على الـ Widget الخاص بك.

**أنواع `Tween`:**
يوجد العديد من أنواع `Tween` للتعامل مع أنواع بيانات مختلفة:
*   `Tween<double>`: للقيم العشرية (مثل الحجم، التعتيم).
*   `ColorTween`: للألوان.
*   `SizeTween`: للأحجام.
*   `RectTween`: للمستطيلات.
*   `IntTween`: للأعداد الصحيحة.

**مثال:**
```dart
// ... داخل _MyAnimationWidgetState

late Animation<double> _animation;

@override
void initState() {
  super.initState();
  _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );
  _animation = Tween<double>(begin: 0.0, end: 300.0).animate(_controller);
}

// ...
```
في هذا المثال، عندما يتغير `_controller.value` من 0.0 إلى 1.0، ستتغير قيمة `_animation.value` من 0.0 إلى 300.0.

### 3.3. `Curve`

`Curve` (المنحنى) يحدد سرعة الرسوم المتحركة بمرور الوقت. بدون منحنى، ستكون الرسوم المتحركة خطية (أي تتحرك بنفس السرعة طوال الوقت). تضيف المنحنيات إحساسًا طبيعيًا للرسوم المتحركة عن طريق تسريعها أو إبطائها في نقاط مختلفة.

**الاستخدامات الشائعة:**
Flutter يوفر مجموعة واسعة من المنحنيات الجاهزة في فئة `Curves`:
*   `Curves.linear`: حركة خطية ثابتة.
*   `Curves.easeIn`: تبدأ ببطء ثم تتسارع.
*   `Curves.easeOut`: تبدأ بسرعة ثم تتباطأ.
*   `Curves.easeInOut`: تبدأ ببطء، تتسارع في المنتصف، ثم تتباطأ في النهاية.
*   `Curves.bounceIn`, `Curves.bounceOut`, `Curves.bounceInOut`: تأثيرات ارتداد.
*   `Curves.elasticIn`, `Curves.elasticOut`, `Curves.elasticInOut`: تأثيرات مرنة.

يمكن تطبيق `Curve` على `Animation` باستخدام الدالة `curved`:

**مثال:**
```dart
// ... داخل _MyAnimationWidgetState

late Animation<double> _animation;

@override
void initState() {
  super.initState();
  _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );
  _animation = Tween<double>(begin: 0.0, end: 300.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );
}

// ...
```
هنا، `CurvedAnimation` يلف `AnimationController` ويطبق `Curves.easeOutBack` على تقدم الرسوم المتحركة، مما يجعلها تبدأ بسرعة ثم تتباطأ مع تأثير ارتداد خفيف في النهاية.

---
## 4. الرسوم المتحركة الصريحة (Explicit Animation Widgets)

بعد فهم `AnimationController` و `Tween` و `Curve`، يمكننا الآن استكشاف الـ Widgets التي تستخدم هذه المفاهيم لإنشاء رسوم متحركة صريحة. هذه الـ Widgets توفر مرونة كبيرة وتسمح بإنشاء تأثيرات معقدة.

### 4.1. `AnimatedBuilder`

`AnimatedBuilder` هو Widget قوي يسمح لك بإعادة بناء جزء من شجرة الـ Widget الخاصة بك عندما تتغير قيمة `Animation` معينة. إنه فعال للغاية لأنه يعيد بناء الجزء المتحرك فقط من الـ Widget، وليس الـ Widget بأكمله، مما يحسن الأداء.

**الخصائص الرئيسية:**
*   `animation`: كائن `Animation` الذي يراقب التغييرات فيه.
*   `builder`: دالة يتم استدعاؤها في كل مرة تتغير فيها قيمة `animation`. تستقبل `BuildContext` و `Widget child` (اختياري).
*   `child`: (اختياري) Widget ثابت لا يتغير أثناء الرسوم المتحركة. يتم تمريره إلى دالة `builder` لتجنب إعادة بنائه.

**مثال:**
```dart
import 'package:flutter/material.dart';

class AnimatedBuilderExample extends StatefulWidget {
  @override
  _AnimatedBuilderExampleState createState() => _AnimatedBuilderExampleState();
}

class _AnimatedBuilderExampleState extends State<AnimatedBuilderExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 50.0, end: 200.0).animate(_controller)
      ..addListener(() {
        setState(() {}); // إعادة بناء الـ Widget عند كل تغيير في قيمة الرسوم المتحركة
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedBuilder Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  width: _animation.value,
                  height: _animation.value,
                  color: Colors.blue,
                  child: child,
                );
              },
              child: Center(child: Text('Grow Me', style: TextStyle(color: Colors.white, fontSize: 24))),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.status == AnimationStatus.completed) {
                  _controller.reverse();
                } else {
                  _controller.forward();
                }
              },
              child: Text('Toggle Animation'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**ملاحظة:** في المثال أعلاه، تم استخدام `addListener` و `setState` داخل `AnimatedBuilder` فقط لتوضيح كيفية عمل `_animation.value`. في التطبيقات الحقيقية، لا تحتاج إلى استدعاء `setState` داخل `AnimatedBuilder` لأن `AnimatedBuilder` نفسه يعيد بناء الـ Widget عند تغير قيمة `animation`.

### 4.2. `FadeTransition`

`FadeTransition` هو Widget يحرك شفافية (opacity) الـ Widget التابع له. يتطلب كائن `Animation<double>` تتراوح قيمته من 0.0 إلى 1.0.

**الخصائص الرئيسية:**
*   `opacity`: كائن `Animation<double>` يتحكم في مستوى الشفافية.
*   `child`: الـ Widget الذي سيتم تطبيق تأثير التلاشي عليه.

**مثال:**
```dart
import 'package:flutter/material.dart';

class FadeTransitionExample extends StatefulWidget {
  @override
  _FadeTransitionExampleState createState() => _FadeTransitionExampleState();
}

class _FadeTransitionExampleState extends State<FadeTransitionExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FadeTransition Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeTransition(
              opacity: _animation,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.red,
                child: Center(child: Text('Fade In/Out', style: TextStyle(color: Colors.white, fontSize: 24))),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.status == AnimationStatus.completed) {
                  _controller.reverse();
                } else if (_controller.status == AnimationStatus.dismissed) {
                  _controller.forward();
                }
              },
              child: Text('Toggle Fade'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.3. `ScaleTransition`

`ScaleTransition` هو Widget يحرك حجم الـ Widget التابع له. يتطلب كائن `Animation<double>` تتراوح قيمته عادةً من 0.0 إلى 1.0 (أو أكثر للتكبير).

**الخصائص الرئيسية:**
*   `scale`: كائن `Animation<double>` يتحكم في عامل التكبير/التصغير.
*   `child`: الـ Widget الذي سيتم تطبيق تأثير الحجم عليه.

**مثال:**
```dart
import 'package:flutter/material.dart';

class ScaleTransitionExample extends StatefulWidget {
  @override
  _ScaleTransitionExampleState createState() => _ScaleTransitionExampleState();
}

class _ScaleTransitionExampleState extends State<ScaleTransitionExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ScaleTransition Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.green,
                child: Center(child: Text('Scale Me', style: TextStyle(color: Colors.white, fontSize: 20))),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.status == AnimationStatus.completed) {
                  _controller.reverse();
                } else if (_controller.status == AnimationStatus.dismissed) {
                  _controller.forward();
                }
              },
              child: Text('Toggle Scale'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.4. `RotationTransition`

`RotationTransition` هو Widget يحرك دوران الـ Widget التابع له. يتطلب كائن `Animation<double>` يمثل عدد الدورات (على سبيل المثال، 1.0 لدورة كاملة).

**الخصائص الرئيسية:**
*   `turns`: كائن `Animation<double>` يتحكم في عدد الدورات.
*   `child`: الـ Widget الذي سيتم تطبيق تأثير الدوران عليه.

**مثال:**
```dart
import 'package:flutter/material.dart';

class RotationTransitionExample extends StatefulWidget {
  @override
  _RotationTransitionExampleState createState() => _RotationTransitionExampleState();
}

class _RotationTransitionExampleState extends State<RotationTransitionExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RotationTransition Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RotationTransition(
              turns: _animation,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.purple,
                child: Center(child: Text('Rotate Me', style: TextStyle(color: Colors.white, fontSize: 20))),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.status == AnimationStatus.completed) {
                  _controller.reverse();
                } else if (_controller.status == AnimationStatus.dismissed) {
                  _controller.forward();
                }
              },
              child: Text('Toggle Rotation'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.5. `SlideTransition`

`SlideTransition` هو Widget يحرك موضع الـ Widget التابع له. يتطلب كائن `Animation<Offset>` يمثل الإزاحة (offset) التي سيتحرك بها الـ Widget.

**الخصائص الرئيسية:**
*   `position`: كائن `Animation<Offset>` يتحكم في موضع الـ Widget.
*   `child`: الـ Widget الذي سيتم تطبيق تأثير التحريك عليه.

**مثال:**
```dart
import 'package:flutter/material.dart';

class SlideTransitionExample extends StatefulWidget {
  @override
  _SlideTransitionExampleState createState() => _SlideTransitionExampleState();
}

class _SlideTransitionExampleState extends State<SlideTransitionExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.5, 0.0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SlideTransition Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SlideTransition(
              position: _animation,
              child: Container(
                width: 150,
                height: 150,
                color: Colors.orange,
                child: Center(child: Text('Slide Me', style: TextStyle(color: Colors.white, fontSize: 20))),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.status == AnimationStatus.completed) {
                  _controller.reverse();
                } else if (_controller.status == AnimationStatus.dismissed) {
                  _controller.forward();
                }
              },
              child: Text('Toggle Slide'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.6. `DecoratedBoxTransition`

`DecoratedBoxTransition` هو Widget يحرك خصائص `Decoration` مثل اللون، `borderRadius`، `boxShadow`، وما إلى ذلك. يتطلب كائن `Animation<Decoration>`.

**الخصائص الرئيسية:**
*   `decoration`: كائن `Animation<Decoration>` يتحكم في الديكور.
*   `child`: الـ Widget الذي سيتم تطبيق تأثير الديكور عليه.

**مثال:**
```dart
import 'package:flutter/material.dart';

class DecoratedBoxTransitionExample extends StatefulWidget {
  @override
  _DecoratedBoxTransitionExampleState createState() => _DecoratedBoxTransitionExampleState();
}

class _DecoratedBoxTransitionExampleState extends State<DecoratedBoxTransitionExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Decoration> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = DecorationTween(
      begin: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      end: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(50.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 15,
            offset: Offset(5, 5),
          ),
        ],
      ),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DecoratedBoxTransition Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DecoratedBoxTransition(
              decoration: _animation,
              child: Container(
                width: 200,
                height: 200,
                child: Center(child: Text('Decorate Me', style: TextStyle(color: Colors.white, fontSize: 24))),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.status == AnimationStatus.completed) {
                  _controller.reverse();
                } else if (_controller.status == AnimationStatus.dismissed) {
                  _controller.forward();
                }
              },
              child: Text('Toggle Decoration'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---
## 5. الرسوم المتحركة المتسلسلة (Staggered Animations)

الرسوم المتحركة المتسلسلة هي تسلسلات من الرسوم المتحركة الصغيرة التي تحدث في تتابع أو تداخل، مما يخلق تأثيرًا بصريًا أكثر تعقيدًا وجاذبية. بدلاً من تحريك خاصية واحدة فقط، يمكنك تحريك عدة خصائص (مثل الحجم، الموضع، الشفافية) لـ Widget واحد أو عدة Widgets بشكل منسق.

لإنشاء رسوم متحركة متسلسلة، ستحتاج إلى دمج `AnimationController` واحد مع عدة كائنات `Animation`، كل منها يستخدم `Interval` لتحديد متى تبدأ وتنتهي الرسوم المتحركة الخاصة به ضمن المدة الإجمالية لـ `AnimationController`.

**المكونات الرئيسية:**
*   **`AnimationController`**: يدير المدة الإجمالية للرسوم المتحركة المتسلسلة.
*   **`Interval`**: يحدد جزءًا من المدة الإجمالية لـ `AnimationController` الذي ستحدث فيه رسوم متحركة معينة. يأخذ `begin` و `end` كقيم تتراوح من 0.0 إلى 1.0.
*   **`Tween`**: يحدد نطاق القيم لكل رسوم متحركة فرعية.
*   **`AnimatedBuilder`**: يُستخدم لإعادة بناء الـ Widgets التي تتأثر بالرسوم المتحركة.

**مثال:**
لنقم بإنشاء رسوم متحركة متسلسلة لمربع يتلاشى، يتغير حجمه، ويتحرك إلى الأسفل.

```dart
import 'package:flutter/material.dart';

class StaggeredAnimationExample extends StatefulWidget {
  @override
  _StaggeredAnimationExampleState createState() => _StaggeredAnimationExampleState();
}

class _StaggeredAnimationExampleState extends State<StaggeredAnimationExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<EdgeInsets> _paddingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0, // تبدأ من بداية الرسوم المتحركة الكلية
          0.5, // تنتهي عند منتصف الرسوم المتحركة الكلية
          curve: Curves.easeIn,
        ),
      ),
    );

    _sizeAnimation = Tween<double>(begin: 50.0, end: 150.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.25, // تبدأ بعد ربع المدة الكلية
          0.75, // تنتهي عند ثلاثة أرباع المدة الكلية
          curve: Curves.elasticOut,
        ),
      ),
    );

    _paddingAnimation = EdgeInsetsTween(
      begin: EdgeInsets.only(top: 0.0),
      end: EdgeInsets.only(top: 100.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.5, // تبدأ من منتصف المدة الكلية
          1.0, // تنتهي عند نهاية المدة الكلية
          curve: Curves.bounceOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Staggered Animation Example')),
      body: GestureDetector(
        onTap: () {
          if (_controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.forward) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        },
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Container(
                padding: _paddingAnimation.value,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: _sizeAnimation.value,
                    height: _sizeAnimation.value,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        'Staggered!',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
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
```

في هذا المثال:
*   يبدأ المربع بالظهور تدريجيًا (`_opacityAnimation`) في النصف الأول من الرسوم المتحركة الكلية.
*   يبدأ حجم المربع في التغير (`_sizeAnimation`) بعد ربع المدة الكلية وينتهي عند ثلاثة أرباع المدة، مع تأثير مرن.
*   يبدأ المربع في التحرك للأسفل (`_paddingAnimation`) من منتصف المدة الكلية وينتهي عند النهاية، مع تأثير ارتداد.

هذا يوضح كيف يمكن لـ `Interval` أن يسمح لك بتنسيق رسوم متحركة متعددة ضمن `AnimationController` واحد لإنشاء تأثيرات متسلسلة معقدة.

---
## 6. Hero Animations (التحولات بين الصفحات)

تُعد Hero Animations نوعًا خاصًا من الرسوم المتحركة في Flutter تُستخدم لإنشاء انتقالات بصرية سلسة بين شاشتين (صفحتين) عندما ينتقل المستخدم من إحداهما إلى الأخرى. الفكرة الأساسية هي أن عنصرًا واحدًا (عادةً صورة أو أيقونة) يبدو وكأنه "يطير" من موقعه في الشاشة الأولى إلى موقعه الجديد في الشاشة الثانية.

**كيف تعمل Hero Animations؟**

تعتمد Hero Animations على مفهوم "البطل" (Hero)، وهو Widget مشترك بين شاشتين. عندما يتم الانتقال بين الشاشتين، يقوم Flutter تلقائيًا بتحريك هذا الـ Widget من موقعه وحجمه في الشاشة المصدر إلى موقعه وحجمه في الشاشة الوجهة.

**المكونات الرئيسية:**
*   **`Hero` Widget**: يجب أن يتم تغليف الـ Widget الذي تريد تحريكه داخل `Hero` Widget في كلتا الشاشتين (المصدر والوجهة).
*   **`tag`**: أهم خاصية في `Hero` Widget. يجب أن تكون قيمة `tag` فريدة ومتطابقة تمامًا بين الـ `Hero` Widget في الشاشة المصدر والـ `Hero` Widget في الشاشة الوجهة. هذه الـ `tag` هي التي تربط بين الـ Widgets وتخبر Flutter بأنهما نفس العنصر.

**مثال:**

لنقم بإنشاء مثال بسيط حيث تنتقل صورة من شاشة قائمة إلى شاشة تفاصيل.

**الشاشة الأولى (شاشة القائمة - `FirstScreen`):**
```dart
import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('First Screen')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondScreen()),
            );
          },
          child: Hero(
            tag: 'hero-image-tag',
            child: Image.network(
              'https://via.placeholder.com/150',
              width: 100,
              height: 100,
            ),
          ),
        ),
      ),
    );
  }
}
```

**الشاشة الثانية (شاشة التفاصيل - `SecondScreen`):**
```dart
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Screen')),
      body: Center(
        child: Hero(
          tag: 'hero-image-tag',
          child: Image.network(
            'https://via.placeholder.com/400',
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}
```

**كيفية الاستخدام:**
1.  قم بتغليف الـ Widget الذي تريد تحريكه داخل `Hero` Widget في كلتا الشاشتين.
2.  قم بتعيين نفس قيمة `tag` لكل من `Hero` Widgets. يجب أن تكون هذه الـ `tag` فريدة على مستوى التطبيق.
3.  استخدم `Navigator.push` أو `Navigator.pushNamed` للانتقال بين الشاشتين. سيتولى Flutter الباقي تلقائيًا.

**ملاحظات هامة:**
*   يجب أن يكون الـ `tag` فريدًا. إذا كان هناك أكثر من `Hero` Widget بنفس الـ `tag` في نفس المسار (Route)، فقد يؤدي ذلك إلى سلوك غير متوقع.
*   يمكن استخدام `Hero` مع أي نوع من الـ Widgets، ليس فقط الصور.
*   يمكنك تخصيص الرسوم المتحركة لـ `Hero` باستخدام خصائص مثل `flightShuttleBuilder` و `createRectTween`، مما يمنحك تحكمًا أكبر في كيفية ظهور الانتقال.

---
## 7. الرسوم المتحركة المخصصة باستخدام `CustomPainter`

عندما تحتاج إلى رسوم متحركة تتجاوز ما يمكن تحقيقه باستخدام الـ Widgets الجاهزة، يوفر Flutter القدرة على الرسم المخصص باستخدام `CustomPainter`. يتيح لك هذا النهج رسم أي شيء تريده على الشاشة، ثم تحريك هذه الرسومات باستخدام مفاهيم الرسوم المتحركة الصريحة.

**كيف يعمل `CustomPainter` مع الرسوم المتحركة؟**

`CustomPainter` هو كلاس مجرد يتطلب منك تجاوز دالتين رئيسيتين:
*   **`paint(Canvas canvas, Size size)`**: هذه الدالة هي المكان الذي تقوم فيه بالرسم الفعلي. يتم تزويدها بكائن `Canvas` للرسم عليه وكائن `Size` يمثل حجم المنطقة المتاحة للرسم.
*   **`shouldRepaint(covariant CustomPainter oldDelegate)`**: هذه الدالة تحدد ما إذا كان يجب إعادة رسم الـ Widget. لتمكين الرسوم المتحركة، يجب أن تعيد `true` عندما تتغير البيانات التي تؤثر على الرسم.

لتحريك الرسم المخصص، ستقوم بتمرير قيمة `Animation` إلى `CustomPainter` الخاص بك. في كل مرة تتغير فيها قيمة `Animation`، سيتم استدعاء `paint` مرة أخرى مع القيم الجديدة، مما يؤدي إلى تحديث الرسم.

**المكونات الرئيسية:**
*   **`AnimationController`**: لإدارة دورة حياة الرسوم المتحركة.
*   **`Tween`**: لتحديد نطاق القيم التي ستتحرك بينها الرسوم المتحركة (مثل نصف قطر دائرة، موضع نقطة، لون).
*   **`CustomPainter`**: الكلاس الذي يحتوي على منطق الرسم.
*   **`CustomPaint` Widget**: الـ Widget الذي يستخدم `CustomPainter` لرسم المحتوى.
*   **`AnimatedBuilder`**: لربط `AnimationController` بـ `CustomPaint`، مما يضمن إعادة رسم الـ `CustomPaint` عند كل تحديث للرسوم المتحركة.

**مثال:**
لنقم بإنشاء دائرة يتغير نصف قطرها ولونها بشكل متحرك.

```dart
import 'package:flutter/material.dart';

class AnimatedCustomPainterExample extends StatefulWidget {
  @override
  _AnimatedCustomPainterExampleState createState() => _AnimatedCustomPainterExampleState();
}

class _AnimatedCustomPainterExampleState extends State<AnimatedCustomPainterExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _radiusAnimation = Tween<double>(begin: 20.0, end: 100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.red).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Animated CustomPainter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(200, 200), // حجم منطقة الرسم
                  painter: CirclePainter(
                    radius: _radiusAnimation.value,
                    color: _colorAnimation.value!,
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.status == AnimationStatus.completed) {
                  _controller.reverse();
                } else {
                  _controller.forward();
                }
              },
              child: Text('Toggle Animation'),
            ),
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double radius;
  final Color color;

  CirclePainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    // إعادة الرسم فقط إذا تغير نصف القطر أو اللون
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}
```

في هذا المثال:
*   `_AnimatedCustomPainterExampleState` يدير `AnimationController` واثنين من كائنات `Animation` (`_radiusAnimation` و `_colorAnimation`).
*   `AnimatedBuilder` يراقب `_controller` ويعيد بناء `CustomPaint` في كل مرة تتغير فيها قيمة الرسوم المتحركة.
*   `CirclePainter` هو الكلاس المخصص للرسم. يستقبل `radius` و `color` كخصائص.
*   دالة `paint` في `CirclePainter` تستخدم القيم الحالية لـ `radius` و `color` لرسم الدائرة.
*   دالة `shouldRepaint` تعيد `true` إذا تغير `radius` أو `color`، مما يضمن إعادة رسم الدائرة فقط عند الضرورة.

يسمح لك هذا النهج بإنشاء رسوم متحركة معقدة للغاية وتفاعلية بالكامل، حيث يمكنك التحكم في كل بكسل على الشاشة.

---
## 8. نصائح لتحسين أداء الرسوم المتحركة (Performance Optimization)

تُعد الرسوم المتحركة جزءًا حيويًا من تجربة المستخدم، ولكنها قد تؤثر سلبًا على الأداء إذا لم يتم التعامل معها بشكل صحيح. يهدف Flutter إلى توفير 60 إطارًا في الثانية (fps) (أو 120 إطارًا في الثانية على الأجهزة التي تدعم ذلك) للحصول على رسوم متحركة سلسة. لتحقيق ذلك، من المهم اتباع بعض أفضل الممارسات:

### 8.1. استخدم `const` Widgets حيثما أمكن

عندما يكون الـ Widget ثابتًا ولا يتغير، استخدم الكلمة المفتاحية `const`. هذا يخبر Flutter بأن الـ Widget لا يحتاج إلى إعادة بناء، مما يوفر موارد المعالجة ويحسن الأداء، خاصة داخل الرسوم المتحركة.

**مثال:**
```dart
// تجنب إعادة بناء هذا النص في كل مرة تتغير فيها الرسوم المتحركة
const Text(
  'Hello',
  style: TextStyle(fontSize: 24),
)
```

### 8.2. استخدم `AnimatedBuilder` و `Transition Widgets` بفعالية

*   **`AnimatedBuilder`**: بدلاً من استدعاء `setState` في كل مرة تتغير فيها قيمة الرسوم المتحركة، استخدم `AnimatedBuilder`. يقوم `AnimatedBuilder` بإعادة بناء الجزء المتغير فقط من شجرة الـ Widget، مما يقلل من العمل الذي يقوم به Flutter.
*   **`child` في `AnimatedBuilder`**: إذا كان لديك جزء من الـ Widget داخل `AnimatedBuilder` لا يتغير أثناء الرسوم المتحركة، قم بتمريره كـ `child` إلى `AnimatedBuilder`. هذا يمنع إعادة بناء هذا الجزء غير المتغير.

**مثال:**
```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: _animation.value,
      child: child, // هذا الـ Widget لا يتم إعادة بنائه في كل إطار
    );
  },
  child: const Text(
    'Scaling Text',
    style: TextStyle(fontSize: 24),
  ),
)
```

### 8.3. تجنب إعادة بناء الـ Widgets غير الضرورية

تأكد من أنك لا تعيد بناء أجزاء كبيرة من شجرة الـ Widget الخاصة بك في كل إطار رسوم متحركة. قم بعزل الـ Widgets التي تحتاج إلى التحديث داخل `AnimatedBuilder` أو `Transition Widgets`.

### 8.4. استخدم `TickerProvider` الصحيح

*   **`SingleTickerProviderStateMixin`**: استخدمه عندما يكون لديك `AnimationController` واحد فقط في `State` الخاص بك.
*   **`TickerProviderStateMixin`**: استخدمه عندما يكون لديك أكثر من `AnimationController` واحد في `State` الخاص بك.

يضمن `TickerProvider` أن الرسوم المتحركة لا تستهلك موارد المعالجة عندما لا تكون مرئية على الشاشة، مما يمنع تسرب الذاكرة ويحسن الأداء.

### 8.5. اختر `Curve` المناسب

بعض المنحنيات (Curves) قد تكون أكثر تعقيدًا من غيرها في الحساب. على الرغم من أن Flutter محسن بشكل جيد، إلا أن استخدام منحنيات أبسط عندما يكون ذلك ممكنًا يمكن أن يساهم في أداء أفضل.

### 8.6. تجنب العمليات الثقيلة في دالة `build`

دالة `build` يمكن استدعاؤها عدة مرات في الثانية أثناء الرسوم المتحركة. تجنب إجراء عمليات حسابية معقدة، أو قراءة من قاعدة البيانات، أو طلبات الشبكة داخل دالة `build`. قم بإجراء هذه العمليات مرة واحدة في `initState` أو `didUpdateWidget` أو في دالة منفصلة.

### 8.7. استخدم `RepaintBoundary` للـ Widgets المعقدة

إذا كان لديك Widget معقد يتم تحريكه، فإن تغليفه بـ `RepaintBoundary` يمكن أن يساعد في تحسين الأداء. يخبر `RepaintBoundary` Flutter بأن هذا الـ Widget يمكن إعادة رسمه بشكل مستقل عن بقية الشجرة، مما يقلل من منطقة إعادة الرسم.

**مثال:**
```dart
RepaintBoundary(
  child: AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      return Transform.rotate(
        angle: _animation.value,
        child: child,
      );
    },
    child: MyComplexWidget(),
  ),
)
```

### 8.8. اختبار الأداء باستخدام أدوات Flutter DevTools

استخدم Flutter DevTools (خاصة أداة Performance) لتحديد أي اختناقات في الأداء في الرسوم المتحركة الخاصة بك. يمكن أن تساعدك هذه الأدوات في رؤية متى يتم إعادة بناء الـ Widgets، وكم من الوقت تستغرقه كل عملية، مما يساعدك على تحسين الكود الخاص بك.

---

## 9. Rive Animations

Rive هو أداة تصميم ورسوم متحركة تفاعلية تتيح للمصممين والمطورين إنشاء رسوم متحركة متجهة (Vector-based) عالية الجودة وتفاعلية يمكن تشغيلها بسلاسة عبر منصات متعددة، بما في ذلك Flutter. تتميز رسوم Rive المتحركة بأنها خفيفة الوزن، وقابلة للتطوير (scalable)، ويمكن التحكم فيها برمجياً بشكل كامل، مما يجعلها بديلاً قويًا للرسوم المتحركة التقليدية أو ملفات GIF.

### 9.1. لماذا Rive؟

*   **رسوم متجهة:** تضمن جودة عالية على أي دقة شاشة دون فقدان الوضوح.
*   **تفاعلية:** يمكن التحكم في الرسوم المتحركة برمجياً بناءً على تفاعلات المستخدم أو حالة التطبيق.
*   **خفيفة الوزن:** حجم الملفات صغير مقارنة بالرسوم المتحركة المستندة إلى الفيديو أو الصور.
*   **أداء عالي:** مصممة للعمل بسلاسة على الأجهزة المحمولة والويب.
*   **State Machine:** تسمح بإنشاء منطق معقد للرسوم المتحركة والانتقال بين الحالات المختلفة.

### 9.2. البدء مع Rive في Flutter

لدمج Rive في تطبيق Flutter، تحتاج إلى إضافة حزمة `rive` إلى ملف `pubspec.yaml` الخاص بك:

```yaml
dependencies:
  flutter:
    sdk: flutter
  rive: ^0.11.0 # تأكد من استخدام أحدث إصدار
```

بعد إضافة الحزمة، قم بتشغيل `flutter pub get`.

### 9.3. تشغيل ملف Rive بسيط

لنفترض أن لديك ملف Rive باسم `my_animation.riv` في مجلد `assets` الخاص بك. أولاً، تأكد من تعريف مجلد `assets` في `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/
```

ثم يمكنك تحميل وتشغيل الرسوم المتحركة باستخدام `RiveAnimation.asset`:

**مثال:**
```dart
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SimpleRiveAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Rive Animation')),
      body: Center(
        child: RiveAnimation.asset(
          'assets/my_animation.riv',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
```

### 9.4. التحكم في الرسوم المتحركة باستخدام `StateMachine`

تُعد `StateMachine` (آلة الحالة) في Rive ميزة قوية تسمح لك بتحديد منطق معقد للانتقال بين الرسوم المتحركة المختلفة بناءً على المدخلات (inputs) مثل الأرقام، القيم المنطقية (booleans)، أو المشغلات (triggers). هذا يتيح لك إنشاء رسوم متحركة تفاعلية تستجيب لتفاعلات المستخدم.

**المكونات الرئيسية:**
*   **`StateMachineController`**: الكائن الذي يسمح لك بالتفاعل مع `StateMachine` في ملف Rive.
*   **`SMIBool`, `SMINumber`, `SMITrigger`**: كائنات تمثل المدخلات التي تم تعريفها في `StateMachine` في Rive Editor.

**مثال:**
لنفترض أن لديك ملف Rive يحتوي على `StateMachine` مع مدخل منطقي (boolean input) يسمى `isHovering` ومدخل مشغل (trigger input) يسمى `onTap`.

```dart
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class InteractiveRiveAnimation extends StatefulWidget {
  @override
  _InteractiveRiveAnimationState createState() => _InteractiveRiveAnimationState();
}

class _InteractiveRiveAnimationState extends State<InteractiveRiveAnimation> {
  late StateMachineController _riveController;
  SMIBool? _isHoveringInput;
  SMITrigger? _onTapInput;

  void _onRiveInit(Artboard artboard) {
    _riveController = StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    artboard.addController(_riveController);
    _isHoveringInput = _riveController.findInput<bool>('isHovering') as SMIBool?;
    _onTapInput = _riveController.findInput<bool>('onTap') as SMITrigger?;
  }

  void _toggleHover(bool value) {
    _isHoveringInput?.value = value;
  }

  void _triggerTap() {
    _onTapInput?.fire();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Interactive Rive Animation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MouseRegion(
              onEnter: (_) => _toggleHover(true),
              onExit: (_) => _toggleHover(false),
              child: GestureDetector(
                onTap: _triggerTap,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/interactive_animation.riv',
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _triggerTap,
              child: Text('Trigger Tap Animation'),
            ),
          ],
        ),
      ),
    );
  }
}
```

في هذا المثال:
*   يتم تحميل ملف Rive `interactive_animation.riv`.
*   دالة `_onRiveInit` يتم استدعاؤها عند تهيئة Artboard. هنا، نقوم بإنشاء `StateMachineController` والبحث عن المدخلات (`isHovering` و `onTap`) التي تم تعريفها في Rive Editor.
*   `MouseRegion` و `GestureDetector` يُستخدمان للتفاعل مع الرسوم المتحركة. عند مرور الماوس فوق الـ Widget، يتم تحديث قيمة `_isHoveringInput`، وعند النقر، يتم إطلاق `_onTapInput`.

### 9.5. نصائح لاستخدام Rive بفعالية

*   **تصميم الرسوم المتحركة في Rive Editor:** ابدأ دائمًا بتصميم الرسوم المتحركة ومنطق `StateMachine` الخاص بك في Rive Editor. هذا يسهل عملية الدمج في Flutter.
*   **تسمية المدخلات بوضوح:** استخدم أسماء واضحة ومفهومة للمدخلات في `StateMachine` لتسهيل التحكم بها برمجياً.
*   **تحسين ملفات Rive:** قم بتحسين ملفات `.riv` لتقليل حجمها وتحسين الأداء. يمكنك القيام بذلك من خلال Rive Editor.
*   **إدارة الموارد:** تذكر أن تتخلص من `StateMachineController` عند عدم الحاجة إليه لمنع تسرب الذاكرة، خاصة في الـ Widgets التي يتم التخلص منها وإعادة إنشائها بشكل متكرر.

يفتح Rive عالمًا جديدًا من الإمكانيات لإنشاء رسوم متحركة غنية وتفاعلية في تطبيقات Flutter، مما يضيف مستوى احترافيًا لتجربة المستخدم.

---


## الخاتمة

يوفر Flutter نظامًا قويًا ومرنًا للرسوم المتحركة يسمح للمطورين بإنشاء تجارب مستخدم مذهلة. سواء كنت بحاجة إلى تحولات بسيطة باستخدام الرسوم المتحركة الضمنية (Implicit Animations) أو رسوم متحركة معقدة ومخصصة باستخدام الرسوم المتحركة الصريحة (Explicit Animations)، فإن Flutter يوفر الأدوات اللازمة لتحقيق ذلك. من خلال فهم المفاهيم المتقدمة مثل الرسوم المتحركة المتسلسلة، و Hero Animations، والرسم المخصص، بالإضافة إلى دمج Rive Animations التفاعلية، يمكنك الارتقاء بتطبيقاتك إلى مستوى جديد من التفاعلية والجمال البصري.

## المراجع

1. [Flutter Documentation: Animations](https://docs.flutter.dev/ui/animations)
2. [Rive Documentation](https://help.rive.app/)
3. [Rive Flutter Package](https://pub.dev/packages/rive)
4. [Flutter Documentation: Staggered Animations](https://docs.flutter.dev/ui/animations/staggered-animations)
5. [Flutter Documentation: Hero Animations](https://docs.flutter.dev/ui/animations/hero-animations)
6. [Flutter Documentation: CustomPainter](https://docs.flutter.dev/ui/widgets/custom-paint)
7. [Flutter Documentation: Performance considerations for animations](https://docs.flutter.dev/perf/rendering/animations)
8. [Flutter Documentation: Implicit Animations](https://docs.flutter.dev/ui/animations/implicit-animations)
9. [Flutter Documentation: Explicit Animations](https://docs.flutter.dev/ui/animations/explicit-animations)
10. [Flutter API Reference: AnimationController](https://api.flutter.dev/flutter/animation/AnimationController-class.html)
11. [Flutter API Reference: Tween](https://api.flutter.dev/flutter/animation/Tween-class.html)
12. [Flutter API Reference: Curves](https://api.flutter.dev/flutter/animation/Curves-class.html)
