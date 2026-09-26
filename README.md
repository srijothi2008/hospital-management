# Hospital Appointment & Patient Management System

A Flutter desktop application for managing patients, doctors, and appointments with SQLite persistence.

## How to extract the ZIP
1. Right-click `hospital_management_system.zip`.
2. Select **Extract All...** and extract it to your desired folder location.

## How to open the project in VS Code
1. Open **Visual Studio Code**.
2. Go to **File > Open Folder...** (`Ctrl + K, Ctrl + O`).
3. Navigate to and select the extracted `hospital_management_system` directory.

## Command for dependencies
Open the integrated VS Code terminal (`Ctrl + ~`) and run:
```bash
flutter pub get
```

## Command to run the Windows app
Make sure Windows Desktop support is enabled, then run:
```bash
flutter run -d windows
```

## Troubleshooting Common Errors

- **`Windows desktop support is not enabled`**:
  Run `flutter config --enable-windows-desktop` and restart VS Code.

- **`Visual C++ Build Tools missing`**:
  Ensure you have **Desktop development with C++** installed via Visual Studio Installer.

- **`sqflite_common_ffi / sqlite3.dll missing`**:
  `sqflite_common_ffi` auto-loads `sqlite3.dll` on Windows. If it fails, run `flutter clean` and then `flutter pub get`.
