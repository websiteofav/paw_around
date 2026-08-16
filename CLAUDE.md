# Paw Around — Claude Code Rules

## Project Overview
Flutter pet management app (iOS + Android). Firebase backend. Version 1.0.5+8.
Package: `com.pawaround.app` | Primary color: `#00C8A6` (teal)

## Architecture
```
lib/
  bloc/         # State management (flutter_bloc) — feature subfolders
  constants/    # AppStrings, AppColors, AppTextStyles, AppRoutes, AppSpacing
  core/         # DI (GetIt), error handling, observers
  models/       # Firestore data models
  repositories/ # Data access layer (Firestore, Auth, Storage)
  router/       # GoRouter configuration (app_router.dart)
  services/     # Business logic (notifications, location, analytics)
  ui/           # Feature screens + widgets/ subdirs
  utils/        # Helpers
```

## Critical Rules

### Constants — ALWAYS use, NEVER hardcode
- **Strings:** `AppStrings.xxx` — never `Text('Save')` or `Text("Cancel")`
- **Colors:** `AppColors.xxx` — never `Colors.blue`, `Color(0xFF...)`, `Colors.white`
- **Text Styles:** `AppTextStyles.semiBoldStyle600(fontSize:, fontColor:)` — never `TextStyle(...)`
- **Spacing:** `AppSpacing`, `AppEdgeInsets`, `AppBorderRadius` — never magic numbers
- **Routes:** `AppRoutes.xxx` — never hardcoded path strings
- If a constant doesn't exist, add it to the constants file first

### Navigation
- Use `context.go()` or `context.pushNamed()` from GoRouter
- Never `Navigator.push()` or `Navigator.pop()`
- Named routes from `AppRoutes`

### State Management
- BLoC pattern only (`flutter_bloc`)
- Business logic in BLoCs, not in UI widgets
- `BlocBuilder` for reactive UI, `BlocListener` for side effects
- Never put async logic directly in `build()`

### UI Screen Size
- Screens must stay under **200 lines**
- Extract into `widgets/` subdirectory when exceeded

### Decorations — ALWAYS use `smoothDecoration`, never `BoxDecoration`
- Use `smoothDecoration(cornerRadius:, color:, shadows:, side:)` from `app_decorations.dart`
- Never use `BoxDecoration(borderRadius: BorderRadius.circular(...))` — use `smoothDecoration` instead
- For clipping children to smooth corners, use `ClipSmoothRect(radius: SmoothBorderRadius(cornerRadius:, cornerSmoothing: 1.0))`
```dart
// CORRECT
smoothDecoration(cornerRadius: 16, color: AppColors.white, shadows: [...])
// WRONG
BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.white)
```

### Shadows — use `AppColors.shadowOverlay`, never `Colors.black`
```dart
// CORRECT
BoxShadow(color: AppColors.shadowOverlay.withValues(alpha: 0.06), blurRadius: 12, offset: Offset(0, 4))
// WRONG
BoxShadow(color: Colors.black.withValues(alpha: 0.06), ...)
```

## Design Patterns

### Standard Card
```dart
Container(
  padding: AppEdgeInsets.cardPadding,
  decoration: BoxDecoration(
    color: AppColors.white,
    borderRadius: AppBorderRadius.md,
    boxShadow: [BoxShadow(color: AppColors.shadowOverlay.withValues(alpha: 0.05), blurRadius: 12, offset: Offset(0, 4))],
  ),
)
```

### Bottom Sheet
- `backgroundColor: Colors.transparent` on `showModalBottomSheet`
- Container: `color: AppColors.surface`, `borderRadius: BorderRadius.vertical(top: Radius.circular(24))`
- Handle bar: `Container(width: 40, height: 4, color: AppColors.border)` with `margin bottom: 24`

### Dialog
- `backgroundColor: AppColors.white`, `borderRadius: BorderRadius.circular(24)`
- `contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 16)`

### Border Radius
| Constant | Value | Use |
|---|---|---|
| `AppBorderRadius.xs` | 8 | Chips, tags |
| `AppBorderRadius.sm` | 12 | Buttons, inputs |
| `AppBorderRadius.md` | 16 | Small cards |
| `AppBorderRadius.lg` | 20 | Medium cards |
| `AppBorderRadius.xl` | 24 | Large cards, dialogs, bottom sheets |
| `AppBorderRadius.full` | 999 | Pills |

## Reusable Widgets
Prefer existing components before creating new ones:
- `CommonButton` — variants: primary, secondary, outline, text, danger
- `CommonTextField` / `CommonFormField` — text inputs
- `ScaleButton` — tappable cards/items
- `AnimatedCard` — animated list items
- `EmptyStateWidget` — empty states

## Code Quality Checklist
Before writing or reviewing code:
1. `AppStrings` for all text?
2. `AppColors` for all colors?
3. `AppTextStyles` for all text styles?
4. `AppBorderRadius` for border radius?
5. `AppColors.shadowOverlay` for shadows?
6. `AppEdgeInsets`/`AppSpacing` for spacing?
7. Screen under 200 lines?
8. Existing common widgets used?
9. BLoC pattern followed?
10. `go_router` for navigation?
11. `const` constructors where possible?
12. No magic numbers?

## Firebase Structure
```
users/{userId}/
  pets/{petId}/         # Pet profiles
    vaccines[]          # Vaccine records
    groomingSettings    # Grooming schedule
    tickFleaSettings    # Tick/flea schedule
community/posts/{postId}/   # Lost & Found community
places/vets|groomers|petStores/
```

## Key Services
- `NotificationService` — local notifications, snooze (30-sec delay)
- `LocationService` — geolocator wrapper
- `AnalyticsService` — Firebase Analytics
- `DeepLinkService` — app_links deep linking
- `PushMessageService` — Firebase Messaging

## Import Order
```dart
import 'package:flutter/material.dart';       // 1. Flutter
import 'package:flutter_bloc/flutter_bloc.dart'; // 2. Packages
import 'package:paw_around/constants/...';    // 3. Local (constants → models → services → bloc → ui)
```

## Performance
- `const` constructors everywhere possible
- `ListView.builder` for long lists
- Specific `BlocBuilder` state checks to minimize rebuilds
- No widget creation inside `build()` methods

## When in Doubt
Check existing similar screens in `lib/ui/` for established patterns. Maintain consistency above all else.
