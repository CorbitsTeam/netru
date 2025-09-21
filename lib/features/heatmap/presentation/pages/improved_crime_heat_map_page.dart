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

class ImprovedCrimeHeatMapPage extends StatefulWidget {
  const ImprovedCrimeHeatMapPage({super.key});

  @override
  State<ImprovedCrimeHeatMapPage> createState() =>
      _ImprovedCrimeHeatMapPageState();
}

class _ImprovedCrimeHeatMapPageState extends State<ImprovedCrimeHeatMapPage> {
  final LocationService _locationService = LocationService();
  bool _isLoadingLocation = true;
  String? _locationError;
  String? _selectedGovernorate;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    // تحميل بيانات الخريطة الحرارية
    context.read<HeatmapCubit>().loadHeatmapData();
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _locationError = null;
      });

      final hasPermission = await _locationService.checkLocationPermission();

      if (!hasPermission) {
        final granted = await _showLocationPermissionDialog();
        if (!granted) {
          setState(() {
            _locationError = 'يجب السماح بالوصول للموقع لعرض الخريطة';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _locationError = 'فشل في تحديد الموقع الحالي';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'خطأ في تحديد الموقع: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  Future<bool> _showLocationPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LocationPermissionDialog(),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocListener<HeatmapCubit, HeatmapState>(
        listener: (context, state) {
          if (state is HeatmapFailure) {
            // طباعة الخطأ في الكونسول
            print('🔴 HeatMap Error: ${state.error}');
            debugPrint('📍 HeatMap Error Details: ${state.error}');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'إعادة المحاولة',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<HeatmapCubit>().loadHeatmapData();
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
                padding: EdgeInsets.all(16.w),
                child: _buildSearchBarWithFilter(),
              ),

              // الخريطة
              Container(
                height: 400.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    children: [_buildMapContent(), _buildMapOverlayStats()],
                  ),
                ),
              ),

              // إحصائيات مفلترة
              _buildFilteredStats(),

              // إحصائيات سريعة
              BlocBuilder<HeatmapCubit, HeatmapState>(
                builder: (context, state) {
                  if (state is HeatmapLoaded) {
                    return _buildQuickStats(state.statistics);
                  } else if (state is HeatmapGovernorateFilterApplied) {
                    return _buildGovernorateStats(state);
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
          // زر تحديث البيانات
          FloatingActionButton(
            heroTag: "refresh",
            mini: true,
            onPressed: () {
              print('🔄 Refreshing heatmap data...');
              context.read<HeatmapCubit>().loadHeatmapData();
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
          SizedBox(height: 10.h),
          // زر الموقع الحالي
          FloatingActionButton(
            heroTag: "location",
            mini: true,
            onPressed: () {
              print('📍 Getting current location...');
              _initializeLocation();
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        'heatMap'.tr(),
        style: TextStyle(
          fontSize: 18.sp,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text('جاري تحديد الموقع...', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              _locationError!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
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
      height: 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // أيقونة البحث
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(Icons.search, color: Colors.grey[600], size: 24.sp),
          ),

          // حقل البحث
          Expanded(
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن منطقة أو عنوان...',
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
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

          // زر الفلتر
          Container(
            margin: EdgeInsets.all(4.w),
            child: InkWell(
              onTap: () {
                print('🎛️ Filter button pressed');
                _showFilterBottomSheet();
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.tune, color: Colors.white, size: 20.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(20.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // مقبض السحب
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // العنوان الرئيسي
                  Text(
                    'تصفية النتائج',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // قسم المحافظات
                  _buildFilterSection(
                    title: 'حسب المحافظة',
                    icon: Icons.location_city,
                    onTap: _showGovernorateFilter,
                  ),

                  SizedBox(height: 12.h),

                  // قسم نوع الجريمة
                  _buildFilterSection(
                    title: 'حسب نوع الجريمة',
                    icon: Icons.category,
                    onTap: () {
                      Navigator.pop(context);
                      _showCrimeTypeFilter();
                    },
                  ),

                  SizedBox(height: 12.h),

                  // قسم الأولوية
                  _buildFilterSection(
                    title: 'حسب مستوى الأولوية',
                    icon: Icons.priority_high,
                    onTap: () {
                      Navigator.pop(context);
                      _showPriorityFilter();
                    },
                  ),

                  SizedBox(height: 12.h),

                  // قسم الفترة الزمنية
                  _buildFilterSection(
                    title: 'حسب الفترة الزمنية',
                    icon: Icons.date_range,
                    onTap: () {
                      Navigator.pop(context);
                      _showDateRangeFilter();
                    },
                  ),

                  SizedBox(height: 20.h),

                  // الفلاتر المطبقة حالياً
                  if (_selectedGovernorate != null) ...[
                    Text(
                      'الفلاتر المطبقة:',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        if (_selectedGovernorate != null)
                          _buildAppliedFilterChip(
                            'المحافظة: $_selectedGovernorate',
                            () => _filterByGovernorate(null),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // زر مسح جميع الفلاتر
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearAllFilters();
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text(
                        'مسح جميع الفلاتر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: Colors.red[200]!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      deleteIcon: Icon(Icons.close, size: 16.sp),
      onDeleted: onRemove,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      deleteIconColor: Theme.of(context).primaryColor,
    );
  }

  void _clearAllFilters() {
    print('🧹 Clearing all filters');
    setState(() {
      _selectedGovernorate = null;
    });
    context.read<HeatmapCubit>().loadHeatmapData();
  }

  void _showCrimeTypeFilter() {
    final crimeTypes = [
      'سرقة',
      'اعتداء',
      'احتيال',
      'مخدرات',
      'حوادث مرور',
      'عنف أسري',
      'أخرى',
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            height: 400.h,
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر نوع الجريمة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: crimeTypes.length,
                    itemBuilder: (context, index) {
                      final crimeType = crimeTypes[index];
                      return ListTile(
                        title: Text(crimeType),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pop(context);
                          print('🔍 Selected crime type: $crimeType');
                          // يمكن إضافة منطق الفلترة هنا
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPriorityFilter() {
    final priorities = [
      {'label': 'عاجل', 'value': 'urgent', 'color': Colors.red},
      {'label': 'عالي', 'value': 'high', 'color': Colors.orange},
      {'label': 'متوسط', 'value': 'medium', 'color': Colors.yellow[700]},
      {'label': 'منخفض', 'value': 'low', 'color': Colors.green},
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            height: 300.h,
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر مستوى الأولوية',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: priorities.length,
                    itemBuilder: (context, index) {
                      final priority = priorities[index];
                      return ListTile(
                        leading: Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: priority['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(priority['label'] as String),
                        onTap: () {
                          Navigator.pop(context);
                          print('⚡ Selected priority: ${priority['value']}');
                          // يمكن إضافة منطق الفلترة هنا
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showDateRangeFilter() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            height: 350.h,
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر الفترة الزمنية',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildDateOption('آخر 24 ساعة', () {
                  Navigator.pop(context);
                  print('📅 Selected: Last 24 hours');
                }),
                _buildDateOption('آخر أسبوع', () {
                  Navigator.pop(context);
                  print('📅 Selected: Last week');
                }),
                _buildDateOption('آخر شهر', () {
                  Navigator.pop(context);
                  print('📅 Selected: Last month');
                }),
                _buildDateOption('آخر 3 شهور', () {
                  Navigator.pop(context);
                  print('📅 Selected: Last 3 months');
                }),
                _buildDateOption('فترة مخصصة', () {
                  Navigator.pop(context);
                  _showCustomDatePicker();
                }),
              ],
            ),
          ),
    );
  }

  Widget _buildDateOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  void _showCustomDatePicker() {
    // يمكن إضافة منطق اختيار التاريخ المخصص هنا
    print('📅 Custom date picker requested');
  }

  Widget _buildMapOverlayStats() {
    return BlocBuilder<HeatmapCubit, HeatmapState>(
      builder: (context, state) {
        int totalReports = 0;
        String lastUpdateTime = 'الآن';

        if (state is HeatmapLoaded) {
          totalReports = state.reports.length;
        } else if (state is HeatmapReportsLoaded) {
          totalReports = state.reports.length;
        } else if (state is HeatmapGovernorateFilterApplied) {
          totalReports = state.filteredReports.length;
        }

        return Positioned(
          top: 20.h,
          left: 20.w,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).primaryColor,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'إحصائيات',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'إجمالي التقارير: $totalReports',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 4.h),
                Text(
                  'آخر تحديث: $lastUpdateTime',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilteredStats() {
    return BlocBuilder<HeatmapCubit, HeatmapState>(
      builder: (context, state) {
        if (state is HeatmapGovernorateFilterApplied) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Theme.of(context).primaryColor,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'تم العثور على ${state.filteredReports.length} تقرير في ${state.selectedGovernorate}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _filterByGovernorate(null),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColor,
                      size: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuickStats(dynamic statistics) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات سريعة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'إجمالي التقارير',
                  statistics?.totalReports?.toString() ?? '0',
                  Icons.report,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'قيد المراجعة',
                  statistics?.pendingReports?.toString() ?? '0',
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
                  statistics?.resolvedReports?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'الأكثر شيوعاً',
                  statistics?.mostCommonType ?? 'غير متاح',
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

  Widget _buildGovernorateStats(HeatmapGovernorateFilterApplied state) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
              SizedBox(width: 8.w),
              Text(
                'نتائج مصفاة: ${state.selectedGovernorate}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildStatItem(
            'عدد التقارير',
            state.filteredReports.length.toString(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.w, color: color),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
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

  void _filterByGovernorate(String? governorate) {
    setState(() {
      _selectedGovernorate = governorate;
    });

    if (governorate == null) {
      context.read<HeatmapCubit>().loadHeatmapData();
    } else {
      context.read<HeatmapCubit>().filterByGovernorate(governorate);
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تصفية النتائج',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                // يمكن إضافة خيارات الفلترة هنا
                ListTile(
                  title: const Text('حسب المحافظة'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    _showGovernorateFilter();
                  },
                ),
                ListTile(
                  title: const Text('حسب نوع الجريمة'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    // يمكن إضافة فلتر نوع الجريمة
                  },
                ),
                ListTile(
                  title: const Text('إزالة جميع الفلاتر'),
                  trailing: const Icon(Icons.clear),
                  onTap: () {
                    Navigator.pop(context);
                    _filterByGovernorate(null);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showGovernorateFilter() {
    // قائمة المحافظات المصرية
    final governorates = [
      'القاهرة',
      'الجيزة',
      'الإسكندرية',
      'الدقهلية',
      'البحر الأحمر',
      'البحيرة',
      'الفيوم',
      'الغربية',
      'الإسماعيلية',
      'المنوفية',
      'المنيا',
      'القليوبية',
      'الوادي الجديد',
      'شمال سيناء',
      'جنوب سيناء',
      'بورسعيد',
      'دمياط',
      'الشرقية',
      'كفر الشيخ',
      'مطروح',
      'أسوان',
      'أسيوط',
      'بني سويف',
      'سوهاج',
      'قنا',
      'الأقصر',
      'السويس',
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            height: 400.h,
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر المحافظة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: governorates.length,
                    itemBuilder: (context, index) {
                      final governorate = governorates[index];
                      return ListTile(
                        title: Text(governorate),
                        onTap: () {
                          Navigator.pop(context);
                          _filterByGovernorate(governorate);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إعدادات الخريطة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('عرض أسماء المدن'),
                  value: true, // يمكن ربطها بإعداد مخزن
                  onChanged: (value) {
                    // حفظ الإعداد
                  },
                ),
                SwitchListTile(
                  title: const Text('عرض الطرق'),
                  value: true,
                  onChanged: (value) {
                    // حفظ الإعداد
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
    );
  }
}
