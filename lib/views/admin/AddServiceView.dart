import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('services').add({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service ajouté avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'ajout : $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un service'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du service',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Veuillez saisir un nom'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Veuillez saisir une description'
                            : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveService,
                  child:
                      _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Enregistrer le service',
                            style: TextStyle(color: Colors.white),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
