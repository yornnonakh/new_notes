import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.note_alt_rounded,
              size: 100,
              color: Colors.white,
            )
            .animate()
            .scale(duration: const Duration(milliseconds: 800), curve: Curves.elasticOut)
            .shimmer(delay: const Duration(seconds: 1), duration: const Duration(milliseconds: 1500)),
            
            const SizedBox(height: 20),
            
            const Text(
              "Piisiit Note",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 500))
            .slideY(begin: 1, end: 0),
          ],
        ),
      ),
    );
  }
}
