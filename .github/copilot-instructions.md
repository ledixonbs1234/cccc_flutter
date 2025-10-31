# CCCD Flutter App - AI Coding Guidelines

## Project Overview
This is a Vietnamese Citizen ID Card (CCCD) scanning Flutter application that uses Firebase for real-time communication, mobile camera scanning, and Excel export functionality. The app follows GetX pattern for state management and uses a modular architecture.

## Architecture Pattern
- **State Management**: GetX with reactive programming (`.obs` variables)
- **Structure**: Modular architecture with `modules/[feature]/[controllers|views|bindings|models]/`
- **Navigation**: GetX routing with centralized `app_pages.dart` and `app_routes.dart`
- **Dependency Injection**: GetX bindings for each module

## Key Technical Concepts

### Firebase Integration
- **Real-time Database**: `FirebaseManager` singleton handles message listening
- **Message System**: `MessageReceiveModel` for Firebase communication with timestamp-based deduplication
- **Setup Pattern**: Firebase initialization in `main.dart`, manager setup with database refs

### CCCD Data Flow
1. **Scanning**: Mobile scanner captures CCCD data → `CCCDInfo` model
2. **Storage**: List management in `HomeController.totalCCCD`
3. **Error Handling**: Separate error list with postal code tracking
4. **Export**: Excel template (`cc.xlsx`) with TSV format for clipboard

### Module Structure (GetX Pattern)
```
modules/[feature]/
├── controllers/     # Business logic with .obs reactive variables
├── views/          # UI with GetView<Controller> pattern
├── bindings/       # Dependency injection setup
└── models/         # Data models with JSON serialization
```

## Development Patterns

### Reactive Programming
- Use `.obs` for reactive variables: `final isRunning = false.obs`
- UI updates with `Obx(() => ...)` widgets
- Controllers extend `GetxController` with lifecycle methods

### Navigation & Routes
- Routes defined in `app_routes.dart` (auto-generated via get_cli)
- Navigation: `Get.toNamed(Routes.FEATURE_NAME)`
- Route registration in `app_pages.dart` with bindings

### Error Management
- Status system with `StatusType` enum and timed status messages
- Error CCCD tracking with postal code association
- Audio feedback system for user interactions

### Firebase Communication
- Singleton `FirebaseManager` with database reference caching
- Message listening with timestamp comparison for deduplication
- Auto-run state synchronization across app instances

## Key Files & Dependencies

### Critical Files
- `lib/main.dart` - Entry point with Firebase/GetX initialization
- `lib/app/routes/app_pages.dart` - Route definitions and bindings
- `lib/app/managers/fireabaseManager.dart` - Firebase real-time communication
- `lib/app/modules/home/controllers/home_controller.dart` - Main business logic (1640+ lines)

### Key Dependencies
- `get: ^4.6.6` - State management and navigation
- `mobile_scanner: ^7.0.1` - CCCD scanning functionality
- `firebase_database: ^10.0.8` - Real-time database
- `excel: ^4.0.6` - Excel file processing
- `diacritic: ^0.1.6` - Vietnamese text normalization for search

### Assets & Resources
- `assets/cc.xlsx` - Excel template for data export
- `assets/beep.mp3` - Audio feedback for user actions

## Testing & Build Commands
```bash
flutter pub get              # Install dependencies
flutter run                 # Run in debug mode
flutter build apk           # Build Android APK
flutter test                # Run unit tests
```

## Code Style Guidelines
- Use Vietnamese variable names for domain-specific concepts (`nameCurrent`, `maBuuGui`)
- Reactive variables with descriptive names and `.obs` suffix
- Card-based UI with consistent elevation and border radius (16px)
- Status message system for user feedback with auto-clear timers

## Common Gotchas
- Firebase timestamp comparison required to prevent duplicate message processing
- Vietnamese diacritic handling needed for accurate CCCD name searching
- Mobile scanner controller lifecycle management (initialize/dispose)
- Excel template path resolution for cross-platform compatibility
- Audio player state management for sound feedback
