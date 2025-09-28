import 'package:supabase_flutter/supabase_flutter.dart';

class ReportMediaService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// جلب جميع الوسائط المرتبطة بتقرير معين
  static Future<List<Map<String, String>>> getReportMedia(
    String reportId,
  ) async {
    try {
      final response = await _supabase
          .from('report_media')
          .select('file_url, media_type, file_name, uploaded_at')
          .eq('report_id', reportId)
          .order('uploaded_at', ascending: true);

      final mediaList = <Map<String, String>>[];

      for (final item in response) {
        mediaList.add({
          'url': item['file_url'] as String,
          'type': item['media_type'] as String,
          'name': item['file_name'] as String? ?? 'ملف غير معروف',
          'uploadedAt': item['uploaded_at'] as String? ?? '',
        });
      }

      return mediaList;
    } catch (e) {
      print('خطأ في جلب وسائط التقرير: $e');
      return [];
    }
  }

  /// جلب الوسائط الأساسية من جدول التقارير (للتوافق مع النظام القديم)
  static Future<List<Map<String, String>>> getMainReportMedia(
    String? mediaUrl,
    String? mediaType,
  ) async {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return [];
    }

    return [
      {
        'url': mediaUrl,
        'type': mediaType ?? 'unknown',
        'name': 'الملف الرئيسي',
        'uploadedAt': '',
      },
    ];
  }

  /// دمج الوسائط من مصادر متعددة (التقرير الرئيسي + الملفات الإضافية)
  static Future<List<Map<String, String>>> getAllReportMedia(
    String reportId,
    String? mainMediaUrl,
    String? mainMediaType,
  ) async {
    final allMedia = <Map<String, String>>[];

    // إضافة الملف الرئيسي إذا كان موجود
    if (mainMediaUrl != null && mainMediaUrl.isNotEmpty) {
      allMedia.add({
        'url': mainMediaUrl,
        'type': mainMediaType ?? 'unknown',
        'name': 'الملف الرئيسي',
        'uploadedAt': '',
        'isMain': 'true',
      });
    }

    // إضافة الملفات الإضافية
    final additionalMedia = await getReportMedia(reportId);
    allMedia.addAll(additionalMedia);

    // إزالة الملفات المكررة
    final uniqueUrls = <String>{};
    return allMedia.where((media) {
      final url = media['url']!;
      if (uniqueUrls.contains(url)) {
        return false;
      }
      uniqueUrls.add(url);
      return true;
    }).toList();
  }

  /// إحصائيات الوسائط
  static Map<String, int> getMediaStats(List<Map<String, String>> mediaList) {
    int imageCount = 0;
    int videoCount = 0;
    int otherCount = 0;

    for (final media in mediaList) {
      final type = media['type']?.toLowerCase() ?? '';
      if (type.startsWith('image')) {
        imageCount++;
      } else if (type.startsWith('video')) {
        videoCount++;
      } else {
        otherCount++;
      }
    }

    return {
      'images': imageCount,
      'videos': videoCount,
      'others': otherCount,
      'total': mediaList.length,
    };
  }

  /// تحديد نوع الوسائط
  static String getMediaTypeLabel(String? type) {
    if (type == null) return 'ملف غير محدد';

    final lowerType = type.toLowerCase();
    if (lowerType.startsWith('image')) return 'صورة';
    if (lowerType.startsWith('video')) return 'فيديو';
    if (lowerType.startsWith('audio')) return 'ملف صوتي';
    if (lowerType.contains('pdf')) return 'ملف PDF';

    return 'ملف';
  }

  /// التحقق من صحة رابط الوسائط
  static bool isValidMediaUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
