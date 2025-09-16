import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:netru_app/features/heatmap/data/model/crime_data_model.dart';
import '../../../../core/services/location_service.dart';

class HeatMapWidget extends StatefulWidget {
  const HeatMapWidget({super.key});

  @override
  State<HeatMapWidget> createState() => _HeatMapWidgetState();
}

class _HeatMapWidgetState extends State<HeatMapWidget>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  late AnimationController _animationController;

  // بيانات الجرائم التجريبية مع أسماء المدن المصرية
  final List<CrimeDataModel> _crimeData = [
    CrimeDataModel(
      location: const LatLng(30.0626, 31.2497),
      crimeCount: 45,
      area: 'وسط القاهرة',
      description: 'منطقة عالية الخطورة',
    ),
    CrimeDataModel(
      location: const LatLng(30.0131, 31.2089),
      crimeCount: 23,
      area: 'حي الجيزة',
      description: 'منطقة متوسطة الخطورة',
    ),
    CrimeDataModel(
      location: const LatLng(31.2001, 29.9187),
      crimeCount: 8,
      area: 'ميناء الاسكندرية',
      description: 'منطقة آمنة',
    ),
    CrimeDataModel(
      location: const LatLng(30.1218, 31.2456),
      crimeCount: 38,
      area: 'شبرا الخيمة',
      description: 'منطقة كثافة عالية من الحوادث',
    ),
    CrimeDataModel(
      location: const LatLng(30.0616, 31.3381),
      crimeCount: 18,
      area: 'مدينة نصر',
      description: 'منطقة متوسطة الأمان',
    ),
    CrimeDataModel(
      location: const LatLng(29.9601, 31.2565),
      crimeCount: 5,
      area: 'المعادي',
      description: 'منطقة سكنية آمنة',
    ),
    CrimeDataModel(
      location: const LatLng(24.0889, 32.8998),
      crimeCount: 12,
      area: 'أسوان',
      description: 'منطقة سياحية آمنة نسبياً',
    ),
    CrimeDataModel(
      location: const LatLng(25.6872, 32.6396),
      crimeCount: 15,
      area: 'الأقصر',
      description: 'منطقة أثرية متوسطة الأمان',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToCurrentLocation();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _moveToCurrentLocation() {
    final currentLocation = _locationService.currentLocation;
    if (currentLocation != null) {
      _mapController.move(currentLocation, 11.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation =
        _locationService.currentLocation ?? const LatLng(30.0444, 31.2357);

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
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.netru_app',
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: currentLocation,
                  radius: 100,
                  color: Colors.blue.withOpacity(0.1),
                  borderColor: Colors.blue.withOpacity(0.3),
                  borderStrokeWidth: 1,
                  useRadiusInMeter: true,
                ),
              ],
            ),
            CircleLayer(
              circles:
                  _crimeData
                      .map(
                        (crime) => CircleMarker(
                          point: crime.location,
                          radius: _calculateRadius(crime.crimeCount),
                          color: _getCrimeColor(
                            crime.crimeCount,
                          ).withOpacity(0.6),
                          borderColor: _getCrimeColor(crime.crimeCount),
                          borderStrokeWidth: 2,
                          useRadiusInMeter: true,
                        ),
                      )
                      .toList(),
            ),
            MarkerLayer(
              markers:
                  _crimeData
                      .map(
                        (crime) => Marker(
                          point: crime.location,
                          width: 120,
                          height: 60,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  crime.area,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getCrimeColor(crime.crimeCount),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => _showCrimeDetails(crime),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _getCrimeColor(crime.crimeCount),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getCrimeColor(
                                          crime.crimeCount,
                                        ).withOpacity(0.4),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${crime.crimeCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: currentLocation,
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // زر إعادة توسيط الخريطة
        // Positioned(
        //   bottom: 20,
        //   right: 20,
        //   child: FloatingActionButton(
        //     onPressed: _moveToCurrentLocation,
        //     backgroundColor: Colors.blue,
        //     elevation: 8,
        //     child: const Icon(Icons.my_location,
        //         color: Colors.white),
        //   ),
        // ),

        // أزرار الزووم
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "zoomIn",
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                },
                child: const Icon(Icons.add, color: Colors.black),
              ),
              SizedBox(height: 5.h),
              FloatingActionButton(
                heroTag: "zoomOut",
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                },
                child: const Icon(Icons.remove, color: Colors.black),
              ),
            ],
          ),
        ),

        // معلومات الموقع الحالي
        // Positioned(
        //   top: 20,
        //   left: 20,
        //   right: 20,
        //   child: Container(
        //     padding: const EdgeInsets.all(12),
        //     decoration: BoxDecoration(
        //       color:
        //           Colors.white.withOpacity(0.9),
        //       borderRadius:
        //           BorderRadius.circular(12),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black
        //               .withOpacity(0.1),
        //           blurRadius: 6,
        //           offset: const Offset(0, 2),
        //         ),
        //       ],
        //     ),
        //     child: Row(
        //       children: [
        //         Container(
        //           width: 12,
        //           height: 12,
        //           decoration: const BoxDecoration(
        //             color: Colors.blue,
        //             shape: BoxShape.circle,
        //           ),
        //         ),
        //         const SizedBox(width: 8),
        //         const Text(
        //           'موقعك الحالي',
        //           style: TextStyle(
        //             fontSize: 14,
        //             fontWeight: FontWeight.w600,
        //             color: Colors.black87,
        //           ),
        //         ),
        //         const Spacer(),
        //         Text(
        //           'دقة: 100م',
        //           style: TextStyle(
        //             fontSize: 12,
        //             color: Colors.grey[600],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  double _calculateRadius(int crimeCount) {
    if (crimeCount >= 30) return 3000.0;
    if (crimeCount >= 15) return 2000.0;
    return 1000.0;
  }

  Color _getCrimeColor(int crimeCount) {
    if (crimeCount >= 30) return Colors.red;
    if (crimeCount >= 15) return Colors.orange;
    return Colors.green;
  }

  void _showCrimeDetails(CrimeDataModel crime) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCrimeColor(crime.crimeCount),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        crime.area,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  crime.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCrimeColor(crime.crimeCount).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: _getCrimeColor(crime.crimeCount),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مستوى الكثافة: ${crime.crimeCount}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getCrimeColor(crime.crimeCount),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getCrimeColor(crime.crimeCount),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
