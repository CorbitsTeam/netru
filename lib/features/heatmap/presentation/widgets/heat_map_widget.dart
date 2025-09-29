import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../cubit/heatmap_cubit.dart';
import '../cubit/heatmap_state.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/heatmap_entity.dart';
import 'report_marker_widget.dart';
import 'clustered_report_marker_widget.dart';
import '../helpers/report_marker_helper.dart';

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
    List<Marker> singleReportMarkers = [];

    // تجميع التقارير في مجموعات بناءً على القرب الجغرافي
    List<ReportCluster> clusters =
        _clusterNearbyReports(reports);

    // إنشاء الدوائر الحرارية والعلامات المحسنة باستخدام المجموعات
    for (final cluster in clusters) {
      final location = cluster.centerLocation;
      final intensity = cluster.reportCount;
      final reportsInCluster = cluster.reports;

      // تحليل أنواع الجرائم في المجموعة
      final crimeTypeStats = _analyzeCrimeTypes(
        reportsInCluster,
      );

      // احصل على أعلى أولوية في المجموعة
      final highestPriority = _getHighestPriority(reportsInCluster);
      final priorityColor = ReportMarkerHelper.getPriorityColor(highestPriority);

      // دائرة شفافة بسيطة
      final baseRadius = _calculateClusterRadius(
        intensity,
      );

      // ===== تحسين مظهر الدوائر الحرارية =====

      // الطبقة الخارجية - دائرة كبيرة جداً شفافة للتأثير
      if (intensity >= 5) {
        heatCircles.add(
          CircleMarker(
            point: location,
            radius: baseRadius * 2.2,
            color: priorityColor.withValues(alpha: 0.02),
            borderStrokeWidth: 0,
          ),
        );
      }

      // الطبقة الوسطى - دائرة متوسطة
      heatCircles.add(
        CircleMarker(
          point: location,
          radius: baseRadius * 1.4,
          color: priorityColor.withValues(alpha: 0.04),
          borderColor: priorityColor.withValues(alpha: 0.08),
          borderStrokeWidth: 1,
        ),
      );

      // الطبقة الداخلية - دائرة أساسية مع حدود واضحة
      heatCircles.add(
        CircleMarker(
          point: location,
          radius: baseRadius,
          color: priorityColor.withValues(alpha: 0.08),
          borderColor: priorityColor.withValues(alpha: 0.25),
          borderStrokeWidth: 2,
        ),
      );

      // دائرة إضافية للتقارير عالية الأولوية
      if (highestPriority == 'urgent') {
        heatCircles.add(
          CircleMarker(
            point: location,
            radius: baseRadius * 0.6,
            color: priorityColor.withValues(alpha: 0.15),
            borderColor: priorityColor.withValues(alpha: 0.35),
            borderStrokeWidth: 1.5,
          ),
        );
      }

      // Use appropriate marker based on cluster size
      if (intensity == 1) {
        // Single report - use individual marker
        final report = reportsInCluster.first;
        singleReportMarkers.add(
          Marker(
            point: location,
            width: 40.w,
            height: 40.h,
            child: ReportMarkerWidget(
              report: report,
              onTap: () => _showEnhancedAreaDetails(
                reportsInCluster,
                crimeTypeStats,
              ),
              showPulseAnimation: ReportMarkerHelper.shouldShowPulse(
                report.priority,
              ),
            ),
          ),
        );
      } else {
        // Multiple reports - use cluster marker
        // Cast to proper type for ClusteredReportMarkerWidget
        final List<ReportLocationEntity> typedReports =
            reportsInCluster.cast<ReportLocationEntity>();

        reportMarkers.add(
          Marker(
            point: location,
            width: _getMarkerSize(intensity),
            height: _getMarkerSize(intensity),
            child: ClusteredReportMarkerWidget(
              reports: typedReports,
              onTap: () => _showEnhancedAreaDetails(
                reportsInCluster,
                crimeTypeStats,
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
    if (reportMarkers.isNotEmpty) {
      layers.add(
        MarkerLayer(markers: reportMarkers),
      );
    }
    if (singleReportMarkers.isNotEmpty) {
      layers.add(
        MarkerLayer(markers: singleReportMarkers),
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
                  color: Colors.blue.withValues(
                    alpha: 0.3,
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

  Color _getCrimeColor(int reportCount) {
    if (reportCount >= 10) {
      return Colors.red.withValues(alpha: 0.7);
    }
    if (reportCount >= 5) {
      return Colors.orange.withValues(alpha: 0.7);
    }
    return Colors.green.withValues(alpha: 0.7);
  }

  /// حساب نصف قطر الدائرة للمجموعة
  double _calculateClusterRadius(
    int reportCount,
  ) {
    if (reportCount >= 20) return 70.0;
    if (reportCount >= 10) return 55.0;
    if (reportCount >= 5) return 40.0;
    return 25.0;
  }


  /// حساب حجم العلامة
  double _getMarkerSize(int reportCount) {
    if (reportCount >= 20) return 60.w;
    if (reportCount >= 10) return 52.w;
    if (reportCount >= 5) return 46.w;
    return 40.w;
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
                        ).withValues(alpha: 0.1),
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
                        ).withValues(alpha: 0.1),
                        _getCrimeColor(
                          totalReports,
                        ).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                    border: Border.all(
                      color: _getCrimeColor(
                        totalReports,
                      ).withValues(alpha: 0.3),
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
                                    ).withValues(
                                      alpha: 0.2,
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

  /// Get highest priority from a list of reports
  String _getHighestPriority(List<dynamic> reports) {
    if (reports.any((r) => r.priority == 'urgent')) return 'urgent';
    if (reports.any((r) => r.priority == 'high')) return 'high';
    if (reports.any((r) => r.priority == 'medium')) return 'medium';
    return 'low';
  }

  /// تجميع التقارير المتقاربة جغرافياً في مجموعات
  List<ReportCluster> _clusterNearbyReports(
    List<dynamic> reports,
  ) {
    List<ReportCluster> clusters = [];
    List<bool> processed = List.filled(
      reports.length,
      false,
    );

    for (int i = 0; i < reports.length; i++) {
      if (processed[i]) continue;

      final mainReport = reports[i];
      List<dynamic> clusterReports = [mainReport];
      processed[i] = true;

      // البحث عن التقارير القريبة
      for (
        int j = i + 1;
        j < reports.length;
        j++
      ) {
        if (processed[j]) continue;

        final otherReport = reports[j];
        final distance = _calculateDistance(
          mainReport.location.latitude,
          mainReport.location.longitude,
          otherReport.location.latitude,
          otherReport.location.longitude,
        );

        // إذا كانت المسافة أقل من نصف كيلومتر، أضفها للمجموعة
        if (distance <= 500) {
          clusterReports.add(otherReport);
          processed[j] = true;
        }
      }

      // حساب المركز الجغرافي للمجموعة
      double avgLat = 0;
      double avgLng = 0;
      for (final report in clusterReports) {
        avgLat += report.location.latitude;
        avgLng += report.location.longitude;
      }
      avgLat /= clusterReports.length;
      avgLng /= clusterReports.length;

      clusters.add(
        ReportCluster(
          centerLocation: LatLng(avgLat, avgLng),
          reports: clusterReports,
          reportCount: clusterReports.length,
        ),
      );
    }

    return clusters;
  }
}

/// فئة لتمثيل مجموعة من التقارير المتقاربة جغرافياً
class ReportCluster {
  final LatLng centerLocation;
  final List<dynamic> reports;
  final int reportCount;

  ReportCluster({
    required this.centerLocation,
    required this.reports,
    required this.reportCount,
  });
}
