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

                // طبقة النقاط الحرارية
                if (state is HeatmapLoaded)
                  ..._buildHeatmapLayers(
                    state.reports,
                  ),
                if (state is HeatmapReportsLoaded)
                  ..._buildHeatmapLayers(
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

  List<Widget> _buildHeatmapLayers(
    List<dynamic> reports,
  ) {
    List<Widget> layers = [];

    // طبقة الدوائر الحرارية
    List<CircleMarker> heatCircles = [];
    List<Marker> reportMarkers = [];

    // تجميع التقارير حسب المنطقة لإنشاء الخريطة الحرارية
    Map<String, List<dynamic>> areaReports = {};
    for (final report in reports) {
      final key =
          '${report.location.latitude.toStringAsFixed(2)},${report.location.longitude.toStringAsFixed(2)}';
      areaReports
          .putIfAbsent(key, () => [])
          .add(report);
    }

    // إنشاء الدوائر الحرارية والعلامات
    for (final entry in areaReports.entries) {
      final reportsInArea = entry.value;
      final location =
          reportsInArea.first.location;
      final intensity = reportsInArea.length;

      // دائرة حرارية
      heatCircles.add(
        CircleMarker(
          point: location,
          radius: _calculateRadius(intensity),
          color: _getCrimeColor(
            intensity,
          ).withOpacity(0.3),
          borderColor: _getCrimeColor(intensity),
          borderStrokeWidth: 2,
        ),
      );

      // علامة للمنطقة
      reportMarkers.add(
        Marker(
          point: location,
          width: 40.w,
          height: 40.h,
          child: GestureDetector(
            onTap:
                () => _showAreaDetails(
                  reportsInArea,
                ),
            child: Container(
              decoration: BoxDecoration(
                color: _getCrimeColor(intensity),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getCrimeColor(
                      intensity,
                    ).withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  intensity.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
    // يمكن إضافة منطق للتعامل مع النقر على الخريطة
    print(
      'Tapped at: ${point.latitude}, ${point.longitude}',
    );
  }

  void _showAreaDetails(List<dynamic> reports) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder:
          (context) => Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل المنطقة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'عدد التقارير: ${reports.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'المحافظة: ${reports.first.governorate}',
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'المدينة: ${reports.first.city}',
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'أنواع التقارير:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                ...reports
                    .take(5)
                    .map(
                      (report) => Padding(
                        padding:
                            EdgeInsets.symmetric(
                              vertical: 2.h,
                            ),
                        child: Text(
                          '• ${report.reportType}',
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                if (reports.length > 5)
                  Text(
                    'و ${reports.length - 5} تقارير أخرى...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}
