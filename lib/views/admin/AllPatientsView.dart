import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllPatientsView extends StatelessWidget {
  const AllPatientsView({Key? key}) : super(key: key);

  Future<void> _deletePatient(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer ce patient ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Patient supprimé')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tous les patients')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'patient')
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
            return const Center(child: Text('Aucun patient trouvé'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(data['name'] ?? 'Nom inconnu'),
                  subtitle: Text(data['email'] ?? 'Email inconnu'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePatient(context, doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
