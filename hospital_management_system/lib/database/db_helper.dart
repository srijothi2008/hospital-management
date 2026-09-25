import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'hospital_system.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        medicalHistory TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        specialty TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        roomNumber TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        doctorId INTEGER NOT NULL,
        patientName TEXT NOT NULL,
        doctorName TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE,
        FOREIGN KEY (doctorId) REFERENCES doctors (id) ON DELETE CASCADE
      )
    ''');

    // Seed Demo Data
    await _seedDemoData(db);
  }

  static Future<void> _seedDemoData(Database db) async {
    await db.rawInsert('''
      INSERT INTO doctors (name, specialty, phone, email, roomNumber) VALUES
      ('Dr. Robert Smith', 'Cardiology', '+1 555-0192', 'r.smith@hospital.org', '101-A'),
      ('Dr. Sarah Jenkins', 'Pediatrics', '+1 555-0184', 's.jenkins@hospital.org', '204-B'),
      ('Dr. Michael Chang', 'Neurology', '+1 555-0143', 'm.chang@hospital.org', '305-C')
    ''');

    await db.rawInsert('''
      INSERT INTO patients (name, age, gender, phone, email, address, medicalHistory) VALUES
      ('John Doe', 45, 'Male', '+1 555-0111', 'john.doe@email.com', '123 Elm St, NY', 'Hypertension'),
      ('Emma Watson', 29, 'Female', '+1 555-0222', 'emma.w@email.com', '456 Oak Ave, NY', 'None'),
      ('James Wilson', 62, 'Male', '+1 555-0333', 'j.wilson@email.com', '789 Pine Rd, NY', 'Type 2 Diabetes')
    ''');

    String today = DateTime.now().toString().split(' ')[0];

    await db.rawInsert('''
      INSERT INTO appointments (patientId, doctorId, patientName, doctorName, dateTime, reason, status) VALUES
      (1, 1, 'John Doe', 'Dr. Robert Smith', '$today 09:30 AM', 'Routine Cardiovascular Checkup', 'Completed'),
      (2, 2, 'Emma Watson', 'Dr. Sarah Jenkins', '$today 11:00 AM', 'Seasonal Allergy Symptoms', 'Pending'),
      (3, 3, 'James Wilson', 'Dr. Michael Chang', '$today 02:15 PM', 'Migraine Follow-up', 'Pending')
    ''');
  }
}
