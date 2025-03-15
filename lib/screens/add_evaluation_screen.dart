import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// تعريف نموذج التقييم الجديد (يمكنك نقله إلى ملف منفصل لاحقاً)
class Evaluation {
  final String groupKey;     // "الصف-الفصل"
  final String subject;      // المادة (يُستدعى تلقائيًا من بيانات المجموعة)
  final String lessonTitle;  // عنوان الدرس
  final String date;         // التاريخ
  final String period;       // الحصة (اختياري)

  Evaluation({
    required this.groupKey,
    required this.subject,
    required this.lessonTitle,
    required this.date,
    required this.period,
  });
}

// شاشة إضافة تقييم جديد
class AddEvaluationScreen extends StatefulWidget {
  final String groupKey;
  final String subject;

  const AddEvaluationScreen({
    super.key,
    required this.groupKey,
    required this.subject,
  });

  @override
  State<AddEvaluationScreen> createState() => _AddEvaluationScreenState();
}

class _AddEvaluationScreenState extends State<AddEvaluationScreen> {
  final TextEditingController _lessonTitleCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _periodCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController(); // لملاحظات إضافية إن رغبت

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale("ar", "SA"),
    );
    if (picked != null) {
      _dateCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
      setState(() {});
    }
  }

  void _saveEvaluation() {
    if (_lessonTitleCtrl.text.trim().isEmpty || _dateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى تعبئة عنوان الدرس والتاريخ")),
      );
      return;
    }
    final newEval = Evaluation(
      groupKey: widget.groupKey,
      subject: widget.subject,
      lessonTitle: _lessonTitleCtrl.text.trim(),
      date: _dateCtrl.text.trim(),
      period: _periodCtrl.text.trim(),
    );
    // إعادة التقييم للشاشة السابقة (يمكنك تعديل هذا حسب منطق تطبيقك)
    Navigator.pop(context, newEval);
  }

  @override
  void dispose() {
    _lessonTitleCtrl.dispose();
    _dateCtrl.dispose();
    _periodCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.groupKey} - ${widget.subject}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _lessonTitleCtrl,
              decoration: const InputDecoration(labelText: "عنوان الدرس"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(labelText: "التاريخ"),
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _periodCtrl,
              decoration: const InputDecoration(labelText: "الحصة (اختياري)"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: "ملاحظات الدرس (اختياري)"),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveEvaluation,
              child: const Text("استمرار"),
            ),
          ],
        ),
      ),
    );
  }
}
