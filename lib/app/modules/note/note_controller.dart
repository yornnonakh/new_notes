import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';

class NoteController extends GetxController {
  final _noteService = Get.find<NoteService>();

  final notes = <NoteModel>[].obs;
  final isLoading = true.obs;
  
  // For Detail View
  final currentNote = Rxn<NoteModel>();
  final titleController = TextEditingController();
  final blocks = <NoteBlock>[].obs;
  
  // Map to keep track of text controllers for each block to prevent focus loss
  final Map<String, TextEditingController> blockControllers = {};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args.containsKey('noteId')) {
      if (args['noteId'] != 0) {
        fetchNoteDetail(args['noteId']);
      } else {
        _initNewNote(args['folderId']);
      }
    } else if (args != null && args is! Map) {
      fetchNotes(folderId: args.id);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    for (var controller in blockControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> fetchNotes({int? folderId}) async {
    isLoading.value = true;
    try {
      final data = await _noteService.getNotes(folderId: folderId);
      notes.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Could not load notes");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNoteDetail(int id) async {
    isLoading.value = true;
    try {
      final note = await _noteService.getNoteDetail(id);
      currentNote.value = note;
      titleController.text = note.title;
      
      // Clear old controllers
      for (var c in blockControllers.values) {
        c.dispose();
      }
      blockControllers.clear();
      
      blocks.assignAll(note.content);
      
      // If content is empty, add an initial text block
      if (blocks.isEmpty) {
        addTextBlock();
      }
    } catch (e) {
      Get.snackbar("Error", "Could not load note detail");
    } finally {
      isLoading.value = false;
    }
  }

  void _initNewNote(int folderId) {
    currentNote.value = NoteModel(id: 0, folderId: folderId, title: "");
    titleController.clear();
    blocks.clear();
    addTextBlock();
    isLoading.value = false;
  }

  TextEditingController getTextController(String blockId, String initialText) {
    if (!blockControllers.containsKey(blockId)) {
      blockControllers[blockId] = TextEditingController(text: initialText);
    }
    return blockControllers[blockId]!;
  }

  Future<void> saveNote() async {
    if (currentNote.value == null) return;
    
    // Update block content from controllers before saving
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i] is TextBlock) {
        final controller = blockControllers[blocks[i].id];
        if (controller != null) {
          blocks[i] = TextBlock(id: blocks[i].id, text: controller.text);
        }
      }
    }
    
    try {
      if (currentNote.value!.id == 0) {
        await _noteService.saveNote(currentNote.value!.folderId, titleController.text);
      } else {
        await _noteService.saveContent(currentNote.value!.id, titleController.text, blocks);
      }
      Get.back(result: true);
    } catch (e) {
      Get.snackbar("Error", "Failed to save note");
    }
  }

  void updateTextBlock(int index, String text) {
    // This is now handled by persistence logic in saveNote or can be debounced
    if (blocks[index] is TextBlock) {
      // Just keep track of text if needed for real-time logic
    }
  }

  void onUpdateChecklistItem(int blockIndex, int itemIndex, String text) {
    if (blocks[blockIndex] is ChecklistBlock) {
      final block = blocks[blockIndex] as ChecklistBlock;
      block.items[itemIndex] = ChecklistItem(
        id: block.items[itemIndex].id,
        text: text,
        checked: block.items[itemIndex].checked,
      );
      blocks[blockIndex] = ChecklistBlock(id: block.id, items: block.items);
    }
  }

  void toggleChecklistItem(int blockIndex, int itemIndex) {
    if (blocks[blockIndex] is ChecklistBlock) {
      final block = blocks[blockIndex] as ChecklistBlock;
      final item = block.items[itemIndex];
      block.items[itemIndex] = ChecklistItem(id: item.id, text: item.text, checked: !item.checked);
      blocks[blockIndex] = ChecklistBlock(id: block.id, items: block.items);
    }
  }

  void addTextBlock() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    blocks.add(TextBlock(id: id, text: ""));
  }

  void addChecklistBlock() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    blocks.add(ChecklistBlock(id: id, items: [
      ChecklistItem(id: "1", text: "")
    ]));
  }
}
