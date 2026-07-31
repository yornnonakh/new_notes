import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_note/app/widgets/glass_widgets.dart';
import '../../data/models/folder_model.dart';
import '../../data/models/note_model.dart';
import '../../routes/app_pages.dart';
import 'note_controller.dart';
import '../../theme/app_theme.dart';
import 'widgets/note_context_menu.dart';

class NoteListView extends GetView<NoteController> {
  const NoteListView({super.key});

  @override
  Widget build(BuildContext context) {
    final FolderModel? folder = Get.arguments;

    if (folder == null) {
      return const Scaffold(body: Center(child: Text("Error: No folder selected")));
    }

    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Top App Bar Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.chevron_left, color: AppTheme.folderYellow, size: 36),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Obx(() {
                      if (controller.isEditing.value) {
                        return GestureDetector(
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
                        );
                      }

                      return GestureDetector(
                        onTap: () => Get.dialog(
                          NoteContextMenu(controller: controller),
                          barrierColor: Colors.black.withValues(alpha: 0.1),
                        ),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.more_horiz,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Large Title Area
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Obx(() => Text(
                      "${controller.notes.length} Notes",
                      style: const TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w400),
                    )),
                  ],
                ),
              ),
            ),

            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.folderYellow)),
                );
              }
              
              if (controller.notes.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text("No Notes", style: TextStyle(color: AppTheme.textGrey, fontSize: 18)),
                  ),
                );
              }

              final groupedNotes = _groupNotesByDate(controller.notes);

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final section = groupedNotes.keys.elementAt(index);
                  final sectionNotes = groupedNotes[section]!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(section, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textPrimary)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < sectionNotes.length; i++) ...[
                                _buildNoteTile(sectionNotes[i], folder.id),
                                if (i < sectionNotes.length - 1)
                                  const Divider(indent: 16, height: 1),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: groupedNotes.length),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isEditing.value) {
          return _buildEditBottomBar(folder);
        }
        return _buildBottomBar(folder);
      }),
    );
  }

  Widget _buildNoteTile(NoteModel note, int folderId) {
    final attachment = note.content.firstWhereOrNull((b) => b is AttachmentBlock) as AttachmentBlock?;

    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSelected = controller.selectedNoteIds.contains(note.id);

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
          if (isEditing) {
            controller.toggleSelectNote(note.id);
          } else {
            Get.toNamed(Routes.NOTE_DETAIL, arguments: {"noteId": note.id})
                ?.then((value) => controller.fetchNotes(folderId: folderId));
          }
        },
        leading: isEditing
            ? Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.textPrimary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppTheme.textPrimary : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              )
            : null,
        title: Text(
          note.title.isEmpty ? "New Note" : note.title,
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            "${_formatTime(note.updatedAt)}  ${_getContentSnippet(note)}",
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: attachment != null
            ? Container(
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
              )
            : (isEditing ? null : const Icon(Icons.chevron_right, color: AppTheme.dividerColor, size: 20)),
      );
    });
  }

  Widget _buildEditBottomBar(FolderModel folder) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Obx(() {
          final selectedCount = controller.selectedNoteIds.length;
          final moveText = selectedCount == 0 ? "Move All" : selectedCount == 1 ? "Move" : "Move ($selectedCount)";
          final deleteText = selectedCount == 0 ? "Delete All" : selectedCount == 1 ? "Delete" : "Delete ($selectedCount)";

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => controller.moveSelectedNotes(context, folder.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(moveText, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.deleteSelectedNotes(folder.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Text(deleteText, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(FolderModel folder) {
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
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppTheme.textGrey, size: 22),
                      const SizedBox(width: 8),
                      const Expanded(child: Text("Search", style: TextStyle(color: AppTheme.textGrey, fontSize: 17))),
                      const Icon(Icons.mic, color: AppTheme.textGrey, size: 22),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => Get.toNamed(Routes.NOTE_DETAIL, arguments: {"folderId": folder.id, "noteId": 0})
                  ?.then((value) => controller.fetchNotes(folderId: folder.id)),
              icon: const Icon(Icons.open_in_new, color: AppTheme.textPrimary, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<NoteModel>> _groupNotesByDate(List<NoteModel> notes) {
    Map<String, List<NoteModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    for (var note in notes) {
      final date = note.updatedAt ?? now;
      final noteDate = DateTime(date.year, date.month, date.day);
      
      String key;
      if (noteDate == today) {
        key = "Today";
      } else if (noteDate == yesterday) {
        key = "Yesterday";
      } else if (noteDate.isAfter(sevenDaysAgo)) {
        key = "Previous 7 Days";
      } else {
        key = DateFormat('MMMM').format(date);
      }

      if (!groups.containsKey(key)) groups[key] = [];
      groups[key]!.add(note);
    }
    return groups;
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "";
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('EEEE').format(date); 
  }

  String _getContentSnippet(NoteModel note) {
    if (note.content.isEmpty) {
      if (note.attachmentCount > 0) {
        return "${note.attachmentCount} attachment${note.attachmentCount > 1 ? 's' : ''}";
      }
      return "No additional text";
    }
    final firstBlock = note.content.firstWhereOrNull((b) => b is TextBlock) as TextBlock?;
    if (firstBlock != null) return firstBlock.text;
    return "Attachment/Checklist";
  }
}
