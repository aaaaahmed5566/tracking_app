import 'package:flutter/material.dart';
import '../data.dart'; // يحتوي على: List<ClassGroup> groups و Map<String, List<Student>> studentGroupsGlobal
import 'group_details_screen.dart';

class StudentRegistrationScreen extends StatelessWidget {
  const StudentRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل الطلاب"),
      ),
      body: groups.isEmpty
          ? const Center(child: Text("لا توجد مجموعات مسجلة"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final groupKey = "${group.grade}-${group.section}";
                final studentCount =
                    studentGroupsGlobal[groupKey]?.length ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text("الصف ${group.grade} - الفصل ${group.section}"),
                    subtitle: Text(
                        "المواد: ${group.subjects.isEmpty ? "لا توجد مواد" : group.subjects.join(', ')}\nعدد الطلاب: $studentCount"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // عند الضغط على المجموعة، ينتقل المستخدم إلى صفحة تفاصيل المجموعة
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDetailsScreen(groupKey: groupKey),
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
