
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Complex Animation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ComplexAnimationScreen(),
    );
  }
}

class ComplexAnimationScreen extends StatefulWidget {
  const ComplexAnimationScreen({Key? key}) : super(key: key);

  @override
  State<ComplexAnimationScreen> createState() => _ComplexAnimationScreenState();
}

class _ComplexAnimationScreenState extends State<ComplexAnimationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Curve for the entire animation
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack, // A more dynamic curve
    );

    // Scale Animation: from 0.5 to 1.5
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(curvedAnimation);

    // Rotation Animation: from 0 to 2 full rotations
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut, // Different curve for rotation
      ),
    );

    // Color Animation: from blue to red
    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.red).animate(curvedAnimation);

    // Slide Animation: from top-left to center
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5), // Start slightly off-screen top-left
      end: Offset.zero, // End at center
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn, // Another curve for sliding
      ),
    );

    // Listen for animation status changes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complex Animation Example'),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _slideAnimation.value * 100, // Apply slide animation
              child: Transform.rotate(
                angle: _rotationAnimation.value, // Apply rotation animation
                child: Transform.scale(
                  scale: _scaleAnimation.value, // Apply scale animation
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _colorAnimation.value, // Apply color animation
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Animate Me!',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.isAnimating) {
            _controller.stop();
          } else {
            _controller.forward();
          }
        },
        child: Icon(_controller.isAnimating ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
