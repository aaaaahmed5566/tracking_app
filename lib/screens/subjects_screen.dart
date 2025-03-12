// lib/screens/subjects_screen.dart
import 'package:flutter/material.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المواد'),
      ),
      body: const Center(child: Text('محتوى المواد والدروس')),
    );
  }
}
