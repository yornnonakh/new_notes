# Implementation Plan - Recently Deleted & Trash Visibility Fix

Resolve the issue where deleted items are not appearing in the UI by expanding the fetching logic to include both `trash` and `archive` buckets from the API, and ensuring data is correctly mapped.

## Proposed Changes

### Data Layer
#### [MODIFY] [note_model.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/data/models/note_model.dart)
- Clean up any potential typos in the JSON mapping.
- Ensure `isArchived` and `isPinned` are correctly identified.

### Service Layer
#### [MODIFY] [note_service.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/data/services/note_service.dart)
- Update `getTrashNotes()` to return a combined list of items from both the `trash` and `archive` fields in the API response. This handles backends that use "Archive" as a staging area for deleted items.

### Controller Layer
#### [MODIFY] [recently_deleted_controller.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/recently_deleted/recently_deleted_controller.dart)
- **Unified Fetching**: Update `fetchDeletedItems` to correctly parse the `trash` array from the folder response and the combined trash/archive list from the note service.
- **Auto-Refresh**: Call `fetchDeletedItems` on every screen entry using `onReady`.

#### [MODIFY] [trash_controller.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/trash/trash_controller.dart)
- Match the robust fetching logic of the Recently Deleted controller.

### Presentation Layer
#### [MODIFY] [recently_deleted_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/recently_deleted/recently_deleted_view.dart)
- Update the item count display to reflect the total of folders and notes.
- Ensure the list rendering is stable and correctly identifies item types.

## Verification Plan

### Manual Verification
1.  **Delete & Verify**: Delete a note/folder and immediately navigate to "Recently Deleted".
2.  **Console Inspection**: Check the new `SUCCESS` debug logs to see if items are present in either `archive` or `trash` fields.
3.  **UI Sync**: Confirm the new "Trash" folder in the main list matches the count and content of the recently deleted items.
