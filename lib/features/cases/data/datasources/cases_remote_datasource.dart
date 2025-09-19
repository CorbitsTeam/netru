import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/case_model.dart';

abstract class CasesRemoteDataSource {
  Future<List<CaseModel>> getLatestCases({int limit = 10});
  Future<List<CaseModel>> getTrendingCases({int limit = 10});
  Future<CaseModel?> getCaseById(String id);
  Future<void> incrementCaseViewCount(String id);
}

class CasesRemoteDataSourceImpl implements CasesRemoteDataSource {
  final SupabaseClient supabaseClient;

  CasesRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CaseModel>> getLatestCases({int limit = 10}) async {
    try {
      print('🔄 جاري جلب أحدث القضايا...');

      final response = await supabaseClient
          .from('reports')
          .select('''
            *,
            report_type:report_type_id(name, name_ar)
          ''')
          .eq('report_status', 'resolved') // فقط القضايا المحلولة
          .order('resolved_at', ascending: false)
          .limit(limit);

      print('✅ تم جلب ${response.length} قضية بنجاح');

      return response.map<CaseModel>((json) {
        // تحويل بيانات التقرير إلى نموذج قضية
        final reportType = json['report_type'];
        return CaseModel.fromJson({
          ...json,
          'title':
              reportType?['name_ar'] ?? reportType?['name'] ?? 'قضية محلولة',
          'description':
              json['public_notes'] ??
              json['report_details'] ??
              'تم حل هذه القضية بنجاح',
          'location': json['incident_location_address'] ?? 'غير محدد',
          'incident_date': json['resolved_at'] ?? json['submitted_at'],
          'priority': json['priority_level'],
          'status': 'resolved',
          'case_number': json['case_number'],
          'view_count': 0, // يمكن إضافة حقل منفصل للمشاهدات
          'is_trending': false,
          'created_at': json['submitted_at'],
          'updated_at': json['updated_at'],
        });
      }).toList();
    } catch (e, stackTrace) {
      print('❌ خطأ في جلب أحدث القضايا: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('فشل في جلب أحدث القضايا: $e');
    }
  }

  @override
  Future<List<CaseModel>> getTrendingCases({int limit = 10}) async {
    try {
      print('🔄 جاري جلب القضايا الرائجة...');

      // جلب القضايا التي تم حلها مؤخراً وذات أولوية عالية
      final response = await supabaseClient
          .from('reports')
          .select('''
            *,
            report_type:report_type_id(name, name_ar)
          ''')
          .eq('report_status', 'resolved')
          // Use the PostgREST filter operator for multiple values
          .filter('priority_level', 'in', '(high,urgent)')
          .order('resolved_at', ascending: false)
          .limit(limit);

      print('✅ تم جلب ${response.length} قضية رائجة بنجاح');

      return response.map<CaseModel>((json) {
        final reportType = json['report_type'];
        return CaseModel.fromJson({
          ...json,
          'title':
              reportType?['name_ar'] ?? reportType?['name'] ?? 'قضية رائجة',
          'description':
              json['public_notes'] ??
              json['report_details'] ??
              'قضية مهمة تم حلها بنجاح',
          'location': json['incident_location_address'] ?? 'غير محدد',
          'incident_date': json['resolved_at'] ?? json['submitted_at'],
          'priority': json['priority_level'],
          'status': 'resolved',
          'case_number': json['case_number'],
          'view_count': 0,
          'is_trending': true,
          'created_at': json['submitted_at'],
          'updated_at': json['updated_at'],
        });
      }).toList();
    } catch (e, stackTrace) {
      print('❌ خطأ في جلب القضايا الرائجة: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('فشل في جلب القضايا الرائجة: $e');
    }
  }

  @override
  Future<CaseModel?> getCaseById(String id) async {
    try {
      print('🔄 جاري جلب القضية بالمعرف: $id');

      final response =
          await supabaseClient
              .from('reports')
              .select('''
            *,
            report_type:report_type_id(name, name_ar)
          ''')
              .eq('id', id)
              .single();

      final reportType = response['report_type'];
      return CaseModel.fromJson({
        ...response,
        'title': reportType?['name_ar'] ?? reportType?['name'] ?? 'قضية',
        'description':
            response['public_notes'] ?? response['report_details'] ?? '',
        'location': response['incident_location_address'] ?? 'غير محدد',
        'incident_date': response['resolved_at'] ?? response['submitted_at'],
        'priority': response['priority_level'],
        'status': response['report_status'],
        'case_number': response['case_number'],
        'view_count': 0,
        'is_trending': false,
        'created_at': response['submitted_at'],
        'updated_at': response['updated_at'],
      });
    } catch (e) {
      print('❌ خطأ في جلب القضية: $e');
      return null;
    }
  }

  @override
  Future<void> incrementCaseViewCount(String id) async {
    try {
      // يمكن إضافة جدول منفصل لتتبع المشاهدات
      // أو إضافة حقل view_count إلى جدول reports
      print('📈 زيادة عدد مشاهدات القضية: $id');

      // TODO: تنفيذ زيادة عدد المشاهدات
      // await supabaseClient.rpc('increment_case_views', {'case_id': id});
    } catch (e) {
      print('❌ خطأ في زيادة عدد المشاهدات: $e');
      // يمكن تجاهل هذا الخطأ لأنه ليس حرجاً
    }
  }
}
