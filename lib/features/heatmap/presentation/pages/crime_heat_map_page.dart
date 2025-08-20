import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/heat_map_widget.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/crime_legend_widget.dart';
import '../widgets/location_permission_dialog.dart';
import '../../../../core/services/location_service.dart';

class CrimeHeatMapPage extends StatefulWidget {
  const CrimeHeatMapPage({super.key});

  @override
  State<CrimeHeatMapPage> createState() =>
      _CrimeHeatMapPageState();
}

class _CrimeHeatMapPageState
    extends State<CrimeHeatMapPage> {
  final LocationService _locationService =
      LocationService();
  bool _isLoadingLocation = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _locationError = null;
      });

      final hasPermission = await _locationService
          .checkLocationPermission();

      if (!hasPermission) {
        final granted =
            await _showLocationPermissionDialog();
        if (!granted) {
          setState(() {
            _locationError =
                'يجب السماح بالوصول للموقع لعرض الخريطة';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      await _locationService.getCurrentLocation();
    } catch (e) {
      setState(() {
        _locationError =
            'حدث خطأ في الحصول على الموقع: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<bool>
      _showLocationPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const LocationPermissionDialog(),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(8),
              child: const MapSearchBar(),
            ),
            // الخريطة
            Expanded(
              child: _buildMapContent(),
            ),
            // مفتاح الألوان
            SizedBox(
              height: 250.h,
              child: const CrimeLegendWidget(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        'heatMap'.tr(),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _initializeLocation,
          icon: const Icon(
            Icons.my_location,
          ),
        ),
      ],
    );
  }

  Widget _buildMapContent() {
    if (_isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحديد الموقع...'),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _locationError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeLocation,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return const HeatMapWidget();
  }
}
