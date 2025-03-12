import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // لاستخدام firstWhereOrNull
import '../data.dart'; // يجب أن يحتوي على: List<ClassGroup> groups و Map<String, List<Student>> studentGroupsGlobal
import '../models.dart'; // يجب أن يحتوي على تعريف ClassGroup و Student

/// نموذج تقييم جديد
class Evaluation {
  final String groupKey;    // "الصف-الفصل"
  final String subject;     // المادة (يُستدعى تلقائيًا من بيانات المجموعة)
  final String lessonTitle; // عنوان الدرس
  final String date;        // التاريخ
  final String period;      // الحصة (اختياري)

  Evaluation({
    required this.groupKey,
    required this.subject,
    required this.lessonTitle,
    required this.date,
    required this.period,
  });
}

class EvaluationScreen extends StatefulWidget {
  final Evaluation evaluation;

  const EvaluationScreen({
    Key? key,
    required this.evaluation,
  }) : super(key: key);

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  // قائمة أنواع التقييم الثابتة التي ستظهر لكل طالب
  final List<String> evaluationTypes = ["حفظ", "واجبات", "مشاركة", "أداء مهام"];

  // الخرائط لتخزين بيانات التقييم لكل طالب
  // ratingMap: لكل نوع تقييم، يخزن (studentIndex -> الدرجة) حيث الدرجة من 1 إلى 5
  final Map<String, Map<int, int>> ratingMap = {};
  // attendanceMap: لكل طالب (true إذا كان حاضرًا)
  final Map<int, bool> attendanceMap = {};
  // notesMap: لكل طالب، يخزن Controller للملاحظات
  final Map<int, TextEditingController> notesMap = {};

  @override
  void initState() {
    super.initState();
    // استدعاء بيانات الطلاب بناءً على groupKey للتقييم الحالي
    final groupKey = widget.evaluation.groupKey;
    final students = studentGroupsGlobal[groupKey] ?? [];
    for (int i = 0; i < students.length; i++) {
      for (var type in evaluationTypes) {
        ratingMap[type] ??= {};
        ratingMap[type]![i] = 0; // القيمة الافتراضية 0 (لم يتم التقييم)
      }
      attendanceMap[i] = true; // افتراضيًا الطالب حاضر
      notesMap[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var ctrl in notesMap.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // دالة بناء جدول الطلاب لتقييم الطلاب
  Widget _buildStudentsTable() {
    final groupKey = widget.evaluation.groupKey;
    final students = studentGroupsGlobal[groupKey] ?? [];
    if (students.isEmpty) {
      return const Center(child: Text("لا توجد بيانات طلاب لهذه المجموعة."));
    }
    // الأعمدة الثابتة: اسم الطالب + أعمدة لكل نوع تقييم + الحضور + الملاحظات
    final columns = <DataColumn>[
      const DataColumn(label: Text("اسم الطالب")),
      ...evaluationTypes.map((t) => DataColumn(label: Text(t))).toList(),
      const DataColumn(label: Text("الحضور")),
      const DataColumn(label: Text("الملاحظات")),
    ];

    final rows = <DataRow>[];
    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final cells = <DataCell>[];

      // عمود اسم الطالب
      cells.add(DataCell(Text(student.name)));

      // أعمدة التقييم لكل نوع
      for (var type in evaluationTypes) {
        final currentRating = ratingMap[type]?[i] ?? 0;
        cells.add(
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (idx) {
                int ratingValue = idx + 1;
                final emojis = [
                  Icons.sentiment_very_dissatisfied,
                  Icons.sentiment_dissatisfied,
                  Icons.sentiment_neutral,
                  Icons.sentiment_satisfied,
                  Icons.sentiment_very_satisfied,
                ];
                final colors = [
                  Colors.red,
                  Colors.orange,
                  Colors.amber,
                  Colors.lightGreen,
                  Colors.green,
                ];
                return IconButton(
                  icon: Icon(
                    emojis[idx],
                    color: ratingValue <= currentRating ? colors[idx] : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      ratingMap[type]![i] = ratingValue;
                    });
                  },
                );
              }),
            ),
          ),
        );
      }

      // عمود الحضور
      final isPresent = attendanceMap[i] ?? true;
      cells.add(
        DataCell(
          Checkbox(
            value: isPresent,
            onChanged: (val) {
              setState(() {
                attendanceMap[i] = val ?? false;
              });
            },
          ),
        ),
      );

      // عمود الملاحظات
      final notesCtrl = notesMap[i]!;
      cells.add(
        DataCell(
          SizedBox(
            width: 100,
            child: TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                hintText: "ملاحظات",
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
        ),
      );

      rows.add(DataRow(cells: cells));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(columns: columns, rows: rows),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eval = widget.evaluation;
    return Scaffold(
      appBar: AppBar(
        title: Text("${eval.groupKey} - ${eval.subject}\n${eval.lessonTitle}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildStudentsTable(),
      ),
    );
  }
}
