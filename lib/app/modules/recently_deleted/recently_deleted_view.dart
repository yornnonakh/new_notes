import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'recently_deleted_controller.dart';
import '../../theme/app_theme.dart';
import '../../data/models/note_model.dart';
import '../../routes/app_pages.dart';

class RecentlyDeletedView extends GetView<RecentlyDeletedController> {
  const RecentlyDeletedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // AppBar Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.chevron_left, color: AppTheme.folderYellow, size: 36),
                    ),
                    Obx(() => controller.isEditing.value
                      ? GestureDetector(
                          onTap: controller.toggleEditing,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.folderYellow,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 20),
                          ),
                        )
                      : TextButton(
                          onPressed: controller.toggleEditing,
                          child: const Text("Edit", 
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
                        ),
                    ),
                  ],
                ),
              ),
            ),

            // Large Title Area
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recently Deleted",
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Obx(() => Text(
                      "${controller.deletedNotes.length} Notes",
                      style: const TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w400),
                    )),
                  ],
                ),
              ),
            ),

            // Instructional Text
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Deleted notes are removed from your devices after 30 days, which may require Notes to be open. Permanent deletion from iCloud may take up to 40 more days.",
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.3),
                ),
              ),
            ),

            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.folderYellow)),
                );
              }
              
              if (controller.deletedNotes.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text("No Deleted Notes", style: TextStyle(color: AppTheme.textGrey))),
                );
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < controller.deletedNotes.length; i++) ...[
                          _buildNoteTile(controller.deletedNotes[i]),
                          if (i < controller.deletedNotes.length - 1)
                            const Divider(indent: 16, height: 1),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildNoteTile(NoteModel note) {
    final attachment = note.content.firstWhereOrNull((b) => b is AttachmentBlock) as AttachmentBlock?;
    final attachmentCount = note.content.whereType<AttachmentBlock>().length;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        note.title.isEmpty ? "New Note" : note.title,
        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          "${_formatDate(note.updatedAt)}  ${attachmentCount > 0 && _getContentSnippet(note).isEmpty ? '$attachmentCount attachments' : _getContentSnippet(note)}",
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: attachment != null ? Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: attachment.url != null 
              ? NetworkImage(attachment.url!) 
              : const AssetImage('assets/images/placeholder.png') as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ) : const Icon(Icons.chevron_right, color: AppTheme.dividerColor, size: 20),
    );
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
            const Icon(Icons.edit_note_rounded, color: AppTheme.textPrimary, size: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('MM/dd/yy').format(date);
  }

  String _getContentSnippet(NoteModel note) {
    final textBlock = note.content.firstWhereOrNull((b) => b is TextBlock) as TextBlock?;
    return textBlock?.text ?? "";
  }
}
