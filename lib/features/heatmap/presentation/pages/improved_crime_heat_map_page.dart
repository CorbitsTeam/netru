import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/heat_map_widget.dart';
import '../widgets/crime_legend_widget.dart';
import '../widgets/location_permission_dialog.dart';
import '../cubit/heatmap_cubit.dart';
import '../cubit/heatmap_state.dart';
import '../../../../core/services/location_service.dart';

class ImprovedCrimeHeatMapPage
    extends StatefulWidget {
  const ImprovedCrimeHeatMapPage({super.key});

  @override
  State<ImprovedCrimeHeatMapPage> createState() =>
      _ImprovedCrimeHeatMapPageState();
}

class _ImprovedCrimeHeatMapPageState
    extends State<ImprovedCrimeHeatMapPage> {
  final LocationService _locationService =
      LocationService();
  bool _isLoadingLocation = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    // تحميل بيانات الخريطة الحرارية
    context
        .read<HeatmapCubit>()
        .loadHeatmapData();
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _locationError = null;
      });

      final hasPermission =
          await _locationService
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

      final location =
          await _locationService
              .getCurrentLocation();
      if (location != null) {
        setState(() {
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _locationError =
              'فشل في تحديد الموقع الحالي';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationError =
            'خطأ في تحديد الموقع: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  Future<bool>
  _showLocationPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) =>
                  const LocationPermissionDialog(),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocListener<
        HeatmapCubit,
        HeatmapState
      >(
        listener: (context, state) {
          if (state is HeatmapFailure) {
            // طباعة الخطأ في الكونسول
            print(
              '🔴 HeatMap Error: ${state.error}',
            );
            debugPrint(
              '📍 HeatMap Error Details: ${state.error}',
            );

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior:
                    SnackBarBehavior.floating,
                duration: const Duration(
                  seconds: 5,
                ),
                action: SnackBarAction(
                  label: 'إعادة المحاولة',
                  textColor: Colors.white,
                  onPressed: () {
                    context
                        .read<HeatmapCubit>()
                        .loadHeatmapData();
                  },
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // شريط البحث
              Container(
                padding: EdgeInsets.all(14.w),
                child:
                    _buildSearchBarWithFilter(),
              ),

              // الخريطة
              Container(
                height: 400.h,
                margin: EdgeInsets.symmetric(
                  horizontal: 14.w,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12.r),
                  child: Stack(
                    children: [
                      _buildMapContent(),
                    ],
                  ),
                ),
              ),

              // إحصائيات سريعة
              BlocBuilder<
                HeatmapCubit,
                HeatmapState
              >(
                builder: (context, state) {
                  if (state is HeatmapLoaded) {
                    return _buildQuickStats(
                      state.statistics,
                    );
                  } else if (state
                      is HeatmapGovernorateFilterApplied) {
                    return _buildGovernorateStats(
                      state,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // زر الموقع الحالي
          FloatingActionButton(
            heroTag: "location",
            mini: true,
            onPressed: () {
              print(
                '📍 Getting current location...',
              );
              _initializeLocation();
            },
            backgroundColor:
                Theme.of(context).primaryColor,
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor:
          Theme.of(
            context,
          ).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        'heatMap'.tr(),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildMapContent() {
    if (_isLoadingLocation) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'جاري تحديد الموقع...',
              style: TextStyle(fontSize: 14.sp),
            ),
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
              size: 48.w,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              _locationError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16.h),
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

  Widget _buildSearchBarWithFilter() {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          // أيقونة البحث
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 24.sp,
            ),
          ),

          // حقل البحث
          Expanded(
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText:
                    'ابحث عن منطقة أو عنوان...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 16.w,
                    ),
              ),
              onChanged: (value) {
                print('🔍 Search query: $value');
                // يمكن إضافة منطق البحث هنا
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(dynamic statistics) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color:
            Theme.of(
              context,
            ).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات سريعة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'إجمالي التقارير',
                  statistics?.totalReports
                          ?.toString() ??
                      '0',
                  Icons.report,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'قيد المراجعة',
                  statistics?.pendingReports
                          ?.toString() ??
                      '0',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'تم الحل',
                  statistics?.resolvedReports
                          ?.toString() ??
                      '0',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'الأكثر شيوعاً',
                  statistics?.mostCommonType ??
                      'غير متاح',
                  Icons.trending_up,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGovernorateStats(
    HeatmapGovernorateFilterApplied state,
  ) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color:
            Theme.of(
              context,
            ).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color:
                    Theme.of(
                      context,
                    ).primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                'نتائج مصفاة: ${state.selectedGovernorate}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(
                        context,
                      ).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildStatItem(
            'عدد التقارير',
            state.filteredReports.length
                .toString(),
            Icons.location_on,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.w,
                color: color,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
