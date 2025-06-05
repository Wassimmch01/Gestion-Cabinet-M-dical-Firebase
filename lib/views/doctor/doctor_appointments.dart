import 'package:cabinet_medical_maria/views/doctor/DoctorEditAppointmentPage.dart';
import 'package:cabinet_medical_maria/views/doctor/DoctorMedicalRecordPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorAppointmentsView extends StatefulWidget {
  final String doctorId;

  const DoctorAppointmentsView({Key? key, required this.doctorId})
    : super(key: key);

  @override
  _DoctorAppointmentsViewState createState() => _DoctorAppointmentsViewState();
}

class _DoctorAppointmentsViewState extends State<DoctorAppointmentsView> {
  final CollectionReference appointmentsCollection = FirebaseFirestore.instance
      .collection('appointments');

  void _editAppointment(DocumentSnapshot doc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoctorEditAppointmentPage(appointmentDoc: doc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Rendez-vous'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            appointmentsCollection
                .where('doctorId', isEqualTo: widget.doctorId)
                .orderBy('date')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Aucun rendez-vous trouvé'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;

              final patientId = data['patientId'] ?? '';
              final date = data['date'] ?? 'Non défini';
              final time = data['time'] ?? 'Non défini';
              final status =
                  (data['status'] ?? 'en_attente').toString().toLowerCase();

              Color statusColor;
              switch (status) {
                case 'confirmé':
                  statusColor = Colors.green;
                  break;
                case 'annulé':
                  statusColor = Colors.red;
                  break;
                case 'accepté et modifié':
                  statusColor = Colors.orange;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(patientId)
                        .get(),
                builder: (context, patientSnapshot) {
                  if (!patientSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  String patientName = 'Nom inconnu';
                  if (patientSnapshot.data != null &&
                      patientSnapshot.data!.exists) {
                    final patientData =
                        patientSnapshot.data!.data() as Map<String, dynamic>;
                    patientName = patientData['name'] ?? 'Nom inconnu';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        patientName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('$date à $time'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status[0].toUpperCase() +
                                  status.substring(1).replaceAll('_', ' '),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editAppointment(doc),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.folder_shared,
                              color: Colors.green,
                            ),
                            tooltip: 'Voir/modifier dossier médical',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => DoctorEditMedicalRecordPage(
                                        patientId: patientId,
                                        patientName: patientName,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
