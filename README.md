# Flutter Firebase To-Do App

A robust, responsive To-Do List application built as part of a technical assessment. The app features secure authentication and real-time data persistence using Firebase.

## 🚀 Features
- **User Authentication:** Email/Password Sign-up and Login via Firebase Auth REST API.
- **Task Management:** Full CRUD (Create, Read, Update, Delete) functionality.
- **Persistent Storage:** Data is stored and synced using Firebase Realtime Database.
- **State Management:** Efficiently handled using the `provider` package.
- **Responsiveness:** Optimized for various screen sizes and orientations (Portrait/Landscape).
- **Auto-Login:** Remembers user sessions using `SharedPreferences`.

## 🛠️ Tech Stack
- **Framework:** Flutter
- **State Management:** Provider
- **Backend:** Firebase (Authentication & Realtime Database)
- **API Communication:** HTTP (REST API calls)

## 📦 How to Run
1. Clone this repository.
2. Run `flutter pub get` to install dependencies.
3. Connect an Android device or emulator.
4. Run `flutter run`.

## 📄 Note on Security
The Firebase Web API Key is included in the source code to allow for immediate testing by the evaluator. In a production environment, these would be managed via environment variables.