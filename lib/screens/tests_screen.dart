import 'package:flutter/material.dart';
import '../database.dart' as db;
import '../models.dart';
import 'test_subjects_screen.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  _TestsScreenState createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final db.AppDatabase database = db.AppDatabase(); // قاعدة البيانات
  List<ClassGroup> groups = []; // قائمة الفصول
  bool isLoading = true; // حالة تحميل البيانات

  @override
  void initState() {
    super.initState();
    _loadGroups(); // تحميل الفصول عند فتح الشاشة
  }

  Future<void> _loadGroups() async {
    List<db.Student> students = await database.getStudents(); // جلب الطلاب من قاعدة البيانات
    Map<String, List<db.Student>> tempGroups = {};

    for (var student in students) {
      String key = "${student.grade}-${student.section}"; // تصنيف الطلاب حسب الصف والفصل
      tempGroups.putIfAbsent(key, () => []);
      tempGroups[key]!.add(student);
    }

    setState(() {
      groups = tempGroups.keys
          .map((key) {
            var parts = key.split('-');
            return ClassGroup(
              id: key.hashCode, // توليد ID فريد
              grade: parts[0],
              section: parts[1],
              subjects: [], // تحتاج إلى تحديث بناءً على المواد المسجلة
            );
          })
          .toList();
      isLoading = false; // إيقاف تحميل البيانات
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الاختبارات")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // عرض مؤشر تحميل
          : groups.isEmpty
              ? const Center(
                  child: Text(
                    "يجب تسجيل مجموعة واحدة على الأقل قبل إضافة الاختبارات!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.class_),
                        title: Text("الصف ${group.grade} - الفصل ${group.section}"),
                        subtitle: const Text("اضغط لعرض الاختبارات"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TestSubjectsScreen(group: group),
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
