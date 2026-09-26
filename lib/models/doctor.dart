class Doctor {
  final int? id;
  final String name;
  final String specialty;
  final String phone;
  final String email;
  final String roomNumber;

  Doctor({
    this.id,
    required this.name,
    required this.specialty,
    required this.phone,
    required this.email,
    required this.roomNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'phone': phone,
      'email': email,
      'roomNumber': roomNumber,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as int?,
      name: map['name'] as String,
      specialty: map['specialty'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      roomNumber: map['roomNumber'] as String,
    );
  }
}
