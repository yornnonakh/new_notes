import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_pages.dart';
import 'auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar Actions (Matching Folder Style)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 44), 
                  ],
                ),
              ),
            ),

            // Large Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  "Login",
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
                    // Logo or Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                        ],
                      ),
                      child: const Icon(Icons.note_alt_rounded, size: 50, color: AppTheme.folderYellow),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 32),
                    
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 8),
                    
                    const Text(
                      "Login to your account",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                    ).animate().fadeIn(delay: 300.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Login Card
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
                            controller: controller.phoneController,
                            hint: "Phone Number",
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 20),
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
                              onPressed: controller.isLoading.value ? null : controller.login,
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
                                  : const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          )),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.REGISTER),
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
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
