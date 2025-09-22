import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../cubit/heatmap_cubit.dart';
import '../cubit/heatmap_state.dart';
import '../../../../core/services/location_service.dart';

class RealTimeHeatMapWidget
    extends StatefulWidget {
  const RealTimeHeatMapWidget({super.key});

  @override
  State<RealTimeHeatMapWidget> createState() =>
      _RealTimeHeatMapWidgetState();
}

class _RealTimeHeatMapWidgetState
    extends State<RealTimeHeatMapWidget>
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
        List<Widget> layers = [
          // الطبقة الأساسية للخريطة
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.netru_app',
            maxZoom: 18,
          ),
        ];

        // إضافة النقاط الحرارية حسب حالة البيانات
        if (state is HeatmapLoaded) {
          layers.addAll(
            _buildHeatmapLayers(state.reports),
          );
        } else if (state
            is HeatmapReportsLoaded) {
          layers.addAll(
            _buildHeatmapLayers(state.reports),
          );
        } else if (state
            is HeatmapGovernorateFilterApplied) {
          layers.addAll(
            _buildHeatmapLayers(
              state.filteredReports,
            ),
          );
        }

        // طبقة الموقع الحالي
        layers.add(
          _buildCurrentLocationLayer(
            currentLocation,
          ),
        );

        return Stack(
          children: [
            // الخريطة الرئيسية
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 11.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                onTap: (tapPosition, point) {
                  _handleMapTap(point, state);
                },
              ),
              children: layers,
            ),

            // مؤشر التحميل
            if (state is HeatmapLoading)
              Container(
                color: Colors.black.withOpacity(
                  0.3,
                ),
                child: const Center(
                  child:
                      CircularProgressIndicator(),
                ),
              ),

            // رسالة الخطأ
            if (state is HeatmapFailure)
              Container(
                color: Colors.black.withOpacity(
                  0.3,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48.w,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'خطأ في تحميل البيانات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<
                                HeatmapCubit
                              >()
                              .refreshData();
                        },
                        child: const Text(
                          'إعادة المحاولة',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // عداد التقارير
            _buildReportCounter(state),
          ],
        );
      },
    );
  }

  List<Widget> _buildHeatmapLayers(
    List<dynamic> reports,
  ) {
    List<Widget> layers = [];

    // طبقة الدوائر الحرارية
    List<CircleMarker> heatCircles = [];
    List<Marker> reportMarkers = [];

    for (final report in reports) {
      final location = report.location;
      final reportCount = _getReportSeverityLevel(
        report,
      );

      // إضافة دائرة حرارية
      heatCircles.add(
        CircleMarker(
          point: location,
          radius: _calculateRadius(reportCount),
          color: _getCrimeColor(
            reportCount,
          ).withOpacity(0.3),
          borderColor: _getCrimeColor(
            reportCount,
          ),
          borderStrokeWidth: 1,
        ),
      );

      // إضافة علامة للتقرير
      reportMarkers.add(
        Marker(
          point: location,
          width: 30.w,
          height: 30.h,
          child: GestureDetector(
            onTap:
                () => _showReportDetails(report),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      1.0 +
                      (0.1 *
                          _animationController
                              .value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getCrimeColor(
                        reportCount,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getCrimeColor(
                            reportCount,
                          ).withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getReportIcon(
                        report.reportType,
                      ),
                      color: Colors.white,
                      size: 16.w,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // إضافة الطبقات
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

    return layers;
  }

  Widget _buildCurrentLocationLayer(
    LatLng currentLocation,
  ) {
    return MarkerLayer(
      markers: [
        Marker(
          point: currentLocation,
          width: 40.w,
          height: 40.h,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(
                    0.3,
                  ),
                  spreadRadius: 3,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              Icons.my_location,
              color: Colors.white,
              size: 20.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCounter(HeatmapState state) {
    int reportCount = 0;
    if (state is HeatmapLoaded) {
      reportCount = state.reports.length;
    } else if (state is HeatmapReportsLoaded) {
      reportCount = state.reports.length;
    } else if (state
        is HeatmapGovernorateFilterApplied) {
      reportCount = state.filteredReports.length;
    }

    return Positioned(
      top: 16.h,
      left: 16.w,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            20.r,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.1,
              ),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              color: Colors.red,
              size: 16.w,
            ),
            SizedBox(width: 4.w),
            Text(
              '$reportCount تقرير',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateRadius(int severity) {
    switch (severity) {
      case 3:
        return 3000.0; // خطير
      case 2:
        return 2000.0; // متوسط
      case 1:
        return 1000.0; // منخفض
      default:
        return 1000.0;
    }
  }

  Color _getCrimeColor(int severity) {
    switch (severity) {
      case 3:
        return Colors.red; // خطير
      case 2:
        return Colors.orange; // متوسط
      case 1:
        return Colors.green; // منخفض
      default:
        return Colors.grey;
    }
  }

  int _getReportSeverityLevel(dynamic report) {
    // تحديد مستوى الخطورة بناءً على نوع التقرير أو الأولوية
    switch (report.priority) {
      case 'urgent':
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 2;
    }
  }

  IconData _getReportIcon(String reportType) {
    // تحديد الأيقونة بناءً على نوع التقرير
    if (reportType.contains('سرقة') ||
        reportType.contains('theft')) {
      return Icons.security;
    } else if (reportType.contains('اعتداء') ||
        reportType.contains('assault')) {
      return Icons.warning;
    } else if (reportType.contains('حادث') ||
        reportType.contains('accident')) {
      return Icons.car_crash;
    } else if (reportType.contains('مخدرات') ||
        reportType.contains('drugs')) {
      return Icons.local_pharmacy;
    } else {
      return Icons.report_problem;
    }
  }

  void _handleMapTap(
    LatLng point,
    HeatmapState state,
  ) {
    // يمكن إضافة منطق للتعامل مع النقر على الخريطة
    // مثل إضافة نقطة جديدة أو عرض معلومات المنطقة
  }

  void _showReportDetails(dynamic report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder:
                (
                  context,
                  scrollController,
                ) => Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(
                          top: Radius.circular(
                            20.r,
                          ),
                        ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // مقبض السحب
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color:
                                Colors.grey[300],
                            borderRadius:
                                BorderRadius.circular(
                                  2.r,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // عنوان التقرير
                      Row(
                        children: [
                          Container(
                            padding:
                                EdgeInsets.all(
                                  8.w,
                                ),
                            decoration: BoxDecoration(
                              color: _getCrimeColor(
                                _getReportSeverityLevel(
                                  report,
                                ),
                              ).withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(
                                    8.r,
                                  ),
                            ),
                            child: Icon(
                              _getReportIcon(
                                report.reportType,
                              ),
                              color: _getCrimeColor(
                                _getReportSeverityLevel(
                                  report,
                                ),
                              ),
                              size: 24.w,
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
                                  report
                                      .reportType,
                                  style: TextStyle(
                                    fontSize:
                                        18.sp,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                Text(
                                  '${report.governorate} - ${report.city}',
                                  style: TextStyle(
                                    fontSize:
                                        14.sp,
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
                      SizedBox(height: 20.h),

                      // تفاصيل التقرير
                      _buildDetailRow(
                        'الحالة',
                        _getStatusText(
                          report.status,
                        ),
                        _getStatusColor(
                          report.status,
                        ),
                      ),
                      _buildDetailRow(
                        'الأولوية',
                        _getPriorityText(
                          report.priority,
                        ),
                        _getPriorityColor(
                          report.priority,
                        ),
                      ),
                      _buildDetailRow(
                        'تاريخ التقرير',
                        _formatDate(
                          report.reportDate,
                        ),
                        Colors.grey[700]!,
                      ),
                      _buildDetailRow(
                        'العنوان',
                        report.address,
                        Colors.grey[700]!,
                      ),

                      SizedBox(height: 20.h),

                      // إحداثيات الموقع
                      Container(
                        padding: EdgeInsets.all(
                          16.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius:
                              BorderRadius.circular(
                                8.r,
                              ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'الإحداثيات',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'خط العرض: ${report.location.latitude.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              'خط الطول: ${report.location.longitude.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // أزرار الإجراءات
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                                _centerMapOnReport(
                                  report,
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .center_focus_strong,
                              ),
                              label: const Text(
                                'توسيط الخريطة',
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                                // يمكن إضافة المزيد من التفاصيل
                              },
                              icon: const Icon(
                                Icons
                                    .info_outline,
                              ),
                              label: const Text(
                                'المزيد',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.h,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _centerMapOnReport(dynamic report) {
    _mapController.move(report.location, 15.0);
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'under_investigation':
        return 'قيد التحقيق';
      case 'resolved':
        return 'تم الحل';
      case 'closed':
        return 'مغلق';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_investigation':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'عالي';
      case 'medium':
        return 'متوسط';
      case 'low':
        return 'منخفض';
      default:
        return priority;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
