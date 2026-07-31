import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/note_model.dart';
import '../../data/models/folder_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
import 'recently_deleted_controller.dart';

class RecentlyDeletedView extends GetView<RecentlyDeletedController> {
  const RecentlyDeletedView({super.key});

  static const String _displayFont = 'CupertinoSystemDisplay';
  static const String _textFont = 'CupertinoSystemText';
  static const double _maxContentWidth = 600;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _backgroundColor(context);
    final topControlHeight = _scaledControlHeight(context, 44);
    final editControlWidth = _scaledControlWidth(context, 60);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _pageContent(
                Padding(
                  padding: EdgeInsets.fromLTRB(_horizontalInset(context), 0, _horizontalInset(context), 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: Get.back,
                        child: Container(
                          width: topControlHeight,
                          height: topControlHeight,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(CupertinoIcons.chevron_back, color: AppTheme.folderYellow, size: 27),
                        ),
                      ),
                      Obx(() => controller.isEditing.value
                        ? GestureDetector(
                            onTap: controller.toggleEditing,
                            child: Container(
                              width: topControlHeight,
                              height: topControlHeight,
                              decoration: const BoxDecoration(color: AppTheme.folderYellow, shape: BoxShape.circle),
                              child: const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 20),
                            ),
                          )
                        : TextButton(
                            onPressed: controller.toggleEditing,
                            child: const Text("Edit", style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: _pageContent(
                Padding(
                  padding: EdgeInsets.fromLTRB(_horizontalInset(context), 7, _horizontalInset(context), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recently Deleted', style: TextStyle(color: _primaryTextColor(context), fontFamily: _displayFont, fontSize: 34, fontWeight: FontWeight.bold)),
                      Obx(() => Text('${controller.deletedNotes.length + controller.deletedFolders.length} Items', 
                        style: TextStyle(color: _secondaryTextColor(context), fontSize: 15))),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Notes are available here for 30 days. After that time, notes will be permanently deleted. This may take up to 40 days.",
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.3),
                ),
              ),
            ),

            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.folderYellow)));
              }

              if (controller.deletedNotes.isEmpty && controller.deletedFolders.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false, 
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.delete, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text("No Deleted Items", style: TextStyle(color: AppTheme.textGrey, fontSize: 17)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: controller.fetchDeletedItems,
                          child: const Text("Refresh"),
                        ),
                      ],
                    )
                  )
                );
              }

              return SliverToBoxAdapter(
                child: _pageContent(
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _horizontalInset(context), vertical: 16),
                    child: GlassCard(
                      borderRadius: 20,
                      children: [
                        // Render Folders first
                        for (int i = 0; i < controller.deletedFolders.length; i++) ...[
                          _buildFolderTile(context, controller.deletedFolders[i]),
                          if (i < controller.deletedFolders.length - 1 || controller.deletedNotes.isNotEmpty)
                            const Divider(indent: 56, height: 1),
                        ],
                        // Render Notes
                      for (int i = 0; i < controller.deletedNotes.length; i++) ...[
                        _buildNoteTile(context, controller.deletedNotes[i]),
                        if (i < controller.deletedNotes.length - 1)
                          const Divider(indent: 56, height: 1),
                      ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 112)),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => controller.isEditing.value ? _buildEditBottomBar(context) : const SizedBox.shrink()),
    );
  }

  Widget _buildFolderTile(BuildContext context, FolderModel folder) {
    return Obx(() {
      final isSelected = controller.selectedFolderIds.contains(folder.id);
      return ListTile(
        onTap: controller.isEditing.value ? () => controller.toggleSelectFolder(folder.id) : null,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.isEditing.value)
              _buildSelectionIndicator(isSelected),
            Icon(folder.icon, color: folder.color, size: 24),
          ],
        ),
        title: Text(folder.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        subtitle: const Text("Folder", style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
      );
    });
  }

  Widget _buildNoteTile(BuildContext context, NoteModel note) {
    final attachmentCount = note.content.whereType<AttachmentBlock>().length;
    return Obx(() {
      final isSelected = controller.selectedNoteIds.contains(note.id);
      return ListTile(
        onTap: controller.isEditing.value ? () => controller.toggleSelectNote(note.id) : null,
        leading: controller.isEditing.value ? _buildSelectionIndicator(isSelected) : null,
        title: Text(note.title.isEmpty ? "New Note" : note.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        subtitle: Text("${_formatDate(note.updatedAt)}  ${attachmentCount > 0 ? '$attachmentCount attachments' : _getContentSnippet(note)}", 
          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, color: AppTheme.textGrey)),
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

  Widget _buildEditBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionButton("Recover", onTap: controller.recoverSelectedItems),
            _actionButton("Delete", color: Colors.redAccent, onTap: controller.deletePermanentlySelectedItems),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, {Color? color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Text(label, style: TextStyle(color: color ?? AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return DateFormat('HH:mm').format(date);
    return DateFormat('MM/dd/yy').format(date);
  }

  String _getContentSnippet(NoteModel note) {
    final textBlock = note.content.firstWhereOrNull((b) => b is TextBlock) as TextBlock?;
    return textBlock?.text.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
  }

  Widget _pageContent(Widget child) {
    return Align(alignment: Alignment.topCenter, heightFactor: 1, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: _maxContentWidth), child: SizedBox(width: double.infinity, child: child)));
  }

  double _horizontalInset(BuildContext context) => (MediaQuery.sizeOf(context).width * 0.05).clamp(16.0, 24.0);
  double _scaledControlHeight(BuildContext context, double baseHeight) => baseHeight + ((MediaQuery.textScalerOf(context).scale(1) - 1).clamp(0.0, 1.0) * 12);
  double _scaledControlWidth(BuildContext context, double baseWidth) => baseWidth + ((MediaQuery.textScalerOf(context).scale(1) - 1).clamp(0.0, 1.0) * 28);
  Color _primaryTextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textPrimary;
  Color _secondaryTextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF98989D) : AppTheme.textGrey;
  bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  Color _backgroundColor(BuildContext context) => _isDark(context) ? const Color(0xFF000000) : AppTheme.bodyColor;
  Color _cardColor(BuildContext context) => _isDark(context) ? const Color(0xFF1C1C1E) : AppTheme.cardColor;
  Color _dividerColor(BuildContext context) => _isDark(context) ? const Color(0xFF38383A) : AppTheme.dividerColor;
}
