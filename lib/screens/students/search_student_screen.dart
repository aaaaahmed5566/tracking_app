// lib/screens/search_student_screen.dart
import 'package:flutter/material.dart';

class SearchStudentScreen extends StatelessWidget {
  const SearchStudentScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث الطالب'),
      ),
      body: const Center(child: Text('محتوى بحث الطالب')),
    );
  }
}
