import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/hospital_repository.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../models/doctor.dart';
import '../widgets/confirmation_dialog.dart';
import '../core/app_theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final HospitalRepository _repo = HospitalRepository();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final data = await _repo.getAppointments();
    setState(() {
      _appointments = data;
      _isLoading = false;
    });
  }

  void _showBookAppointmentDialog([Appointment? appointment]) async {
    final patients = await _repo.getPatients();
    final doctors = await _repo.getDoctors();

    if (patients.isEmpty || doctors.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one patient and doctor first.')),
      );
      return;
    }

    Patient selectedPatient = appointment != null
        ? patients.firstWhere((p) => p.id == appointment.patientId, orElse: () => patients.first)
        : patients.first;

    Doctor selectedDoctor = appointment != null
        ? doctors.firstWhere((d) => d.id == appointment.doctorId, orElse: () => doctors.first)
        : doctors.first;

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final reasonController = TextEditingController(text: appointment?.reason ?? '');
    String status = appointment?.status ?? 'Pending';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(appointment == null ? 'Book New Appointment' : 'Edit Appointment'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Patient>(
                      initialValue: selectedPatient,
                      decoration: const InputDecoration(labelText: 'Select Patient'),
                      items: patients
                          .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                          .toList(),
                      onChanged: (val) => setDialogState(() => selectedPatient = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Doctor>(
                      initialValue: selectedDoctor,
                      decoration: const InputDecoration(labelText: 'Select Doctor'),
                      items: doctors
                          .map((d) => DropdownMenuItem(value: d, child: Text('${d.name} (${d.specialty})')))
                          .toList(),
                      onChanged: (val) => setDialogState(() => selectedDoctor = val!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(selectedTime.format(context)),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setDialogState(() => selectedTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Reason for Visit'),
                    ),
                    if (appointment != null) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['Pending', 'Completed', 'Cancelled']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) => setDialogState(() => status = val!),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () async {
                  final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                  final formattedTime = selectedTime.format(context);
                  final dateTimeStr = '$formattedDate $formattedTime';

                  final newAppt = Appointment(
                    id: appointment?.id,
                    patientId: selectedPatient.id!,
                    doctorId: selectedDoctor.id!,
                    patientName: selectedPatient.name,
                    doctorName: selectedDoctor.name,
                    dateTime: dateTimeStr,
                    reason: reasonController.text,
                    status: status,
                  );

                  if (appointment == null) {
                    await _repo.insertAppointment(newAppt);
                  } else {
                    await _repo.updateAppointment(newAppt);
                  }

                  if (mounted) Navigator.pop(ctx);
                  _loadAppointments();
                },
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
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
              const Text('Appointment Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () => _showBookAppointmentDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Book Appointment', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                      ? const Center(child: Text('No appointments booked.'))
                      : SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Patient')),
                                DataColumn(label: Text('Doctor')),
                                DataColumn(label: Text('Date & Time')),
                                DataColumn(label: Text('Reason')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _appointments.map((a) {
                                return DataRow(cells: [
                                  DataCell(Text('#${a.id}')),
                                  DataCell(Text(a.patientName)),
                                  DataCell(Text(a.doctorName)),
                                  DataCell(Text(a.dateTime)),
                                  DataCell(Text(a.reason)),
                                  DataCell(Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: a.status == 'Completed'
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : (a.status == 'Pending'
                                              ? Colors.orange.withValues(alpha: 0.1)
                                              : Colors.red.withValues(alpha: 0.1)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      a.status,
                                      style: TextStyle(
                                        color: a.status == 'Completed'
                                            ? Colors.green
                                            : (a.status == 'Pending'
                                                ? Colors.orange
                                                : Colors.red),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        onPressed: () => _showBookAppointmentDialog(a),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final res = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => const ConfirmationDialog(
                                              title: 'Delete Appointment',
                                              content:
                                                  'Are you sure you want to delete this appointment?',
                                            ),
                                          );
                                          if (res == true && a.id != null) {
                                            await _repo.deleteAppointment(a.id!);
                                            _loadAppointments();
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
