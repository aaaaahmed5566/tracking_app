import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift; // ✅ استيراد Drift
import '../../data/models.dart' as models;
import '../../data/database.dart' as db;

class TestScoresScreen extends StatefulWidget {
  final models.ClassGroup group;
  final String subject;
  final db.Test? test;

  const TestScoresScreen({super.key, required this.group, required this.subject, this.test});

  @override
  State<TestScoresScreen> createState() => _TestScoresScreenState();
}

class _TestScoresScreenState extends State<TestScoresScreen> {
  final db.AppDatabase database = db.AppDatabase();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController maxScoreController = TextEditingController();
  final Map<int, TextEditingController> studentScores = {};
  DateTime? selectedDate;
  List<db.Student> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    if (widget.test != null) {
      titleController.text = widget.test!.title ?? "";
      maxScoreController.text = widget.test!.maxScore.toString();
      selectedDate = widget.test!.date;
    }
  }

  Future<void> _loadStudents() async {
    students = await database.getStudentsForGroup(widget.group.id); // ✅ استخدام الدالة الصحيحة
    setState(() {
      for (var student in students) {
        studentScores[student.id] = TextEditingController();
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    maxScoreController.dispose();
    for (var controller in studentScores.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTest() async {
    if (maxScoreController.text.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب إدخال درجة الاختبار وتحديد التاريخ!")),
      );
      return;
    }

    int maxScore = int.tryParse(maxScoreController.text) ?? 0;
    if (maxScore <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب إدخال درجة اختبار صحيحة!")),
      );
      return;
    }

    final testId = await database.addTest(db.TestsCompanion(
      title: drift.Value(titleController.text),
      date: drift.Value(selectedDate!),
      maxScore: drift.Value(maxScore),
    ));

    for (var student in students) {
      int? score = int.tryParse(studentScores[student.id]!.text);
      if (score != null && score > maxScore) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لا يمكن أن تتجاوز درجة ${student.name} الحد الأقصى ($maxScore)")),
        );
        return;
      }
      await database.addTestScore(db.TestScoresCompanion(
        testId: drift.Value(testId),
        studentId: drift.Value(student.id),
        score: drift.Value(score ?? 0),
      ));
    }

    Navigator.pop(context, "saved");
  }

  void _deleteTest() async {
    if (widget.test != null) {
      await database.deleteTest(widget.test!.id);
      Navigator.pop(context, "deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل درجات الاختبار"),
        actions: [
          if (widget.test != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteTest,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "عنوان الاختبار (اختياري)"),
            ),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "التاريخ (إجباري)",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"
                        : "",
                  ),
                ),
              ),
            ),
            TextField(
              controller: maxScoreController,
              decoration: const InputDecoration(labelText: "درجة الاختبار (إجباري)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text("درجات الطلاب:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(student.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: studentScores[student.id],
                              decoration: const InputDecoration(hintText: "الدرجة"),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                ),
                child: const Text("حفظ", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
