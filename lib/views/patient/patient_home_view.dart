import 'package:cabinet_medical_maria/views/patient/PatientMedicalRecordPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userName = doc.data()?['name'] ?? 'Patient';
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (shouldLogout == true) {
      logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Mon Cabinet Médical',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/user_profile');
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Image de fond
                  Positioned.fill(
                    child: Image.asset(
                      'assets/img/bgapps.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Filtre blanc semi-transparent
                  Positioned.fill(
                    child: Container(color: Colors.white.withOpacity(0.0)),
                  ),

                  // Contenu principal
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Bienvenue, $userName 👋',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: Image.asset(
                            'assets/img/userHome.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Notre cabinet médical en ligne vous permet de prendre rendez-vous, consulter nos services et suivre vos soins en toute simplicité, où que vous soyez.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/user_services');
                          },
                          icon: const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Voir les services',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/appointments');
                          },
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Mes rendez-vous',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            final userId =
                                FirebaseAuth.instance.currentUser?.uid;
                            if (userId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PatientMedicalRecordPage(
                                        patientId: userId,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Utilisateur non connecté."),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.folder_shared,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Mon dossier médical',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: confirmLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
