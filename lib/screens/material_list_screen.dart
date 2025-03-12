import 'package:flutter/material.dart';
import '../models.dart'; // ClassGroup
import 'evaluation_list_screen.dart';

class MaterialListScreen extends StatelessWidget {
  final ClassGroup classGroup; // نمرّر الصنف والفصل من الشاشة السابقة

  const MaterialListScreen({Key? key, required this.classGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نعرض المواد الموجودة في classGroup.subjects
    return Scaffold(
      appBar: AppBar(
        title: Text("الصف ${classGroup.grade} - الفصل ${classGroup.section}"),
      ),
      body: ListView.builder(
        itemCount: classGroup.subjects.length,
        itemBuilder: (context, index) {
          final subject = classGroup.subjects[index];
          return ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(subject),
            onTap: () {
              // عند الضغط ننتقل لشاشة تقييمات المادة
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EvaluationListScreen(
                    groupKey: "${classGroup.grade}-${classGroup.section}",
                    subject: subject,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
