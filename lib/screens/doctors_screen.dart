import 'package:flutter/material.dart';
import '../services/hospital_repository.dart';
import '../models/doctor.dart';
import '../widgets/confirmation_dialog.dart';
import '../core/app_theme.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final HospitalRepository _repo = HospitalRepository();
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors([String query = '']) async {
    setState(() => _isLoading = true);
    final data = await _repo.getDoctors(query: query);
    setState(() {
      _doctors = data;
      _isLoading = false;
    });
  }

  void _showDoctorForm([Doctor? doctor]) {
    final nameController = TextEditingController(text: doctor?.name ?? '');
    final specialtyController = TextEditingController(text: doctor?.specialty ?? '');
    final phoneController = TextEditingController(text: doctor?.phone ?? '');
    final emailController = TextEditingController(text: doctor?.email ?? '');
    final roomController = TextEditingController(text: doctor?.roomNumber ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doctor == null ? 'Add Doctor' : 'Edit Doctor'),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Doctor Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: specialtyController,
                    decoration: const InputDecoration(labelText: 'Specialty'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roomController,
                    decoration: const InputDecoration(labelText: 'Room Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newDoctor = Doctor(
                  id: doctor?.id,
                  name: nameController.text,
                  specialty: specialtyController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  roomNumber: roomController.text,
                );

                if (doctor == null) {
                  await _repo.insertDoctor(newDoctor);
                } else {
                  await _repo.updateDoctor(newDoctor);
                }
                if (mounted) Navigator.pop(ctx);
                _loadDoctors();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Doctor Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () => _showDoctorForm(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Doctor', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 350,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search doctors by name/specialty...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => _loadDoctors(val),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _doctors.isEmpty
                      ? const Center(child: Text('No doctors listed.'))
                      : SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Specialty')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Room')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _doctors.map((d) {
                                return DataRow(cells: [
                                  DataCell(Text('#${d.id}')),
                                  DataCell(Text(d.name)),
                                  DataCell(Text(d.specialty)),
                                  DataCell(Text(d.phone)),
                                  DataCell(Text(d.roomNumber)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        onPressed: () => _showDoctorForm(d),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final res = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => const ConfirmationDialog(
                                              title: 'Delete Doctor',
                                              content:
                                                  'Are you sure you want to delete this doctor?',
                                            ),
                                          );
                                          if (res == true && d.id != null) {
                                            await _repo.deleteDoctor(d.id!);
                                            _loadDoctors();
                                          }
                                        },
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
