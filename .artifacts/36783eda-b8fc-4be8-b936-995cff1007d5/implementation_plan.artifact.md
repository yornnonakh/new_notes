# Implementation Plan - iOS Note List Context Menu

Implement the high-fidelity iOS floating context menu for the Note List view, providing advanced management tools with a premium glass aesthetic.

## Proposed Changes

### Note Module Refinement
#### [MODIFY] [note_controller.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/note/note_controller.dart)
- Add stubs for new management features:
    - `toggleViewMode()` (List vs Gallery)
    - `updateSorting(String criteria)`
    - `toggleDateGrouping()`
    - `viewAllAttachments()`

#### [MODIFY] [note_list_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/note/note_list_view.dart)
- Replace the current `PopupMenuButton` with a custom gesture detector that triggers the new `NoteContextMenu`.
- Ensure the "more" button visual perfectly matches the iOS circular white button.

### UI Components
#### [NEW] [NoteContextMenu](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/note/widgets/note_context_menu.dart)
- **Styling**:
    - High-blur `BackdropFilter` with a semi-transparent white background.
    - Large border radius (16) and subtle outer shadow.
- **Menu Items**:
    - **View as Gallery**: `Icons.grid_view_rounded`
    - **Select Notes**: `Icons.check_circle_outline`
    - **Sort By**: `Icons.swap_vert_rounded` with "Default (Date Edited)" subtitle and chevron.
    - **Group By Date**: `Icons.calendar_view_day_rounded` with "Default (On)" subtitle and chevron.
    - **View Attachments**: `Icons.attach_file_rounded`

## Verification Plan

### Manual Verification
- **Visual Match**: Verify the popup matches the iOS screenshot exactly (blur, rounding, spacing).
- **Interaction**: Confirm "Select Notes" correctly triggers the edit mode.
- **Functional Stubs**: Ensure clicking the other options provides visual feedback (snackbars for now).
- **Header Fidelity**: Verify the "Notes" count subtitle and large title are still correctly weighted.
