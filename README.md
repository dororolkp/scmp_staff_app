# SCMP Staff Management App

The People Department aims to offer employees a secure and user-friendly mobile application. This Flutter application provides a Login Authentication Page and a Staff Directory Page.

## Features

- **Login Authentication Page**
  - Validates email and masked password (6-10 characters, letters and numbers only).
  - Shows loading indicator during API call.
  - Handles API errors gracefully.
- **Staff Directory Page**
  - Displays a list of staff information (avatar, email, first and last name).
  - Shows login token at the top.
  - Implements pagination ("Load More") without full page re-rendering.
- **Local Storage / Caching**
  - Uses `sqflite` for storing session token and caching staff data.

## Architecture & Tech Stack

- **Framework**: Flutter
- **Architecture**: MVVM (Model-View-ViewModel)
- **Dependency Injection**: `get_it`
- **State Management**: `provider`
- **Network**: `dio`
- **Local DB**: `sqflite`
- **Images**: `cached_network_image`

## Prerequisites

- **Flutter SDK**: `>= 3.41.6`
- **Dart SDK**: `>= 3.11.4`

To install the Flutter SDK, please follow the official guide for your operating system:
- [Windows](https://docs.flutter.dev/get-started/install/windows)
- [macOS](https://docs.flutter.dev/get-started/install/macos)
- [Linux](https://docs.flutter.dev/get-started/install/linux)

After installation, verify your setup by running `flutter doctor` in your terminal.

## How to Run

1. Clone this repository and navigate to the project directory (`cd scmp_staff_app`).
2. Run `flutter pub get` to install all dependencies.
3. Run `flutter run` to build and start the app on your emulator or connected device.
4. Alternatively, if you want to run it on web, use `flutter run -d web` (Note: sqflite caching won't work on Web, but you can configure `sqflite_common_ffi_web` if needed. The app is optimized for mobile platforms as per instructions).

## Testing

Run unit tests using the following command:

```bash
flutter test
```

## Agentic Coding

This app was developed heavily leveraging AI Agentic coding tools to minimize direct human involvement. Please refer to `AGENTS.md` for more details on how agents were utilized.
