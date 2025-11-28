# GoDropMe Architecture Overview

This document summarizes the current structure, dependencies, navigation, and key conventions of the GoDropMe Flutter app, based on repository analysis (Oct 2025).

## Tech Stack

- Flutter (Material 3) and Dart SDK constraint: ^3.9.2
- State management & navigation: GetX (`get`)
- UI assets: `flutter_svg`, image assets under `assets/`
- Platform features:
  - Google Maps: `google_maps_flutter`
  - Permissions: `permission_handler`
  - Geolocation: `geolocator`
  - Image capture/picker: `image_picker`
  - Local storage: `shared_preferences`
  - Backend: `appwrite` client
- Lints: `flutter_lints` via `analysis_options.yaml`

## Project Structure

```
lib/
  main.dart                     # App entry; GetMaterialApp with AppTheme and AppRoutes
  routes.dart                   # Centralized route names and GetPage registry
  theme/                        # Colors and ThemeData (Material 3)
  constants/                    # Strings and UI constants (button sizes, etc.)
  utils/                        # App-wide utilities: responsive helpers, assets, typography
  common_widgets/               # Reusable UI widgets (buttons, text fields, etc.)
  config/                       # Environment values (Appwrite project/endpoint)
  services/appwrite/            # Appwrite client singleton
  sharedPrefs/                  # Local storage wrapper around SharedPreferences
  features/
    commonFeatures/             # Flows used by multiple roles (onboard, option, phone/otp)
    driverSide/                 # Driver onboarding and home
    parentSide/                 # Parent home, chat, profile, reports
assets/
  images/, icons/, json/        # Referenced via pubspec.yaml assets section
```

## App Bootstrap

- `main.dart` creates `GetMaterialApp` with:
  - theme: `AppTheme.lightTheme`
  - initialRoute: `AppRoutes.onboard`
  - getPages: `AppRoutes.routes`

## Routing & Bindings (GetX)

- `routes.dart` defines string route constants and a list of `GetPage` entries.
- Each feature screen can declare its binding to lazily provide controllers. Examples:
  - Onboarding: `OnboardBinding()` (controller: `OnboardController`)
  - Option screen: `OptionBinding()` (controller: `OptionController`)
  - Phone/OTP: `PhoneBinding()` and `OtpBinding()`
  - Driver onboarding steps: Bindings for name, licence, identification, etc.
- Navigation uses named routes (`Get.toNamed`, `Get.offAllNamed`, `Get.offNamed`).

## Common UI & Utilities

- `theme/colors.dart`: central color palette (primary, gradients, neutrals, semantic) used consistently.
- `utils/app_typography.dart`: shared text styles for common UI elements.
- `utils/responsive.dart`: helper for responsive sizing and clamped scaling using a 390pt design baseline.
- `common_widgets/`:
  - `custom_button.dart`: gradient button with optional leading and width/height controls.
  - `custom_phone_text_field.dart`: phone input with Pakistan number validator and composable prefix.
  - Additional widgets: `custom_text_field.dart`, `google_button.dart`, etc.

## Feature Highlights

- Onboarding (`features/commonFeatures/onboard`):
  - `OnboardScreen` with `PageView`, `OnboardController` tracking `pageIndex` and continuous `pageOffset` for animations.
  - `ProgressBar` reflects page progress using `pageOffset`.
  - Final page shows a `CustomButton` to continue to `OptionScreen`.
- Registration Option (`features/commonFeatures/registrationOption`):
  - `OptionScreen` composes header, illustration, actions, and terms.
  - `OptionController` centralizes actions (phone flow, TODO: Google sign-in, terms/privacy).
- Phone & OTP (`features/commonFeatures/phoneAndOtpVerfication`):
  - `EmailScreen` uses `CustonPhoneTextField` and validator for Pakistani numbers. Navigates to OTP when valid.
  - Widgets are split into small composables (header, input row, actions).
- Driver onboarding (`features/driverSide/driverRegistration`):
  - Multi-step flow: driver name, vehicle selection, personal info, licence, identification, vehicle registration.
  - Uses `SharedPreferences` via `LocalStorage` to persist step data (keys in `StorageKeys`).
- Parent map (`features/parentSide/parentHome`):
  - `ParentMapScreen` embeds `GoogleMap`, shows a chat FAB leading to `ParentChatScreen` route.

## State Management

- GetX controllers per flow/screen using Bindings, retrieved with `Get.find()` inside widgets.
- Reactive state via `Rx<T>` (e.g., `pageIndex`, `pageOffset` in onboarding).

## Persistence

- `sharedPrefs/local_storage.dart` wraps `SharedPreferences` for:
  - Primitive set/get/remove
  - JSON map and list helpers
  - Clearing onboarding-related keys atomically

## Backend

- `services/appwrite/appwrite_client.dart` exposes a singleton `Client` configured by `config/environment.dart`.
- Convenience constructors for `Account`, `Databases`, and `Storage` services.

## Assets & Fonts

- Assets paths declared in `pubspec.yaml` and referenced via `utils/app_assets.dart` constants.
- No custom fonts enabled currently (commented out section in pubspec).

## Linting & Analysis

- `analysis_options.yaml` includes `flutter_lints`. Custom rules can be added later.
- Analyzer currently shows no errors for key files scanned.

## Conventions & Notes

- Use named routes with `AppRoutes` constants and `GetPage` registry; prefer bindings to wire controllers.
- UI split into small composable widgets under each feature's `widgets/` folder to keep screens clean.
- Responsive sizing uses `Responsive.scaleClamped` to preserve design intent across devices.
- Phone validation currently tailored to Pakistan numbers; consider i18n in future.
- Secrets: `Environment` contains Appwrite public endpoint and project id; do not commit sensitive secrets.

## Potential Next Steps

- Implement Google Sign-In and terms/privacy screens.
- Add unit/widget tests for validators and critical flows (e.g., onboarding navigation).
- Centralize error handling and show validation errors accessibly (right now some use hidden error text).
- Integrate real OTP flow and Appwrite auth; wire phone verification backend.
- Add CI to run `flutter analyze` and tests.
