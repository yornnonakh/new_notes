import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../data/models/note_model.dart';
import 'note_controller.dart';
import '../../theme/app_theme.dart';

class NoteDetailView extends GetView<NoteController> {
  const NoteDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.chevron_left, color: AppTheme.folderYellow, size: 36),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.undo, color: AppTheme.folderYellow)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share, color: AppTheme.folderYellow)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, color: AppTheme.folderYellow)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => controller.saveNote(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.folderYellow,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.folderYellow));
        }

        return Column(
          children: [
            Center(
              child: Text(
                DateFormat('MMMM d, yyyy at h:mm a').format(controller.currentNote.value?.updatedAt ?? DateTime.now()),
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  TextField(
                    controller: controller.titleController,
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: "Title",
                      hintStyle: TextStyle(color: AppTheme.textGrey),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  ...controller.blocks.asMap().entries.map((entry) {
                    int idx = entry.key;
                    NoteBlock block = entry.value;
                    if (block is TextBlock) {
                      final textController = controller.getTextController(block.id, block.text);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: textController,
                          maxLines: null,
                          style: const TextStyle(fontSize: 17, color: AppTheme.textPrimary, height: 1.5),
                          decoration: const InputDecoration(
                            hintText: "Start writing...",
                            hintStyle: TextStyle(color: AppTheme.textGrey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                      );
                    } else if (block is ChecklistBlock) {
                      return _buildChecklistBlock(block, idx);
                    } else if (block is AttachmentBlock) {
                      return _buildAttachmentBlock(block);
                    }
                    return const SizedBox();
                  }),
                ],
              ),
            ),
            
            // iOS Style Keyboard Accessory Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: AppTheme.dividerColor.withValues(alpha: 0.5), width: 0.5)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: controller.addChecklistBlock, 
                        icon: const Icon(Icons.checklist_rtl_rounded, color: AppTheme.textPrimary, size: 28),
                      ),
                      IconButton(
                        onPressed: () {}, 
                        icon: const Icon(Icons.camera_alt_outlined, color: AppTheme.textPrimary, size: 28),
                      ),
                      IconButton(
                        onPressed: () {}, 
                        icon: const Icon(Icons.draw_outlined, color: AppTheme.textPrimary, size: 28),
                      ),
                      IconButton(
                        onPressed: controller.addTextBlock, 
                        icon: const Icon(Icons.edit_note_rounded, color: AppTheme.textPrimary, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildChecklistBlock(ChecklistBlock block, int blockIndex) {
    return Column(
      children: [
        ...block.items.asMap().entries.map((entry) {
          int itemIndex = entry.key;
          ChecklistItem item = entry.value;
          final itemController = controller.getTextController("${block.id}_$itemIndex", item.text);
          
          return Row(
            children: [
              IconButton(
                onPressed: () => controller.toggleChecklistItem(blockIndex, itemIndex),
                icon: Icon(
                  item.checked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: item.checked ? AppTheme.folderYellow : AppTheme.textGrey,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: itemController,
                  onChanged: (val) => controller.onUpdateChecklistItem(blockIndex, itemIndex, val),
                  style: TextStyle(
                    fontSize: 17, 
                    color: AppTheme.textPrimary,
                    decoration: item.checked ? TextDecoration.lineThrough : null,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAttachmentBlock(AttachmentBlock block) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 120, // Smaller image width as seen in screenshot
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: block.localPath != null 
              ? Image.file(File(block.localPath!), fit: BoxFit.cover)
              : block.url != null 
                ? Image.network(block.url!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[100],
                    child: const Center(child: Icon(Icons.image, size: 30, color: Colors.grey)),
                  ),
          ),
        ),
      ),
    );
  }
}
