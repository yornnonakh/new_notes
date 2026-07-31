import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_widgets.dart';
import '../note_controller.dart';

class NoteContextMenu extends StatelessWidget {
  final NoteController controller;

  const NoteContextMenu({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: LiquidGlassContainer(
            borderRadius: 16,
            opacity: 0.95,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(
                  "View as Gallery",
                  Icons.grid_view_rounded,
                  onTap: () {
                    Get.back();
                    controller.toggleViewMode();
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  "Select Notes",
                  Icons.check_circle_outline,
                  onTap: () {
                    Get.back();
                    controller.toggleEditing();
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  "Sort By",
                  Icons.swap_vert_rounded,
                  subtitle: "Default (Date Edited)",
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.textGrey),
                  onTap: () {
                    Get.back();
                    controller.updateSorting("Date Edited");
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  "Group By Date",
                  Icons.calendar_view_day_rounded,
                  subtitle: "Default (On)",
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.textGrey),
                  onTap: () {
                    Get.back();
                    controller.toggleDateGrouping();
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  "View Attachments",
                  Icons.attach_file_rounded,
                  onTap: () {
                    Get.back();
                    controller.viewAllAttachments();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon, {
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, color: AppTheme.textPrimary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13))
          : null,
      trailing: trailing,
    );
  }

  Widget _buildDivider() {
    return const Divider(indent: 56, height: 1, thickness: 0.5);
  }
}
