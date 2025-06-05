import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserServicesView extends StatelessWidget {
  const UserServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference servicesCollection = FirebaseFirestore.instance
        .collection('services');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos services'),
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

          // Contenu principal : liste des services
          StreamBuilder<QuerySnapshot>(
            stream:
                servicesCollection
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
                return const Center(child: Text('Aucun service disponible.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final serviceName = service['name'] ?? 'Sans nom';
                  final serviceDesc = service['description'] ?? '';

                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      subtitle: Text(
                        serviceDesc,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
