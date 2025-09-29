import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../model/report_location_model.dart';

abstract class HeatmapRemoteDataSource {
  Future<List<ReportLocationModel>> getReportsLocations();
  Future<CrimeStatisticsModel> getCrimeStatistics();
  Future<List<GovernorateStatsModel>> getGovernorateStatistics();
  Future<List<ReportTypeStatsModel>> getReportTypeStatistics();
  Future<List<ReportLocationModel>> getReportsByGovernorate(String governorate);
  Future<List<ReportLocationModel>> getRecentReports({int limit = 50});
}

class HeatmapRemoteDataSourceImpl implements HeatmapRemoteDataSource {
  final SupabaseClient _supabase;

  HeatmapRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<ReportLocationModel>> getReportsLocations() async {
    try {
      print('🔍 Starting to fetch reports locations...');
      final response = await _supabase
          .from('reports')
          .select('''
            id,
            incident_location_latitude,
            incident_location_longitude,
            report_type_custom,
            report_status,
            priority_level,
            submitted_at,
            incident_location_address,
            user_id,
            users!reports_user_id_fkey(governorate, city),
            report_types(name, name_ar)
          ''')
          .not('incident_location_latitude', 'is', null)
          .not('incident_location_longitude', 'is', null);

      print('✅ Successfully fetched ${response.length} reports');

      return (response as List<dynamic>)
          .map(
            (item) => ReportLocationModel.fromJson({
              ...item,
              'governorate': item['users']?['governorate'] ?? 'غير محدد',
              'city': item['users']?['city'] ?? 'غير محدد',
              'report_type_name':
                  item['report_types']?['name_ar'] ??
                  item['report_type_custom'],
            }),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching reports locations: $e');
      debugPrint('🔍 Full error details: $e');
      throw Exception('فشل في جلب مواقع التقارير: $e');
    }
  }

  @override
  Future<CrimeStatisticsModel> getCrimeStatistics() async {
    try {
      print('📊 Fetching crime statistics...');
      // إجمالي التقارير
      final totalResponse =
          await _supabase.from('reports').select('id').count();
      final totalCount = totalResponse.count;
      print('📈 Total reports: $totalCount');

      // التقارير المعلقة
      final pendingResponse =
          await _supabase
              .from('reports')
              .select('id')
              .eq('report_status', 'pending')
              .count();
      final pendingCount = pendingResponse.count;
      print('⏳ Pending reports: $pendingCount');

      // التقارير المحلولة
      final resolvedResponse =
          await _supabase
              .from('reports')
              .select('id')
              .eq('report_status', 'resolved')
              .count();
      final resolvedCount = resolvedResponse.count;
      print('✅ Resolved reports: $resolvedCount');

      // أكثر أنواع التقارير شيوعاً
      print('📋 Getting most common report types...');
      final typeStats = await getReportTypeStatistics();
      final mostCommon = typeStats.isNotEmpty ? typeStats.first : null;
      print('🎯 Most common type: ${mostCommon?.typeNameAr}');

      print('🗺️ Getting governorate statistics...');
      final governorateStats = await getGovernorateStatistics();
      print('🏙️ Found ${governorateStats.length} governorates');

      final statistics = CrimeStatisticsModel(
        totalReports: totalCount,
        pendingReports: pendingCount,
        resolvedReports: resolvedCount,
        mostCommonType: mostCommon?.typeNameAr ?? 'غير محدد',
        mostCommonTypePercentage:
            mostCommon != null && totalCount > 0
                ? (mostCommon.count / totalCount) * 100
                : 0.0,
        governorateStats: governorateStats,
        reportTypeStats: typeStats,
      );

      print('✅ Successfully compiled crime statistics');
      return statistics;
    } catch (e) {
      print('❌ Error fetching crime statistics: $e');
      debugPrint('📊 Full error details: $e');
      throw Exception('فشل في جلب الإحصائيات: $e');
    }
  }

  @override
  Future<List<GovernorateStatsModel>> getGovernorateStatistics() async {
    try {
      print('📊 Fetching governorate statistics...');
      final response = await _supabase.rpc('get_governorate_stats');

      if (response == null) {
        print('⚠️ RPC function not available, using fallback method');
        // Fallback: جلب البيانات يدوياً
        final reports = await _supabase
            .from('reports')
            .select('users!reports_user_id_fkey(governorate)')
            .not('users.governorate', 'is', null);

        final Map<String, int> governorateCounts = {};
        for (final report in reports) {
          final governorate = report['users']['governorate'] as String?;
          if (governorate != null) {
            governorateCounts[governorate] =
                (governorateCounts[governorate] ?? 0) + 1;
          }
        }

        final List<GovernorateStatsModel> stats = [];
        for (final entry in governorateCounts.entries) {
          final center = await _calculateGovernorateCenter(entry.key);
          stats.add(GovernorateStatsModel(
            governorateName: entry.key,
            reportCount: entry.value,
            centerLocation: center,
          ));
        }
        return stats;
      }

      return (response as List<dynamic>)
          .map((item) => GovernorateStatsModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Error fetching governorate statistics: $e');
      debugPrint('🏙️ Full error details: $e');
      throw Exception('فشل في جلب إحصائيات المحافظات: $e');
    }
  }

  @override
  Future<List<ReportTypeStatsModel>> getReportTypeStatistics() async {
    try {
      print('📊 Fetching report type statistics...');
      final response = await _supabase.rpc('get_report_type_stats');

      if (response == null) {
        print('⚠️ RPC function not available, using fallback method');
        // Fallback: جلب البيانات يدوياً
        final reports = await _supabase
            .from('reports')
            .select(
              'report_type_id, report_type_custom, report_types(name, name_ar, priority_level)',
            );

        final Map<String, Map<String, dynamic>> typeCounts = {};
        for (final report in reports) {
          String typeName, typeNameAr, priority;

          if (report['report_types'] != null) {
            typeName = report['report_types']['name'] ?? 'غير محدد';
            typeNameAr = report['report_types']['name_ar'] ?? 'غير محدد';
            priority = report['report_types']['priority_level'] ?? 'medium';
          } else {
            typeName = typeNameAr = report['report_type_custom'] ?? 'غير محدد';
            priority = 'medium';
          }

          if (typeCounts.containsKey(typeNameAr)) {
            typeCounts[typeNameAr]!['count']++;
          } else {
            typeCounts[typeNameAr] = {
              'name': typeName,
              'name_ar': typeNameAr,
              'count': 1,
              'priority_level': priority,
            };
          }
        }

        return typeCounts.values
            .map((item) => ReportTypeStatsModel.fromJson(item))
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));
      }

      return (response as List<dynamic>)
          .map((item) => ReportTypeStatsModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Error fetching report type statistics: $e');
      debugPrint('📋 Full error details: $e');
      throw Exception('فشل في جلب إحصائيات أنواع التقارير: $e');
    }
  }

  @override
  Future<List<ReportLocationModel>> getReportsByGovernorate(
    String governorate,
  ) async {
    try {
      print('🏙️ Fetching reports for governorate: $governorate');
      final response = await _supabase
          .from('reports')
          .select('''
            id,
            incident_location_latitude,
            incident_location_longitude,
            report_type_custom,
            report_status,
            priority_level,
            submitted_at,
            incident_location_address,
            users!reports_user_id_fkey(governorate, city),
            report_types(name, name_ar)
          ''')
          .eq('users.governorate', governorate)
          .not('incident_location_latitude', 'is', null)
          .not('incident_location_longitude', 'is', null);

      print('✅ Found ${response.length} reports for $governorate');

      return (response as List<dynamic>)
          .map(
            (item) => ReportLocationModel.fromJson({
              ...item,
              'governorate': item['users']?['governorate'] ?? governorate,
              'city': item['users']?['city'] ?? 'غير محدد',
              'report_type_name':
                  item['report_types']?['name_ar'] ??
                  item['report_type_custom'],
            }),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching reports by governorate: $e');
      debugPrint('🏛️ Full error details: $e');
      throw Exception('فشل في جلب تقارير المحافظة: $e');
    }
  }

  @override
  Future<List<ReportLocationModel>> getRecentReports({int limit = 50}) async {
    try {
      print('⏰ Fetching recent reports with limit: $limit');
      final response = await _supabase
          .from('reports')
          .select('''
            id,
            incident_location_latitude,
            incident_location_longitude,
            report_type_custom,
            report_status,
            priority_level,
            submitted_at,
            incident_location_address,
            users!reports_user_id_fkey(governorate, city),
            report_types(name, name_ar)
          ''')
          .not('incident_location_latitude', 'is', null)
          .not('incident_location_longitude', 'is', null)
          .order('submitted_at', ascending: false)
          .limit(limit);

      print('✅ Found ${response.length} recent reports');

      return (response as List<dynamic>)
          .map(
            (item) => ReportLocationModel.fromJson({
              ...item,
              'governorate': item['users']?['governorate'] ?? 'غير محدد',
              'city': item['users']?['city'] ?? 'غير محدد',
              'report_type_name':
                  item['report_types']?['name_ar'] ??
                  item['report_type_custom'],
            }),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching recent reports: $e');
      debugPrint('⏰ Full error details: $e');
      throw Exception('فشل في جلب التقارير الحديثة: $e');
    }
  }

  /// حساب مركز المحافظة من البيانات الفعلية المخزنة في قاعدة البيانات
  Future<LatLng> _calculateGovernorateCenter(String governorateName) async {
    try {
      print('🎯 Calculating center for governorate: $governorateName');

      final response = await _supabase
          .from('reports')
          .select('incident_location_latitude, incident_location_longitude')
          .eq('users.governorate', governorateName)
          .not('incident_location_latitude', 'is', null)
          .not('incident_location_longitude', 'is', null)
          .limit(100); // نأخذ عينة من 100 تقرير لحساب المتوسط

      if (response.isEmpty) {
        print('⚠️ No data found for $governorateName, using default center');
        return _getDefaultCenter();
      }

      double totalLat = 0.0;
      double totalLng = 0.0;
      int validCount = 0;

      for (final report in response) {
        final lat = report['incident_location_latitude'] as double?;
        final lng = report['incident_location_longitude'] as double?;

        if (lat != null && lng != null) {
          totalLat += lat;
          totalLng += lng;
          validCount++;
        }
      }

      if (validCount == 0) {
        print('⚠️ No valid coordinates found for $governorateName');
        return _getDefaultCenter();
      }

      final centerLat = totalLat / validCount;
      final centerLng = totalLng / validCount;

      print('✅ Calculated center for $governorateName: ($centerLat, $centerLng)');
      return LatLng(centerLat, centerLng);
    } catch (e) {
      print('❌ Error calculating center for $governorateName: $e');
      return _getDefaultCenter();
    }
  }

  /// المركز الافتراضي (وسط مصر تقريباً)
  LatLng _getDefaultCenter() {
    return const LatLng(26.8206, 30.8025); // وسط مصر جغرافياً
  }
}
