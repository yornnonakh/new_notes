import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/note_model.dart';
import '../../theme/app_theme.dart';
import 'note_controller.dart';

class NoteDetailView extends GetView<NoteController> {
  const NoteDetailView({super.key});

  static const String _displayFont = 'CupertinoSystemDisplay';
  static const String _textFont = 'CupertinoSystemText';
  static const double _maxContentWidth = 600;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _backgroundColor(context),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CupertinoActivityIndicator(
                        color: AppTheme.folderYellow,
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
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: controlSize,
                  height: controlSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    color: AppTheme.folderYellow,
                    size: 24,
                  ),
                ),
              ),

              // Right: Undo, Share, More, Done
              Row(
                children: [
                  _circleAction(CupertinoIcons.arrow_counterclockwise, onTap: () {}),
                  const SizedBox(width: 8),
                  _circleAction(CupertinoIcons.share, onTap: () {}),
                  const SizedBox(width: 8),
                  _circleAction(CupertinoIcons.ellipsis, onTap: () {}),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.saveNote,
                    child: Container(
                      width: controlSize,
                      height: controlSize,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleAction(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
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
              style: TextStyle(
                color: _secondaryTextColor(context),
                fontFamily: _textFont,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
                height: 1.2,
              ),
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
            style: TextStyle(
              color: _primaryTextColor(context),
              fontFamily: _displayFont,
              fontSize: 29,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              height: 1.13,
            ),
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: TextStyle(
                color: _secondaryTextColor(context),
                fontFamily: _displayFont,
                fontSize: 29,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
              ),
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
          style: TextStyle(
            color: _primaryTextColor(context),
            fontFamily: _textFont,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.15,
            height: 1.45,
          ),
          decoration: InputDecoration(
            hintText: 'Start writing...',
            hintStyle: TextStyle(
              color: _secondaryTextColor(context),
              fontFamily: _textFont,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
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
                              : _secondaryTextColor(context),
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
                    style: TextStyle(
                      color: _primaryTextColor(context),
                      fontFamily: _textFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.15,
                      height: 1.45,
                      decoration: entry.value.checked
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: _secondaryTextColor(context),
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
    return ColoredBox(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFF2F2F7),
      child: Center(
        child: Icon(
          CupertinoIcons.photo,
          size: 27,
          color: _secondaryTextColor(context),
        ),
      ),
    );
  }

  Widget _buildEditingToolbar(BuildContext context) {
    const controlHeight = 50.0;

    return ColoredBox(
      color: _backgroundColor(context),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        onPressed: controller.addChecklistBlock,
                        icon: const Icon(
                          Icons.checklist_rtl_rounded,
                          color: AppTheme.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        onPressed: () {},
                        icon: const Icon(
                          CupertinoIcons.paperclip,
                          color: AppTheme.textPrimary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        onPressed: () {},
                        icon: const Icon(
                          CupertinoIcons.pencil_outline,
                          color: AppTheme.textPrimary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Floating Circle (New note / Edit button)
                GestureDetector(
                  onTap: controller.saveNote,
                  child: Container(
                    width: controlHeight,
                    height: controlHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.square_pencil,
                        color: AppTheme.textPrimary,
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

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _backgroundColor(BuildContext context) {
    return _isDark(context) ? Colors.black : Colors.white;
  }

  Color _primaryTextColor(BuildContext context) {
    return _isDark(context) ? Colors.white : AppTheme.textPrimary;
  }

  Color _secondaryTextColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF98989D) : AppTheme.textGrey;
  }

  Color _controlColor(BuildContext context) {
    return _isDark(context) ? Colors.white : AppTheme.textPrimary;
  }
}
