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

## How to Run

1. Make sure you have Flutter installed and set up correctly.
2. Clone this repository.
3. Run `flutter pub get` to install all dependencies.
4. Run `flutter run` to build and start the app on your emulator or connected device.
5. Alternatively, if you want to run it on web, use `flutter run -d web` (Note: sqflite caching won't work on Web, but you can configure `sqflite_common_ffi_web` if needed. The app is optimized for mobile platforms as per instructions).

## Testing

Run unit tests using the following command:

```bash
flutter test
```

## Agentic Coding

This app was developed heavily leveraging AI Agentic coding tools to minimize direct human involvement. Please refer to `AGENTS.md` for more details on how agents were utilized.
