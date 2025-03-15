import 'package:flutter/material.dart';
import '../../data/database.dart' as db;
import '../../data/models.dart';
import 'test_subjects_screen.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final db.AppDatabase database = db.AppDatabase(); // ✅ قاعدة البيانات
  List<ClassGroup> groups = []; // ✅ قائمة الفصول
  bool isLoading = true; // ✅ حالة تحميل البيانات

  @override
  void initState() {
    super.initState();
    _loadGroups(); // ✅ تحميل الفصول عند فتح الشاشة
  }

  Future<void> _loadGroups() async {
    List<db.Group> dbGroups = await database.getGroups(); // ✅ جلب المجموعات من قاعدة البيانات

    setState(() {
      groups = dbGroups
          .map((group) => ClassGroup(
                id: group.id,
                grade: group.grade,
                section: group.section,
                subjects: [], // ✅ المواد تحتاج إلى تحديث لاحقًا
              ))
          .toList();
      isLoading = false; // ✅ إيقاف تحميل البيانات
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الاختبارات")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // ✅ عرض مؤشر تحميل
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
