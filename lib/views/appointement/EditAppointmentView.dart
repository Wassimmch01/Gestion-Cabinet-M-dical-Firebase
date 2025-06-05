import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditAppointmentView extends StatefulWidget {
  final String appointmentId;
  final Map<String, dynamic> data;

  const EditAppointmentView({
    Key? key,
    required this.appointmentId,
    required this.data,
  }) : super(key: key);

  @override
  State<EditAppointmentView> createState() => _EditAppointmentViewState();
}

class _EditAppointmentViewState extends State<EditAppointmentView> {
  final _formKey = GlobalKey<FormState>();

  List<String> services = [];
  List<Map<String, dynamic>> doctors = [];

  String? selectedService;
  String? selectedDoctorId;
  String? selectedDoctorName;

  late TextEditingController dateController;
  late TextEditingController timeController;

  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    selectedService = widget.data['service'];
    selectedDoctorName = widget.data['doctorName'];
    dateController = TextEditingController(text: widget.data['date']);
    timeController = TextEditingController(text: widget.data['time']);
    fetchServices().then((_) {
      if (selectedService != null) {
        fetchDoctorsForService(selectedService!);
      }
    });
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

      // On essaye de retrouver doctorId en fonction du doctorName courant
      final doctor = doctors.firstWhere(
        (d) => d['name'] == selectedDoctorName,
        orElse: () => {'id': null, 'name': null},
      );
      selectedDoctorId = doctor['id'];
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(dateController.text),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    final initialTimeParts = timeController.text.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(initialTimeParts[0]) ?? 9,
      minute: int.tryParse(initialTimeParts[1]) ?? 0,
    );

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final formattedTime =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      setState(() {
        timeController.text = formattedTime;
      });
    }
  }

  Future<void> _updateAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedService == null || selectedDoctorId == null) {
      setState(() {
        error = 'Veuillez choisir un service et un docteur.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
            'service': selectedService!,
            'doctorId': selectedDoctorId!,
            'doctorName': selectedDoctorName!,
            'date': dateController.text.trim(),
            'time': timeController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
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
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le rendez-vous')),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
                            services
                                .map(
                                  (service) => DropdownMenuItem<String>(
                                    value: service,
                                    child: Text(service),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedService = value;
                            selectedDoctorId = null;
                            selectedDoctorName = null;
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
                            doctors
                                .map(
                                  (doc) => DropdownMenuItem<String>(
                                    value: doc['id'],
                                    child: Text(doc['name']),
                                  ),
                                )
                                .toList(),
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
                        controller: dateController,
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
                        controller: timeController,
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
                            onPressed: _updateAppointment,
                            child: const Text('Enregistrer'),
                          ),
                    ],
                  ),
                ),
      ),
    );
  }
}
