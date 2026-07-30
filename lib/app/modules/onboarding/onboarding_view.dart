import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_widgets.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Circles for Glass Effect
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ),
          
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.pages.length,
            itemBuilder: (context, index) {
              final page = controller.pages[index];
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LiquidGlassContainer(
                      height: 300,
                      width: 300,
                      child: Center(
                        child: Icon(
                          page.icon,
                          size: 100,
                          color: Colors.white,
                        ).animate().shake(duration: const Duration(seconds: 1)),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.5, end: 0),
                    const SizedBox(height: 20),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                  ],
                ),
              );
            },
          ),
          
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                  children: List.generate(
                    controller.pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 5),
                      width: controller.currentPage.value == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: controller.currentPage.value == index 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                )),
                
                ElevatedButton(
                  onPressed: controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Obx(() => Text(
                    controller.currentPage.value == controller.pages.length - 1 
                        ? "Get Started" 
                        : "Next"
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
