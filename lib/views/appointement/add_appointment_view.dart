import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddAppointmentView extends StatefulWidget {
  const AddAppointmentView({Key? key}) : super(key: key);

  @override
  State<AddAppointmentView> createState() => _AddAppointmentViewState();
}

class _AddAppointmentViewState extends State<AddAppointmentView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String? selectedService;
  String? selectedDoctorId;
  String? selectedDoctorName;

  List<String> services = [];
  List<Map<String, dynamic>> doctors = [];

  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('services').get();
    setState(() {
      services = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> fetchDoctorsForService(String serviceName) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('doctors')
            .where('service', isEqualTo: serviceName)
            .get();

    setState(() {
      doctors =
          snapshot.docs
              .map((doc) => {'id': doc.id, 'name': doc['name']})
              .toList();
      selectedDoctorId = null;
      selectedDoctorName = null;
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime != null) {
      final formattedTime =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }

  Future<void> _addAppointment() async {
    if (!_formKey.currentState!.validate() ||
        selectedDoctorId == null ||
        selectedService == null) {
      print('Formulaire non valide ou données manquantes');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Récupérer les infos du patient dans la collection 'users'
      final patientDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (!patientDoc.exists) {
        print('Document utilisateur non trouvé avec id: $userId');
        setState(() {
          error = 'Utilisateur non trouvé.';
          isLoading = false;
        });
        return;
      }

      final data = patientDoc.data();
      if (data == null || !data.containsKey('name')) {
        print('Champ "name" absent dans le document utilisateur');
        setState(() {
          error = 'Nom de l\'utilisateur manquant.';
          isLoading = false;
        });
        return;
      }

      final patientName = data['name'] as String;

      print('Nom du patient : $patientName');
      print('selectedDoctorId: $selectedDoctorId');
      print('selectedService: $selectedService');

      // Ajouter le rendez-vous avec le nom du patient
      await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': userId,
        'patientName': patientName, // on ajoute le nom du patient ici
        'doctorId': selectedDoctorId,
        'doctorName': selectedDoctorName,
        'service': selectedService,
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'status': 'en_attente',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = 'Erreur : $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau rendez-vous')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            services.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedService,
                        decoration: const InputDecoration(
                          labelText: 'Service',
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        items:
                            services.map((service) {
                              return DropdownMenuItem<String>(
                                value: service,
                                child: Text(service),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedService = value;
                            doctors = [];
                          });
                          if (value != null) fetchDoctorsForService(value);
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Veuillez choisir un service'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedDoctorId,
                        decoration: const InputDecoration(
                          labelText: 'Docteur',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items:
                            doctors.map((doctor) {
                              return DropdownMenuItem<String>(
                                value: doctor['id'],
                                child: Text(doctor['name']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDoctorId = value;
                            selectedDoctorName =
                                doctors.firstWhere(
                                  (doc) => doc['id'] == value,
                                )['name'];
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Veuillez choisir un docteur'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: _selectDate,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Champ requis'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Heure',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        onTap: _selectTime,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Champ requis'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      if (error.isNotEmpty)
                        Text(error, style: const TextStyle(color: Colors.red)),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _addAppointment,
                            child: const Text('Valider le rendez-vous'),
                          ),
                    ],
                  ),
                ),
      ),
    );
  }
}
