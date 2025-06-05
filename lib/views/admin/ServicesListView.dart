import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesListView extends StatefulWidget {
  const ServicesListView({super.key});

  @override
  State<ServicesListView> createState() => _ServicesListViewState();
}

class _ServicesListViewState extends State<ServicesListView> {
  final CollectionReference _servicesCollection = FirebaseFirestore.instance
      .collection('services');

  Future<void> _deleteService(String docId) async {
    try {
      await _servicesCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
    }
  }

  Future<void> _confirmDelete(String docId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer ce service ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      _deleteService(docId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des services'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _servicesCollection
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data?.docs ?? [];

          if (services.isEmpty) {
            return const Center(child: Text('Aucun service trouvé.'));
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final serviceName = service['name'] ?? 'Sans nom';
              final serviceDesc = service['description'] ?? '';
              final docId = service.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    serviceName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(serviceDesc),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(docId),
                    tooltip: 'Supprimer ce service',
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
