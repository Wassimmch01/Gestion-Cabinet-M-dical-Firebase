import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Tableau de bord')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenue Admin',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Image illustrative
            Center(
              child: Image.asset(
                'assets/img/adminHome.jpg',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add_doctor');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Ajouter un docteur'),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/list_doctors');
              },
              icon: const Icon(Icons.medical_services),
              label: const Text('Voir tous les docteurs'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add_service');
              },
              icon: const Icon(Icons.add_business),
              label: const Text('Ajouter un service'),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/list_services');
              },
              icon: const Icon(Icons.list),
              label: const Text('Voir les services'),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/all_patients');
              },
              icon: const Icon(Icons.people),
              label: const Text('Voir tous les patients'),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
