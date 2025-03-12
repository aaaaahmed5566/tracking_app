import 'package:flutter/material.dart';
import '../models.dart';
import '../data.dart';
import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

  // قائمة محلية للمجموعات المُضافة
  final List<ClassGroup> _localGroups = [];

  // حالة بيانات المعلم
  bool _teacherDataSaved = false;
  Map<String, String> teacherData = {};

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

  void _clearTeacherData() {
    setState(() {
      _teacherDataSaved = false;
      teacherData.clear();
      _teacherNameController.clear();
      _teacherEmailController.clear();
      _eduAdminController.clear();
      _schoolNameController.clear();
    });
  }

  void _editTeacherData() {
    setState(() {
      _teacherDataSaved = false;
      _teacherNameController.text = teacherData['teacherName'] ?? '';
      _teacherEmailController.text = teacherData['teacherEmail'] ?? '';
      _eduAdminController.text = teacherData['eduAdmin'] ?? '';
      _schoolNameController.text = teacherData['schoolName'] ?? '';
    });
  }

  // إضافة مادة إلى القائمة المؤقتة للمواد الخاصة بالمجموعة
  void _addSubject() {
    if (_subjectController.text.trim().isEmpty) return;
    setState(() {
      _groupSubjects.add(_subjectController.text.trim());
      _subjectController.clear();
    });
  }

  // إضافة مجموعة جديدة: الصف والفصل والمواد المُضافة
  void _addGroup() {
    if (_gradeController.text.trim().isEmpty ||
        _sectionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال الصف والفصل")),
      );
      return;
    }
    if (_groupSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إضافة مادة واحدة على الأقل")),
      );
      return;
    }
    // منع التكرار: التأكد من عدم وجود مجموعة بنفس الصف والفصل
    bool exists = _localGroups.any((group) =>
        group.grade.trim().toLowerCase() ==
            _gradeController.text.trim().toLowerCase() &&
        group.section.trim().toLowerCase() ==
            _sectionController.text.trim().toLowerCase());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("هذه المجموعة مسجلة مسبقاً")),
      );
      return;
    }
    setState(() {
      // إنشاء المجموعة مع المواد المُضافة
      ClassGroup newGroup = ClassGroup(
        grade: _gradeController.text.trim(),
        section: _sectionController.text.trim(),
        subjects: List.from(_groupSubjects),
      );
      _localGroups.add(newGroup);
      groups.add(newGroup); // إضافة المجموعة إلى القائمة العالمية
      _gradeController.clear();
      _sectionController.clear();
      _groupSubjects.clear();
    });
  }

  void _deleteGroup(int index) {
    setState(() {
      ClassGroup group = _localGroups[index];
      _localGroups.removeAt(index);
      groups.removeWhere((g) =>
          g.grade == group.grade &&
          g.section == group.section &&
          g.subjects.toString() == group.subjects.toString());
    });
  }

  void _editGroup(int index) {
    ClassGroup group = _localGroups[index];
    final gradeController = TextEditingController(text: group.grade);
    final sectionController = TextEditingController(text: group.section);
    List<String> tempSubjects = List.from(group.subjects);
    final subjectController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("تعديل بيانات المجموعة"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: gradeController,
                    decoration: const InputDecoration(labelText: "الصف الدراسي"),
                  ),
                  TextField(
                    controller: sectionController,
                    decoration: const InputDecoration(labelText: "الفصل الدراسي"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: subjectController,
                          decoration:
                              const InputDecoration(labelText: "المادة الدراسية"),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (subjectController.text.trim().isEmpty) return;
                          setStateDialog(() {
                            tempSubjects.add(subjectController.text.trim());
                            subjectController.clear();
                          });
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (tempSubjects.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tempSubjects
                          .map((subj) => ListTile(
                                title: Text(subj),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setStateDialog(() {
                                      tempSubjects.remove(subj);
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () {
                  if (gradeController.text.trim().isEmpty ||
                      sectionController.text.trim().isEmpty ||
                      tempSubjects.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("جميع الحقول مطلوبة")),
                    );
                    return;
                  }
                  setState(() {
                    ClassGroup updatedGroup = ClassGroup(
                      grade: gradeController.text.trim(),
                      section: sectionController.text.trim(),
                      subjects: tempSubjects,
                    );
                    _localGroups[index] = updatedGroup;
                    groups.removeWhere((g) =>
                        g.grade == group.grade &&
                        g.section == group.section &&
                        g.subjects.toString() == group.subjects.toString());
                    groups.add(updatedGroup);
                  });
                  Navigator.pop(context);
                },
                child: const Text("حفظ"),
              ),
            ],
          );
        },
      ),
    );
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل بيانات المعلم والمجموعات"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بيانات المعلم
            _teacherDataSaved
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "أهلا بك ${teacherData['teacherName']}",
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: _editTeacherData,
                                icon: const Icon(Icons.edit, color: Colors.blue)),
                            IconButton(
                                onPressed: _clearTeacherData,
                                icon: const Icon(Icons.delete, color: Colors.red)),
                          ],
                        )
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("بيانات المعلم",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _teacherNameController,
                        decoration:
                            const InputDecoration(labelText: "اسم المعلم *"),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _eduAdminController,
                        decoration: const InputDecoration(
                            labelText: "إدارة التعليم (اختياري)"),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _teacherEmailController,
                        decoration: const InputDecoration(
                            labelText: "البريد الإلكتروني (اختياري)"),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _schoolNameController,
                        decoration: const InputDecoration(
                            labelText: "اسم المدرسة (اختياري)"),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveTeacherData,
                          child: const Text("حفظ بيانات المعلم"),
                        ),
                      )
                    ],
                  ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // بيانات المجموعة (الصف والفصل والمواد)
            const Text("بيانات الصفوف والفصول",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            // صفوف اختيار الصف والفصل جنبًا إلى جنب
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gradeController,
                    decoration:
                        const InputDecoration(labelText: "الصف الدراسي *"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _sectionController,
                    decoration:
                        const InputDecoration(labelText: "الفصل الدراسي *"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // حقل إضافة مادة مع زر
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subjectController,
                    decoration:
                        const InputDecoration(labelText: "المادة الدراسية *"),
                  ),
                ),
                IconButton(
                  onPressed: _addSubject,
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            // عرض قائمة المواد المضافة للمجموعة
            _groupSubjects.isEmpty
                ? const Text("لم يتم إضافة مواد بعد")
                : Wrap(
                    spacing: 8,
                    children: _groupSubjects
                        .map((subj) => Chip(
                              label: Text(subj),
                              onDeleted: () {
                                setState(() {
                                  _groupSubjects.remove(subj);
                                });
                              },
                            ))
                        .toList(),
                  ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addGroup,
                child: const Text("أضف مجموعة"),
              ),
            ),
            const SizedBox(height: 16),
            // عرض قائمة المجموعات المُضافة
            _localGroups.isEmpty
                ? const Text("لم يتم تسجيل أي مجموعات بعد")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _localGroups.length,
                    itemBuilder: (context, index) {
                      ClassGroup group = _localGroups[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                              "الصف ${group.grade} - الفصل ${group.section}"),
                          subtitle:
                              Text("المواد: ${group.subjects.join(', ')}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () => _editGroup(index),
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue)),
                              IconButton(
                                  onPressed: () => _deleteGroup(index),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
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
