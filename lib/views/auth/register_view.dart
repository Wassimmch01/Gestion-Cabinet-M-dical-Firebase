import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String error = '';
  bool isLoading = false;

  Future<void> register() async {
    setState(() {
      error = '';
      isLoading = true;
    });

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      setState(() {
        error = 'Le nom est requis';
        isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        error = 'Les mots de passe ne correspondent pas';
        isLoading = false;
      });
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Stockage dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'name': name,
            'email': email,
            'password':
                password, // Mot de passe stocké en clair ❌ uniquement pour test
            'role': 'patient',
            'createdAt': FieldValue.serverTimestamp(),
          });

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Erreur lors de l\'inscription';
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          "Inscription",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Créer un compte',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Inscrivez-vous en tant que patient',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: nameController,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  labelText: 'Confirmer mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              if (error.isNotEmpty)
                Text(
                  error,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Poppins',
                  ),
                ),
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
                      onPressed: register,
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Vous avez déjà un compte ? ",
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: Text(
                      'Connectez-vous',
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
