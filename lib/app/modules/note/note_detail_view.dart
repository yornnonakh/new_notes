import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/note_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
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
    final controlSize = _scaledControlSize(context);
    final groupedControlWidth = controlSize * 2.12;

    return _pageContent(
      Padding(
        padding: EdgeInsets.fromLTRB(
          _topBarInset(context),
          0,
          _topBarInset(context),
          0,
        ),
        child: SizedBox(
          height: controlSize,
          child: Row(
            children: [
              _glassControl(
                context,
                key: const ValueKey('note-back-button'),
                width: controlSize,
                height: controlSize,
                borderRadius: controlSize / 2,
                label: 'Back',
                onTap: Get.back,
                child: Icon(
                  CupertinoIcons.back,
                  color: _controlColor(context),
                  size: 27,
                ),
              ),
              const Spacer(),
              _glassControl(
                context,
                key: const ValueKey('note-undo-button'),
                width: controlSize,
                height: controlSize,
                borderRadius: controlSize / 2,
                label: 'Undo',
                onTap: () {},
                child: Icon(
                  CupertinoIcons.arrow_uturn_left,
                  color: _controlColor(context),
                  size: 25,
                ),
              ),
              const SizedBox(width: 8),
              _buildShareAndMoreControl(
                context,
                width: groupedControlWidth,
                height: controlSize,
              ),
              const SizedBox(width: 8),
              _saveButton(context, size: controlSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareAndMoreControl(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    return DecoratedBox(
      decoration: _glassShadow(context, height / 2),
      child: LiquidGlassContainer(
        width: width,
        height: height,
        borderRadius: height / 2,
        opacity: 0.9,
        child: Row(
          children: [
            Expanded(
              child: _toolbarTapTarget(
                key: const ValueKey('note-share-button'),
                label: 'Share note',
                onTap: () {},
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(height / 2),
                ),
                child: Icon(
                  CupertinoIcons.share,
                  color: _controlColor(context),
                  size: 24,
                ),
              ),
            ),
            Expanded(
              child: _toolbarTapTarget(
                key: const ValueKey('note-more-button'),
                label: 'More note options',
                onTap: () {},
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(height / 2),
                ),
                child: Icon(
                  CupertinoIcons.ellipsis,
                  color: _controlColor(context),
                  size: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton(BuildContext context, {required double size}) {
    return Semantics(
      key: const ValueKey('note-save-button'),
      button: true,
      label: 'Save note',
      onTap: controller.saveNote,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.folderYellow,
          boxShadow: [
            BoxShadow(
              color: AppTheme.folderYellow.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: controller.saveNote,
            excludeFromSemantics: true,
            child: SizedBox.square(
              dimension: size,
              child: const Center(
                child: Icon(
                  CupertinoIcons.check_mark,
                  color: Colors.white,
                  size: 27,
                ),
              ),
            ),
          ),
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
      padding: const EdgeInsets.only(top: 4, bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          image: true,
          label: semanticsLabel,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(width: 60, height: 82, child: attachment),
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
    final toolbarHeight = _scaledToolbarHeight(context);

    return ColoredBox(
      color: _backgroundColor(context),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 10),
        child: _pageContent(
          Padding(
            padding: EdgeInsets.fromLTRB(
              _toolbarInset(context),
              6,
              _toolbarInset(context),
              0,
            ),
            child: DecoratedBox(
              decoration: _glassShadow(context, toolbarHeight / 2),
              child: LiquidGlassContainer(
                height: toolbarHeight,
                borderRadius: toolbarHeight / 2,
                opacity: 0.92,
                child: Row(
                  children: [
                    Expanded(
                      child: _toolbarTapTarget(
                        key: const ValueKey('add-text-block-button'),
                        label: 'Add text block',
                        onTap: controller.addTextBlock,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(toolbarHeight / 2),
                        ),
                        child: Text(
                          'Aa',
                          style: TextStyle(
                            color: _controlColor(context),
                            fontFamily: _displayFont,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.7,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _toolbarTapTarget(
                        key: const ValueKey('add-checklist-button'),
                        label: 'Add checklist',
                        onTap: controller.addChecklistBlock,
                        child: Icon(
                          CupertinoIcons.check_mark_circled,
                          color: _controlColor(context),
                          size: 24,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _toolbarTapTarget(
                        key: const ValueKey('add-table-button'),
                        label: 'Add table',
                        onTap: () {},
                        child: Icon(
                          CupertinoIcons.table,
                          color: _controlColor(context),
                          size: 24,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _toolbarTapTarget(
                        key: const ValueKey('add-attachment-button'),
                        label: 'Add attachment',
                        onTap: () {},
                        child: Icon(
                          CupertinoIcons.paperclip,
                          color: _controlColor(context),
                          size: 26,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _toolbarTapTarget(
                        key: const ValueKey('drawing-button'),
                        label: 'Drawing tools',
                        onTap: () {},
                        child: Icon(
                          CupertinoIcons.pencil_circle,
                          color: _controlColor(context),
                          size: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _toolbarTapTarget(
                        key: const ValueKey('camera-button'),
                        label: 'Add photo or video',
                        onTap: () {},
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(toolbarHeight / 2),
                        ),
                        child: Icon(
                          CupertinoIcons.camera,
                          color: _controlColor(context),
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassControl(
    BuildContext context, {
    Key? key,
    required double width,
    required double height,
    required double borderRadius,
    required String label,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Semantics(
      key: key,
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: _glassShadow(context, borderRadius),
        child: LiquidGlassContainer(
          width: width,
          height: height,
          borderRadius: borderRadius,
          opacity: 0.9,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              excludeFromSemantics: true,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarTapTarget({
    Key? key,
    required String label,
    required VoidCallback onTap,
    required Widget child,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    return Semantics(
      key: key,
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          excludeFromSemantics: true,
          child: Center(child: child),
        ),
      ),
    );
  }

  BoxDecoration _glassShadow(BuildContext context, double borderRadius) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 9),
        ),
      ],
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

  double _topBarInset(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.045).clamp(14.0, 22.0);
  }

  double _editorInset(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.065).clamp(21.0, 32.0);
  }

  double _toolbarInset(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.035).clamp(12.0, 20.0);
  }

  double _scaledControlSize(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final growth = (scale - 1).clamp(0.0, 1.0);
    return 44 + (growth * 8);
  }

  double _scaledToolbarHeight(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final growth = (scale - 1).clamp(0.0, 1.0);
    return 44 + (growth * 12);
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
