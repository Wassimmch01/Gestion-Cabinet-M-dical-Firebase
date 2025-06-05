import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorEditAppointmentPage extends StatefulWidget {
  final DocumentSnapshot appointmentDoc;

  const DoctorEditAppointmentPage({Key? key, required this.appointmentDoc})
    : super(key: key);

  @override
  _DoctorEditAppointmentPageState createState() =>
      _DoctorEditAppointmentPageState();
}

class _DoctorEditAppointmentPageState extends State<DoctorEditAppointmentPage> {
  late TextEditingController patientNameController;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String status = 'en attente';

  // Liste des statuts possibles (doit correspondre aux valeurs dans DropdownMenuItem)
  final List<String> statuses = [
    'en attente',
    'confirmé',
    'annulé',
    'accepté et modifié',
  ];

  @override
  void initState() {
    super.initState();

    final data = widget.appointmentDoc.data() as Map<String, dynamic>;
    patientNameController = TextEditingController(
      text: data['patientName'] ?? '',
    );

    // Normaliser le statut pour qu'il corresponde exactement à une des valeurs de la liste
    String rawStatus =
        (data['status'] ?? 'en attente').toString().toLowerCase();

    // On cherche dans la liste des statuts un qui contient le même texte (ignorer accent, espace, etc.)
    status = statuses.firstWhere(
      (s) => s.toLowerCase() == rawStatus,
      orElse: () => 'en attente',
    );

    if (data['date'] != null) {
      try {
        selectedDate = DateTime.parse(data['date']);
      } catch (_) {
        selectedDate = null;
      }
    }

    if (data['time'] != null) {
      final parts = (data['time'] as String).split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _saveAppointment() async {
    if (patientNameController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final dateStr =
        '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentDoc.id)
        .update({
          'patientName': patientNameController.text,
          'date': dateStr,
          'time': timeStr,
          'status': status,
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rendez-vous mis à jour')));
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    patientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le rendez-vous'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: patientNameController,
                decoration: const InputDecoration(labelText: 'Nom patient'),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? 'Date : ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'Aucune date sélectionnée',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Choisir'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedTime != null
                          ? 'Heure : ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                          : 'Aucune heure sélectionnée',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Choisir'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items:
                    statuses.map((statut) {
                      return DropdownMenuItem(
                        value: statut,
                        child: Text(
                          statut[0].toUpperCase() +
                              statut.substring(1).replaceAll('_', ' '),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveAppointment,
                child: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
