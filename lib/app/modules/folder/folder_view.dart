import 'package:flutter/cupertino.dart';
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
                    16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _glassControl(
                        context,
                        key: const ValueKey('create-folder-button'),
                        width: topControlHeight,
                        height: topControlHeight,
                        borderRadius: topControlHeight / 2,
                        label: 'New folder',
                        onTap: () => Get.bottomSheet(
                          FolderCreateModal(controller: controller),
                          isScrollControlled: true,
                        ),
                        child: Icon(
                          CupertinoIcons.folder_badge_plus,
                          color: _controlColor(context),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Obx(
                        () => _glassControl(
                          context,
                          key: const ValueKey('edit-folders-button'),
                          width: editControlWidth,
                          height: topControlHeight,
                          borderRadius: topControlHeight / 2,
                          label: controller.isEditing.value
                              ? 'Finish editing folders'
                              : 'Edit folders',
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
                    10,
                    _horizontalInset(context),
                    23,
                  ),
                  child: Text(
                    'Folders',
                    style: TextStyle(
                      color: _primaryTextColor(context),
                      fontFamily: _displayFont,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.05,
                      height: 1.08,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _pageContent(
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 180,
                      child: Center(
                        child: CupertinoActivityIndicator(
                          color: AppTheme.folderYellow,
                        ),
                      ),
                    );
                  }

                  final iCloudFolders = controller.iCloudFolders;
                  final onDeviceFolders = controller.onMyiPhoneFolders;
                  final hasICloudFolders = iCloudFolders.isNotEmpty;

                  return Column(
                    children: [
                      if (hasICloudFolders) ...[
                        _buildFolderSection(
                          context,
                          title: 'iCloud',
                          folders: iCloudFolders,
                        ),
                        const SizedBox(height: 30),
                      ],
                      _buildFolderSection(
                        context,
                        title: 'On My iPhone',
                        folders: onDeviceFolders,
                        includeRecentlyDeleted: true,
                      ),
                      const SizedBox(height: 28),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildFolderSection(
    BuildContext context, {
    required String title,
    required List<FolderModel> folders,
    bool includeRecentlyDeleted = false,
  }) {
    return Column(
      children: [
        _buildSectionHeader(context, title: title),
        _buildFolderGroup(
          context,
          folders,
          includeRecentlyDeleted: includeRecentlyDeleted,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalInset(context),
        0,
        _horizontalInset(context),
        5,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: _primaryTextColor(context),
            fontFamily: _displayFont,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.45,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildFolderGroup(
    BuildContext context,
    List<FolderModel> folders, {
    bool includeRecentlyDeleted = false,
  }) {
    final rows = <Widget>[
      for (final folder in folders) _buildFolderTile(context, folder),
      if (includeRecentlyDeleted && controller.deletedCount.value > 0)
        _buildRecentlyDeletedTile(context),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalInset(context)),
      child: Material(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              rows[index],
              if (index < rows.length - 1)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.only(left: 54, right: 16),
                  color: _dividerColor(context),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFolderTile(BuildContext context, FolderModel folder) {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSystem = controller.isSystemFolder(folder);
      final folderIcon =
          folder.iconName.isEmpty || folder.iconName.toLowerCase() == 'folder'
          ? CupertinoIcons.folder
          : folder.icon;

      return Opacity(
        opacity: isEditing && isSystem ? 0.3 : 1,
        child: _folderRow(
          context,
          onTap: isEditing && isSystem
              ? null
              : () => Get.toNamed(
                  Routes.NOTE_LIST,
                  arguments: folder,
                )?.then((_) => controller.fetchFolders()),
          leading: Icon(folderIcon, color: folder.color, size: 25),
          title: folder.name,
          trailing: isEditing && !isSystem
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      button: true,
                      label: 'More options for ${folder.name}',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.dialog(
                          FolderContextMenu(
                            folder: folder,
                            controller: controller,
                          ),
                          barrierColor: Colors.black.withValues(alpha: 0.1),
                        ),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: Icon(
                              CupertinoIcons.ellipsis_circle,
                              color: AppTheme.folderYellow,
                              size: 23,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.line_horizontal_3,
                      color: _secondaryTextColor(context),
                      size: 23,
                    ),
                  ],
                )
              : _countAndChevron(context, folder.noteCount),
        ),
      );
    });
  }

  Widget _buildRecentlyDeletedTile(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;

      return Opacity(
        opacity: isEditing ? 0.3 : 1,
        child: _folderRow(
          context,
          onTap: isEditing ? null : () => Get.toNamed(Routes.RECENTLY_DELETED),
          leading: const Icon(
            CupertinoIcons.delete,
            color: AppTheme.folderYellow,
            size: 25,
          ),
          title: 'Recently Deleted',
          trailing: _countAndChevron(context, controller.deletedCount.value),
        ),
      );
    });
  }

  Widget _folderRow(
    BuildContext context, {
    required Widget leading,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 47),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 1.5, 14, 1.5),
            child: Row(
              children: [
                SizedBox(width: 26, child: Center(child: leading)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primaryTextColor(context),
                      fontFamily: _textFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.25,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _countAndChevron(BuildContext context, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: _secondaryTextColor(context),
            fontFamily: _textFont,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
            height: 1,
          ),
        ),
        const SizedBox(width: 5),
        Icon(
          CupertinoIcons.chevron_forward,
          color: _chevronColor(context),
          size: 18,
        ),
      ],
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
                    key: const ValueKey('folder-search-button'),
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
                _glassControl(
                  context,
                  key: const ValueKey('new-note-button'),
                  width: controlHeight,
                  height: controlHeight,
                  borderRadius: controlHeight / 2,
                  label: 'New note',
                  onTap: controller.createNewNote,
                  child: Icon(
                    CupertinoIcons.square_pencil,
                    color: _controlColor(context),
                    size: 26,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
    return _isDark(context) ? const Color(0xFF98989D) : const Color(0xFF7C7C80);
  }

  Color _controlColor(BuildContext context) {
    return _isDark(context) ? Colors.white : AppTheme.textPrimary;
  }

  Color _dividerColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF38383A) : AppTheme.dividerColor;
  }

  Color _chevronColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF48484A) : const Color(0xFFC7C7CC);
  }
}
