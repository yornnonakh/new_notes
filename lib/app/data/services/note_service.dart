import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response;
import '../models/note_model.dart';
import 'api_service.dart';

class NoteService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<NoteModel>> getNotes({int? folderId}) async {
    final response = await _api.dio.get("/api/note", queryParameters: {
      if (folderId != null) "folderId": folderId,
    });
    final data = response.data['data'];
    if (data == null) return [];
    
    // The API returns a Map with 'note', 'archive', 'trash' lists
    final List noteList = data['note'] ?? [];
    return noteList
        .map((e) => NoteModel.fromJson(e))
        .toList();
  }

  Future<List<NoteModel>> getTrashNotes() async {
    final response = await _api.dio.get("/api/note");
    final data = response.data['data'];
    if (data == null) return [];
    
    final List trashList = data['trash'] ?? [];
    return trashList
        .map((e) => NoteModel.fromJson(e))
        .toList();
  }

  Future<NoteModel> getNoteDetail(int id) async {
    final response = await _api.dio.get("/api/note/$id");
    return NoteModel.fromJson(response.data['data']);
  }

  Future<void> saveNote(int folderId, String title, {int noteId = 0}) async {
    await _api.dio.post("/api/note/save", data: {
      "noteId": noteId,
      "folderId": folderId,
      "title": title,
    });
  }

  Future<void> saveContent(int noteId, String title, List<NoteBlock> content) async {
    await _api.dio.post("/api/note/save-content", data: {
      "id": noteId,
      "title": title,
      "content": content.map((e) => e.toJson()).toList(),
    });
  }

  Future<void> updateNoteState(int id, {bool? isPinned, bool? isArchived, bool? isLocked}) async {
    await _api.dio.post("/api/note/update-state", data: {
      "id": id,
      if (isPinned != null) "isPinned": isPinned,
      if (isArchived != null) "isArchived": isArchived,
      if (isLocked != null) "isLocked": isLocked,
    });
  }

  Future<void> uploadAttachment(int noteId, String filePath, String blockId, int displayOrder) async {
    dio.FormData formData = dio.FormData.fromMap({
      "Id": noteId.toString(),
      "File": await dio.MultipartFile.fromFile(filePath),
      "BlockId": blockId,
      "DisplayOrder": displayOrder.toString(),
    });
    await _api.dio.post("/api/note/attachment", data: formData);
  }
}
