class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String address;
  final String medicalHistory;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.address,
    required this.medicalHistory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'medicalHistory': medicalHistory,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      medicalHistory: map['medicalHistory'] as String,
    );
  }
}
