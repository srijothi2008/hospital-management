import 'package:flutter/material.dart';
import '../services/hospital_repository.dart';
import '../widgets/stat_card.dart';
import '../models/appointment.dart';
import '../core/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HospitalRepository _repo = HospitalRepository();
  bool _loading = true;
  Map<String, int> _stats = {};
  List<Appointment> _recentAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    final stats = await _repo.getDashboardStats();
    final appointments = await _repo.getAppointments();
    setState(() {
      _stats = stats;
      _recentAppointments = appointments.take(5).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                title: 'Total Patients',
                value: _stats['totalPatients'].toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              StatCard(
                title: 'Total Doctors',
                value: _stats['totalDoctors'].toString(),
                icon: Icons.medical_services,
                color: Colors.teal,
              ),
              StatCard(
                title: 'Pending Appts',
                value: _stats['pendingAppointments'].toString(),
                icon: Icons.hourglass_empty,
                color: Colors.orange,
              ),
              StatCard(
                title: 'Completed Appts',
                value: _stats['completedAppointments'].toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Recent Appointments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _recentAppointments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No appointments recorded.')),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentAppointments.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final appt = _recentAppointments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.event_note, color: AppTheme.primaryColor),
                          ),
                          title: Text('${appt.patientName} with ${appt.doctorName}'),
                          subtitle: Text('Date: ${appt.dateTime} | Reason: ${appt.reason}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: appt.status == 'Completed'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : (appt.status == 'Pending'
                                      ? Colors.orange.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appt.status,
                              style: TextStyle(
                                color: appt.status == 'Completed'
                                    ? Colors.green
                                    : (appt.status == 'Pending' ? Colors.orange : Colors.red),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }
}
