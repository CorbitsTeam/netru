import 'package:flutter/services.dart';

class ClipboardManager {
  const ClipboardManager._();

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<String> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text ?? '';
  }
}

String toEnglishNumbers(String input) {
  const arabicToEnglish = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };
  return input.replaceAllMapped(RegExp(r'[٠-٩]'), (match) {
    return arabicToEnglish[match.group(0)]!;
  });
}
