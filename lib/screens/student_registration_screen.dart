import 'package:flutter/material.dart';
import '../database.dart';
import 'group_details_screen.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  _StudentRegistrationScreenState createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final AppDatabase database = AppDatabase();
  late Future<List<Student>> studentsFuture;

  @override
  void initState() {
    super.initState();
    studentsFuture = database.getStudents(); // ✅ جلب جميع الطلاب من قاعدة البيانات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل الطلاب"),
      ),
      body: FutureBuilder<List<Student>>(
        future: studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ أثناء تحميل البيانات"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد مجموعات مسجلة"));
          }

          List<Student> students = snapshot.data!;
          Map<String, List<Student>> groupedStudents = {};

          for (var student in students) {
            String key = "${student.grade}-${student.section}"; // ✅ ربط الطلاب بالصف والفصل
            if (!groupedStudents.containsKey(key)) {
              groupedStudents[key] = [];
            }
            groupedStudents[key]!.add(student);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedStudents.keys.length,
            itemBuilder: (context, index) {
              String groupKey = groupedStudents.keys.elementAt(index);
              List<Student> groupStudents = groupedStudents[groupKey]!;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("الصف: ${groupKey.split('-')[0]} - الفصل: ${groupKey.split('-')[1]}"),
                  subtitle: Text("عدد الطلاب: ${groupStudents.length}"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
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
          );
        },
      ),
    );
  }
}
