import 'package:flutter/material.dart';
import '../models.dart'; // تأكد من أن هذا الملف يحتوي على TestModel
import 'test_scores_screen.dart';
import '../database.dart' as db; // ✅ استيراد قاعدة البيانات


class TestListScreen extends StatefulWidget {
  final ClassGroup group;
  final String subject;

  const TestListScreen({super.key, required this.group, required this.subject});

  @override
  _TestListScreenState createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final List<TestModel> tests = [];

void _addTest() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TestScoresScreen(group: widget.group, subject: widget.subject),
    ),
  );

  if (result != null && result is db.Test) { // ✅ استخدام db.Test
    setState(() {
      tests.add(TestModel(
        id: result.id,
        title: result.title ?? "بدون عنوان",
        type: "اختبار", // ✅ أضف نوع الاختبار
        className: "${widget.group.grade} - ${widget.group.section}", // ✅ أضف اسم الصف
        subject: widget.subject, // ✅ أضف اسم المادة
        date: result.date,
        maxScore: result.maxScore,
      ));
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("اختبارات ${widget.subject}")),
      body: tests.isEmpty
          ? const Center(child: Text("لا توجد اختبارات مسجلة"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(test.title),
                    subtitle: Text("التاريخ: ${test.date.toLocal()}"),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TestScoresScreen(
                            group: widget.group,
                            subject: widget.subject,
                            test: test.toTest(), // تحويل TestModel إلى Test
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTest,
        child: const Icon(Icons.add),
      ),
    );
  }
}
