import 'dart:developer';

import 'package:dio/dio.dart';

import '../../domain/entities/chat_message_entity.dart';
import '../models/chat_message_model.dart';

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
      log('🚀 إرسال رسالة إلى Groq API: $message');

      // Create a specialized Dio instance for Groq API
      final groqDio = Dio();
      groqDio.options.headers = {
        'Authorization': 'Bearer $groqApiKey',
        'Content-Type': 'application/json',
      };

      final requestBody = {
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {'role': 'system', 'content': _getSystemPrompt()},
          {'role': 'user', 'content': message},
        ],
        'temperature': 0.2,
        'max_tokens': 1000,
      };

      log('📤 إرسال الطلب إلى: $baseUrl');
      final response = await groqDio.post(baseUrl, data: requestBody);
      log('📥 حالة الاستجابة: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        log('✅ تم الحصول على الاستجابة بنجاح');

        final content = data['choices'][0]['message']['content'] as String;
        log('📝 محتوى الاستجابة: ${content.substring(0, 100)}...');

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
        log('✅ ChatMessageModel تم إنشاؤه بنجاح: ${result.id}');
        return result;
      } else {
        log('❌ فشل API call: ${response.statusCode}');
        throw Exception('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      log('💥 خطأ في sendMessage: $e');
      throw Exception('خطأ في الاتصال بالمساعد الذكي: $e');
    }
  }

  /// Clean markdown formatting from text and fix UTF-16 issues
  String _cleanMarkdownText(String text) {
    String cleanText = text;

    // Fix UTF-16 issues by removing invalid characters
    cleanText = _sanitizeUtf16(cleanText);

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
    cleanText = cleanText.replaceAll(
      RegExp(r'^\s*[-*+•]\s*', multiLine: true),
      '',
    );
    cleanText = cleanText.replaceAll(
      RegExp(r'^\s*\d+\.\s*', multiLine: true),
      '',
    );

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

  /// Sanitize text to fix UTF-16 issues
  String _sanitizeUtf16(String text) {
    try {
      // Remove invalid UTF-16 characters
      final sanitized = text.runes
          .where((rune) => rune != 0xFFFD && rune <= 0x10FFFF)
          .map((rune) => String.fromCharCode(rune))
          .join('');
      
      // Remove any problematic emojis or characters that might cause issues
      return sanitized
          .replaceAll(RegExp(r'[\uD800-\uDFFF]'), '') // Remove surrogate pairs
          .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]'), '') // Remove control characters
          .trim();
    } catch (e) {
      log('⚠️ خطأ في تنظيف النص: $e');
      return text.replaceAll(RegExp(r'[^\x20-\x7E\u0600-\u06FF\u0750-\u077F]'), '');
    }
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

السرقة - المواد 311-317 من قانون العقوبات:
تعريف السرقة: هي أخذ مال منقول مملوك للغير بغير رضاه وبقصد تملكه نهائياً.

العقوبات المقررة:
• السرقة البسيطة: الحبس من 6 أشهر إلى سنتين أو غرامة من 200 إلى 500 جنيه مصري
• السرقة من المنازل: الحبس مع الشغل من سنة إلى 7 سنوات
• السرقة بالإكراه (السطو): الأشغال الشاقة المؤبدة أو المؤقتة من 10 إلى 15 سنة
• السرقة في الليل: عقوبة مشددة تصل إلى الأشغال الشاقة
• السرقة من وسائل النقل: الحبس من سنة إلى 7 سنوات

الظروف المشددة:
- إذا كانت السرقة في مكان مسكون أو معد للسكن
- إذا كانت بكسر أو تسلق أو استعمال مفاتيح مصطنعة
- إذا وقعت من شخصين فأكثر
- إذا كان الجاني يحمل سلاحاً

الاعتداء - المواد 240-244 من قانون العقوبات:
يشمل الاعتداء على سلامة الجسم أو إلحاق أذى جسدي أو معنوي بالآخرين.

أنواع الاعتداء والعقوبات:
• الضرب البسيط: الحبس من شهر إلى سنتين وغرامة من 200 إلى 1000 جنيه
• الإيذاء العمد: الحبس من 6 أشهر إلى 3 سنوات إذا نتج عنه مرض أو عجز عن العمل لأكثر من 20 يوماً
• الجرح العمد: الحبس من سنة إلى 5 سنوات إذا استعمل آلة حادة أو راضة
• الإيذاء المفضي إلى الموت: الأشغال الشاقة من 3 إلى 7 سنوات
• الاعتداء على الموظفين: عقوبة مشددة تصل إلى الأشغال الشاقة

الظروف المشددة:
- إذا كان المجني عليه من أصول الجاني أو فروعه
- إذا كان الاعتداء على موظف عام أثناء تأدية وظيفته
- إذا كان الاعتداء بسبب الدين أو العقيدة أو الجنس

💡 تطبيق نترو يدعم الإبلاغ الفوري عن جميع أنواع السرقة والاعتداء مع إمكانية رفع الأدلة والصور.''';

      case 'مرور':
        return '''قانون المرور المصري رقم 66 لسنة 1973 والقوانين المعدلة:

المخالفات المرورية الرئيسية:
• تجاوز السرعة المقررة:
  - تجاوز 20 كم/س: غرامة 100 جنيه
  - تجاوز 40 كم/س: غرامة 200 جنيه  
  - تجاوز 60 كم/س: غرامة 300 جنيه + سحب الرخصة شهر

• القيادة تحت تأثير المواد المخدرة أو الكحولية:
  العقوبة: الحبس من شهر إلى سنة وغرامة من 1000 إلى 5000 جنيه + سحب الرخصة من 3 إلى 12 شهر

• عدم ربط حزام الأمان: غرامة 100 جنيه
• استخدام الهاتف أثناء القيادة: غرامة 150 جنيه
• القيادة بدون رخصة: غرامة 300 جنيه + حجز المركبة
• عدم التوقف عند الإشارة الحمراء: غرامة 100 جنيه

الحوادث المرورية:
• وجوب الإبلاغ فوراً لأقرب قسم شرطة أو نجدة 122
• عدم ترك مكان الحادث قبل وصول الشرطة (عقوبة الهروب: الحبس والغرامة)
• تقديم المساعدة للمصابين واجب قانوني

المركبات والتراخيص:
• القيادة بدون تراخيص سارية: غرامة وحجز المركبة
• عدم تجديد الرخصة في الموعد: غرامة 50 جنيه شهرياً
• نقل الملكية خلال 30 يوم من الشراء

💡 نترو يسهل الإبلاغ الفوري عن الحوادث المرورية ومخالفات السير مع تحديد الموقع الدقيق.''';

      case 'بيانات':
      case 'خصوصية':
        return '''قانون حماية البيانات الشخصية المصري رقم 151 لسنة 2020:

المبادئ الأساسية:
• الحصول على موافقة صريحة ومكتوبة من صاحب البيانات قبل جمعها أو معالجتها
• استخدام البيانات للغرض المعلن عنه فقط
• عدم الاحتفاظ بالبيانات لفترة أطول من اللازم
• ضمان دقة وتحديث البيانات باستمرار
• حماية البيانات من الوصول غير المصرح به

حقوق أصحاب البيانات:
• الحق في معرفة البيانات المجمعة عنهم
• الحق في تصحيح البيانات غير الصحيحة
• الحق في محو البيانات (الحق في النسيان)
• الحق في نقل البيانات إلى جهة أخرى
• الحق في الاعتراض على معالجة البيانات

التزامات مسئولي البيانات:
• تسجيل أنشطة المعالجة
• إجراء تقييم أثر حماية البيانات للعمليات عالية المخاطر
• الإبلاغ عن انتهاكات البيانات خلال 72 ساعة
• تعيين مسئول لحماية البيانات في بعض الحالات

العقوبات المقررة:
• مخالفة أحكام القانون: غرامة من 200,000 إلى 2,000,000 جنيه
• عدم الحصول على موافقة: غرامة من 100,000 إلى 1,000,000 جنيه  
• إفشاء البيانات بدون تصريح: الحبس من 6 أشهر إلى 3 سنوات والغرامة
• تكرار المخالفة: مضاعفة العقوبة ومنع النشاط

💡 تطبيق نترو ملتزم بالكامل بقانون حماية البيانات المصري ويطبق أعلى معايير الأمان والخصوصية لحماية بيانات المستخدمين.''';

      case 'تحرش':
      case 'عنف':
        return '''قوانين مكافحة التحرش في القانون المصري:

قانون مكافحة التحرش (المادة 306 مكرر من قانون العقوبات):
التحرش الجنسي: كل من تعرض لآخر في مكان عام أو خاص أو مطروق بإتيان أمور أو إيحاءات أو تلميحات جنسية أو إباحية بالإشارة أو بالقول أو بالفعل.

العقوبات المقررة:
• التحرش البسيط: الحبس مدة لا تقل عن 6 أشهر وغرامة لا تقل عن 3000 جنيه ولا تزيد على 5000 جنيه أو بإحدى هاتين العقوبتين

الظروف المشددة (عقوبة الحبس سنة + غرامة 5000-10000 جنيه):
- إذا تكرر الفعل من الجاني
- إذا كان الجاني في موضع السلطة أو الأشراف على المجني عليها
- إذا كان المجني عليها في مكان عمل الجاني
- إذا كان المجني عليها في حالة ضعف أو احتياج للجاني

التحرش الإلكتروني:
يشمل إرسال رسائل أو صور أو مقاطع فيديو ذات طبيعة جنسية عبر وسائل التواصل الاجتماعي أو التطبيقات.
العقوبة: نفس عقوبات التحرش العادي مع إمكانية التشديد

العنف المنزلي (القانون رقم 15 لسنة 2017):
يشمل العنف الجسدي والنفسي والجنسي والاقتصادي داخل نطاق الأسرة.
العقوبة: الحبس من 6 أشهر إلى 3 سنوات وغرامة من 5000 إلى 20000 جنيه

آليات الحماية:
• أوامر الحماية المؤقتة من المحكمة
• إنشاء دور إيواء للضحايا
• برامج تأهيل نفسي واجتماعي
• خط ساخن للمساعدة

💡 تطبيق نترو يوفر إبلاغ آمن ومجهول عن حالات التحرش والعنف المنزلي مع إمكانية طلب المساعدة الفورية.''';

      default:
        return '''تطبيق نترو هو تطبيق متطور للهواتف الذكية يعمل على نظام Android، مصمم خصيصاً للمواطنين المصريين لتسهيل عملية الإبلاغ عن الحوادث والجرائم بطريقة آمنة وفعالة.

المميزات الرئيسية للتطبيق:

🚨 نظام البلاغات المتطور:
- إبلاغ فوري عن الجرائم والحوادث
- رفع الصور والفيديوهات كأدلة
- تحديد الموقع الدقيق تلقائياً
- متابعة حالة البلاغ في الوقت الفعلي
- نظام التصنيف الذكي للبلاغات

🗺️ الخريطة الحرارية التفاعلية:
- عرض مستويات الأمان في المناطق المختلفة
- إحصائيات الجرائم والحوادث
- تنبيهات المناطق عالية الخطورة
- خرائط طرق آمنة

🤖 المساعد الذكي سوبيك:
- مساعد ذكي متاح 24/7
- إرشادات قانونية فورية
- مساعدة في صياغة البلاغات
- معلومات عن الإجراءات القانونية

🔒 الأمان والخصوصية:
- تشفير متقدم لحماية البيانات
- إمكانية الإبلاغ المجهول
- نظام التحقق بالرقم القومي
- حماية هوية المبلغين

📊 المتابعة والإحصائيات:
- تتبع حالة البلاغات
- إحصائيات الأمان في المنطقة
- تقارير دورية للسلطات
- تحليلات الأمان الشخصي

التقنيات المستخدمة:
- تطبيق Android أصلي باستخدام Flutter
- قاعدة بيانات آمنة ومشفرة
- نظام GPS للتتبع الدقيق
- تكامل مع خدمات الطوارئ المصرية

💡 تطبيق نترو يهدف إلى بناء مجتمع أكثر أماناً من خلال تسهيل التواصل بين المواطنين وأجهزة الأمن المصرية.''';
    }
  }

  @override
  Future<bool> isContextAllowed(String message) async {
    // تسريح كل الرسائل للوقت الحالي للاختبار
    log('🔍 فحص السياق للرسالة: $message');
    log('✅ تم السماح لكل الرسائل مؤقتاً للاختبار');
    return true; // مؤقتاً للاختبار
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
