import 'package:flutter/material.dart';
import 'app_ui.dart';
import 'second_page.dart';

void main() {
  runApp(MyApp(userId: 'userId'));
}

class MyApp extends StatelessWidget {
  final String userId; // Define userId as a parameter

  // Constructor to receive userId
  MyApp({required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Infertility App',
      theme: AppTheme.light,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Navigate to the second page after a delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SecondPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        decor: BgDecor.hearts,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Opacity(
              opacity: ((scale - 0.8) / 0.2).clamp(0.0, 1.0),
              child: Transform.scale(scale: scale, child: child),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GradientIconBadge(
                  icon: Icons.favorite_rounded,
                  size: 110,
                  iconSize: 56,
                ),
                const SizedBox(height: 28),
                const Text(
                  'Fertility Care',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '"We help you to be complete"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
