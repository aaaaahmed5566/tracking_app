import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart' as db;

class GroupDetailsScreen extends StatefulWidget {
  final db.Group group; // ✅ استقبال بيانات المجموعة
  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final db.AppDatabase database = db.AppDatabase(); // ✅ قاعدة البيانات
  late Future<List<db.Student>> studentsFuture;

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

  /// ✅ **جلب الطلاب المرتبطين بالمجموعة**
  void _loadStudents() {
    setState(() {
      studentsFuture = database.getStudentsForGroup(widget.group.id);
    });
  }

  /// ✅ **إضافة طالب جديد إلى قاعدة البيانات**
  void _addStudent() async {
    if (_studentNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال اسم الطالب")),
      );
      return;
    }

    await database.addStudent(db.StudentsCompanion(
      name: drift.Value(_studentNameController.text.trim()),
      groupId: drift.Value(widget.group.id),
      notes: _notesController.text.trim().isEmpty
          ? const drift.Value.absent()
          : drift.Value(_notesController.text.trim()),
    ));

    _studentNameController.clear();
    _notesController.clear();
    _loadStudents();
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

              await database.updateStudent(db.Student(
                id: student.id,
                name: nameController.text.trim(),
                groupId: student.groupId,
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              ));

              _loadStudents();
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  /// ✅ **حذف طالب مع رسالة تأكيد**
  void _deleteStudent(int studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف هذا الطالب؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await database.deleteStudent(studentId);
              _loadStudents();
              Navigator.pop(context);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المجموعة ${widget.group.grade} - ${widget.group.section}")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("إضافة طالب جديد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(controller: _studentNameController, decoration: const InputDecoration(labelText: "اسم الطالب *")),
                TextField(controller: _notesController, decoration: const InputDecoration(labelText: "ملاحظات (اختياري)")),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _addStudent, child: const Text("إضافة الطالب")),
              ],
            ),
          ),
          const Divider(),
          const Text("الطلاب المسجلون", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: FutureBuilder<List<db.Student>>(
              future: studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("حدث خطأ أثناء تحميل البيانات"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("لا يوجد طلاب مسجلون"));
                }

                List<db.Student> students = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    db.Student student = students[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
