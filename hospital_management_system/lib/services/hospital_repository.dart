import '../database/db_helper.dart';
import '../models/patient.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import 'package:sqflite_common/utils/utils.dart';

class HospitalRepository {
  // Patients
  Future<List<Patient>> getPatients({String query = ''}) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps;
    if (query.isEmpty) {
      maps = await db.query('patients', orderBy: 'id DESC');
    } else {
      maps = await db.query(
        'patients',
        where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    }
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  Future<int> insertPatient(Patient patient) async {
    final db = await DBHelper.database;
    return await db.insert('patients', patient.toMap());
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await DBHelper.database;
    return await db.update('patients', patient.toMap(),
        where: 'id = ?', whereArgs: [patient.id]);
  }

  Future<int> deletePatient(int id) async {
    final db = await DBHelper.database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // Doctors
  Future<List<Doctor>> getDoctors({String query = ''}) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps;
    if (query.isEmpty) {
      maps = await db.query('doctors', orderBy: 'id DESC');
    } else {
      maps = await db.query(
        'doctors',
        where: 'name LIKE ? OR specialty LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    }
    return maps.map((map) => Doctor.fromMap(map)).toList();
  }

  Future<int> insertDoctor(Doctor doctor) async {
    final db = await DBHelper.database;
    return await db.insert('doctors', doctor.toMap());
  }

  Future<int> updateDoctor(Doctor doctor) async {
    final db = await DBHelper.database;
    return await db.update('doctors', doctor.toMap(),
        where: 'id = ?', whereArgs: [doctor.id]);
  }

  Future<int> deleteDoctor(int id) async {
    final db = await DBHelper.database;
    return await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // Appointments
  Future<List<Appointment>> getAppointments({int? patientId}) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps;
    if (patientId != null) {
      maps = await db.query('appointments',
          where: 'patientId = ?', whereArgs: [patientId], orderBy: 'id DESC');
    } else {
      maps = await db.query('appointments', orderBy: 'id DESC');
    }
    return maps.map((map) => Appointment.fromMap(map)).toList();
  }

  Future<int> insertAppointment(Appointment appointment) async {
    final db = await DBHelper.database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<int> updateAppointmentStatus(int id, String status) async {
    final db = await DBHelper.database;
    return await db.update('appointments', {'status': status},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await DBHelper.database;
    return await db.update('appointments', appointment.toMap(),
        where: 'id = ?', whereArgs: [appointment.id]);
  }

  Future<int> deleteAppointment(int id) async {
    final db = await DBHelper.database;
    return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }

  // Dashboard Stats
  Future<Map<String, int>> getDashboardStats() async {
    final db = await DBHelper.database;
    String today = DateTime.now().toString().split(' ')[0];

    int? totalPatients = firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM patients'));
    int? totalDoctors = firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM doctors'));
    int? todayAppointments = firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM appointments WHERE dateTime LIKE ?',
        ['$today%']));
    int? pendingAppointments = firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM appointments WHERE status = ?', ['Pending']));
    int? completedAppointments = firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM appointments WHERE status = ?', ['Completed']));

    return {
      'totalPatients': totalPatients ?? 0,
      'totalDoctors': totalDoctors ?? 0,
      'todayAppointments': todayAppointments ?? 0,
      'pendingAppointments': pendingAppointments ?? 0,
      'completedAppointments': completedAppointments ?? 0,
    };
  }
}
