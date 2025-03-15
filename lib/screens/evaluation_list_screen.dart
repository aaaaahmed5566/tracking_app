import 'package:flutter/material.dart';
import '../models.dart';
import 'students_evaluation_screen.dart';



class EvaluationListScreen extends StatefulWidget {
  final ClassGroup group; // ✅ تعريف المجموعة

  const EvaluationListScreen({super.key, required this.group});

  @override
  _EvaluationListScreenState createState() => _EvaluationListScreenState();
}

class _EvaluationListScreenState extends State<EvaluationListScreen> {
  // تخزين التقييمات لكل مادة
  final Map<String, List<Evaluation>> evaluationsMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.group.grade} - الفصل (${widget.group.section})")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.group.subjects.length,
        itemBuilder: (context, index) {
          final subject = widget.group.subjects[index];
          final evaluations = evaluationsMap[subject] ?? [];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(subject),
              subtitle: Text("عدد التقييمات للمادة: ${evaluations.length}"), // ✅ عرض العدد الحقيقي
              children: [
                // عرض التقييمات السابقة
                ...evaluations.map((eval) => ListTile(
                      title: Text(eval.lessonTitle),
                      subtitle: Text("تاريخ: ${eval.date} - الحصة: ${eval.session}"),
                    )),
                // زر لإضافة تقييم جديد
                ElevatedButton(
                  onPressed: () async {
                    final newEval = await Navigator.push<Evaluation>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentsEvaluationScreen(
                          className: widget.group.grade,
                          section: widget.group.section,
                          subject: subject,
                        ),
                      ),
                    );

                    if (newEval != null) {
                      setState(() {
                        evaluationsMap.putIfAbsent(subject, () => []).add(newEval);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("+ إضافة تقييم جديد"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
