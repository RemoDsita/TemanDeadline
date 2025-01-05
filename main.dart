import 'package:flutter/material.dart';
import 'screen/beranda.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.8),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            const SizedBox(width: 10),
            const Text(
              'My Profile',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: const Beranda(),
    );
  }
}
