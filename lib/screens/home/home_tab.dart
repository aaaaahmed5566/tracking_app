// lib/screens/home_tab.dart
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
      ),
      body: const Center(child: Text('محتوى الصفحة الرئيسية')),
    );
  }
}
