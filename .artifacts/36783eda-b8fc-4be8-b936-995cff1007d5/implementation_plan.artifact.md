# Implementation Plan - iOS Folder UI & Profile Integration

Update the Folders screen to perfectly match the iOS Notes aesthetic and integrate the Profile entry into the folder list.

## Proposed Changes

### Folder Module Refinement
#### [MODIFY] [folder_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/folder/folder_view.dart)
- **Top Actions**:
    - Ensure "Edit" text button transitions to the yellow circular checkmark in edit mode.
    - Match the "New Folder" icon (`Icons.create_new_folder_outlined`) and spacing.
- **Folder List (Edit Mode Fidelity)**:
    - System folders ("All on My iPhone", "Notes", "Recently Deleted") will be dimmed to 15% opacity and disabled when `isEditing` is true.
    - User folders will show the yellow circular more icon (`Icons.more_horiz` in a circle) and the reorder handle.
- **Profile Integration**:
    - Add a "Profile" tile at the bottom of the "On My iPhone" card group.
    - Use a person icon (`Icons.person_outline`) and navigate to the Profile screen on tap.
    - Ensure it also dims during edit mode as it's a system-level navigation.
- **Bottom Bar**:
    - Refine the floating rounded search bar with microphone.
    - Use the `Icons.open_in_new` (or similar iOS-style compose icon) on the far right.

#### [MODIFY] [folder_controller.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/folder/folder_controller.dart)
- Update `isSystemFolder` to include the "Profile" entry to ensure correct edit-mode behavior.

## Verification Plan

### Manual Verification
- **Visual Check**: Open the folder list and verify it matches the provided screenshot (padding, typography, colors).
- **Edit Mode**: Toggle edit mode and verify:
    - The header button changes correctly.
    - System folders (and Profile) are faded.
    - Custom folders show the management icons.
- **Profile Tap**: Verify tapping the new Profile entry navigates to the Profile screen.
