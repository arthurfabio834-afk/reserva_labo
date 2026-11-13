import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ReservaLaboApp());
}

class ReservaLaboApp extends StatelessWidget {
  const ReservaLaboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Laboratórios IFPA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 29, 114, 74),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}