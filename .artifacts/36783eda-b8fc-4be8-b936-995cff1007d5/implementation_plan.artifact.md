# Implementation Plan - Unified Search for Folders & Notes

Enhance the Search module to fetch and display both folders and notes from their respective APIs, providing a unified search experience that matches the provided JSON data structure.

## Proposed Changes

### Search Module
#### [MODIFY] [search_controller.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/search/search_controller.dart)
- **Service Integration**: Inject `FolderService` alongside `NoteService`.
- **Unified Results**:
    - Create an observable list of folders (`folderResults`).
    - Update `search()` to call both `_folderService.getFolders()` and `_noteService.getNotes()`.
    - Filter both lists based on the `searchQuery`.

#### [MODIFY] [search_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/search/search_view.dart)
- **UI Sections**:
    - Update `_buildSearchResults()` to show a "Folders" section and a "Notes" section if results are found for both.
    - Style folder search results using the same rounded white card aesthetic.
- **Navigation**:
    - Tapping a folder result should navigate to its note list.
    - Tapping a note result should navigate to the note detail.

## Verification Plan

### Manual Verification
- **Dynamic Fetching**: Type a query and verify that matching folders (like "work" or "ddd" from your JSON) appear alongside matching notes.
- **Visual Accuracy**: Ensure folder results show their dynamic icons and colors (using the helpers from `FolderModel`).
- **Navigation Flow**: Confirm that tapping search results takes you to the correct destination.
