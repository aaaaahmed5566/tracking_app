import 'package:flutter/material.dart';
import '../data.dart';      // يحتوي على قائمة groups
import '../models.dart';   // يحتوي على ClassGroup, Student
import 'material_list_screen.dart';

class ClassListScreen extends StatelessWidget {
  const ClassListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نحصل على قائمة الصفوف من data.dart (المتغير groups)
    // كل عنصر من نوع ClassGroup
    // نعرضهم في ListView
    return Scaffold(
      appBar: AppBar(
        title: const Text("اختر الصف لتقييم الطلاب"),
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final grp = groups[index];
          final groupKey = "${grp.grade}-${grp.section}";
          // نحسب عدد الطلاب من studentGroupsGlobal إذا وُجد
          final students = studentGroupsGlobal[groupKey] ?? [];
          final count = students.length;

          return ListTile(
            leading: const Icon(Icons.list),
            title: Text("الصف ${grp.grade} الفصل ${grp.section}"),
            subtitle: Text("عدد الطلاب: $count"),
            onTap: () {
              // عند الضغط نذهب لشاشة المواد
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MaterialListScreen(classGroup: grp),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
