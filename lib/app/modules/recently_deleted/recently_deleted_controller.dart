import 'package:get/get.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';

class RecentlyDeletedController extends GetxController {
  final _noteService = Get.find<NoteService>();
  
  final deletedNotes = <NoteModel>[].obs;
  final isLoading = true.obs;
  final isEditing = false.obs;
  final selectedNoteIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeletedNotes();
  }

  void toggleEditing() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      selectedNoteIds.clear();
    }
  }

  void toggleSelectNote(int id) {
    if (selectedNoteIds.contains(id)) {
      selectedNoteIds.remove(id);
    } else {
      selectedNoteIds.add(id);
    }
  }

  Future<void> recoverSelectedNotes() async {
    final targets = selectedNoteIds.isNotEmpty
        ? selectedNoteIds.toList()
        : deletedNotes.map((n) => n.id).toList();

    if (targets.isEmpty) return;

    try {
      for (final id in targets) {
        await _noteService.updateNoteState(id, isArchived: false);
      }
      selectedNoteIds.clear();
      isEditing.value = false;
      await fetchDeletedNotes();
      Get.snackbar("Success", "Notes recovered", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Could not recover notes");
    }
  }

  Future<void> deletePermanentlySelectedNotes() async {
    final targets = selectedNoteIds.isNotEmpty
        ? selectedNoteIds.toList()
        : deletedNotes.map((n) => n.id).toList();

    if (targets.isEmpty) return;

    try {
      for (final id in targets) {
        await _noteService.updateNoteState(id, isArchived: true);
      }
      selectedNoteIds.clear();
      isEditing.value = false;
      await fetchDeletedNotes();
      Get.snackbar("Success", "Notes permanently deleted", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Could not delete notes");
    }
  }

  Future<void> fetchDeletedNotes() async {
    isLoading.value = true;
    try {
      final trashNotes = await _noteService.getTrashNotes();
      deletedNotes.assignAll(trashNotes); 
    } catch (e) {
      Get.snackbar("Error", "Could not load deleted notes");
    } finally {
      isLoading.value = false;
    }
  }
}
