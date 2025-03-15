import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift; // ✅ استيراد Drift
import '../../data/database.dart';
import '../home/main_screen.dart';

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

  // بيانات الصف والفصل والمواد
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  late Future<List<Group>> groupsFuture;

  bool _teacherDataSaved = false;
  Map<String, String> teacherData = {};

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      groupsFuture = database.getGroups();
    });
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

  // حفظ بيانات المعلم
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

  // إضافة مجموعة جديدة (صف + فصل)
  void _addGroup() async {
    String grade = _gradeController.text.trim();
    String section = _sectionController.text.trim();

    if (grade.isEmpty || section.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال الصف والفصل")),
      );
      return;
    }

    bool exists = await database.isGroupExists(grade, section);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("هذه المجموعة مسجلة مسبقًا")),
      );
      return;
    }

    int groupId = await database.addGroup(GroupsCompanion(
      grade: drift.Value(grade),
      section: drift.Value(section),
    ));

    setState(() {
      _gradeController.clear();
      _sectionController.clear();
      _loadGroups();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تمت إضافة المجموعة بنجاح")),
    );
  }

  // حذف مجموعة
  void _deleteGroup(int groupId) async {
    await database.deleteGroup(groupId);
    _loadGroups();
  }

  // إضافة مادة لمجموعة معينة
  void _addSubject(int groupId) async {
    String subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال اسم المادة")),
      );
      return;
    }

    await database.addSubject(SubjectsCompanion(
      groupId: drift.Value(groupId),
      name: drift.Value(subject),
    ));

    setState(() {
      _subjectController.clear();
      _loadGroups();
    });
  }

  // حذف مادة من مجموعة
  void _deleteSubject(int subjectId) async {
    await database.deleteSubject(subjectId);
    _loadGroups();
  }

  // حفظ جميع البيانات والانتقال للصفحة الرئيسية
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
                      ElevatedButton(onPressed: _saveTeacherData, child: const Text("حفظ بيانات المعلم")),
                    ],
                  ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // ✅ إدخال بيانات الصف والفصل
            const Text("إضافة صفوف وفصول", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(controller: _gradeController, decoration: const InputDecoration(labelText: "الصف")),
            const SizedBox(height: 8),
            TextField(controller: _sectionController, decoration: const InputDecoration(labelText: "الفصل")),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addGroup, child: const Text("إضافة المجموعة")),

            const SizedBox(height: 16),
            const Text("المجموعات المسجلة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),

            // ✅ عرض المجموعات مع المواد
            FutureBuilder<List<Group>>(
              future: groupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("لا توجد مجموعات مسجلة");
                }

                return Column(
                  children: snapshot.data!.map((group) {
                    return ListTile(
                      title: Text("الصف: ${group.grade} - الفصل: ${group.section}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGroup(group.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveAllData, child: const Text("حفظ والانتقال للصفحة الرئيسية")),
          ],
        ),
      ),
    );
  }
}
