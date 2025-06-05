import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String error = '';
  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      error = '';
      isLoading = true;
    });

    try {
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = authResult.user!.uid;

      // Chercher d'abord dans 'users'
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'];

        setState(() => isLoading = false);

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_home');
        } else if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, '/doctor_home');
        } else if (role == 'patient') {
          Navigator.pushReplacementNamed(context, '/patient_home');
        } else {
          setState(() {
            error = 'Rôle utilisateur inconnu.';
          });
        }
      } else {
        // Si non trouvé dans 'users', chercher dans 'doctors'
        final doctorDoc =
            await FirebaseFirestore.instance
                .collection('doctors')
                .doc(uid)
                .get();

        if (doctorDoc.exists) {
          setState(() => isLoading = false);
          Navigator.pushReplacementNamed(context, '/doctor_home');
        } else {
          setState(() {
            error = 'Profil utilisateur non trouvé.';
            isLoading = false;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Erreur de connexion';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur inattendue : $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Connexion', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bienvenue',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Connectez-vous pour continuer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: login,
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Pas de compte ? ",
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: Text(
                      'Inscrivez-vous',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
