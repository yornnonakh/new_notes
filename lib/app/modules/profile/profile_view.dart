import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_widgets.dart';
import 'profile_controller.dart';
import '../../theme/app_theme.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.folderYellow.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // User Avatar & Info
                  Center(
                    child: Column(
                      children: [
                        LiquidGlassContainer(
                          width: 120,
                          height: 120,
                          borderRadius: 60,
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
                  
                  const SizedBox(height: 40),
                  
                  // Appearance Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Appearance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ),
                  const SizedBox(height: 15),
                  
                  LiquidGlassContainer(
                    borderRadius: 15,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildThemeOption(context, "Light Mode", Icons.light_mode, ThemeMode.light),
                        const Divider(indent: 40),
                        _buildThemeOption(context, "Dark Mode", Icons.dark_mode, ThemeMode.dark),
                        const Divider(indent: 40),
                        _buildThemeOption(context, "System Default", Icons.settings_brightness, ThemeMode.system),
                      ],
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  // Account Section
                  LiquidGlassContainer(
                    borderRadius: 15,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListTile(
                      onTap: controller.logout,
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
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
