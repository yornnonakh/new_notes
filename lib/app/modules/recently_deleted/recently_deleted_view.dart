import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/note_model.dart';
import '../../routes/app_pages.dart';
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
                  padding: EdgeInsets.fromLTRB(
                    _horizontalInset(context),
                    0,
                    _horizontalInset(context),
                    14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glassControl(
                        context,
                        key: const ValueKey('recently-deleted-back-button'),
                        width: topControlHeight,
                        height: topControlHeight,
                        borderRadius: topControlHeight / 2,
                        label: 'Back to folders',
                        onTap: Get.back,
                        child: Icon(
                          CupertinoIcons.chevron_back,
                          color: _controlColor(context),
                          size: 27,
                        ),
                      ),
                      Obx(
                        () => _glassControl(
                          context,
                          key: const ValueKey('recently-deleted-edit-button'),
                          width: editControlWidth,
                          height: topControlHeight,
                          borderRadius: topControlHeight / 2,
                          label: controller.isEditing.value
                              ? 'Finish editing deleted notes'
                              : 'Edit deleted notes',
                          onTap: controller.toggleEditing,
                          child: Text(
                            controller.isEditing.value ? 'Done' : 'Edit',
                            style: TextStyle(
                              color: _controlColor(context),
                              fontFamily: _textFont,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.25,
                              height: 1,
                            ),
                          ),
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
                  padding: EdgeInsets.fromLTRB(
                    _horizontalInset(context),
                    7,
                    _horizontalInset(context),
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recently Deleted',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _primaryTextColor(context),
                          fontFamily: _displayFont,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.05,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          _noteCountLabel(controller.deletedNotes.length),
                          style: TextStyle(
                            color: _secondaryTextColor(context),
                            fontFamily: _textFont,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.2,
                            height: 1.15,
                          ),
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
                  padding: EdgeInsets.fromLTRB(
                    _horizontalInset(context) + 10,
                    5,
                    _horizontalInset(context) + 10,
                    16,
                  ),
                  child: Text(
                    'Deleted notes are removed from your devices after 30 '
                    'days, which may require Notes to be open. Permanent '
                    'deletion from iCloud may take up to 40 more days.',
                    style: TextStyle(
                      color: _secondaryTextColor(context),
                      fontFamily: _textFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.05,
                      height: 1.28,
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CupertinoActivityIndicator(
                      color: _secondaryTextColor(context),
                    ),
                  ),
                );
              }

              if (controller.deletedNotes.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _pageContent(
                    Center(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          'No Deleted Notes',
                          style: TextStyle(
                            color: _secondaryTextColor(context),
                            fontFamily: _textFont,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: _pageContent(
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _horizontalInset(context),
                    ),
                    child: Material(
                      color: _cardColor(context),
                      borderRadius: BorderRadius.circular(22),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (
                            var index = 0;
                            index < controller.deletedNotes.length;
                            index++
                          ) ...[
                            _buildNoteTile(
                              context,
                              controller.deletedNotes[index],
                            ),
                            if (index < controller.deletedNotes.length - 1)
                              Container(
                                height: 0.5,
                                margin: const EdgeInsets.only(
                                  left: 26,
                                  right: 18,
                                ),
                                color: _dividerColor(context),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 112)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildNoteTile(BuildContext context, NoteModel note) {
    final attachmentCount = note.content.whereType<AttachmentBlock>().length;
    final title = note.title.trim().isEmpty ? 'New Note' : note.title.trim();
    final subtitle = _noteSubtitle(note, attachmentCount);

    return Semantics(
      container: true,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 55),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 18, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryTextColor(context),
                        fontFamily: _textFont,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryTextColor(context),
                        fontFamily: _textFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.15,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final controlHeight = _scaledControlHeight(context, 44);

    return ColoredBox(
      color: _backgroundColor(context),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: _pageContent(
          Padding(
            padding: EdgeInsets.fromLTRB(
              _horizontalInset(context) + 4,
              8,
              _horizontalInset(context) + 4,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _glassControl(
                    context,
                    key: const ValueKey('recently-deleted-search-button'),
                    height: controlHeight,
                    borderRadius: controlHeight / 2,
                    label: 'Search notes',
                    onTap: () => Get.toNamed(Routes.SEARCH),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            color: _controlColor(context),
                            size: 23,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Search',
                              style: TextStyle(
                                color: _secondaryTextColor(context),
                                fontFamily: _textFont,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.mic,
                            color: _controlColor(context),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label: 'New note',
                  image: true,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(controlHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _isDark(context) ? 0.3 : 0.08,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: LiquidGlassContainer(
                      width: controlHeight,
                      height: controlHeight,
                      borderRadius: controlHeight / 2,
                      opacity: 0.88,
                      child: Center(
                        child: Icon(
                          CupertinoIcons.square_pencil,
                          color: _controlColor(context),
                          size: 26,
                        ),
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

  Widget _glassControl(
    BuildContext context, {
    Key? key,
    double? width,
    required double height,
    required double borderRadius,
    required String label,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final isDark = _isDark(context);

    return Semantics(
      key: key,
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LiquidGlassContainer(
          width: width,
          height: height,
          borderRadius: borderRadius,
          opacity: 0.88,
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

  String _noteCountLabel(int count) =>
      '$count ${count == 1 ? 'Note' : 'Notes'}';

  String _noteSubtitle(NoteModel note, int attachmentCount) {
    final parts = <String>[];
    final date = _formatDate(note.updatedAt);
    if (date.isNotEmpty) parts.add(date);

    final snippet = _getContentSnippet(note);
    if (snippet.isNotEmpty) {
      parts.add(snippet);
    } else if (attachmentCount > 0) {
      parts.add(
        '$attachmentCount ${attachmentCount == 1 ? 'attachment' : 'attachments'}',
      );
    }

    return parts.isEmpty ? 'No additional text' : parts.join('  ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('MM/dd/yy').format(date);
  }

  String _getContentSnippet(NoteModel note) {
    final textBlock =
        note.content.firstWhereOrNull((block) => block is TextBlock)
            as TextBlock?;
    return textBlock?.text.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
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

  double _horizontalInset(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.05).clamp(16.0, 24.0);
  }

  double _scaledControlHeight(BuildContext context, double baseHeight) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final growth = (scale - 1).clamp(0.0, 1.0);
    return baseHeight + (growth * 12);
  }

  double _scaledControlWidth(BuildContext context, double baseWidth) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final growth = (scale - 1).clamp(0.0, 1.0);
    return baseWidth + (growth * 28);
  }

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _backgroundColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF000000) : AppTheme.bodyColor;
  }

  Color _cardColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF1C1C1E) : AppTheme.cardColor;
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

  Color _dividerColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF38383A) : AppTheme.dividerColor;
  }
}
