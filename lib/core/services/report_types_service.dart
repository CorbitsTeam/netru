import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/reports/data/datasources/report_types_datasource.dart';
import '../../features/reports/data/models/report_type_model.dart';

class ReportTypesService {
  static final ReportTypesService _instance = ReportTypesService._internal();
  factory ReportTypesService() => _instance;
  ReportTypesService._internal();

  late final ReportTypesDataSource _dataSource;
  List<ReportTypeModel>? _cachedReportTypes;
  DateTime? _lastFetch;

  void initialize() {
    _dataSource = ReportTypesDataSourceImpl(
      supabaseClient: Supabase.instance.client,
    );
  }

  /// Get all active report types with caching
  Future<List<ReportTypeModel>> getAllReportTypes({
    bool forceRefresh = false,
  }) async {
    // Check if we have cached data and it's not expired (cache for 1 hour)
    if (!forceRefresh &&
        _cachedReportTypes != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inHours < 1) {
      return _cachedReportTypes!;
    }

    try {
      final reportTypes = await _dataSource.getAllReportTypes();

      // Cache the data
      _cachedReportTypes = reportTypes;
      _lastFetch = DateTime.now();

      return reportTypes;
    } catch (e) {
      // If failed and we have cached data, return it
      if (_cachedReportTypes != null) {
        return _cachedReportTypes!;
      }

      // Otherwise return default types as fallback
      return _getDefaultReportTypes();
    }
  }

  /// Get report type by ID
  Future<ReportTypeModel?> getReportTypeById(int id) async {
    try {
      // First try to find in cache
      if (_cachedReportTypes != null) {
        try {
          final cached =
              _cachedReportTypes!.where((type) => type.id == id).first;
          return cached;
        } catch (e) {
          // If not found in cache, continue to fetch from database
        }
      }

      // If not in cache, fetch from database
      return await _dataSource.getReportTypeById(id);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache to force refresh
  void clearCache() {
    _cachedReportTypes = null;
    _lastFetch = null;
  }

  /// Get default report types as fallback
  List<ReportTypeModel> _getDefaultReportTypes() {
    final now = DateTime.now();
    return [
      ReportTypeModel(
        id: 1,
        name: 'theft',
        nameAr: 'سرقة',
        priorityLevel: 'high',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 2,
        name: 'domestic_violence',
        nameAr: 'عنف أسري',
        priorityLevel: 'urgent',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 3,
        name: 'missing_persons',
        nameAr: 'بلاغ مفقودات',
        priorityLevel: 'high',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 4,
        name: 'riots',
        nameAr: 'أعمال شغب او تجمع غير قانوني',
        priorityLevel: 'urgent',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 5,
        name: 'traffic_accident',
        nameAr: 'حادث مروري جسيم',
        priorityLevel: 'high',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 6,
        name: 'fire_vandalism',
        nameAr: 'حريق / محاولة تخريب',
        priorityLevel: 'urgent',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 7,
        name: 'bribery_corruption',
        nameAr: 'رشوة / فساد مالي',
        priorityLevel: 'medium',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 8,
        name: 'cybercrime',
        nameAr: 'جريمة إلكترونية ( اختراق - نصب إلكتروني )',
        priorityLevel: 'medium',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 9,
        name: 'blackmail_threats',
        nameAr: 'ابتزاز  / تهديد',
        priorityLevel: 'high',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 10,
        name: 'kidnapping',
        nameAr: 'خطف / إختفاء',
        priorityLevel: 'urgent',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 11,
        name: 'unlicensed_weapons',
        nameAr: 'أسلحة غير مرخصة',
        priorityLevel: 'high',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 12,
        name: 'drugs',
        nameAr: 'مخدرات ( تعاطي - اتجار - تصنيع )',
        priorityLevel: 'high',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 13,
        name: 'assault',
        nameAr: 'اعتداء جسدي',
        priorityLevel: 'high',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 14,
        name: 'terrorism',
        nameAr: 'إرهاب / نشاط مشبوه',
        priorityLevel: 'urgent',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 15,
        name: 'murder_attempt',
        nameAr: 'قتل / محاولة قتل',
        priorityLevel: 'urgent',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 16,
        name: 'armed_robbery',
        nameAr: 'سطو مسلح',
        priorityLevel: 'urgent',
        isActive: true,
        createdAt: now,
      ),
      ReportTypeModel(
        id: 17,
        name: 'other',
        nameAr: 'بلاغ آخر',
        priorityLevel: 'medium',
        isActive: true,
        createdAt: now,
      ),
    ];
  }
}
