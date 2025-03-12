import 'package:flutter/material.dart';
import '../data.dart'; // يحتوي على: studentGroupsGlobal
import '../models.dart';
// لاستخدام firstWhereOrNull إن احتجت

class GroupDetailsScreen extends StatefulWidget {
  final String groupKey; // المفتاح بالشكل "الصف-الفصل"
  const GroupDetailsScreen({super.key, required this.groupKey});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  // متحكمات لإدخال بيانات الطالب الفردي
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _studentNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // دالة لإضافة طالب فردي (لا تحتاج إلى معلمة لأننا نستخدم widget.groupKey)
  void _addStudent() {
    if (_studentNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى إدخال اسم الطالب")));
      return;
    }
    final newStudent = Student(
      name: _studentNameController.text.trim(),
      parentPhone: _parentPhoneController.text.trim().isEmpty
          ? null
          : _parentPhoneController.text.trim(),
      parentEmail: _parentEmailController.text.trim().isEmpty
          ? null
          : _parentEmailController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    setState(() {
      if (!studentGroupsGlobal.containsKey(widget.groupKey)) {
        studentGroupsGlobal[widget.groupKey] = [];
      }
      studentGroupsGlobal[widget.groupKey]!.add(newStudent);
      _studentNameController.clear();
      _parentPhoneController.clear();
      _parentEmailController.clear();
      _notesController.clear();
    });
  }

  // دالة تعديل بيانات طالب (لا تأخذ معلمات إضافية)
  void _editStudent(int index) {
    Student student = studentGroupsGlobal[widget.groupKey]![index];
    final nameController = TextEditingController(text: student.name);
    final phoneController =
        TextEditingController(text: student.parentPhone ?? "");
    final emailController =
        TextEditingController(text: student.parentEmail ?? "");
    final notesController =
        TextEditingController(text: student.notes ?? "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تعديل بيانات الطالب"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "اسم الطالب")),
              const SizedBox(height: 8),
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                      labelText: "رقم ولي الأمر (اختياري)")),
              const SizedBox(height: 8),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: "البريد الإلكتروني (اختياري)")),
              const SizedBox(height: 8),
              TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                      labelText: "الملاحظات (اختياري)")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("اسم الطالب مطلوب")));
                return;
              }
              setState(() {
                studentGroupsGlobal[widget.groupKey]![index] = Student(
                  name: nameController.text.trim(),
                  parentPhone: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                  parentEmail: emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim(),
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );
              });
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // دالة حذف طالب
  void _deleteStudent(int index) {
    setState(() {
      studentGroupsGlobal[widget.groupKey]!.removeAt(index);
    });
  }

  // دالة لإضافة مجموعة من الطلاب دفعة واحدة (تستخدم widget.groupKey داخلياً)
  void _addMultipleStudents() {
    final TextEditingController multiController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة مجموعة طلاب"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                  "أدخل بيانات الطلاب في كل سطر، مع فصل الحقول بفاصلة.\nمثال:\nأحمد, 0123456789, ahmed@example.com, ملاحظات"),
              const SizedBox(height: 8),
              TextField(
                controller: multiController,
                decoration: const InputDecoration(
                    hintText: "أدخل بيانات الطلاب هنا"),
                keyboardType: TextInputType.multiline,
                maxLines: 8,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              List<String> lines = multiController.text
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .toList();
              setState(() {
                if (!studentGroupsGlobal.containsKey(widget.groupKey)) {
                  studentGroupsGlobal[widget.groupKey] = [];
                }
                for (var line in lines) {
                  List<String> parts =
                      line.split(',').map((e) => e.trim()).toList();
                  if (parts.isNotEmpty) {
                    studentGroupsGlobal[widget.groupKey]!.add(
                      Student(
                        name: parts[0],
                        parentPhone: parts.length > 1 ? parts[1] : null,
                        parentEmail: parts.length > 2 ? parts[2] : null,
                        notes: parts.length > 3 ? parts[3] : null,
                      ),
                    );
                  }
                }
              });
              Navigator.pop(context);
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // فرز الطلاب وترقيمهم
    List<Student> sortedStudents =
        List.from(studentGroupsGlobal[widget.groupKey] ?? [])
          ..sort((a, b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: Text("المجموعة ${widget.groupKey}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // نموذج لإضافة طالب فردي
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentNameController,
                    decoration: const InputDecoration(
                      labelText: "اسم الطالب",
                      prefixIcon: Icon(Icons.person, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _parentPhoneController,
                    decoration: const InputDecoration(
                        labelText: "رقم ولي الأمر (اختياري)"),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _parentEmailController,
                    decoration: const InputDecoration(
                        labelText: "البريد الإلكتروني (اختياري)"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                        labelText: "الملاحظات (اختياري)"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addStudent,
                    child: const Text("أضف طالب"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addMultipleStudents,
                    child: const Text("أضف مجموعة"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // عرض قائمة الطلاب
            sortedStudents.isEmpty
                ? const Center(child: Text("لا توجد طلاب مسجلين"))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedStudents.length,
                    itemBuilder: (context, index) {
                      final student = sortedStudents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Text(
                            "${index + 1}.",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          title: Text(student.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (student.parentPhone != null)
                                Text("رقم ولي الأمر: ${student.parentPhone}"),
                              if (student.parentEmail != null)
                                Text("البريد الإلكتروني: ${student.parentEmail}"),
                              if (student.notes != null)
                                Text("ملاحظات: ${student.notes}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editStudent(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteStudent(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
