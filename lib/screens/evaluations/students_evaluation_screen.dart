import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart' as db;

class StudentsEvaluationScreen extends StatefulWidget {
  final String className;
  final String section;
  final String subject;

  const StudentsEvaluationScreen({
    super.key,
    required this.className,
    required this.section,
    required this.subject,
  });

  @override
  _StudentsEvaluationScreenState createState() => _StudentsEvaluationScreenState();
}

class _StudentsEvaluationScreenState extends State<StudentsEvaluationScreen> {
  final db.AppDatabase database = db.AppDatabase(); // ✅ قاعدة البيانات
  List<db.Student> students = []; // ✅ قائمة الطلاب
  List<String> selectedEvaluationTypes = [];
  final Map<int, Map<String, dynamic>> evaluations = {}; // ✅ ربط الطلاب بالتقييمات

  final TextEditingController lessonTitleController = TextEditingController();
  final TextEditingController sessionController = TextEditingController();
  DateTime? selectedDate;

  final List<String> evaluationTypes = ["الحفظ", "الواجب", "المشاركة", "أداء المهام"];
  final List<String> emojis = ["😟", "😐", "🙂", "😃"];

  @override
  void initState() {
    super.initState();
    _loadStudents(); // ✅ تحميل الطلاب عند بدء الشاشة
  }

  void _loadStudents() async {
    students = await database.getStudents(); // ✅ جلب الطلاب من قاعدة البيانات
    setState(() {
      for (var student in students) {
        evaluations[student.id] = {
          "attendance": true,
          "scores": {for (var type in evaluationTypes) type: 2}, // ✅ تقييم افتراضي لكل نوع
          "notes": "",
          "showNotes": false,
        };
      }
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تقييم الطلاب - ${widget.className} الفصل ${widget.section}")),
      body: Column(
        children: [
          // ✅ **إدخال عنوان الدرس + اختيار التاريخ + إدخال الحصة**
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: lessonTitleController,
                  decoration: const InputDecoration(labelText: "عنوان الدرس *", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : "",
                        ),
                        readOnly: true,
                        decoration: const InputDecoration(labelText: "التاريخ *", border: OutlineInputBorder()),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sessionController,
                  decoration: const InputDecoration(labelText: "الحصة (اختياري)", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),

          // ✅ **أزرار اختيار التقييمات**
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: evaluationTypes.map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: selectedEvaluationTypes.contains(type),
                  selectedColor: Colors.blue,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedEvaluationTypes.add(type);
                      } else {
                        selectedEvaluationTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          // ✅ **عرض قائمة الطلاب**
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text("لا يوجد طلاب مسجلين"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final studentEval = evaluations[student.id]!;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ **اسم الطالب + حضور + زر الملاحظات**
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(student.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      Text(studentEval["attendance"] ? "حاضر" : "غائب", style: const TextStyle(fontSize: 16)),
                                      Checkbox(
                                        value: studentEval["attendance"],
                                        onChanged: (value) {
                                          setState(() {
                                            studentEval["attendance"] = value!;
                                            if (!value) {
                                              for (var type in evaluationTypes) {
                                                studentEval["scores"][type] = 0;
                                              }
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                                        onPressed: () {
                                          setState(() {
                                            studentEval["showNotes"] = !studentEval["showNotes"];
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // ✅ **إظهار خانة الملاحظات عند الحاجة**
                              if (studentEval["showNotes"])
                                TextField(
                                  onChanged: (value) {
                                    studentEval["notes"] = value;
                                  },
                                  decoration: const InputDecoration(labelText: "ملاحظات", border: OutlineInputBorder()),
                                ),

                              const Divider(),

                              // ✅ **عرض التقييمات المختارة فقط**
                              if (studentEval["attendance"])
                                Column(
                                  children: selectedEvaluationTypes.map((type) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(type, style: const TextStyle(fontSize: 16)),
                                        Row(
                                          children: List.generate(4, (emojiIndex) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  studentEval["scores"][type] = emojiIndex;
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                                child: Text(
                                                  emojis[emojiIndex],
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    color: studentEval["scores"][type] == emojiIndex
                                                        ? Colors.blue
                                                        : Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    );
                                  }).toList(),
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
