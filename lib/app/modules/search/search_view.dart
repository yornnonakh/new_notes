import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
import '../../routes/app_pages.dart';
import 'search_controller.dart' as sc;

class SearchView extends GetView<sc.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bodyColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isSearching.value) {
                  return _buildSearchResults();
                }
                return _buildSuggestedSection();
              }),
            ),
            _buildBottomSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              "Suggested",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          LiquidGlassContainer(
            borderRadius: 15,
            opacity: 1.0, // White card look
            child: Column(
              children: [
                for (int i = 0; i < controller.suggestions.length; i++) ...[
                  _buildSuggestionTile(
                    controller.suggestions[i]['title'] as String,
                    controller.suggestions[i]['icon'] as IconData,
                  ),
                  if (i < controller.suggestions.length - 1)
                    const Divider(indent: 56, height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(String title, IconData icon) {
    return ListTile(
      onTap: () => controller.applyFilter(title),
      leading: Icon(icon, color: AppTheme.folderYellow, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (controller.noteResults.isEmpty && controller.folderResults.isEmpty) {
      return const Center(
        child: Text(
          "No results found",
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (controller.folderResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12),
            child: Text("Folders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                for (int i = 0; i < controller.folderResults.length; i++) ...[
                  ListTile(
                    onTap: () => Get.toNamed(Routes.NOTE_LIST, arguments: controller.folderResults[i]),
                    leading: Icon(controller.folderResults[i].icon, color: controller.folderResults[i].color),
                    title: Text(controller.folderResults[i].name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.textGrey),
                  ),
                  if (i < controller.folderResults.length - 1)
                    const Divider(indent: 56, height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        if (controller.noteResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12),
            child: Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                for (int i = 0; i < controller.noteResults.length; i++) ...[
                  ListTile(
                    onTap: () => Get.toNamed(Routes.NOTE_DETAIL, arguments: {"noteId": controller.noteResults[i].id}),
                    title: Text(controller.noteResults[i].title.isEmpty ? "New Note" : controller.noteResults[i].title, 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.textGrey),
                  ),
                  if (i < controller.noteResults.length - 1)
                    const Divider(indent: 16, height: 1),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          children: [
            Expanded(
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
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(color: AppTheme.textGrey, fontSize: 17),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.mic, color: AppTheme.textGrey, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (controller.isSearching.value) {
                  controller.clearSearch();
                } else {
                  Get.back();
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: AppTheme.textPrimary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSearchBar() {
    // This is handled by _buildBottomBar, keeping for consistency if called elsewhere
    return _buildBottomBar();
  }
}
