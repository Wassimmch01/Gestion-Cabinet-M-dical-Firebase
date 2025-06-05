import 'package:cabinet_medical_maria/views/admin/AddDoctorView.dart';
import 'package:cabinet_medical_maria/views/admin/AddServiceView.dart';
import 'package:cabinet_medical_maria/views/admin/AdminHomeView.dart';
import 'package:cabinet_medical_maria/views/admin/AllPatientsView.dart';
import 'package:cabinet_medical_maria/views/admin/ListDoctorsView.dart';
import 'package:cabinet_medical_maria/views/admin/ServicesListView.dart';
import 'package:cabinet_medical_maria/views/appointement/add_appointment_view.dart';
import 'package:cabinet_medical_maria/views/auth/register_view.dart';
import 'package:cabinet_medical_maria/views/doctor/DoctorMedicalRecordPage.dart';
import 'package:cabinet_medical_maria/views/doctor/doctor_appointments.dart';
import 'package:cabinet_medical_maria/views/doctor/doctor_home_view.dart';
import 'package:cabinet_medical_maria/views/doctor/doctor_patients.dart';
import 'package:cabinet_medical_maria/views/doctor/doctor_profile.dart';
import 'package:cabinet_medical_maria/views/patient/PatientMedicalRecordPage.dart';
import 'package:cabinet_medical_maria/views/patient/UserProfilePage.dart';
import 'package:cabinet_medical_maria/views/patient/patient_home_view.dart';
import 'package:cabinet_medical_maria/views/appointement/user_appointment_view.dart';
import 'package:cabinet_medical_maria/views/patient/user_services_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/theme/app_theme.dart';
import 'views/auth/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CabinetMedicalApp());
}

class CabinetMedicalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cabinet Médical',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginView(),
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/patient_home': (context) => const PatientHomeView(),
        '/medical_record': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args == null || args is! String) {
            return const Scaffold(
              body: Center(child: Text("Erreur : patientId manquant.")),
            );
          }
          return PatientMedicalRecordPage(patientId: args);
        },
        '/user_profile': (context) => const UserProfilePage(),
        '/appointments': (context) => const UserAppointmentView(),
        '/add_appointment': (context) => const AddAppointmentView(),
        '/admin_home': (context) => const AdminHomeView(),
        '/add_doctor': (context) => const AddDoctorView(),
        '/list_doctors': (context) => const ListDoctorsView(),
        '/all_patients': (context) => const AllPatientsView(),
        '/add_service': (context) => const AddServiceView(),
        '/list_services': (context) => const ServicesListView(),
        '/doctor_home': (context) => const DoctorHomeView(),
        '/doctor_patients': (context) => const DoctorPatientsView(),
        '/doctor/medical_record': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return DoctorEditMedicalRecordPage(
            patientId: args['patientId'].toString(),
            patientName: args['patientName'].toString(),
          );
        },
        '/doctor_appointments': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          final doctorId = args['doctorId'] as String?;
          if (doctorId == null) {
            throw ArgumentError(
              'doctorId is required for DoctorAppointmentsView',
            );
          }
          return DoctorAppointmentsView(doctorId: doctorId);
        },
        '/doctor_profile': (context) => const DoctorProfilePage(),
        '/user_services': (context) => const UserServicesView(),
      },
    );
  }
}
