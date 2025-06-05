import 'package:cabinet_medical_maria/views/appointement/EditAppointmentView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAppointmentView extends StatefulWidget {
  const UserAppointmentView({Key? key}) : super(key: key);

  @override
  State<UserAppointmentView> createState() => _UserAppointmentViewState();
}

class _UserAppointmentViewState extends State<UserAppointmentView> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _deleteAppointment(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rendez-vous supprimé')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
    }
  }

  void _editAppointment(String docId, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditAppointmentView(appointmentId: docId, data: data),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmé':
        return Colors.green;
      case 'annulé':
        return Colors.red;
      case 'accepté et modifié':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return "En attente";
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes rendez-vous')),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('appointments')
                  .where('patientId', isEqualTo: userId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
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
                final String status =
                    (data['status'] ?? 'en attente').toString().toLowerCase();
                final bool isEditable =
                    !(status == 'confirmé' || status == 'annulé');

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      '${data['service']} avec ${data['doctorName']}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Le ${data['date']} à ${data['time']}'),
                        const SizedBox(height: 4),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text("Statut : "),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatStatus(status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: isEditable ? Colors.blue : Colors.grey,
                          ),
                          onPressed:
                              isEditable
                                  ? () => _editAppointment(doc.id, data)
                                  : null,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: isEditable ? Colors.red : Colors.grey,
                          ),
                          onPressed:
                              isEditable
                                  ? () => _deleteAppointment(doc.id)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_appointment'),
        backgroundColor: Colors.blue,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}
