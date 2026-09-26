import 'package:flutter/material.dart';
import '../services/hospital_repository.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../widgets/confirmation_dialog.dart';
import '../core/app_theme.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final HospitalRepository _repo = HospitalRepository();
  List<Patient> _patients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients([String query = '']) async {
    setState(() => _isLoading = true);
    final data = await _repo.getPatients(query: query);
    setState(() {
      _patients = data;
      _isLoading = false;
    });
  }

  void _showPatientForm([Patient? patient]) {
    final nameController = TextEditingController(text: patient?.name ?? '');
    final ageController = TextEditingController(text: patient?.age.toString() ?? '');
    final genderController = TextEditingController(text: patient?.gender ?? 'Male');
    final phoneController = TextEditingController(text: patient?.phone ?? '');
    final emailController = TextEditingController(text: patient?.email ?? '');
    final addressController = TextEditingController(text: patient?.address ?? '');
    final historyController = TextEditingController(text: patient?.medicalHistory ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(patient == null ? 'Add New Patient' : 'Edit Patient'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Age'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: genderController.text,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: ['Male', 'Female', 'Other']
                              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: (v) => genderController.text = v!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: historyController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Medical History'),
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
                final newPatient = Patient(
                  id: patient?.id,
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  gender: genderController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  address: addressController.text,
                  medicalHistory: historyController.text,
                );

                if (patient == null) {
                  await _repo.insertPatient(newPatient);
                } else {
                  await _repo.updatePatient(newPatient);
                }
                if (mounted) Navigator.pop(ctx);
                _loadPatients();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(Patient patient) async {
    List<Appointment> history = await _repo.getAppointments(patientId: patient.id);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Patient Profile: ${patient.name}'),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Age / Gender:', '${patient.age} / ${patient.gender}'),
                _detailRow('Phone:', patient.phone),
                _detailRow('Email:', patient.email),
                _detailRow('Address:', patient.address),
                _detailRow('Medical History:', patient.medicalHistory),
                const SizedBox(height: 20),
                const Text('Appointment History',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                history.isEmpty
                    ? const Text('No appointment record found.')
                    : Column(
                        children: history
                            .map((a) => ListTile(
                                  dense: true,
                                  title: Text('${a.dateTime} - ${a.doctorName}'),
                                  subtitle: Text('Reason: ${a.reason}'),
                                  trailing: Text(a.status,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ))
                            .toList(),
                      ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
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
              const Text('Patient Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () => _showPatientForm(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Patient', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 350,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search patients by name/phone...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => _loadPatients(val),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _patients.isEmpty
                      ? const Center(child: Text('No patients found.'))
                      : SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Age/Gender')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _patients.map((p) {
                                return DataRow(cells: [
                                  DataCell(Text('#${p.id}')),
                                  DataCell(Text(p.name)),
                                  DataCell(Text('${p.age} / ${p.gender}')),
                                  DataCell(Text(p.phone)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility, color: Colors.blue),
                                        onPressed: () => _showPatientDetails(p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        onPressed: () => _showPatientForm(p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final res = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => const ConfirmationDialog(
                                              title: 'Delete Patient',
                                              content:
                                                  'Are you sure you want to delete this patient record?',
                                            ),
                                          );
                                          if (res == true && p.id != null) {
                                            await _repo.deletePatient(p.id!);
                                            _loadPatients();
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
