import 'package:flutter/material.dart';
import '../models.dart' as models;
import '../database.dart' as db;
import 'evaluation_list_screen.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final db.AppDatabase database = db.AppDatabase();
  List<models.ClassGroup> groups = [];
  Map<String, List<models.Student>> studentGroups = {};

  @override
  void initState() {
    super.initState();
    _loadGroupsAndStudents();
  }

  /// تحميل المجموعات الصفية والطلاب من قاعدة البيانات
  Future<void> _loadGroupsAndStudents() async {
    // جلب جميع الطلاب من قاعدة البيانات
    List<db.Student> dbStudents = await database.getStudents();

    // تجميع الطلاب حسب الصف والفصل
    Map<String, List<models.Student>> groupedStudents = {};
    for (var student in dbStudents) {
      String key = "${student.grade}-${student.section}";
      groupedStudents.putIfAbsent(key, () => []);
      groupedStudents[key]!.add(
        models.Student(
          id: student.id,              // استخدام id الطالب من قاعدة البيانات
          name: student.name,
          notes: student.notes,
        ),
      );
    }

    // إنشاء قائمة بالمجموعات الصفية
    List<models.ClassGroup> loadedGroups = groupedStudents.keys.map((key) {
      var parts = key.split('-');
      return models.ClassGroup(
        id: key.hashCode,            // توليد id باستخدام hashCode للمفتاح
        grade: parts[0],
        section: parts[1],
        subjects: [],                // قيمة افتراضية لقائمة المواد
      );
    }).toList();

    setState(() {
      groups = loadedGroups;
      studentGroups = groupedStudents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اختر الصف لتقييم الطلاب")),
      body: groups.isEmpty
          ? const Center(
              child: Text(
                "يجب تسجيل مجموعة واحدة على الأقل قبل التقييم!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final groupKey = "${group.grade}-${group.section}";
                final studentCount = studentGroups[groupKey]?.length ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.list),
                    title: Text("${group.grade} - الفصل (${group.section})"),
                    subtitle: Text("عدد الطلاب: $studentCount"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (studentCount == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("يجب تسجيل طلاب في هذا الفصل قبل التقييم!"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EvaluationListScreen(group: group),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
