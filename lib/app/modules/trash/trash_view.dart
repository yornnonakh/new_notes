import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/note_model.dart';
import '../../data/models/folder_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
import 'trash_controller.dart';

class TrashView extends GetView<TrashController> {
  const TrashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sticky Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      ),
                  ),
                ],
              ),
            ),
            
            // Full-Width Body
            Expanded(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Trash", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          Obx(() => Text("${controller.trashNotes.length + controller.trashFolders.length} Items", 
                            style: const TextStyle(fontSize: 13, color: AppTheme.textGrey))),
                        ],
                      ),
                    ),
                  ),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.folderYellow)));
                    }

                    if (controller.trashNotes.isEmpty && controller.trashFolders.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text("No items in trash", style: TextStyle(color: AppTheme.textGrey, fontSize: 17))),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: GlassCard(
                          borderRadius: 20,
                          children: [
                            for (int i = 0; i < controller.trashFolders.length; i++) ...[
                              _buildFolderTile(controller.trashFolders[i]),
                              const Divider(indent: 56, height: 1),
                            ],
                            for (int i = 0; i < controller.trashNotes.length; i++) ...[
                              _buildNoteTile(controller.trashNotes[i]),
                              if (i < controller.trashNotes.length - 1)
                                const Divider(indent: 56, height: 1),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => controller.isEditing.value ? _buildEditBottomBar() : const SizedBox.shrink()),
    );
  }

  Widget _buildFolderTile(FolderModel folder) {
    return Obx(() {
      final isSelected = controller.selectedFolderIds.contains(folder.id);
      return ListTile(
        onTap: controller.isEditing.value ? () => controller.toggleSelectFolder(folder.id) : null,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.isEditing.value) _buildSelectionIndicator(isSelected),
            Icon(folder.icon, color: folder.color, size: 24),
          ],
        ),
        title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Folder", style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
      );
    });
  }

  Widget _buildNoteTile(NoteModel note) {
    return Obx(() {
      final isSelected = controller.selectedNoteIds.contains(note.id);
      return ListTile(
        onTap: controller.isEditing.value ? () => controller.toggleSelectNote(note.id) : null,
        leading: controller.isEditing.value ? _buildSelectionIndicator(isSelected) : null,
        title: Text(note.title.isEmpty ? "New Note" : note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('MM/dd/yy').format(note.updatedAt ?? DateTime.now()), style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.dividerColor, size: 20),
      );
    });
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return Container(
      width: 22, height: 22,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppTheme.textPrimary : Colors.transparent,
        border: Border.all(color: isSelected ? AppTheme.textPrimary : Colors.grey.shade400, width: 1.5),
      ),
      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
    );
  }

  Widget _buildEditBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionButton("Recover", onTap: controller.recoverSelectedItems),
            _actionButton("Delete", color: Colors.redAccent, onTap: controller.deletePermanently),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, {Color? color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassContainer(
        borderRadius: 25,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          label,
          style: TextStyle(
            color: color ?? AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
