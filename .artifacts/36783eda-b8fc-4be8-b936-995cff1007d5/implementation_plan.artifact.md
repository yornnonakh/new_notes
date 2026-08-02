# Implementation Plan - Recently Deleted & Trash Visibility & Sticky Header

Resolve the trash visibility issue and implement a full-width sticky header for the Trash and Recently Deleted screens to match the iOS system look.

## Proposed Changes

### Data Layer
#### [MODIFY] [folder_model.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/data/models/folder_model.dart)
- Update `FolderResponse` to parse an optional `archive` list in addition to `trash`, ensuring no deleted folders are missed.

### Service Layer
#### [MODIFY] [note_service.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/data/services/note_service.dart)
- Enhance `getTrashNotes()` to combine `trash` and `archive` notes from the raw API response.

### UI Structure - Sticky Body Full
#### [MODIFY] [recently_deleted_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/recently_deleted/recently_deleted_view.dart) & [trash_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/trash/trash_view.dart)
- Implement `SliverPersistentHeader` or a custom sticky header using `SliverToBoxAdapter` and `Column` logic to ensure the header stays at the top while the body takes up the full scrollable area.
- Remove redundant nesting to ensure the glass containers stretch properly.

### Logic Refinement
#### [MODIFY] [recently_deleted_controller.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/recently_deleted/recently_deleted_controller.dart)
- Implement a **polling refresh** or a more aggressive `onReady` fetch to ensure newly deleted items appear instantly.
- Log the combined count of items found in all buckets (`note`, `trash`, `archive`).

## Verification Plan

### Manual Verification
1.  **Delete Action**: Delete a folder and verify it appears in Recently Deleted.
2.  **Scroll Test**: Scroll the Recently Deleted list and verify the header remains visible and professional.
3.  **Cross-Check**: Ensure the same note appears in both "Recently Deleted" and the new "Trash" folder.
