import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
import 'auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar Actions (Matching Folder Style)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    LiquidGlassContainer(
                      width: 44,
                      height: 44,
                      borderRadius: 22,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.chevron_left, color: AppTheme.textSecondary, size: 30),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // Large Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  "Register",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 8),
                    
                    const Text(
                      "Sign up to get started",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                    ).animate().fadeIn(delay: 100.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Register Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: controller.nameController,
                            hint: "Full Name",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: controller.phoneController,
                            hint: "Phone Number",
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: controller.passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 32),
                          
                          Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.folderYellow,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: controller.isLoading.value 
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          )),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bodyColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textGrey),
          prefixIcon: Icon(icon, color: AppTheme.textGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
