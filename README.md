# Break Reminder (Flutter)

Smart Desk Break Reminder — Flutter app inspired by the provided Figma design.

## Prerequisites
- Flutter SDK installed and in PATH (3.22+ recommended)
- A recent Android SDK / Xcode if targeting mobile

## Setup
```powershell
# From this folder
flutter pub get
flutter run
```

If you have multiple devices, select one using:
```powershell
flutter devices
flutter run -d <device_id>
```

## Structure
- `lib/main.dart`: App entry, routing, theming
- `lib/ui/`: UI components and screens
- `lib/logic/`: Break controller and state

## Notes
- Local notifications are listed in `pubspec.yaml` but not configured. We can wire them to alert when a break starts/ends.
- Theme and typography approximate the Figma; share specific color tokens if you want an exact match.
