import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/note_model.dart';
import '../../widgets/glass_widgets.dart';
import 'note_controller.dart';
import '../../theme/app_theme.dart';

class NoteDetailView extends GetView<NoteController> {
  const NoteDetailView({super.key});

  static const String _displayFont = 'CupertinoSystemDisplay';
  static const double _maxContentWidth = 600;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                      ),
                    );
                  }

                  return _buildEditor(context);
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => controller.isLoading.value
              ? const SizedBox.shrink()
              : _buildEditingToolbar(context),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final controlSize = 40.0;

    return _pageContent(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: controlSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Back button
              LiquidGlassContainer(
                width: controlSize,
                height: controlSize,
                borderRadius: controlSize / 2,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: Get.back,
                  icon: Icon(
                    CupertinoIcons.chevron_left,
                    color: AppTheme.folderYellow,
                    size: 24,
                  ),
                ),
              ),

              // Right: Undo, Share, More, Done
              Row(
                children: [
                  _circleAction(context, CupertinoIcons.arrow_counterclockwise, onTap: () {}),
                  const SizedBox(width: 8),
                  _circleAction(context, CupertinoIcons.share, onTap: () {}),
                  const SizedBox(width: 8),
                  _circleAction(context, CupertinoIcons.ellipsis, onTap: () {}),
                  const SizedBox(width: 8),
                  LiquidGlassContainer(
                    width: controlSize,
                    height: controlSize,
                    borderRadius: controlSize / 2,
                    opacity: 1.0, 
                    child: GestureDetector(
                      onTap: controller.saveNote,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.folderYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.checkmark,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleAction(BuildContext context, IconData icon, {required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return LiquidGlassContainer(
      width: 40,
      height: 40,
      borderRadius: 20,
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _toolbarIcon(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return LiquidGlassContainer(
      width: 38,
      height: 38,
      borderRadius: 19,
      opacity: 0.1, 
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(icon, color: theme.colorScheme.onSurface, size: 22),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final theme = Theme.of(context);
    final noteDate = controller.currentNote.value?.updatedAt ?? DateTime.now();
    final horizontalInset = _editorInset(context);

    return _pageContent(
      ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 28),
        children: [
          Center(
            child: Text(
              DateFormat("MMMM d, yyyy 'at' h:mm a").format(noteDate),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 11),
          TextField(
            key: const ValueKey('note-title-field'),
            controller: controller.titleController,
            cursorColor: AppTheme.folderYellow,
            cursorWidth: 1.5,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            scrollPadding: const EdgeInsets.only(bottom: 92),
            style: theme.textTheme.headlineLarge,
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isCollapsed: true,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in controller.blocks.asMap().entries)
            _buildBlock(context, entry.value, entry.key),
        ],
      ),
    );
  }

  Widget _buildBlock(BuildContext context, NoteBlock block, int blockIndex) {
    final theme = Theme.of(context);
    if (block is TextBlock) {
      final textController = controller.getTextController(block.id, block.text);

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: TextField(
          key: ValueKey('note-text-${block.id}'),
          controller: textController,
          cursorColor: AppTheme.folderYellow,
          cursorWidth: 1.5,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          scrollPadding: const EdgeInsets.only(bottom: 92),
          onChanged: (value) => controller.updateTextBlock(blockIndex, value),
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          decoration: InputDecoration(
            hintText: 'Start writing...',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isCollapsed: true,
          ),
        ),
      );
    }

    if (block is ChecklistBlock) {
      return _buildChecklistBlock(context, block, blockIndex);
    }

    if (block is AttachmentBlock) {
      return _buildAttachmentBlock(context, block);
    }

    return const SizedBox.shrink();
  }

  Widget _buildChecklistBlock(
    BuildContext context,
    ChecklistBlock block,
    int blockIndex,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          for (final entry in block.items.asMap().entries)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  checked: entry.value.checked,
                  label: entry.value.checked
                      ? 'Mark checklist item incomplete'
                      : 'Mark checklist item complete',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        controller.toggleChecklistItem(blockIndex, entry.key),
                    child: SizedBox(
                      width: 31,
                      height: 31,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          entry.value.checked
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.circle,
                          color: entry.value.checked
                              ? AppTheme.folderYellow
                              : theme.colorScheme.onSurfaceVariant,
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    key: ValueKey('checklist-${block.id}-${entry.value.id}'),
                    controller: controller.getTextController(
                      '${block.id}_${entry.key}',
                      entry.value.text,
                    ),
                    cursorColor: AppTheme.folderYellow,
                    cursorWidth: 1.5,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    scrollPadding: const EdgeInsets.only(bottom: 92),
                    onChanged: (value) => controller.onUpdateChecklistItem(
                      blockIndex,
                      entry.key,
                      value,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                      decoration: entry.value.checked
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: theme.colorScheme.onSurfaceVariant,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentBlock(BuildContext context, AttachmentBlock block) {
    final attachment = _attachmentImage(context, block);
    final semanticsLabel = block.displayName.trim().isEmpty
        ? 'Note attachment'
        : 'Attachment: ${block.displayName}';

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          image: true,
          label: semanticsLabel,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 150,
              height: 200,
              child: attachment,
            ),
          ),
        ),
      ),
    );
  }

  Widget _attachmentImage(BuildContext context, AttachmentBlock block) {
    final errorPlaceholder = _attachmentPlaceholder(context);

    if (block.localPath != null && block.localPath!.isNotEmpty) {
      return Image.file(
        File(block.localPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => errorPlaceholder,
      );
    }

    if (block.url != null && block.url!.isNotEmpty) {
      return Image.network(
        block.url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => errorPlaceholder,
      );
    }

    return errorPlaceholder;
  }

  Widget _attachmentPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Icon(
          CupertinoIcons.photo,
          size: 27,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildEditingToolbar(BuildContext context) {
    final theme = Theme.of(context);
    const controlHeight = 50.0;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: _pageContent(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Floating Pill (Checklist, Attachment, Drawing)
                Container(
                  height: controlHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _toolbarIcon(
                        context,
                        icon: Icons.checklist_rtl_rounded,
                        onTap: controller.addChecklistBlock,
                      ),
                      const SizedBox(width: 4),
                      _toolbarIcon(
                        context,
                        icon: CupertinoIcons.paperclip,
                        onTap: () {},
                      ),
                      const SizedBox(width: 4),
                      _toolbarIcon(
                        context,
                        icon: CupertinoIcons.pencil_outline,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // Right Floating Circle (New note / Edit button)
                LiquidGlassContainer(
                  width: controlHeight,
                  height: controlHeight,
                  borderRadius: controlHeight / 2,
                  child: GestureDetector(
                    onTap: controller.saveNote,
                    child: Center(
                      child: Icon(
                        CupertinoIcons.square_pencil,
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageContent(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }

  double _editorInset(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.065).clamp(21.0, 32.0);
  }
}
