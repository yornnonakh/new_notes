# Implementation Plan - Modern Auth & Splash UI Refinement

Modernize the Splash, Login, and Register screens with smooth animations and the updated iOS-style color palette.

## Proposed Changes

### Theme & Colors
- All screens will now strictly use `AppTheme.bodyColor` (0xFFF2F2F7) as the background.
- UI elements will use `AppTheme.textPrimary`, `AppTheme.textSecondary`, and `AppTheme.folderYellow`.
- Replace all deprecated `withOpacity` calls with `withValues(alpha: ...)`.

### Splash Screen
#### [MODIFY] [splash_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/splash/splash_view.dart)
- **Background**: Switch from a harsh orange gradient to the clean `bodyColor`.
- **Animation**: Refine the icon scale and shimmer effect. Add a fade-in for the "Piisiit Note" text with a slight slide-up.

### Authentication Screens
#### [MODIFY] [login_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/auth/login_view.dart)
- **Structure**: Replace the dark glass container with a clean, high-opacity white `LiquidGlassContainer` (80-100% opacity) to match the Folder list cards.
- **Typography**: Switch all text to `AppTheme.textPrimary` and `AppTheme.textSecondary`.
- **Input Fields**: Update to match the Search bar style (rounded corners, subtle borders).
- **Animations**:
    - Staggered fade-in and slide-up for title, subtitle, and input fields.
    - Button pulse animation on loading.

#### [MODIFY] [register_view.dart](file:///Users/yornnona/Documents/flutter_app/new_note/lib/app/modules/auth/register_view.dart)
- **Style Consistency**: Apply the same clean, white-on-gray aesthetic as the Login view.
- **Animations**: Implement matching entry animations for a seamless transition between login and register.

## Verification Plan
- **Visual Match**: Verify that the auth screens look like part of the same app as the Folders and Notes screens.
- **Animation Smoothness**: Confirm that transitions are fluid and non-blocking.
- **Functional Check**: Verify that Login and Register still correctly communicate with the `AuthController` and backend.
