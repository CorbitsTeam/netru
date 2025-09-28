/// Advanced notification templates service for the Netru app
/// This service provides professional, contextual notification templates
/// for various app scenarios with proper Arabic localization
library;

class NotificationTemplateService {
  static const String _defaultAppName = 'نترو';

  /// Generate notification for report status updates
  static Map<String, String> reportStatusUpdate({
    required String status,
    required String reporterName,
    required String caseNumber,
    String? investigatorName,
    String? estimatedTime,
    String? additionalInfo,
  }) {
    switch (status.toLowerCase()) {
      case 'received':
        return {
          'title': '📩 تم استلام بلاغكم بنجاح',
          'body': '''مرحباً $reporterName،

تم استلام بلاغكم رقم #$caseNumber بنجاح وتسجيله في النظام.

📋 رقم القضية: #$caseNumber
⏰ وقت الاستلام: ${DateTime.now().toString().split('.')[0]}
📍 الحالة: تحت المراجعة الأولية

سيتم مراجعة بلاغكم من قبل الفريق المختص خلال الساعات القادمة. سنقوم بإشعاركم بأي تطورات.

شكراً لثقتكم في خدماتنا.''',
          'emoji': '📩',
        };

      case 'under_investigation':
        return {
          'title': '🔍 بدء التحقيق في بلاغكم',
          'body': '''السيد/ة $reporterName،

نود إعلامكم بأن بلاغكم رقم #$caseNumber قيد التحقيق النشط.

👨‍💼 المحقق المسؤول: ${investigatorName ?? 'سيتم تحديده قريباً'}
⏳ الوقت المتوقع: ${estimatedTime ?? '48 ساعة'}
📊 مرحلة التحقيق: جمع الأدلة والمعلومات

${additionalInfo != null ? '📝 ملاحظات إضافية: $additionalInfo' : ''}

نعمل بجد لضمان حل قضيتكم بأسرع وقت ممكن.''',
          'emoji': '🔍',
        };

      case 'resolved':
        return {
          'title': '✅ تم حل بلاغكم بنجاح',
          'body': '''السيد/ة $reporterName،

يسعدنا إعلامكم بأن بلاغكم رقم #$caseNumber تم حله بنجاح!

✅ حالة القضية: مُحلّة
📅 تاريخ الحل: ${DateTime.now().toString().split(' ')[0]}
👨‍💼 المحقق المسؤول: ${investigatorName ?? 'الفريق المختص'}

${additionalInfo != null ? '📄 تفاصيل الحل: $additionalInfo' : ''}

يمكنكم الاطلاع على تفاصيل الحل الكاملة في التطبيق.

شكراً لتعاونكم واستخدامكم خدماتنا.''',
          'emoji': '✅',
        };

      case 'rejected':
        return {
          'title': '❌ تنبيه بخصوص بلاغكم',
          'body': '''السيد/ة $reporterName،

نأسف لإعلامكم بأن بلاغكم رقم #$caseNumber لم يتم قبوله للأسباب التالية:

${additionalInfo ?? 'عدم توفر معلومات كافية أو عدم وضوح البلاغ'}

📞 يمكنكم التواصل معنا لمزيد من التوضيح
📝 يمكنكم إعادة تقديم البلاغ مع معلومات إضافية

نحن هنا لمساعدتكم دائماً.''',
          'emoji': '❌',
        };

      case 'closed':
        return {
          'title': '🔒 تم إغلاق البلاغ',
          'body': '''السيد/ة $reporterName،

تم إغلاق بلاغكم رقم #$caseNumber نهائياً.

📋 ملخص القضية:
• تاريخ التقديم: متاح في التطبيق
• تاريخ الإغلاق: ${DateTime.now().toString().split(' ')[0]}
• المحقق المسؤول: ${investigatorName ?? 'الفريق المختص'}

${additionalInfo != null ? '📝 ملاحظات الإغلاق: $additionalInfo' : ''}

شكراً لثقتكم في خدماتنا.''',
          'emoji': '🔒',
        };

      case 'pending':
        return {
          'title': '⏳ بلاغكم في قائمة الانتظار',
          'body': '''السيد/ة $reporterName،

بلاغكم رقم #$caseNumber في قائمة الانتظار حالياً.

📊 موقعكم في القائمة: يتم تحديثه دورياً
⏰ الوقت المتوقع للمراجعة: ${estimatedTime ?? '24-48 ساعة'}
📈 حالة النظام: يتم معالجة البلاغات حسب الأولوية

سنقوم بإشعاركم فور بدء المراجعة.''',
          'emoji': '⏳',
        };

      default:
        return {
          'title': '📋 تحديث في حالة بلاغكم',
          'body':
              'السيد/ة $reporterName، تم تحديث حالة بلاغكم رقم #$caseNumber. يرجى مراجعة التطبيق للاطلاع على التفاصيل.',
          'emoji': '📋',
        };
    }
  }

  /// Generate notification for report assignment to investigator
  static Map<String, String> investigatorAssignment({
    required String reportId,
    required String reporterName,
    required String caseNumber,
    required String reportType,
    required String priority,
    String? reportSummary,
    String? deadline,
  }) {
    String priorityEmoji = '';
    String priorityText = '';

    switch (priority.toLowerCase()) {
      case 'urgent':
        priorityEmoji = '🚨';
        priorityText = 'عاجل جداً';
        break;
      case 'high':
        priorityEmoji = '🔴';
        priorityText = 'عالي';
        break;
      case 'medium':
        priorityEmoji = '🟡';
        priorityText = 'متوسط';
        break;
      case 'low':
        priorityEmoji = '🟢';
        priorityText = 'منخفض';
        break;
    }

    return {
      'title': '$priorityEmoji تكليف جديد - قضية #$caseNumber',
      'body': '''تم تعيين قضية جديدة لك للتحقيق:

📋 رقم القضية: #$caseNumber
👤 اسم المبلغ: $reporterName
📂 نوع البلاغ: $reportType
$priorityEmoji الأولوية: $priorityText

${reportSummary != null ? '📝 ملخص البلاغ:\n$reportSummary\n' : ''}
${deadline != null ? '⏰ الموعد النهائي: $deadline\n' : ''}

يرجى مراجعة التفاصيل الكاملة في لوحة التحكم.''',
      'emoji': priorityEmoji,
    };
  }

  /// Generate notification for user about investigator assignment
  static Map<String, String> reportAssignmentToUser({
    required String reporterName,
    required String caseNumber,
    required String investigatorName,
    required String investigatorTitle,
    String? expectedDuration,
    String? contactInfo,
  }) {
    return {
      'title': '👨‍💼 تم تعيين محقق لقضيتكم',
      'body': '''السيد/ة $reporterName،

تم تعيين محقق مختص للنظر في بلاغكم رقم #$caseNumber:

👨‍💼 اسم المحقق: $investigatorName
🏛️ المنصب: $investigatorTitle
⏰ المدة المتوقعة: ${expectedDuration ?? '3-5 أيام عمل'}

${contactInfo != null ? '📞 معلومات التواصل: $contactInfo\n' : ''}

سيقوم المحقق المختص بمراجعة قضيتكم وإجراء التحقيقات اللازمة. ستتلقون تحديثات دورية حول التقدم المحرز.''',
      'emoji': '👨‍💼',
    };
  }

  /// Generate notification for system announcements
  static Map<String, String> systemAnnouncement({
    required String title,
    required String message,
    String? urgencyLevel,
    String? actionRequired,
    String? deadline,
  }) {
    String emoji = '📢';

    switch (urgencyLevel?.toLowerCase()) {
      case 'urgent':
        emoji = '🚨';
        break;
      case 'important':
        emoji = '⚠️';
        break;
      case 'info':
        emoji = 'ℹ️';
        break;
    }

    return {
      'title': '$emoji $title',
      'body': '''$message

${actionRequired != null ? '✅ الإجراء المطلوب: $actionRequired\n' : ''}
${deadline != null ? '⏰ الموعد النهائي: $deadline\n' : ''}

فريق $_defaultAppName''',
      'emoji': emoji,
    };
  }

  /// Generate notification for security alerts
  static Map<String, String> securityAlert({
    required String alertType,
    required String location,
    required String severity,
    String? description,
    String? safetyInstructions,
  }) {
    String emoji = '🔒';
    String title = '';

    switch (alertType.toLowerCase()) {
      case 'emergency':
        emoji = '🚨';
        title = 'تنبيه أمني عاجل';
        break;
      case 'warning':
        emoji = '⚠️';
        title = 'تحذير أمني';
        break;
      case 'info':
        emoji = 'ℹ️';
        title = 'معلومات أمنية';
        break;
    }

    return {
      'title': '$emoji $title - $location',
      'body': '''تم رصد حالة أمنية في المنطقة:

📍 الموقع: $location
📊 مستوى الخطورة: $severity

${description != null ? '📝 التفاصيل: $description\n' : ''}
${safetyInstructions != null ? '🛡️ تعليمات السلامة:\n$safetyInstructions\n' : ''}

يرجى اتخاذ الحيطة والحذر واتباع التعليمات الأمنية.

فريق الأمان - $_defaultAppName''',
      'emoji': emoji,
    };
  }

  /// Generate notification for app updates
  static Map<String, String> appUpdate({
    required String version,
    required String updateType, // 'mandatory', 'optional', 'security'
    List<String>? newFeatures,
    List<String>? bugFixes,
    String? updateSize,
  }) {
    String emoji = '🔄';
    String title = 'تحديث جديد متاح';

    switch (updateType.toLowerCase()) {
      case 'mandatory':
        emoji = '⚠️';
        title = 'تحديث مطلوب فوراً';
        break;
      case 'security':
        emoji = '🔒';
        title = 'تحديث أمني مهم';
        break;
    }

    String featuresText = '';
    if (newFeatures != null && newFeatures.isNotEmpty) {
      featuresText =
          '\n✨ المميزات الجديدة:\n${newFeatures.map((f) => '• $f').join('\n')}';
    }

    String fixesText = '';
    if (bugFixes != null && bugFixes.isNotEmpty) {
      fixesText =
          '\n🔧 إصلاحات الأخطاء:\n${bugFixes.map((f) => '• $f').join('\n')}';
    }

    return {
      'title': '$emoji $title',
      'body': '''إصدار جديد من التطبيق متاح الآن!

📦 الإصدار: $version
${updateSize != null ? '📏 حجم التحديث: $updateSize\n' : ''}$featuresText$fixesText

${updateType.toLowerCase() == 'mandatory' ? '\n⚠️ هذا التحديث مطلوب للاستمرار في استخدام التطبيق.' : ''}

انقر للتحديث الآن.''',
      'emoji': emoji,
    };
  }

  /// Generate personalized welcome notification for new users
  static Map<String, String> welcomeUser({
    required String userName,
    required String userType,
    List<String>? quickTips,
  }) {
    String userTypeText = '';
    List<String> defaultTips = [];

    switch (userType.toLowerCase()) {
      case 'citizen':
        userTypeText = 'مواطن';
        defaultTips = [
          'يمكنك تقديم البلاغات بسهولة من الصفحة الرئيسية',
          'تابع حالة بلاغاتك من قسم "بلاغاتي"',
          'فعّل الإشعارات للحصول على التحديثات فوراً',
        ];
        break;
      case 'foreigner':
        userTypeText = 'مقيم';
        defaultTips = [
          'يمكنك الإبلاغ باستخدام رقم الإقامة أو الباسبورت',
          'الخدمات متاحة لك كما هي متاحة للمواطنين',
          'تواصل معنا في حالة الحاجة لمساعدة إضافية',
        ];
        break;
      case 'admin':
        userTypeText = 'مسؤول';
        defaultTips = [
          'يمكنك إدارة البلاغات من لوحة التحكم',
          'راجع التقارير والإحصائيات من القائمة الرئيسية',
          'استخدم نظام الإشعارات المجمعة للتواصل مع المستخدمين',
        ];
        break;
    }

    final tipsText = (quickTips ?? defaultTips)
        .map((tip) => '💡 $tip')
        .join('\n');

    return {
      'title': '🎉 أهلاً وسهلاً $userName!',
      'body': '''مرحباً بك في تطبيق $_defaultAppName!

👤 نوع الحساب: $userTypeText
📱 حسابك جاهز للاستخدام

🚀 نصائح سريعة للبداية:
$tipsText

نحن سعداء بانضمامك إلينا ونتطلع لخدمتك.

فريق $_defaultAppName''',
      'emoji': '🎉',
    };
  }
}
