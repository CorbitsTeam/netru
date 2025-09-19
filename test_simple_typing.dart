import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TestScreen());
  }
}

class TestScreen extends StatefulWidget {
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final String testText =
      "مرحباً! هذا اختبار بسيط للكتابة التدريجية. النص يجب أن يظهر حرف بحرف.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختبار الكتابة التدريجية')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('النص الأصلي:'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Text(testText),
            ),
            SizedBox(height: 20),
            Text('النص مع الكتابة التدريجية:'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue[50],
              child: SimpleTypingWidget(text: testText),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleTypingWidget extends StatefulWidget {
  final String text;
  final Duration speed;

  const SimpleTypingWidget({
    Key? key,
    required this.text,
    this.speed = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<SimpleTypingWidget> createState() => _SimpleTypingWidgetState();
}

class _SimpleTypingWidgetState extends State<SimpleTypingWidget> {
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    for (int i = 0; i <= widget.text.length; i++) {
      if (mounted) {
        setState(() {
          _displayedText = widget.text.substring(0, i);
        });
        await Future.delayed(widget.speed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayedText, style: TextStyle(fontSize: 16));
  }
}
