import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_note/app/data/models/folder_model.dart';
import 'package:new_note/app/data/services/folder_service.dart';
import 'package:new_note/app/modules/folder/folder_controller.dart';
import 'package:new_note/app/modules/folder/folder_view.dart';
import 'package:new_note/app/routes/app_pages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  testWidgets('renders the folder response and primary actions', (
    tester,
  ) async {
    await _pumpFolderView(tester);

    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('On My iPhone'), findsOneWidget);
    expect(find.text('All on My iPhone'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Flutter app'), findsOneWidget);
    expect(find.text('Recently Deleted'), findsOneWidget);

    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('0'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.folder_badge_plus), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.mic), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.square_pencil), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Edit toggles custom-folder controls on and off', (tester) async {
    final harness = await _pumpFolderView(tester);

    expect(harness.controller.isEditing.value, isFalse);
    expect(find.byIcon(CupertinoIcons.ellipsis_circle), findsNothing);
    expect(find.byIcon(CupertinoIcons.line_horizontal_3), findsNothing);

    await tester.tap(find.text('Edit'));
    await tester.pump();

    expect(harness.controller.isEditing.value, isTrue);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.ellipsis_circle), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.line_horizontal_3), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pump();

    expect(harness.controller.isEditing.value, isFalse);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
    expect(find.byIcon(CupertinoIcons.ellipsis_circle), findsNothing);
    expect(find.byIcon(CupertinoIcons.line_horizontal_3), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('folder and search taps keep their named-route contracts', (
    tester,
  ) async {
    final harness = await _pumpFolderView(tester);
    final flutterFolder = harness.controller.folders.singleWhere(
      (folder) => folder.name == 'Flutter app',
    );

    await tester.tap(find.text('Flutter app'));
    await tester.pumpAndSettle();

    expect(find.text('Note list destination'), findsOneWidget);
    expect(Get.arguments, same(flutterFolder));

    Get.back();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('Search destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<_FolderHarness> _pumpFolderView(WidgetTester tester) async {
  Get.testMode = true;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final folderService = _FakeFolderService(_folderResponse());
  Get.put<FolderService>(folderService);
  final controller = Get.put(FolderController());

  await tester.pumpWidget(
    GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const FolderView(),
      getPages: [
        GetPage(
          name: Routes.NOTE_LIST,
          page: () => const Scaffold(body: Text('Note list destination')),
        ),
        GetPage(
          name: Routes.NOTE_DETAIL,
          page: () => const Scaffold(body: Text('Note detail destination')),
        ),
        GetPage(
          name: Routes.SEARCH,
          page: () => const Scaffold(body: Text('Search destination')),
        ),
        GetPage(
          name: Routes.RECENTLY_DELETED,
          page: () =>
              const Scaffold(body: Text('Recently deleted destination')),
        ),
      ],
    ),
  );
  await tester.pump();

  return _FolderHarness(controller: controller, service: folderService);
}

FolderResponse _folderResponse() {
  return FolderResponse(
    folders: [
      FolderModel(
        id: 1,
        name: 'All on My iPhone',
        iconName: 'folder',
        colorValue: '#FFCC00',
        sortOrder: 0,
        noteCount: 1,
      ),
      FolderModel(
        id: 2,
        name: 'Notes',
        iconName: 'folder',
        colorValue: '#FFCC00',
        sortOrder: 1,
        noteCount: 1,
      ),
      FolderModel(
        id: 3,
        name: 'Flutter app',
        iconName: '5',
        colorValue: '#FFCC00',
        sortOrder: 2,
      ),
    ],
    trash: const [{}, {}, {}, {}],
    code: 200,
    message: 'OK',
  );
}

class _FolderHarness {
  const _FolderHarness({required this.controller, required this.service});

  final FolderController controller;
  final _FakeFolderService service;
}

class _FakeFolderService extends GetxService implements FolderService {
  _FakeFolderService(this.response);

  final FolderResponse response;

  @override
  Future<FolderResponse> getFolders() async => response;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
