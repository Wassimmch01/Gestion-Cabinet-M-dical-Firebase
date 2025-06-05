import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientMedicalRecordPage extends StatelessWidget {
  final String patientId;

  const PatientMedicalRecordPage({Key? key, required this.patientId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon dossier médical"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset('assets/img/bgapps.jpg', fit: BoxFit.cover),
          ),

          // Filtre blanc semi-transparent
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.0)),
          ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('dossiers_medicaux')
                      .doc(patientId)
                      .collection('services')
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Aucun dossier médical disponible.'),
                  );
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final diagnostic =
                            data['diagnostic'] ?? 'Non renseigné';
                        final traitement =
                            data['traitement'] ?? 'Non renseigné';
                        final note = data['note'] ?? 'Non renseignée';

                        return Card(
                          color: Colors.white,
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              doc.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            children: [
                              ListTile(
                                title: const Text("Diagnostic"),
                                subtitle: Text(diagnostic),
                              ),
                              ListTile(
                                title: const Text("Traitement"),
                                subtitle: Text(traitement),
                              ),
                              ListTile(
                                title: const Text("Note"),
                                subtitle: Text(note),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
