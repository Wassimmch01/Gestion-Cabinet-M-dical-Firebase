import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorHomeView extends StatelessWidget {
  const DoctorHomeView({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final blue700 = Colors.blue.shade700;
    final doctorId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Docteur'),
        backgroundColor: blue700,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/doctor_profile');
            },
            tooltip: 'Profil',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/bgapps.jpg"), // 🖼️ ton fond d’écran
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenue Docteur 👨‍⚕️',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: blue700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 📸 IMAGE ENTRE TITRE ET BOUTONS
              Image.asset('assets/img/DoctorHome.png', height: 300),

              const SizedBox(height: 40),
              _buildHomeButton(
                context,
                icon: Icons.people,
                label: 'Mes Patients',
                onTap: () {
                  Navigator.pushNamed(context, '/doctor_patients');
                },
                buttonColor: blue700,
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                icon: Icons.calendar_today,
                label: 'Mes Rendez-vous',
                onTap: () {
                  if (doctorId != null) {
                    Navigator.pushNamed(
                      context,
                      '/doctor_appointments',
                      arguments: {'doctorId': doctorId},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Erreur : ID docteur manquant"),
                      ),
                    );
                  }
                },
                buttonColor: blue700,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Déconnexion', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => _logout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color buttonColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
