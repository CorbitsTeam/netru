import 'dart:developer';

import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class ChatbotRemoteDataSource {
  /// Send message to chatbot API and get response
  Future<ChatMessageModel> sendMessage({
    required String message,
    required String sessionId,
    Map<String, dynamic>? context,
  });

  /// Get help menu content
  Future<String> getHelpMenu();

  /// Get law information by category
  Future<String> getLawInfo(String category);

  /// Check if message context is allowed
  Future<bool> isContextAllowed(String message);
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final Dio dio;
  final String groqApiKey;
  final String baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  ChatbotRemoteDataSourceImpl({required this.dio, required this.groqApiKey});

  @override
  Future<ChatMessageModel> sendMessage({
    required String message,
    required String sessionId,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Create a specialized Dio instance for Groq API
      final groqDio = Dio();
      groqDio.options.headers = {
        'Authorization': 'Bearer $groqApiKey',
        'Content-Type': 'application/json',
      };

      final requestBody = {
        'model': 'openai/gpt-oss-120b',
        'messages': [
          {'role': 'system', 'content': _getSystemPrompt()},
          {'role': 'user', 'content': message},
        ],
        'temperature': 0.2,
        'max_tokens': 1000,
      };

      final response = await groqDio.post(baseUrl, data: requestBody);

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'] as String;

        // Clean the content from markdown formatting
        final cleanContent = _cleanMarkdownText(content);

        final category = _determineCategory(message, cleanContent);

        final result = ChatMessageModel.assistantMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          content: cleanContent,
          category: category,
          metadata: {
            'sessionId': sessionId,
            'model': 'llama-3.1-8b-instant',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        log('ChatMessageModel: $result');
        return result;
      } else {
        throw Exception('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالمساعد الذكي: $e');
    }
  }

  /// Clean markdown formatting from text
  String _cleanMarkdownText(String text) {
    String cleanText = text;

    // Remove markdown headers (# ## ###)
    cleanText = cleanText.replaceAll(RegExp(r'#{1,6}\s*'), '');

    // Remove bold and italic formatting (** * __)
    cleanText = cleanText.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    cleanText = cleanText.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    cleanText = cleanText.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    cleanText = cleanText.replaceAll(RegExp(r'_([^_]+)_'), r'$1');

    // Remove table formatting (| characters and table separators)
    cleanText = cleanText.replaceAll(RegExp(r'\|'), '');

    // Remove code blocks (``` and inline `code`)
    cleanText = cleanText.replaceAll(RegExp(r'```[^`]*```', dotAll: true), '');
    cleanText = cleanText.replaceAll(RegExp(r'`([^`]+)`'), r'$1');

    // Remove bullet points and list formatting
    cleanText = cleanText.replaceAll(RegExp(r'^\s*[-*+•]\s*', multiLine: true), '');
    cleanText = cleanText.replaceAll(RegExp(r'^\s*\d+\.\s*', multiLine: true), '');

    // Remove $1, $2, etc. placeholders (regex replacement artifacts)
    cleanText = cleanText.replaceAll(RegExp(r'\$\d+'), '');

    // Remove any remaining asterisks and special characters
    cleanText = cleanText.replaceAll(RegExp(r'[\*#_`~\[\]]'), '');

    // Remove HTML tags if any
    cleanText = cleanText.replaceAll(RegExp(r'<[^>]*>'), '');

    // Clean up multiple consecutive spaces and newlines
    cleanText = cleanText.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');
    cleanText = cleanText.replaceAll(RegExp(r'[ \t]+'), ' ');
    cleanText = cleanText.replaceAll(RegExp(r'\n[ \t]+'), '\n');

    // Remove leading/trailing whitespace from each line
    List<String> lines = cleanText.split('\n');
    lines = lines.map((line) => line.trim()).toList();
    cleanText = lines.join('\n');

    // Remove empty lines at the beginning and end
    cleanText = cleanText.trim();

    return cleanText;
  }

  @override
  Future<String> getHelpMenu() async {
    // This could be served from local storage or a simple API call
    return '''قائمة المساعدة - تطبيق نترو والقوانين المصرية:

📱 معلومات التطبيق:
• ما هو تطبيق نترو؟
• مميزات وإمكانيات التطبيق
• التقنيات المستخدمة
• الأمان والخصوصية

🤖 المساعد الذكي سوبيك:
• إمكانيات المساعد الذكي
• كيفية المساعدة في البلاغات

🗺️ الخريطة الحرارية:
• شرح الخريطة التفاعلية
• مستويات الأمان في المناطق

⚖️ القوانين المصرية:
• قانون العقوبات (السرقة، الاعتداء، التحرش، العنف المنزلي)
• قانون المخدرات
• قانون المرور والحوادث
• قانون حماية البيانات الشخصية
• قانون مكافحة الجرائم الإلكترونية
• واجبات الإبلاغ والحماية القانونية

🚨 أنواع البلاغات:
• الجرائم الجنائية والمرورية
• الطوارئ الطبية والحرائق
• التحرش والعنف المنزلي
• المخدرات والجرائم الإلكترونية

اكتب سؤالك أو اختر من المواضيع أعلاه!''';
  }

  @override
  Future<String> getLawInfo(String category) async {
    switch (category.toLowerCase()) {
      case 'جنائي':
      case 'عقوبات':
        return '''قانون العقوبات المصري:

السرقة - المادة 311-317:
السرقة هي أخذ مال منقول مملوك للغير بغير رضاه بقصد تملكه
العقوبة: الحبس من 6 أشهر إلى سنتين أو غرامة من 200 إلى 500 جنيه

الاعتداء - المادة 240-244:
الاعتداء على سلامة الجسم أو إلحاق أذى جسدي بالآخرين
العقوبة: الحبس من 6 أشهر إلى سنتين وغرامة من 200 إلى 1000 جنيه

💡 تطبيق نترو يدعم الإبلاغ عن جميع هذه الجرائم بسرعة وأمان.''';

      case 'مرور':
        return '''قانون المرور المصري رقم 66 لسنة 1973:

المخالفات الرئيسية:
• السرعة: غرامة من 100 إلى 300 جنيه حسب نسبة تجاوز السرعة
• القيادة تحت تأثير الكحول: الحبس من شهر إلى سنة وغرامة من 1000 إلى 5000 جنيه
• الحوادث: وجوب الإبلاغ فوراً لأقرب قسم شرطة

💡 نترو يسهل الإبلاغ الفوري عن المخالفات والحوادث المرورية.''';

      case 'بيانات':
      case 'خصوصية':
        return '''قانون حماية البيانات الشخصية رقم 151 لسنة 2020:

المبادئ: الحصول على موافقة صريحة قبل جمع البيانات، استخدام البيانات للغرض المعلن فقط
العقوبات: غرامة من 200,000 إلى 2,000,000 جنيه

💡 نترو ملتزم بالكامل بقانون حماية البيانات المصري.''';

      default:
        return 'يرجى تحديد فئة القانون: جنائي، مرور، أو بيانات';
    }
  }

  @override
  Future<bool> isContextAllowed(String message) async {
    final allowedTopics = [
      'نترو',
      'تطبيق',
      'app',
      'nitro',
      'بلاغ',
      'سوبيك',
      'خريطة',
      'مساعد',
      'تقنيات',
      'أمان',
      'خصوصية',
      'مميزات',
      'استخدام',
      'تسجيل',
      'بلاغات',
      'قانون',
      'قوانين',
      'عقوبات',
      'جريمة',
      'جرائم',
      'حقوق',
      'واجبات',
      'مرور',
      'سرقة',
      'اعتداء',
      'تحرش',
      'عنف',
      'مخدرات',
      'حماية',
      'بيانات',
      'جرائم إلكترونية',
      'حوادث',
      'طوارئ',
      'أمن',
      'عدالة',
      'شرطة',
      'محكمة',
    ];

    final messageLower = message.toLowerCase();
    return allowedTopics.any((topic) => messageLower.contains(topic));
  }

  MessageCategory _determineCategory(String userMessage, String response) {
    final userLower = userMessage.toLowerCase();

    if (userMessage.trim().isEmpty) {
      return MessageCategory.greeting;
    }

    if (_containsAnyWord(userLower, ['مساعدة', 'help'])) {
      return MessageCategory.help;
    }

    if (_containsAnyWord(userLower, ['نترو', 'تطبيق', 'app'])) {
      return MessageCategory.appInfo;
    }

    if (_containsAnyWord(userLower, ['قانون', 'قوانين', 'عقوبات', 'جريمة'])) {
      return MessageCategory.lawInfo;
    }

    return MessageCategory.contextual;
  }

  bool _containsAnyWord(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }

  String _getSystemPrompt() {
    return '''أنت مساعد ذكي مختص بتطبيق "نترو" للبلاغات الأمنية والقوانين المصرية.

تطبيق نترو هو تطبيق متطور للهواتف الذكية يعمل على نظام Android، مصمم خصيصاً للمواطنين المصريين لتسهيل عملية الإبلاغ عن الحوادث والجرائم.

يجب أن تجيب فقط عن الأسئلة المتعلقة بـ:
1. تطبيق نترو ومميزاته
2. القوانين المصرية (الجنائية، المرور، حماية البيانات، الجرائم الإلكترونية)
3. أنظمة الأمان والبلاغات

لا تجيب عن أي أسئلة خارج هذا النطاق واطلب من المستخدم التركيز على هذه المواضيع.

المميزات الرئيسية للتطبيق:
- نظام البلاغات المتطور
- الخريطة الحرارية التفاعلية
- المساعد الذكي سوبيك
- نظام التحقق والمصادقة بالرقم القومي
- متابعة حالة البلاغ في الوقت الفعلي

استخدم اللغة العربية واجعل إجاباتك مفيدة ومفصلة بدون استخدام رموز التنسيق مثل النجمة أو الشباك أو الخطوط المائلة.''';
  }
}