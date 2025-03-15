import 'package:flutter/material.dart';
import '../database.dart';
import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AppDatabase database = AppDatabase();

  // بيانات المعلم
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _teacherEmailController = TextEditingController();
  final TextEditingController _eduAdminController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();

  // بيانات المجموعة: الصف والفصل فقط
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  
  // حقل لإدخال المواد التي تُضاف للمجموعة
  final TextEditingController _subjectController = TextEditingController();
  final List<String> _groupSubjects = [];

  // حالة بيانات المعلم
  bool _teacherDataSaved = false;
  Map<String, String> teacherData = {};
  late Future<List<Student>> studentsFuture;

  @override
  void initState() {
    super.initState();
    studentsFuture = database.getStudents(); // ✅ تحميل بيانات الطلاب من قاعدة البيانات
  }

  @override
  void dispose() {
    _teacherNameController.dispose();
    _teacherEmailController.dispose();
    _eduAdminController.dispose();
    _schoolNameController.dispose();
    _gradeController.dispose();
    _sectionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _saveTeacherData() {
    if (_teacherNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اسم المعلم مطلوب")),
      );
      return;
    }
    setState(() {
      teacherData = {
        'teacherName': _teacherNameController.text.trim(),
        'teacherEmail': _teacherEmailController.text.trim(),
        'eduAdmin': _eduAdminController.text.trim(),
        'schoolName': _schoolNameController.text.trim(),
      };
      _teacherDataSaved = true;
    });
  }

  void _saveAllData() {
    if (!_teacherDataSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى حفظ بيانات المعلم أولاً")),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل بيانات المعلم والمجموعات")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ بيانات المعلم
            _teacherDataSaved
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("أهلا بك ${teacherData['teacherName']}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => setState(() => _teacherDataSaved = false),
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("بيانات المعلم", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(controller: _teacherNameController, decoration: const InputDecoration(labelText: "اسم المعلم *")),
                      const SizedBox(height: 8),
                      TextField(controller: _eduAdminController, decoration: const InputDecoration(labelText: "إدارة التعليم (اختياري)")),
                      const SizedBox(height: 8),
                      TextField(controller: _teacherEmailController, decoration: const InputDecoration(labelText: "البريد الإلكتروني (اختياري)")),
                      const SizedBox(height: 8),
                      TextField(controller: _schoolNameController, decoration: const InputDecoration(labelText: "اسم المدرسة (اختياري)")),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _saveTeacherData, child: const Text("حفظ بيانات المعلم")),
                    ],
                  ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // ✅ عرض المجموعات المسجلة من قاعدة البيانات
            const Text("بيانات الصفوف والفصول", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            FutureBuilder<List<Student>>(
              future: studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("حدث خطأ أثناء تحميل البيانات"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("لا توجد مجموعات مسجلة"));
                }

                Map<String, List<Student>> groupedStudents = {};
                for (var student in snapshot.data!) {
                  String key = "${student.grade}-${student.section}";
                  groupedStudents.putIfAbsent(key, () => []).add(student);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedStudents.keys.length,
                  itemBuilder: (context, index) {
                    String groupKey = groupedStudents.keys.elementAt(index);
                    List<Student> groupStudents = groupedStudents[groupKey]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text("الصف: ${groupKey.split('-')[0]} - الفصل: ${groupKey.split('-')[1]}"),
                        subtitle: Text("عدد الطلاب: ${groupStudents.length}"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAllData,
                child: const Text("حفظ والانتقال للصفحة الرئيسية"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
