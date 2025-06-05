import 'package:cabinet_medical_maria/views/patient/PatientMedicalRecordPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorPatientsView extends StatefulWidget {
  const DoctorPatientsView({super.key});

  @override
  State<DoctorPatientsView> createState() => _DoctorPatientsViewState();
}

class _DoctorPatientsViewState extends State<DoctorPatientsView> {
  String searchQuery = '';
  String? doctorId;

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      doctorId = user?.uid;
    });
  }

  Stream<List<Map<String, dynamic>>> _fetchPatientsForDoctor() async* {
    if (doctorId == null) return;

    final appointmentsSnap =
        await FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .get();

    final patientIds =
        appointmentsSnap.docs
            .map((doc) => doc['patientId'] as String)
            .toSet()
            .toList();

    if (patientIds.isEmpty) {
      yield [];
      return;
    }

    yield* FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: patientIds)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) {
                    final data = doc.data();
                    data['id'] = doc.id;
                    return data;
                  })
                  .where((patient) {
                    final name =
                        (patient['name'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery.toLowerCase());
                  })
                  .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Patients'),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un patient par nom',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                doctorId == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _fetchPatientsForDoctor(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Erreur de chargement'),
                          );
                        }
                        final patients = snapshot.data ?? [];
                        if (patients.isEmpty) {
                          return const Center(
                            child: Text('Aucun patient trouvé'),
                          );
                        }

                        return ListView.builder(
                          itemCount: patients.length,
                          itemBuilder: (context, index) {
                            final patient = patients[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                ),
                                title: Text(patient['name'] ?? 'Nom inconnu'),
                                subtitle: Text(
                                  'Email : ${patient['email'] ?? 'Non défini'}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.folder_shared,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                PatientMedicalRecordPage(
                                                  patientId: patient['id'],
                                                ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
