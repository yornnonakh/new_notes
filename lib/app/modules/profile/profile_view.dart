import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'profile_controller.dart';
import '../../theme/app_theme.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: SafeArea(
        bottom: true,
        child: CustomScrollView(
          slivers: [
            // Top App Bar Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.chevron_left, color: AppTheme.folderYellow, size: 36),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // Large Title Area
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  "Profile",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // User Avatar & Info
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person, size: 60, color: AppTheme.folderYellow),
                          ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack),
                          const SizedBox(height: 20),
                          Obx(() => Text(
                            controller.userName.value,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          )),
                          Text(
                            controller.userPhone.value,
                            style: const TextStyle(color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Appearance Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8),
                        child: Text("Appearance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      ),
                    ),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          _buildThemeOption(context, "Light Mode", Icons.light_mode, ThemeMode.light),
                          const Divider(indent: 56, height: 1),
                          _buildThemeOption(context, "Dark Mode", Icons.dark_mode, ThemeMode.dark),
                          const Divider(indent: 56, height: 1),
                          _buildThemeOption(context, "System Default", Icons.settings_brightness, ThemeMode.system),
                        ],
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Account Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: controller.logout,
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, IconData icon, ThemeMode mode) {
    return Obx(() {
      final isSelected = controller.currentThemeMode.value == mode;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      
      return ListTile(
        onTap: () => controller.changeTheme(mode),
        leading: Icon(icon, color: isSelected ? AppTheme.folderYellow : (isDark ? Colors.white70 : AppTheme.textGrey)),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
        trailing: isSelected 
            ? const Icon(Icons.check_circle, color: AppTheme.folderYellow) 
            : null,
      );
    });
  }
}
