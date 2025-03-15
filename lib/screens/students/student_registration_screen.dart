import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift; // ✅ استيراد Drift
import '../../data/database.dart';

class StudentRegistrationScreen extends StatefulWidget {
  final Group group; // ✅ تمرير بيانات المجموعة عند فتح الشاشة

  const StudentRegistrationScreen({super.key, required this.group});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final AppDatabase database = AppDatabase();
  late Future<List<Student>> studentsFuture;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    setState(() {
      studentsFuture = database.getStudentsForGroup(widget.group.id);
    });
  }

  void _addStudent() async {
    String name = _nameController.text.trim();
    String parentPhone = _parentPhoneController.text.trim();
    String notes = _notesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب إدخال اسم الطالب")),
      );
      return;
    }

    await database.addStudent(StudentsCompanion(
      name: drift.Value(name),
      groupId: drift.Value(widget.group.id),
      parentPhone: parentPhone.isNotEmpty ? drift.Value(parentPhone) : const drift.Value.absent(),
      notes: notes.isNotEmpty ? drift.Value(notes) : const drift.Value.absent(),
    ));

    _nameController.clear();
    _parentPhoneController.clear();
    _notesController.clear();

    _loadStudents();
  }

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
      appBar: AppBar(title: Text("إضافة طلاب للمجموعة: ${widget.group.grade} - ${widget.group.section}")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("إضافة طالب جديد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: "اسم الطالب *")),
                TextField(controller: _parentPhoneController, decoration: const InputDecoration(labelText: "رقم ولي الأمر (اختياري)")),
                TextField(controller: _notesController, decoration: const InputDecoration(labelText: "ملاحظات (اختياري)")),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _addStudent, child: const Text("إضافة الطالب")),
              ],
            ),
          ),
          const Divider(),
          const Text("الطلاب المسجلون", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: FutureBuilder<List<Student>>(
              future: studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("حدث خطأ أثناء تحميل البيانات"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("لا يوجد طلاب مسجلون"));
                }

                List<Student> students = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    Student student = students[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(student.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (student.parentPhone != null && student.parentPhone!.isNotEmpty)
                              Text("رقم ولي الأمر: ${student.parentPhone}"),
                            if (student.notes != null && student.notes!.isNotEmpty) Text("ملاحظات: ${student.notes}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStudent(student.id),
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
