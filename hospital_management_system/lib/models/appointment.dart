class Appointment {
  final int? id;
  final int patientId;
  final int doctorId;
  final String patientName;
  final String doctorName;
  final String dateTime;
  final String reason;
  final String status; // 'Pending', 'Completed', 'Cancelled'

  Appointment({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.dateTime,
    required this.reason,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'dateTime': dateTime,
      'reason': reason,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      patientId: map['patientId'] as int,
      doctorId: map['doctorId'] as int,
      patientName: map['patientName'] as String,
      doctorName: map['doctorName'] as String,
      dateTime: map['dateTime'] as String,
      reason: map['reason'] as String,
      status: map['status'] as String,
    );
  }
}
