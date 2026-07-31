import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_note/app/data/models/folder_model.dart';
import 'package:new_note/app/data/models/note_model.dart';
import 'package:new_note/app/data/services/folder_service.dart';
import 'package:new_note/app/data/services/note_service.dart';
import 'package:new_note/app/modules/folder/folder_controller.dart';
import 'package:new_note/app/modules/folder/widgets/folder_create_modal.dart';
import 'package:new_note/app/modules/note/note_controller.dart';
import 'package:new_note/app/modules/note/note_detail_view.dart';
import 'package:new_note/app/modules/recently_deleted/recently_deleted_controller.dart';
import 'package:new_note/app/modules/recently_deleted/recently_deleted_view.dart';
import 'package:new_note/app/routes/app_pages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  group('New Folder modal', () {
    testWidgets('shows the selected default name and only saves a valid name', (
      tester,
    ) async {
      final harness = await _pumpFolderCreateModal(tester);
      final nameField = tester.widget<TextField>(
        find.byKey(const ValueKey('folder-name-field')),
      );

      expect(find.text('New Folder'), findsNWidgets(2));
      expect(nameField.controller?.text, 'New Folder');
      expect(
        nameField.controller?.selection,
        const TextSelection(baseOffset: 0, extentOffset: 10),
      );
      expect(find.text('Make Into Smart Folder'), findsOneWidget);
      expect(
        find.text('Organize using tags and other filters'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('close-folder-modal-button')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('save-folder-button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('clear-folder-name-button')));
      await tester.pump();
      expect(nameField.controller?.text, isEmpty);

      await tester.tap(find.byKey(const ValueKey('save-folder-button')));
      await tester.pump();
      expect(harness.service.savedFolders, isEmpty);

      await tester.enterText(
        find.byKey(const ValueKey('folder-name-field')),
        'Projects',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('save-folder-button')));
      await tester.pump();

      expect(harness.service.savedFolders, hasLength(1));
      expect(harness.service.savedFolders.single.name, 'Projects');
      expect(tester.takeException(), isNull);
    });
  });

  group('Note detail', () {
    testWidgets('renders canned content, attachment, and editor controls', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpNoteDetail(tester);

        expect(find.text('Mobile App'), findsOneWidget);
        expect(
          find.text('Is the Future via\nThe only way you could be'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Attachment: roadmap.png'),
          findsOneWidget,
        );
        expect(find.byIcon(CupertinoIcons.photo), findsOneWidget);

        for (final key in const [
          'note-back-button',
          'note-undo-button',
          'note-share-button',
          'note-more-button',
          'note-save-button',
          'add-text-block-button',
          'add-checklist-button',
          'add-table-button',
          'add-attachment-button',
          'drawing-button',
          'camera-button',
        ]) {
          expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
        }
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  });

  group('Recently Deleted', () {
    testWidgets('shows count, note summaries, and Edit to Done state', (
      tester,
    ) async {
      final harness = await _pumpRecentlyDeleted(tester);

      expect(find.text('Recently Deleted'), findsOneWidget);
      expect(find.text('3 Notes'), findsOneWidget);
      expect(
        find.textContaining(
          'Deleted notes are removed from your devices after 30 days',
        ),
        findsOneWidget,
      );
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('New Note'), findsOneWidget);
      expect(find.text('Attachment note'), findsOneWidget);
      expect(find.text('07/20/20  Thursday Writing text'), findsOneWidget);
      expect(find.text('07/21/20'), findsOneWidget);
      expect(find.text('07/22/20  2 attachments'), findsOneWidget);
      expect(harness.controller.isEditing.value, isFalse);
      expect(find.text('Edit'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('recently-deleted-edit-button')),
      );
      await tester.pump();

      expect(harness.controller.isEditing.value, isTrue);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('recently-deleted-edit-button')),
      );
      await tester.pump();

      expect(harness.controller.isEditing.value, isFalse);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search control keeps the named-route contract', (
      tester,
    ) async {
      await _pumpRecentlyDeleted(tester);

      await tester.tap(
        find.byKey(const ValueKey('recently-deleted-search-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<_FolderHarness> _pumpFolderCreateModal(WidgetTester tester) async {
  _configurePhoneSurface(tester);
  Get.testMode = true;

  final service = _FakeFolderService();
  Get.put<FolderService>(service);
  final controller = Get.put(FolderController());

  await tester.pumpWidget(
    GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: FolderCreateModal(controller: controller)),
    ),
  );
  await tester.pump();

  return _FolderHarness(controller: controller, service: service);
}

Future<_NoteHarness> _pumpNoteDetail(WidgetTester tester) async {
  _configurePhoneSurface(tester);
  Get.testMode = true;

  final note = NoteModel(
    id: 42,
    folderId: 7,
    title: 'Mobile App',
    updatedAt: DateTime(2026, 7, 30, 11, 44),
    content: [
      TextBlock(
        id: 'body',
        text: 'Is the Future via\nThe only way you could be',
      ),
      AttachmentBlock(
        id: 'attachment',
        attachmentId: 9,
        displayName: 'roadmap.png',
      ),
    ],
  );
  final service = _FakeNoteService(noteDetail: note);
  Get.put<NoteService>(service);
  final controller = Get.put(NoteController());
  await controller.fetchNoteDetail(note.id);

  await tester.pumpWidget(
    GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NoteDetailView(),
    ),
  );
  await tester.pump();

  return _NoteHarness(controller: controller, service: service);
}

Future<_RecentlyDeletedHarness> _pumpRecentlyDeleted(
  WidgetTester tester,
) async {
  _configurePhoneSurface(tester);
  Get.testMode = true;

  final service = _FakeNoteService(trashNotes: _deletedNotes());
  Get.put<NoteService>(service);
  final controller = Get.put(RecentlyDeletedController());
  await controller.fetchDeletedNotes();

  await tester.pumpWidget(
    GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const RecentlyDeletedView(),
      getPages: [
        GetPage(
          name: Routes.SEARCH,
          page: () => const Scaffold(body: Text('Search destination')),
        ),
      ],
    ),
  );
  await tester.pump();

  return _RecentlyDeletedHarness(controller: controller, service: service);
}

void _configurePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

List<NoteModel> _deletedNotes() {
  return [
    NoteModel(
      id: 1,
      folderId: 7,
      title: 'Title',
      updatedAt: DateTime(2020, 7, 20),
      content: [TextBlock(id: 'title-body', text: 'Thursday Writing text')],
    ),
    NoteModel(id: 2, folderId: 7, title: '', updatedAt: DateTime(2020, 7, 21)),
    NoteModel(
      id: 3,
      folderId: 7,
      title: 'Attachment note',
      updatedAt: DateTime(2020, 7, 22),
      content: [
        AttachmentBlock(
          id: 'first-attachment',
          attachmentId: 10,
          displayName: 'first.png',
        ),
        AttachmentBlock(
          id: 'second-attachment',
          attachmentId: 11,
          displayName: 'second.png',
        ),
      ],
    ),
  ];
}

class _FolderHarness {
  const _FolderHarness({required this.controller, required this.service});

  final FolderController controller;
  final _FakeFolderService service;
}

class _NoteHarness {
  const _NoteHarness({required this.controller, required this.service});

  final NoteController controller;
  final _FakeNoteService service;
}

class _RecentlyDeletedHarness {
  const _RecentlyDeletedHarness({
    required this.controller,
    required this.service,
  });

  final RecentlyDeletedController controller;
  final _FakeNoteService service;
}

class _FakeFolderService extends GetxService implements FolderService {
  final savedFolders = <FolderModel>[];

  @override
  Future<FolderResponse> getFolders() async {
    return FolderResponse(
      folders: <FolderModel>[],
      trash: const [],
      code: 200,
      message: 'OK',
    );
  }

  @override
  Future<Map<String, dynamic>> saveFolder(FolderModel folder) async {
    savedFolders.add(folder);
    return {'code': 200, 'message': 'OK'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNoteService extends GetxService implements NoteService {
  _FakeNoteService({this.noteDetail, this.trashNotes = const []});

  final NoteModel? noteDetail;
  final List<NoteModel> trashNotes;
  final List<int> requestedNoteIds = [];
  final List<int> savedNoteIds = [];

  @override
  Future<NoteModel> getNoteDetail(int id) async {
    requestedNoteIds.add(id);
    return noteDetail!;
  }

  @override
  Future<List<NoteModel>> getTrashNotes() async => trashNotes;

  @override
  Future<void> saveContent(
    int noteId,
    String title,
    List<NoteBlock> content,
  ) async {
    savedNoteIds.add(noteId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
