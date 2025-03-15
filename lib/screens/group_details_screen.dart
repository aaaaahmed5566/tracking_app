import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift; // ✅ استيراد Drift مع تحديد بادئة
import '../database.dart' as db; // ✅ تحديد مصدر قاعدة البيانات

class GroupDetailsScreen extends StatefulWidget {
  final String groupKey; // المفتاح بالشكل "الصف-الفصل"
  const GroupDetailsScreen({super.key, required this.groupKey});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final db.AppDatabase database = db.AppDatabase(); // ✅ قاعدة البيانات
  List<db.Student> students = []; // ✅ جلب الطلاب من قاعدة البيانات

  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// ✅ **جلب الطلاب من قاعدة البيانات وتحديث القائمة**
  void _loadStudents() async {
    students = await database.getStudents();
    setState(() {});
  }

  /// ✅ **إضافة طالب جديد إلى قاعدة البيانات**
  void _addStudent() async {
    if (_studentNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال اسم الطالب")),
      );
      return;
    }

    final newStudent = db.StudentsCompanion(
      name: drift.Value(_studentNameController.text.trim()), // ✅ استخدام Drift.Value
      notes: _notesController.text.trim().isEmpty
          ? const drift.Value.absent()
          : drift.Value(_notesController.text.trim()), // ✅ استخدام Drift.Value
    );

    await database.into(database.students).insert(newStudent);
    _loadStudents(); // ✅ تحديث القائمة

    _studentNameController.clear();
    _notesController.clear();
  }

  /// ✅ **تعديل بيانات طالب معين**
  void _editStudent(db.Student student) {
    final nameController = TextEditingController(text: student.name);
    final notesController = TextEditingController(text: student.notes ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تعديل بيانات الطالب"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "اسم الطالب")),
            const SizedBox(height: 8),
            TextField(controller: notesController, decoration: const InputDecoration(labelText: "الملاحظات")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("اسم الطالب مطلوب")),
                );
                return;
              }

              final updatedStudent = db.StudentsCompanion(
                id: drift.Value(student.id),
                name: drift.Value(nameController.text.trim()),
                notes: notesController.text.trim().isEmpty
                    ? const drift.Value.absent()
                    : drift.Value(notesController.text.trim()),
              );

              await database.update(database.students).replace(updatedStudent);
              _loadStudents();
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  /// ✅ **حذف طالب معين من قاعدة البيانات**
  void _deleteStudent(int studentId) async {
    await (database.delete(database.students)..where((s) => s.id.equals(studentId))).go();
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المجموعة ${widget.groupKey}")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentNameController,
                    decoration: const InputDecoration(labelText: "اسم الطالب"),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addStudent, child: const Text("إضافة طالب")),
              ],
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text("لا يوجد طلاب مسجلين"))
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(student.name),
                          subtitle: student.notes != null ? Text("ملاحظات: ${student.notes}") : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editStudent(student),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteStudent(student.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
