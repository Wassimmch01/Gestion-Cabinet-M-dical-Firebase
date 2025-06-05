import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddDoctorView extends StatefulWidget {
  const AddDoctorView({Key? key}) : super(key: key);

  @override
  State<AddDoctorView> createState() => _AddDoctorViewState();
}

class _AddDoctorViewState extends State<AddDoctorView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  // Spécialité remplacée par service choisi
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  String error = '';

  List<String> services = [];
  String? selectedService;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('services').get();
      final loadedServices =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        services = loadedServices;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des services : $e';
      });
    }
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedService == null) {
      setState(() {
        error = 'Veuillez sélectionner un service';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    final String name = _nameController.text.trim();
    final String service = selectedService!;
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final doctorId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('doctors').doc(doctorId).set({
        'name': name,
        'service': service,
        'email': email,
        'phone': phone,
        'password':
            password, // Attention : stocker en clair est à éviter en prod
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Docteur ajouté avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        error = 'Erreur : $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un docteur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedService,
                decoration: const InputDecoration(labelText: 'Service'),
                items:
                    services.map((service) {
                      return DropdownMenuItem(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedService = value;
                  });
                },
                validator:
                    (value) =>
                        value == null
                            ? 'Veuillez sélectionner un service'
                            : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _saveDoctor,
                    child: const Text('Ajouter'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
