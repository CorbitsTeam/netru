import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../cubit/heatmap_cubit.dart';
import '../cubit/heatmap_state.dart';
import '../../../../core/services/location_service.dart';

class HeatMapWidget extends StatefulWidget {
  const HeatMapWidget({super.key});

  @override
  State<HeatMapWidget> createState() =>
      _HeatMapWidgetState();
}

class _HeatMapWidgetState
    extends State<HeatMapWidget>
    with SingleTickerProviderStateMixin {
  final MapController _mapController =
      MapController();
  final LocationService _locationService =
      LocationService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.repeat();

    WidgetsBinding.instance.addPostFrameCallback((
      _,
    ) {
      _moveToCurrentLocation();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _moveToCurrentLocation() {
    final currentLocation =
        _locationService.currentLocation;
    if (currentLocation != null) {
      _mapController.move(currentLocation, 11.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation =
        _locationService.currentLocation ??
        const LatLng(30.0444, 31.2357);

    return BlocBuilder<
      HeatmapCubit,
      HeatmapState
    >(
      builder: (context, state) {
        return Stack(
          children: [
            // الخريطة الرئيسية
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 11.0,
                minZoom: 6.0,
                maxZoom: 18.0,
                onTap:
                    (tapPosition, point) =>
                        _handleMapTap(
                          point,
                          state,
                        ),
              ),
              children: [
                // طبقة الخريطة الأساسية
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.netru.app',
                ),

                // طبقة النقاط الحرارية المحسنة
                if (state is HeatmapLoaded)
                  ..._buildEnhancedHeatmapLayers(
                    state.reports,
                  ),
                if (state is HeatmapReportsLoaded)
                  ..._buildEnhancedHeatmapLayers(
                    state.reports,
                  ),
                if (state
                    is HeatmapGovernorateFilterApplied)
                  ..._buildHeatmapLayers(
                    state.filteredReports,
                  ),

                // طبقة الموقع الحالي
                _buildCurrentLocationLayer(
                  currentLocation,
                ),
              ],
            ),

            // أزرار الزووم
            Positioned(
              bottom: 10.h,
              right: 10.w,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "zoom_in",
                    mini: true,
                    onPressed: () {
                      final zoom =
                          _mapController
                              .camera
                              .zoom;
                      _mapController.move(
                        _mapController
                            .camera
                            .center,
                        zoom + 1,
                      );
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: const Icon(Icons.add),
                  ),
                  SizedBox(height: 8.h),
                  FloatingActionButton(
                    heroTag: "zoom_out",
                    mini: true,
                    onPressed: () {
                      final zoom =
                          _mapController
                              .camera
                              .zoom;
                      _mapController.move(
                        _mapController
                            .camera
                            .center,
                        zoom - 1,
                      );
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: const Icon(
                      Icons.remove,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildEnhancedHeatmapLayers(
    List<dynamic> reports,
  ) {
    List<Widget> layers = [];

    // طبقة الدوائر الحرارية المحسنة
    List<CircleMarker> heatCircles = [];
    List<Marker> reportMarkers = [];
    List<Marker> governorateMarkers = [];

    // تجميع التقارير حسب المحافظة
    Map<String, List<dynamic>>
    governorateReports = {};
    Map<String, List<dynamic>> areaReports = {};

    for (final report in reports) {
      // تجميع حسب المحافظة
      final governorate =
          report.governorate ?? 'غير محدد';
      governorateReports
          .putIfAbsent(governorate, () => [])
          .add(report);

      // تجميع حسب المنطقة المحددة
      final key =
          '${report.location.latitude.toStringAsFixed(3)},${report.location.longitude.toStringAsFixed(3)}';
      areaReports
          .putIfAbsent(key, () => [])
          .add(report);
    }

    // إضافة علامات للمحافظات
    _addGovernorateMarkers(
      governorateMarkers,
      governorateReports,
    );

    // إنشاء الدوائر الحرارية والعلامات المحسنة
    for (final entry in areaReports.entries) {
      final reportsInArea = entry.value;
      final location =
          reportsInArea.first.location;
      final intensity = reportsInArea.length;

      // تحليل أنواع الجرائم في المنطقة
      final crimeTypeStats = _analyzeCrimeTypes(
        reportsInArea,
      );
      final dominantCrimeType =
          crimeTypeStats.entries
              .reduce(
                (a, b) =>
                    a.value > b.value ? a : b,
              )
              .key;

      // دوائر حرارية متدرجة احترافية
      final baseRadius = _calculateRadius(
        intensity,
      );
      final mainColor = _getCrimeColor(intensity);

      // دوائر خارجية متدرجة للتأثير الحراري
      for (int i = 4; i >= 1; i--) {
        final radiusMultiplier = i * 0.7;
        final opacityLevel = 0.15 / i;

        heatCircles.add(
          CircleMarker(
            point: location,
            radius:
                baseRadius *
                (radiusMultiplier + 0.3),
            color: mainColor.withOpacity(
              opacityLevel,
            ),
            borderColor: mainColor.withOpacity(
              opacityLevel * 2,
            ),
            borderStrokeWidth: i == 1 ? 2.0 : 1.0,
          ),
        );
      }

      // علامة رئيسية للمنطقة مع تصميم محسن
      reportMarkers.add(
        Marker(
          point: location,
          width: 60.w,
          height: 80.h,
          child: GestureDetector(
            onTap:
                () => _showEnhancedAreaDetails(
                  reportsInArea,
                  crimeTypeStats,
                ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // العلامة الرئيسية
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: mainColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor
                            .withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(
                          0,
                          4,
                        ),
                      ),
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(
                          0,
                          2,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCrimeTypeIcon(
                          dominantCrimeType,
                        ),
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      Text(
                        intensity.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // شارة عدد الأنواع المختلفة
                if (crimeTypeStats.length > 1)
                  Positioned(
                    top: -5.h,
                    right: -5.w,
                    child: Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '+${crimeTypeStats.length - 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      // نقاط صغيرة للتقارير الفردية حول العلامة الرئيسية
      for (
        int i = 0;
        i < reportsInArea.length && i < 8;
        i++
      ) {
        final angle =
            (i * 45.0) *
            (3.14159 / 180); // تحويل إلى راديان
        final offsetLat =
            location.latitude +
            (0.001 * math.cos(angle));
        final offsetLng =
            location.longitude +
            (0.001 * math.sin(angle));

        reportMarkers.add(
          Marker(
            point: LatLng(offsetLat, offsetLng),
            width: 12.w,
            height: 12.h,
            child: Container(
              decoration: BoxDecoration(
                color: _getCrimeTypeColor(
                  reportsInArea[i].reportType,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getCrimeTypeColor(
                      reportsInArea[i].reportType,
                    ).withOpacity(0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // إضافة الطبقات بترتيب مناسب
    if (heatCircles.isNotEmpty) {
      layers.add(
        CircleLayer(circles: heatCircles),
      );
    }
    if (governorateMarkers.isNotEmpty) {
      layers.add(
        MarkerLayer(markers: governorateMarkers),
      );
    }
    if (reportMarkers.isNotEmpty) {
      layers.add(
        MarkerLayer(markers: reportMarkers),
      );
    }

    return layers;
  }

  // تحليل أنواع الجرائم في منطقة معينة
  Map<String, int> _analyzeCrimeTypes(
    List<dynamic> reports,
  ) {
    final Map<String, int> crimeTypes = {};
    for (final report in reports) {
      final type =
          report.reportType ?? 'غير محدد';
      crimeTypes[type] =
          (crimeTypes[type] ?? 0) + 1;
    }
    return crimeTypes;
  }

  // الحصول على أيقونة نوع الجريمة
  IconData _getCrimeTypeIcon(String crimeType) {
    if (crimeType.contains('سرقة')) {
      return Icons.security;
    }
    if (crimeType.contains('اعتداء')) {
      return Icons.warning;
    }
    if (crimeType.contains('مرور') ||
        crimeType.contains('حادث')) {
      return Icons.directions_car;
    }
    if (crimeType.contains('مخدرات')) {
      return Icons.local_pharmacy;
    }
    if (crimeType.contains('احتيال')) {
      return Icons.monetization_on;
    }
    if (crimeType.contains('عنف')) {
      return Icons.home;
    }
    return Icons.report_problem;
  }

  // الحصول على لون نوع الجريمة
  Color _getCrimeTypeColor(String crimeType) {
    if (crimeType.contains('سرقة')) {
      return Colors.red;
    }
    if (crimeType.contains('اعتداء')) {
      return Colors.orange;
    }
    if (crimeType.contains('مرور') ||
        crimeType.contains('حادث')) {
      return Colors.blue;
    }
    if (crimeType.contains('مخدرات')) {
      return Colors.purple;
    }
    if (crimeType.contains('احتيال')) {
      return Colors.yellow[700] ?? Colors.yellow;
    }
    if (crimeType.contains('عنف')) {
      return Colors.pink;
    }
    return Colors.grey;
  }

  // إضافة علامات المحافظات
  void _addGovernorateMarkers(
    List<Marker> governorateMarkers,
    Map<String, List<dynamic>> governorateReports,
  ) {
    // مواقع المحافظات المصرية الرئيسية
    final Map<String, LatLng>
    governorateLocations = {
      'القاهرة': const LatLng(30.0444, 31.2357),
      'الجيزة': const LatLng(30.0131, 31.2089),
      'الإسكندرية': const LatLng(
        31.2001,
        29.9187,
      ),
      'الغربية': const LatLng(30.7618, 31.0335),
      'المنوفية': const LatLng(30.5972, 30.9876),
      'القليوبية': const LatLng(30.1792, 31.2045),
      'كفر الشيخ': const LatLng(31.1107, 30.9388),
      'الدقهلية': const LatLng(31.0409, 31.3785),
      'دمياط': const LatLng(31.4165, 31.8133),
      'الشرقية': const LatLng(30.7327, 31.7195),
      'المنيا': const LatLng(28.0871, 30.7618),
      'بني سويف': const LatLng(29.0661, 31.0994),
      'الفيوم': const LatLng(29.2985, 30.8418),
      'أسيوط': const LatLng(27.1809, 31.1837),
      'سوهاج': const LatLng(26.5569, 31.6948),
      'قنا': const LatLng(26.1551, 32.7160),
      'الأقصر': const LatLng(25.6872, 32.6396),
      'أسوان': const LatLng(24.0889, 32.8998),
      'البحر الأحمر': const LatLng(
        26.1062,
        33.8116,
      ),
      'الوادي الجديد': const LatLng(
        25.4500,
        30.5500,
      ),
      'مطروح': const LatLng(31.3543, 27.2373),
      'شمال سيناء': const LatLng(
        31.1313,
        33.8116,
      ),
      'جنوب سيناء': const LatLng(
        28.9717,
        33.6175,
      ),
    };

    for (final entry
        in governorateReports.entries) {
      final governorate = entry.key;
      final reports = entry.value;

      if (governorate == 'غير محدد' ||
          !governorateLocations.containsKey(
            governorate,
          )) {
        continue;
      }

      final location =
          governorateLocations[governorate]!;
      final reportCount = reports.length;
      final crimeLevel = _getCrimeLevel(
        reportCount,
      );

      governorateMarkers.add(
        Marker(
          point: location,
          width: 60.w,
          height: 80.h,
          child: GestureDetector(
            onTap:
                () => _showGovernorateDetails(
                  governorate,
                  reports,
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // سهم متحرك للمحافظات الأكثر خطورة
                if (crimeLevel == 'high')
                  TweenAnimationBuilder<double>(
                    duration: const Duration(
                      seconds: 1,
                    ),
                    tween: Tween(
                      begin: 0.0,
                      end: 1.0,
                    ),
                    builder: (
                      context,
                      value,
                      child,
                    ) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          -5 *
                              math.sin(
                                value *
                                    2 *
                                    math.pi,
                              ),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.red
                              .withOpacity(
                                0.7 + 0.3 * value,
                              ),
                          size: 24.sp,
                        ),
                      );
                    },
                  ),

                // العلامة الرئيسية
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: _getCrimeLevelColor(
                      crimeLevel,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _getCrimeLevelColor(
                              crimeLevel,
                            ).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCrimeLevelIcon(
                          crimeLevel,
                        ),
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      Text(
                        reportCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  String _getCrimeLevel(int reportCount) {
    if (reportCount >= 20) return 'high';
    if (reportCount >= 10) return 'medium';
    if (reportCount >= 5) return 'low';
    return 'safe';
  }

  Color _getCrimeLevelColor(String level) {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow[700] ??
            Colors.yellow;
      case 'safe':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCrimeLevelIcon(String level) {
    switch (level) {
      case 'high':
        return Icons.dangerous;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      case 'safe':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  void _showGovernorateDetails(
    String governorate,
    List<dynamic> reports,
  ) {
    final crimeStats = _analyzeCrimeTypes(
      reports,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder:
          (context) => Container(
            height:
                MediaQuery.of(
                  context,
                ).size.height *
                0.7,
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // مقبض السحب
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(
                      bottom: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          BorderRadius.circular(
                            2.r,
                          ),
                    ),
                  ),
                ),

                // عنوان المحافظة
                Text(
                  'إحصائيات $governorate',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 16.h),

                // إجمالي البلاغات
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.report,
                        color: Colors.blue,
                        size: 32.sp,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'إجمالي البلاغات',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color:
                                  Colors
                                      .grey[600],
                            ),
                          ),
                          Text(
                            '${reports.length}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // إحصائيات أنواع الجرائم
                Text(
                  'توزيع أنواع الجرائم',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 12.h),

                Expanded(
                  child: ListView.builder(
                    itemCount:
                        crimeStats.entries.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final entry = crimeStats
                          .entries
                          .elementAt(index);
                      final percentage =
                          (entry.value /
                                  reports.length *
                                  100)
                              .round();

                      return Container(
                        margin: EdgeInsets.only(
                          bottom: 8.h,
                        ),
                        padding: EdgeInsets.all(
                          12.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius:
                              BorderRadius.circular(
                                8.r,
                              ),
                          border: Border.all(
                            color:
                                Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getCrimeTypeIcon(
                                entry.key,
                              ),
                              color:
                                  _getCrimeTypeColor(
                                    entry.key,
                                  ),
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize:
                                          14.sp,
                                      fontWeight:
                                          FontWeight
                                              .w500,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value} بلاغ ($percentage%)',
                                    style: TextStyle(
                                      fontSize:
                                          12.sp,
                                      color:
                                          Colors
                                              .grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  EdgeInsets.symmetric(
                                    horizontal:
                                        8.w,
                                    vertical: 4.h,
                                  ),
                              decoration: BoxDecoration(
                                color:
                                    _getCrimeTypeColor(
                                      entry.key,
                                    ).withOpacity(
                                      0.2,
                                    ),
                                borderRadius:
                                    BorderRadius.circular(
                                      12.r,
                                    ),
                              ),
                              child: Text(
                                entry.value
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      _getCrimeTypeColor(
                                        entry.key,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  List<Widget> _buildHeatmapLayers(
    List<dynamic> reports,
  ) {
    // للحفاظ على التوافق مع الكود القديم
    return _buildEnhancedHeatmapLayers(reports);
  }

  Widget _buildCurrentLocationLayer(
    LatLng currentLocation,
  ) {
    return MarkerLayer(
      markers: [
        Marker(
          point: currentLocation,
          width: 60.w,
          height: 60.h,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(
                    0.3,
                  ),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double _calculateRadius(int reportCount) {
    if (reportCount >= 10) return 50.0;
    if (reportCount >= 5) return 35.0;
    return 25.0;
  }

  Color _getCrimeColor(int reportCount) {
    if (reportCount >= 10) return Colors.red;
    if (reportCount >= 5) return Colors.orange;
    return Colors.green;
  }

  void _handleMapTap(
    LatLng point,
    HeatmapState state,
  ) {
    if (state is HeatmapLoaded) {
      // البحث عن تقارير قريبة من النقطة المحددة
      final nearbyReports =
          state.reports.where((report) {
            final distance = _calculateDistance(
              point.latitude,
              point.longitude,
              report.location.latitude,
              report.location.longitude,
            );
            return distance <=
                5000; // ضمن دائرة نصف قطرها 5 كم
          }).toList();

      if (nearbyReports.isNotEmpty) {
        _showEnhancedAreaDetails(
          nearbyReports,
          _analyzeCrimeTypes(nearbyReports),
        );
      }
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // متر
    final double dLat =
        (lat2 - lat1) * (math.pi / 180);
    final double dLon =
        (lon2 - lon1) * (math.pi / 180);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c =
        2 *
        math.atan2(
          math.sqrt(a),
          math.sqrt(1 - a),
        );
    return earthRadius * c;
  }

  void _showEnhancedAreaDetails(
    List<dynamic> reports,
    Map<String, int> crimeTypeStats,
  ) {
    final totalReports = reports.length;
    final location =
        reports.first.governorate ?? 'غير محدد';
    final city = reports.first.city ?? 'غير محدد';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder:
          (context) => Container(
            height:
                MediaQuery.of(
                  context,
                ).size.height *
                0.6,
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // مقبض السحب
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(
                      bottom: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          BorderRadius.circular(
                            2.r,
                          ),
                    ),
                  ),
                ),

                // عنوان المنطقة
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        12.w,
                      ),
                      decoration: BoxDecoration(
                        color: _getCrimeColor(
                          totalReports,
                        ).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(
                              12.r,
                            ),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: _getCrimeColor(
                          totalReports,
                        ),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'تفاصيل المنطقة',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$location - $city',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color:
                                  Colors
                                      .grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // إجمالي التقارير
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCrimeColor(
                          totalReports,
                        ).withOpacity(0.1),
                        _getCrimeColor(
                          totalReports,
                        ).withOpacity(0.05),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                    border: Border.all(
                      color: _getCrimeColor(
                        totalReports,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'إجمالي التقارير: ',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                      Text(
                        totalReports.toString(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight:
                              FontWeight.bold,
                          color: _getCrimeColor(
                            totalReports,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // أنواع الجرائم
                Text(
                  'توزيع أنواع الجرائم',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 12.h),

                // قائمة أنواع الجرائم
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        crimeTypeStats.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final entry = crimeTypeStats
                          .entries
                          .elementAt(index);
                      final crimeType = entry.key;
                      final count = entry.value;
                      final percentage =
                          (count /
                                  totalReports *
                                  100)
                              .round();

                      return Container(
                        margin: EdgeInsets.only(
                          bottom: 8.h,
                        ),
                        padding: EdgeInsets.all(
                          12.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius:
                              BorderRadius.circular(
                                8.r,
                              ),
                          border: Border.all(
                            color:
                                Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                color:
                                    _getCrimeTypeColor(
                                      crimeType,
                                    ).withOpacity(
                                      0.2,
                                    ),
                                borderRadius:
                                    BorderRadius.circular(
                                      6.r,
                                    ),
                              ),
                              child: Icon(
                                _getCrimeTypeIcon(
                                  crimeType,
                                ),
                                size: 16.sp,
                                color:
                                    _getCrimeTypeColor(
                                      crimeType,
                                    ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    crimeType,
                                    style: TextStyle(
                                      fontSize:
                                          14.sp,
                                      fontWeight:
                                          FontWeight
                                              .w500,
                                    ),
                                  ),
                                  Text(
                                    '$count حالة ($percentage%)',
                                    style: TextStyle(
                                      fontSize:
                                          12.sp,
                                      color:
                                          Colors
                                              .grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // شريط التقدم
                            Container(
                              width: 60.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color:
                                    Colors
                                        .grey[200],
                                borderRadius:
                                    BorderRadius.circular(
                                      3.r,
                                    ),
                              ),
                              child: FractionallySizedBox(
                                widthFactor:
                                    count /
                                    totalReports,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _getCrimeTypeColor(
                                          crimeType,
                                        ),
                                    borderRadius:
                                        BorderRadius.circular(
                                          3.r,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                // زر إغلاق
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.pop(
                          context,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey[100],
                      foregroundColor:
                          Colors.grey[700],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              12.r,
                            ),
                      ),
                    ),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
