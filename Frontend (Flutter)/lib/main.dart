import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:term_project/app_screen/auth_screen/auth_screen.dart';
import 'package:term_project/app_screen/notification/Notify.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

// ส่วนของ Stateless widget
class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'First Flutter App',
        debugShowCheckedModeBanner: true,
        home: AuthScreen()
    );
  }
}