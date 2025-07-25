# 📁 Flutter Firebase File Upload App

A responsive Flutter app that allows users to sign in, upload files to Firebase Storage, preview and download them — with clean architecture using BLoC.

---

## ✅ Features

- 🔐 Firebase Authentication (Login & Signup)
- 🔼 Upload any file (image, PDF, etc.) to Firebase Storage
- 📃 List of all uploaded files
- 📥 Download button (with image resizing before download)
- 🖼️ Preview image in resized format
- 📊 Upload progress indicators
- 🚪 User logout feature
- ⚙️ BLoC for state management
- 📱 Fully responsive (Mobile, Tablet, Desktop)

---

## 📦 Tech Stack

| Tool/Library      | Purpose                      |
| ----------------- | ---------------------------- |
| Flutter           | Cross-platform framework     |
| Firebase Auth     | User login/signup            |
| Firebase Storage  | Cloud file storage           |
| BLoC              | State management             |
| Dio               | Download files with progress |
| FileSaver         | Save files (web supported)   |
| UniversalPlatform | Platform-specific code paths |

---

## 📂 Project Structure

lib/
├── common/
│ └── widgets/
│ └── appbar_widget.dart
├── home/
│ ├── bloc/
│ │ ├── home_bloc.dart
│ │ ├── home_event.dart
│ │ └── home_state.dart
│ ├── repo/
│ │ └── home_repository.dart
│ ├── views/
│ │ ├── home_page_tablet.dart
│ │ └── ... (mobile, desktop)
│ └── widgets/
│ └── ... (if separated)
└── main.dart
