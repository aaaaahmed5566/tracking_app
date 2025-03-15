import 'package:flutter/material.dart';
import 'home_tab.dart';
import '../students/student_registration_screen.dart';
import '../evaluations/evaluation_screen.dart';
import '../students/search_student_screen.dart';
import '../tests/tests_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeTab(),
          StudentRegistrationScreen(),
          EvaluationScreen(), // ✅ سيتم تمرير البيانات عند الحاجة فقط
          SearchStudentScreen(),
          TestsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'تسجيل الطلاب'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'التقييم'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث الطالب'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'الاختبارات'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
