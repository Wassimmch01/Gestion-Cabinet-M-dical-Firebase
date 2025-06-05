import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorEditMedicalRecordPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DoctorEditMedicalRecordPage({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<DoctorEditMedicalRecordPage> createState() =>
      _DoctorEditMedicalRecordPageState();
}

class _DoctorEditMedicalRecordPageState
    extends State<DoctorEditMedicalRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, Map<String, TextEditingController>> _controllers = {};
  bool _loading = true;

  List<String> availableServices = [];

  @override
  void initState() {
    super.initState();
    _loadServicesAndData();
  }

  Future<void> _loadServicesAndData() async {
    try {
      // Charger les services
      final servicesSnapshot =
          await FirebaseFirestore.instance.collection('services').get();
      availableServices =
          servicesSnapshot.docs
              .map((doc) => (doc.data()['name'] as String?) ?? doc.id)
              .toList();

      // Charger dossiers médicaux du patient
      final dossiersSnapshot =
          await FirebaseFirestore.instance
              .collection('dossiers_medicaux')
              .doc(widget.patientId)
              .collection('services')
              .get();

      for (var doc in dossiersSnapshot.docs) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());

        _controllers[doc.id] = {
          'diagnostic': TextEditingController(text: data['diagnostic'] ?? ''),
          'traitement': TextEditingController(text: data['traitement'] ?? ''),
          'note': TextEditingController(text: data['note'] ?? ''),
        };
      }
    } catch (e) {
      print('Erreur chargement : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des données'),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveAll() async {
    for (var entry in _controllers.entries) {
      await FirebaseFirestore.instance
          .collection('dossiers_medicaux')
          .doc(widget.patientId)
          .collection('services')
          .doc(entry.key)
          .set({
            'diagnostic': entry.value['diagnostic']!.text,
            'traitement': entry.value['traitement']!.text,
            'note': entry.value['note']!.text,
          });
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dossiers mis à jour')));
    }
  }

  Future<void> _addNewService() async {
    await showDialog(
      context: context,
      builder: (context) {
        String?
        selectedService; // Variable dans le scope du builder, pas dans _addNewService

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un nouveau service'),
              content: DropdownButton<String>(
                isExpanded: true,
                value: selectedService,
                hint: const Text('Choisissez un service'),
                items:
                    availableServices.map((service) {
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed:
                      selectedService == null
                          ? null
                          : () async {
                            if (_controllers.containsKey(selectedService)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Le service "$selectedService" existe déjà.',
                                  ),
                                ),
                              );
                              return;
                            }

                            await FirebaseFirestore.instance
                                .collection('dossiers_medicaux')
                                .doc(widget.patientId)
                                .collection('services')
                                .doc(selectedService)
                                .set({
                                  'diagnostic': '',
                                  'traitement': '',
                                  'note': '',
                                });

                            _controllers[selectedService!] = {
                              'diagnostic': TextEditingController(),
                              'traitement': TextEditingController(),
                              'note': TextEditingController(),
                            };

                            if (mounted)
                              setState(() {}); // Met à jour le widget principal
                            Navigator.of(context).pop();
                          },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (var map in _controllers.values) {
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Dossiers de ${widget.patientName}'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un service',
            onPressed: _addNewService,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child:
            _controllers.isEmpty
                ? const Center(
                  child: Text('Aucun dossier médical. Ajouter un service.'),
                )
                : ListView(
                  padding: const EdgeInsets.all(16),
                  children:
                      _controllers.entries.map((entry) {
                        final service = entry.key;
                        final diagnostic = entry.value['diagnostic']!;
                        final traitement = entry.value['traitement']!;
                        final note = entry.value['note']!;

                        return ExpansionTile(
                          title: Text(service),
                          children: [
                            TextFormField(
                              controller: diagnostic,
                              decoration: const InputDecoration(
                                labelText: 'Diagnostic',
                              ),
                              maxLines: 2,
                            ),
                            TextFormField(
                              controller: traitement,
                              decoration: const InputDecoration(
                                labelText: 'Traitement',
                              ),
                              maxLines: 2,
                            ),
                            TextFormField(
                              controller: note,
                              decoration: const InputDecoration(
                                labelText: 'Note',
                              ),
                              maxLines: 2,
                            ),
                          ],
                        );
                      }).toList(),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAll,
        label: const Text('Enregistrer'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
