import 'package:flutter/material.dart';
import 'add_evaluation_screen.dart' hide Evaluation; // لن نستورد Evaluation من هذا الملف
import 'evaluation_screen.dart'; // هنا يتم استيراد Evaluation
import '../models.dart';

class EvaluationListScreen extends StatefulWidget {
  final String groupKey; // مثل "ثالث-أ"
  final String subject;

  const EvaluationListScreen({
    Key? key,
    required this.groupKey,
    required this.subject,
  }) : super(key: key);

  @override
  State<EvaluationListScreen> createState() => _EvaluationListScreenState();
}

class _EvaluationListScreenState extends State<EvaluationListScreen> {
  // قائمة التقييمات
  final List<Evaluation> evaluations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("المادة: ${widget.subject}"),
      ),
      body: Column(
        children: [
          // زر إضافة تقييم جديد
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("إضافة تقييم جديد"),
              onPressed: () async {
                // الانتقال إلى شاشة إضافة تقييم جديد
                final newEval = await Navigator.push<Evaluation>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEvaluationScreen(
                      groupKey: widget.groupKey,
                      subject: widget.subject,
                    ),
                  ),
                );
                // عند العودة مع تقييم جديد، إضافته للقائمة
                if (newEval != null) {
                  setState(() {
                    evaluations.add(newEval);
                  });
                }
              },
            ),
          ),
          const Divider(),
          // عرض قائمة التقييمات
          Expanded(
            child: ListView.builder(
              itemCount: evaluations.length,
              itemBuilder: (context, index) {
                final eval = evaluations[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(eval.lessonTitle),
                    subtitle: Text("تاريخ: ${eval.date} - الحصة: ${eval.period}"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // الانتقال إلى شاشة تقييم الطلاب مع التقييم المحدد
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EvaluationScreen(evaluation: eval),
                        ),
                      );
                    },
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
