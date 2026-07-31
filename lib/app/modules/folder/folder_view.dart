import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/folder_model.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
import 'folder_controller.dart';
import 'widgets/folder_create_modal.dart';
import 'widgets/folder_context_menu.dart';

class FolderView extends GetView<FolderController> {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: SafeArea(
        bottom: true,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Top App Bar Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LiquidGlassContainer(
                      width: 44,
                      height: 44,
                      borderRadius: 22,
                      child: IconButton(
                        onPressed: () => Get.bottomSheet(
                          FolderCreateModal(controller: controller),
                          isScrollControlled: true,
                        ),
                        icon: const Icon(Icons.create_new_folder_outlined, color: AppTheme.textPrimary, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => controller.isEditing.value
                        ? LiquidGlassContainer(
                            width: 44,
                            height: 44,
                            borderRadius: 22,
                            child: GestureDetector(
                              onTap: controller.toggleEditing,
                              child: Center(
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.folderYellow,
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          )
                        : LiquidGlassContainer(
                            height: 44,
                            borderRadius: 22,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextButton(
                              onPressed: controller.toggleEditing,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Edit",
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),

            // Large Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  "Folders",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: AppTheme.folderYellow)),
                  );
                }

                return Column(
                  children: [
                    // iCloud Section (if any)
                    if (controller.iCloudFolders.isNotEmpty) ...[
                      _buildSectionHeader("iCloud", controller.isICloudExpanded, controller.toggleICloud),
                      Obx(() => controller.isICloudExpanded.value
                          ? _buildFolderGroup(context, controller.iCloudFolders)
                          : const SizedBox.shrink()),
                      const SizedBox(height: 32),
                    ],

                    // On My iPhone Section
                    _buildSectionHeader("On My iPhone", controller.isOnMyiPhoneExpanded, controller.toggleOnMyiPhone),
                    Obx(() => controller.isOnMyiPhoneExpanded.value
                        ? _buildFolderGroup(context, controller.onMyiPhoneFolders, includeRecentlyDeleted: true)
                        : const SizedBox.shrink()),

                    const SizedBox(height: 100), // Padding for bottom bar
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionHeader(String title, RxBool isExpanded, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Obx(() => Icon(
                  isExpanded.value ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  color: AppTheme.folderYellow,
                  size: 24,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderGroup(BuildContext context, List<FolderModel> folders, {bool includeRecentlyDeleted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderRadius: 20,
        padding: EdgeInsets.zero,
        children: [
          for (int i = 0; i < folders.length; i++) ...[
            _buildFolderTile(context, folders[i]),
            const Divider(indent: 56, height: 1),
          ],
          if (includeRecentlyDeleted) ...[
            _buildRecentlyDeletedTile(context),
            const Divider(indent: 56, height: 1),
            _buildTrashTile(context),
            const Divider(indent: 56, height: 1),
            _buildProfileTile(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderTile(BuildContext context, FolderModel folder) {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSystem = controller.isSystemFolder(folder);

      return Opacity(
        opacity: (isEditing && isSystem) ? 0.15 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: (isEditing && isSystem)
              ? null
              : () => Get.toNamed(Routes.NOTE_LIST, arguments: folder)?.then((value) => controller.fetchFolders()),
          leading: LiquidGlassContainer(
            width: 34,
            height: 34,
            borderRadius: 8,
            opacity: 0.08,
            blur: 15,
            child: Center(
              child: Icon(folder.icon, color: folder.color, size: 20),
            ),
          ),
          title: Text(folder.name, style: const TextStyle(fontSize: 17, color: AppTheme.textPrimary, fontWeight: FontWeight.w400)),
          trailing: isEditing && !isSystem
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => Get.dialog(
                        FolderContextMenu(folder: folder, controller: controller),
                        barrierColor: Colors.black.withValues(alpha: 0.1),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.folderYellow, width: 1.5),
                        ),
                        child: const Icon(Icons.more_horiz, color: AppTheme.folderYellow, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.reorder, color: AppTheme.textGrey, size: 24),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${folder.noteCount}", style: const TextStyle(fontSize: 17, color: AppTheme.textGrey)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: AppTheme.dividerColor, size: 20),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildRecentlyDeletedTile(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;

      return Opacity(
        opacity: isEditing ? 0.15 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: isEditing ? null : () => Get.toNamed(Routes.RECENTLY_DELETED),
          leading: LiquidGlassContainer(
            width: 34,
            height: 34,
            borderRadius: 8,
            opacity: 0.08,
            blur: 15,
            child: const Center(
              child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            ),
          ),
          title: const Text("Recently Deleted", style: TextStyle(fontSize: 17, color: AppTheme.textPrimary, fontWeight: FontWeight.w400)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${controller.deletedCount.value}", style: const TextStyle(fontSize: 17, color: AppTheme.textGrey)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppTheme.dividerColor, size: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileTile(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;

      return Opacity(
        opacity: isEditing ? 0.15 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: isEditing ? null : () => Get.toNamed(Routes.PROFILE),
          leading: LiquidGlassContainer(
            width: 34,
            height: 34,
            borderRadius: 8,
            opacity: 0.08,
            blur: 15,
            child: const Center(
              child: Icon(Icons.person_outline, color: AppTheme.folderYellow, size: 20),
            ),
          ),
          title: const Text("Profile", style: TextStyle(fontSize: 17, color: AppTheme.textPrimary, fontWeight: FontWeight.w400)),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.dividerColor, size: 20),
        ),
      );
    });
  }

  Widget _buildTrashTile(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;

      return Opacity(
        opacity: isEditing ? 0.15 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: isEditing ? null : () => Get.toNamed(Routes.TRASH),
          leading: LiquidGlassContainer(
            width: 34,
            height: 34,
            borderRadius: 8,
            opacity: 0.08,
            blur: 15,
            child: const Center(
              child: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
            ),
          ),
          title: const Text("Trash", style: TextStyle(fontSize: 17, color: AppTheme.textPrimary, fontWeight: FontWeight.w400)),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.dividerColor, size: 20),
        ),
      );
    });
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.SEARCH),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppTheme.textGrey, size: 22),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text("Search", style: TextStyle(color: AppTheme.textGrey, fontSize: 17)),
                      ),
                      const Icon(Icons.mic, color: AppTheme.textGrey, size: 22),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            LiquidGlassContainer(
              width: 50,
              height: 50,
              borderRadius: 25,
              child: IconButton(
                onPressed: () => controller.createNewNote(),
                icon: const Icon(Icons.open_in_new, color: AppTheme.textPrimary, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
