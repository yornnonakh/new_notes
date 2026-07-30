import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/folder_model.dart';
import '../../../widgets/glass_widgets.dart';
import '../../../theme/app_theme.dart';
import '../folder_controller.dart';

class FolderCreateModal extends StatelessWidget {
  final FolderModel? folder;
  final FolderController controller;

  const FolderCreateModal({super.key, this.folder, required this.controller});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: folder?.name);
    final RxString folderName = (folder?.name ?? '').obs;
    nameController.addListener(() => folderName.value = nameController.text);

    return Container(
      height: Get.height * 0.9,
      decoration: const BoxDecoration(
        color: AppTheme.bodyColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: AppTheme.textPrimary, size: 28),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "New Folder",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                Obx(() => GestureDetector(
                  onTap: folderName.isEmpty ? null : () async {
                    final success = await controller.onSaveFolder(
                      id: folder?.id ?? 0,
                      name: folderName.value,
                      iconName: folder?.iconName,
                      colorValue: folder?.colorValue,
                      sortOrder: folder?.sortOrder,
                    );
                    if (success) Get.back();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: folderName.isEmpty 
                          ? AppTheme.folderYellow.withValues(alpha: 0.3) 
                          : AppTheme.folderYellow,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Name Input Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LiquidGlassContainer(
              borderRadius: 12,
              opacity: 1.0,
              child: TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(fontSize: 17, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: "Name",
                  hintStyle: const TextStyle(color: AppTheme.hintColor),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  suffixIcon: Obx(() => folderName.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: AppTheme.textGrey, size: 20),
                        onPressed: () => nameController.clear(),
                      ) 
                    : const SizedBox.shrink()),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Smart Folder Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LiquidGlassContainer(
              borderRadius: 12,
              opacity: 1.0,
              child: ListTile(
                onTap: () {},
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.folderYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings_outlined, color: AppTheme.folderYellow, size: 22),
                ),
                title: const Text(
                  "Make Into Smart Folder",
                  style: TextStyle(fontSize: 17, color: AppTheme.textPrimary, fontWeight: FontWeight.w400),
                ),
                subtitle: const Text(
                  "Organize using tags and other filters",
                  style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
