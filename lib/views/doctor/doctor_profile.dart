import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({Key? key}) : super(key: key);

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String? _docId;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('doctors')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      _docId = doc.id;
      final data = doc.data();
      _nameController.text = data['name'] ?? '';
      _serviceController.text = data['service'] ?? ''; // service affiché
      _phoneController.text = data['phone'] ?? '';
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _docId == null) return;

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.collection('doctors').doc(_docId).update(
        {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          // 'service' n'est pas modifié ici
        },
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: blue,
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 16),
                      _buildTextField('Nom complet', _nameController),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Service',
                        _serviceController,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Téléphone',
                        _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                      _saving
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _saveChanges,
                            child: const Text('Enregistrer les modifications'),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'Champ requis' : null,
    );
  }
}
