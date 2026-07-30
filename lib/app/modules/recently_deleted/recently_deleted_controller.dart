import 'package:get/get.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';

class RecentlyDeletedController extends GetxController {
  final _noteService = Get.find<NoteService>();
  
  final deletedNotes = <NoteModel>[].obs;
  final isLoading = true.obs;
  final isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeletedNotes();
  }

  void toggleEditing() => isEditing.value = !isEditing.value;

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
