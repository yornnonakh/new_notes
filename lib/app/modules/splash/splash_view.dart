import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
              child: const Icon(
                Icons.note_alt_rounded,
                size: 60,
                color: AppTheme.folderYellow,
              ),
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .shimmer(delay: 1000.ms, duration: 1500.ms),
            
            const SizedBox(height: 32),
            
            const Text(
              "Piisiit Note",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: 1.2,
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms)
            .slideY(begin: 0.5, end: 0),
          ],
        ),
      ),
    );
  }
}
