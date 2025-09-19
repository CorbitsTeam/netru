void main() async {
  // Test simple function
  print('Testing chatbot response...');

  final message = "مرحبا";
  final response = generateLocalResponse(message);
  print('Input: $message');
  print('Output: $response');
}

String generateLocalResponse(String message) {
  final lowerMessage = message.toLowerCase();

  // Check for greetings
  if (lowerMessage.contains('مرحبا') ||
      lowerMessage.contains('السلام') ||
      lowerMessage.contains('أهلا')) {
    return '''مرحباً! أنا سوبيك، المساعد الذكي لتطبيق نترو.

يمكنني مساعدتك في:
📱 معلومات حول تطبيق نترو ومميزاته
⚖️ القوانين المصرية (الجنائية، المرور، حماية البيانات)
🚨 أنواع البلاغات وكيفية التعامل معها
🔒 الأمان والخصوصية في التطبيق

اسأل عن أي موضوع تريد معرفة المزيد عنه!''';
  }

  // Check for law-related queries
  if (lowerMessage.contains('قانون') ||
      lowerMessage.contains('عقوبة') ||
      lowerMessage.contains('جريمة') ||
      lowerMessage.contains('سرقة') ||
      lowerMessage.contains('اعتداء')) {
    return '''قانون العقوبات المصري يحتوي على عقوبات متنوعة للجرائم المختلفة:

السرقة: العقوبة تتراوح من الحبس 6 أشهر إلى سنتين أو غرامة من 200 إلى 500 جنيه حسب نوع السرقة وظروفها.

الاعتداء: العقوبة تتراوح من الحبس شهر إلى سنتين وغرامة من 200 إلى 1000 جنيه حسب شدة الإصابة.

يمكن لتطبيق نترو مساعدتك في الإبلاغ عن أي من هذه الجرائم بطريقة آمنة وسريعة.''';
  }

  // Check for app-related queries
  if (lowerMessage.contains('نترو') ||
      lowerMessage.contains('تطبيق') ||
      lowerMessage.contains('بلاغ')) {
    return '''تطبيق نترو هو تطبيق متطور للإبلاغ عن الحوادث والجرائم في مصر.

المميزات الرئيسية:
🚨 إبلاغ فوري عن الجرائم والحوادث
🗺️ خريطة حرارية تفاعلية لمستويات الأمان
🤖 مساعد ذكي (سوبيك) متاح 24/7
📱 واجهة سهلة الاستخدام
🔒 حماية كاملة للخصوصية والبيانات

يمكنك استخدام التطبيق للإبلاغ عن أي حادث أو جريمة تشهدها بطريقة آمنة.''';
  }

  // Default response
  return '''مرحباً! أنا سوبيك، المساعد الذكي لتطبيق نترو.

يمكنني مساعدتك في:
📱 معلومات حول تطبيق نترو ومميزاته
⚖️ القوانين المصرية (الجنائية، المرور، حماية البيانات)
🚨 أنواع البلاغات وكيفية التعامل معها
🔒 الأمان والخصوصية في التطبيق

اسأل عن أي موضوع تريد معرفة المزيد عنه!''';
}
