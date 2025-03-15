import 'package:flutter/material.dart';
import '../auth/signup_screen.dart'; // تأكد من وجود صفحة SignUpScreen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // النصوص التي نريد عرضها في الصفحات (بدل الصور)
  final List<String> _featureTexts = [
    "سهولة الاستخدام وتحكم متكامل",
    "تنظيم ومتابعة بيانات الطلاب بكفاءة",
    "تصميم عصري وميزات مبتكرة",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // خلفية بيضاء
      body: SafeArea(
        child: Column(
          children: [
            // الجزء العلوي: PageView للنصوص المتحركة
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _featureTexts.length,
                itemBuilder: (context, index) {
                  return _buildFeaturePage(_featureTexts[index]);
                },
              ),
            ),

            // المؤشر (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_featureTexts.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  width: _currentPage == i ? 12 : 8,
                  height: _currentPage == i ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? Colors.blue
                        : Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            // النصوص الثابتة في الأسفل: "مرحباً بكم" + النص التوضيحي
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Text(
                    "مرحباً بكم",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "برنامج كشف متابعة الطلاب\nيساعد المعلم في متابعة الطلاب في الواجبات والمهام",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // زر Next
            ElevatedButton(
              onPressed: () {
                // إذا لم نصل إلى الصفحة الأخيرة، ننتقل للصفحة التالية
                if (_currentPage < _featureTexts.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // إذا كنا في آخر صفحة، ننتقل لشاشة التسجيل
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignUpScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _currentPage < _featureTexts.length - 1 ? "Next" : "ابدأ",
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // دالة تبني الصفحة الواحدة داخل الـ PageView
  Widget _buildFeaturePage(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
