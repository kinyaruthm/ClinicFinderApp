import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/pages/register_page.dart';
import 'screens/pages/login.dart';
import 'screens/pages/home.dart';
import 'screens/pages/review.dart'; // Replace with your actual HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ClinicFinderApp());
}

class ClinicFinderApp extends StatelessWidget {
  const ClinicFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Finder',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      // 👇 Show RegisterPage first on app launch
      home: const RegisterPage(),
      routes: {
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        //'/review': (context) => const ReviewPage(),
      },
    );
  }
}
