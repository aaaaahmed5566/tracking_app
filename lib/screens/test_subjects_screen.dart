import 'package:flutter/material.dart';
import '../models.dart';
import 'test_list_screen.dart';

class TestSubjectsScreen extends StatelessWidget {
  final ClassGroup group;

  const TestSubjectsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("اختبارات ${group.grade} - الفصل ${group.section}")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: group.subjects.length,
        itemBuilder: (context, index) {
          final subject = group.subjects[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(subject),
              subtitle: const Text("عرض وإضافة الاختبارات"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TestListScreen(group: group, subject: subject),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
