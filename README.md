# SCMP Staff Management App

The People Department aims to offer employees a secure and user-friendly mobile application. This Flutter application provides a Login Authentication Page and a Staff Directory Page.

## Features

- **Login Authentication Page**
  - Validates email and masked password (6-10 characters, letters and numbers only).
  - Authenticates against the auto-seeded `auth_users` table in `scmp_app.db`.
  - Hashes the entered password before matching it with the stored SQLite password hash.
  - Returns a JWT-style token after successful login.
  - Shows loading indicator during login.
  - Handles API errors gracefully.
- **Staff Directory Page**
  - Displays a list of staff information (avatar, email, first and last name).
  - Shows login token at the top.
  - Requires authorization before any staff-directory API or repository access.
  - Calls the ReqRes staff list API and caches results locally.
  - Implements pagination ("Load More") without full page re-rendering.
- **Local Storage / Caching**
  - Uses SQLite locally without any separate database username or database password.
  - Uses the `scmp_app.db` database name on every platform.
  - Automatically creates all app tables and seeds dummy data when the app starts.
  - Uses the local database as API cache and offline fallback.

## Architecture & Tech Stack

- **Framework**: Flutter
- **Architecture**: MVVM (Model-View-ViewModel)
- **Dependency Injection**: `get_it`
- **State Management**: `provider`
- **Network**: `dio`
- **Local DB**: `sqlite3`
- **Images**: `cached_network_image`

## Assignment Alignment

- **Agentic Coding**: Implemented with AI agentic coding workflow and documented in [AGENTS.md](file:///C:/Users/leekw/Documents/Flutter%20test%20SCMP/scmp_staff_app/AGENTS.md)
- **Repository URL**: [GitHub Repository](https://github.com/dororolkp/scmp_staff_app)
- **Architecture**: MVVM with dependency injection and observer-style state updates
- **Testing**: Includes unit and widget tests with focused database verification
- **Scalability**: Code is separated into services, repositories, viewmodels, models, and views

## Prerequisites

- **Flutter SDK**: `>= 3.41.6`
- **Dart SDK**: `>= 3.11.4`

To install the Flutter SDK (which includes the Dart SDK), please follow the official guide for your operating system:
- [Windows](https://docs.flutter.dev/get-started/install/windows)
- [macOS](https://docs.flutter.dev/get-started/install/macos)
- [Linux](https://docs.flutter.dev/get-started/install/linux)

*Note: The Dart SDK is bundled with Flutter. If you need to install Dart separately for any reason, you can follow the [Dart installation guide](https://dart.dev/get-dart).*

After installation, verify your setup by running `flutter doctor` in your terminal.

## How to Run

1. Clone this repository and navigate to the project directory (`cd scmp_staff_app`).
2. Run `flutter pub get` to install all dependencies.
3. Run the app:
   - Mobile / desktop:
     ```bash
     flutter run
     ```
   - Web:
     ```bash
     flutter run -d chrome
     ```
   - `REQRES_API_KEY` is optional. If it is not provided, the app still runs and uses the local seeded/cached SQLite data for staff loading.
4. Use one of the following testing auth credentials to log in:
   - `eve.holt@reqres.in` / `cityslicka`
   - `john.doe@company.com` / `abc123`

### Testing Auth Credentials

This is a testing application, so the usable login credentials are documented here directly:

- `eve.holt@reqres.in` / `cityslicka`
- `john.doe@company.com` / `abc123`

These are the plaintext credentials you enter on the login screen. The database still stores hashed password values internally.

## API Reference Used By The App

### API Application

- **API Provider**: ReqRes Demo API
- **Base URL**: `https://reqres.in/api`
- **Client Service**: [api_service.dart](file:///C:/Users/leekw/Documents/Flutter%20test%20SCMP/scmp_staff_app/lib/core/services/api_service.dart)
- **Authorization Model**: local SQLite login + JWT-style session token
- **Database Connection**: API responses are connected to the `sqlite3`-backed `scmp_app.db` cache layer
- **API Key Requirement**: optional for runtime; without it, staff loading falls back to local seeded/cached SQLite data
- **Persistence Flow**:
  - login credentials are read from `auth_users`
  - generated login tokens are stored in `session`
  - staff responses are stored in `staff`
  - pagination metadata is stored in `staff_list_meta`
  - API application metadata is stored in `app_config`

### Login Authorization Flow

- **Source**: local SQLite table `auth_users`
- **Method**: local credential validation with hashed password comparison
- **Seeded Login Credentials**:

```json
[
  {
    "email": "eve.holt@reqres.in",
    "password": "cityslicka"
  },
  {
    "email": "john.doe@company.com",
    "password": "abc123"
  }
]
```

- **Database Storage**:
  - the `password` column stores a SHA-256 hash, not the raw password text
  - the app hashes the entered password before matching it in SQLite
- **Success Result**:
  - generates a JWT-style token
  - stores the token in `session`
  - authorizes access to the staff directory page

### Staff List API

- **Endpoint**: `https://reqres.in/api/users?page=1`
- **Method**: `GET`
- **Behavior**:
  - A valid JWT-style login token is required before the request is allowed
  - Page 1 is loaded first
  - Additional pages are loaded with the `Load More` button
  - Successful API responses are cached into `scmp_app.db`
  - If the API is unavailable or no ReqRes API key is provided, the app falls back to cached database rows and seeded dummy data

## Database Setup

No manual database setup is required.

- The program automatically creates and initializes `scmp_app.db`.
- `scmp_app.db` does not require a database username or database password.
- Native platforms store the file in the repository root:
  - `.\scmp_staff_app\scmp_app.db`
- Web uses the same database name, `scmp_app.db`, in browser-backed storage for the web backend.

### Tables Created Automatically

The program creates these tables during startup:

- `session`
  - Columns: `id`, `user_id`, `email`, `token`
  - Seeded automatically with a placeholder row for the active login session
- `auth_users`
  - Columns: `id`, `email`, `password`
  - Seeded automatically with dummy login credentials and hashed password values
- `staff`
  - Columns: `id`, `email`, `first_name`, `last_name`, `avatar`
  - Seeded automatically with 12 dummy staff records
- `staff_list_meta`
  - Columns: `id`, `page`, `per_page`, `total`, `total_pages`, `last_synced_at`
  - Seeded automatically with the default pagination metadata
- `app_config`
  - Columns: `config_key`, `config_value`
  - Seeded automatically with database name, API application name, API base URL, repository URL, architecture, and agentic tooling metadata

### Automatic Dummy Data Seeding

When the app starts and `scmp_app.db` does not exist yet, or when the tables are empty, the program will:

1. Create all required tables automatically.
2. Insert the default `session` row automatically.
3. Insert the seeded `auth_users` login rows automatically.
4. Insert the default `staff_list_meta` row automatically.
5. Insert the default `app_config` rows automatically.
6. Insert 12 dummy staff rows automatically.

You do not need to run SQL manually.

### API And Database Flow

1. The app starts and initializes `scmp_app.db`.
2. All required tables are created automatically.
3. Dummy data is seeded automatically if the tables are empty.
4. Login hashes the entered password and checks the local `auth_users` table for a matching email and password hash.
5. A successful login generates a JWT-style token and stores it in `session`.
6. The API application uses the base URL `https://reqres.in/api`.
7. Staff pages verify the stored token before any protected access is allowed.
8. Authorized staff requests try the ReqRes users endpoint first and cache the returned rows in `staff`.
9. Pagination metadata is updated in `staff_list_meta`.
10. If the API fails or no API key is configured, the app reads from `scmp_app.db` instead of crashing.

### Reset The Database

If you want to recreate the database and seed everything again:

1. Close the running app.
2. Delete `scmp_app.db` from the repository root.
3. Run the app again with `flutter run`.

The program will rebuild the database and populate the dummy data automatically.

## Testing

Run unit tests using the following command:

```bash
flutter test
```

To specifically verify database creation and CRUD behavior:

```bash
flutter test test/database_crud_test.dart
```

## Agentic Coding

This app was developed heavily leveraging AI Agentic coding tools to minimize direct human involvement. Please refer to `AGENTS.md` for more details on how agents were utilized.
