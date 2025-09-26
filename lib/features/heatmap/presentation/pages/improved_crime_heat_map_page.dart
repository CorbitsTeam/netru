import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:netru_app/features/heatmap/presentation/widgets/floating_action_buttons_widget.dart';
import '../widgets/heat_map_widget.dart';
import '../widgets/location_permission_dialog.dart';
import '../widgets/heatmap_stats_widget.dart';
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
  String? _selectedGovernorate;
  String? _selectedCrimeType;

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
              // الخريطة
              Container(
                height: 450.h,
                margin: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(4.r),
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

              // إحصائيات الخريطة الحرارية
              const HeatmapStatsWidget(),

              // إحصائيات مفلترة
              _buildFilteredStats(),

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
                    return _buildFilteredStatsCard(
                      'نتائج مرشحة: ${state.selectedGovernorate}',
                      state
                          .filteredReports
                          .length,
                      Icons.location_city,
                    );
                  } else if (state
                      is HeatmapCrimeTypeFilterApplied) {
                    return _buildFilteredStatsCard(
                      'نتائج مرشحة: ${state.selectedCrimeType}',
                      state
                          .filteredReports
                          .length,
                      Icons.category,
                    );
                  } else if (state
                      is HeatmapCombinedFilterApplied) {
                    String title = 'نتائج مرشحة';
                    if (state.selectedGovernorate !=
                            null &&
                        state.selectedCrimeType !=
                            null) {
                      title +=
                          ': ${state.selectedGovernorate} - ${state.selectedCrimeType}';
                    } else if (state
                            .selectedGovernorate !=
                        null) {
                      title +=
                          ': ${state.selectedGovernorate}';
                    } else if (state
                            .selectedCrimeType !=
                        null) {
                      title +=
                          ': ${state.selectedCrimeType}';
                    }
                    return _buildFilteredStatsCard(
                      title,
                      state
                          .filteredReports
                          .length,
                      Icons.filter_list,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: 20.h,
          right: 8.w,
        ),
        child: FloatingActionButtonsWidget(
          onFilterPressed: () {
            _showFilterBottomSheet();
          },
          onRefreshPressed: () {
            context
                .read<HeatmapCubit>()
                .refreshData();
          },
          onLocationPressed: () {
            _initializeLocation();
          },
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder:
          (context) => Container(
            height:
                MediaQuery.of(
                  context,
                ).size.height *
                0.7,
            padding: EdgeInsets.all(20.w),
            child: SingleChildScrollView(
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

                  // العنوان الرئيسي
                  Text(
                    'تصفية النتائج',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(
                            context,
                          ).primaryColor,
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

                  SizedBox(height: 20.h),

                  // الفلاتر المطبقة حالياً
                  if (_selectedGovernorate !=
                          null ||
                      _selectedCrimeType !=
                          null) ...[
                    Container(
                      padding: EdgeInsets.all(
                        16.w,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.05),
                        borderRadius:
                            BorderRadius.circular(
                              12.r,
                            ),
                        border: Border.all(
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.filter_alt,
                                color:
                                    Theme.of(
                                      context,
                                    ).primaryColor,
                                size: 18.sp,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Text(
                                'الفلاتر المطبقة',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color:
                                      Theme.of(
                                        context,
                                      ).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              if (_selectedGovernorate !=
                                  null)
                                _buildAppliedFilterChip(
                                  'المحافظة: $_selectedGovernorate',
                                  () =>
                                      _filterByGovernorate(
                                        null,
                                      ),
                                  Icons
                                      .location_city,
                                ),
                              if (_selectedCrimeType !=
                                  null)
                                _buildAppliedFilterChip(
                                  'نوع الجريمة: $_selectedCrimeType',
                                  () =>
                                      _filterByCrimeType(
                                        null,
                                      ),
                                  Icons.category,
                                ),
                            ],
                          ),
                        ],
                      ),
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
                      icon: const Icon(
                        Icons.clear_all,
                      ),
                      label: const Text(
                        'مسح جميع الفلاتر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red[50],
                        foregroundColor:
                            Colors.red[700],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                12.r,
                              ),
                          side: BorderSide(
                            color:
                                Colors.red[200]!,
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
          borderRadius: BorderRadius.circular(
            12.r,
          ),
          border: Border.all(
            color: Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color:
                    Theme.of(
                      context,
                    ).primaryColor,
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
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedFilterChip(
    String label,
    VoidCallback onRemove,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(
            context,
          ).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color:
                  Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12.sp,
                color:
                    Theme.of(
                      context,
                    ).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    print('🧹 Clearing all filters');
    setState(() {
      _selectedGovernorate = null;
      _selectedCrimeType = null;
    });
    context
        .read<HeatmapCubit>()
        .loadHeatmapData();
  }

  void _showCrimeTypeFilter() {
    final crimeTypes = [
      {
        'name': 'سرقة',
        'icon': Icons.security,
        'color': Colors.red,
      },
      {
        'name': 'اعتداء',
        'icon': Icons.warning,
        'color': Colors.orange,
      },
      {
        'name': 'احتيال',
        'icon': Icons.monetization_on,
        'color': Colors.yellow[700],
      },
      {
        'name': 'مخدرات',
        'icon': Icons.local_pharmacy,
        'color': Colors.purple,
      },
      {
        'name': 'حوادث مرور',
        'icon': Icons.directions_car,
        'color': Colors.blue,
      },
      {
        'name': 'عنف أسري',
        'icon': Icons.home,
        'color': Colors.pink,
      },
      {
        'name': 'أخرى',
        'icon': Icons.category,
        'color': Colors.grey,
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder:
          (context) => Container(
            height: 450.h,
            padding: EdgeInsets.all(20.w),
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

                Text(
                  'اختر نوع الجريمة',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(
                          context,
                        ).primaryColor,
                  ),
                ),
                SizedBox(height: 16.h),

                Expanded(
                  child: ListView.builder(
                    itemCount: crimeTypes.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final crimeType =
                          crimeTypes[index];
                      final isSelected =
                          _selectedCrimeType ==
                          crimeType['name'];

                      return Container(
                        margin: EdgeInsets.only(
                          bottom: 8.h,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                            _filterByCrimeType(
                              crimeType['name']
                                  as String,
                            );
                          },
                          borderRadius:
                              BorderRadius.circular(
                                12.r,
                              ),
                          child: Container(
                            padding:
                                EdgeInsets.all(
                                  16.w,
                                ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? (crimeType['color']
                                              as Color)
                                          .withOpacity(
                                            0.1,
                                          )
                                      : Colors
                                          .grey[50],
                              borderRadius:
                                  BorderRadius.circular(
                                    12.r,
                                  ),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? (crimeType['color']
                                            as Color)
                                        : Colors
                                            .grey[200]!,
                                width:
                                    isSelected
                                        ? 2
                                        : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    color: (crimeType['color']
                                            as Color)
                                        .withOpacity(
                                          0.2,
                                        ),
                                    borderRadius:
                                        BorderRadius.circular(
                                          10.r,
                                        ),
                                  ),
                                  child: Icon(
                                    crimeType['icon']
                                        as IconData,
                                    color:
                                        crimeType['color']
                                            as Color,
                                    size: 22.sp,
                                  ),
                                ),
                                SizedBox(
                                  width: 16.w,
                                ),

                                Expanded(
                                  child: Text(
                                    crimeType['name']
                                        as String,
                                    style: TextStyle(
                                      fontSize:
                                          16.sp,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                      color:
                                          isSelected
                                              ? (crimeType['color']
                                                  as Color)
                                              : Colors.grey[800],
                                    ),
                                  ),
                                ),

                                if (isSelected)
                                  Icon(
                                    Icons
                                        .check_circle,
                                    color:
                                        crimeType['color']
                                            as Color,
                                    size: 20.sp,
                                  )
                                else
                                  Icon(
                                    Icons
                                        .arrow_forward_ios,
                                    color:
                                        Colors
                                            .grey[400],
                                    size: 16.sp,
                                  ),
                              ],
                            ),
                          ),
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

  void _filterByCrimeType(String? crimeType) {
    setState(() {
      _selectedCrimeType = crimeType;
    });

    if (crimeType == null) {
      context
          .read<HeatmapCubit>()
          .loadHeatmapData();
    } else {
      // استخدام الفلتر المجمع إذا كان هناك محافظة مختارة أيضاً
      context.read<HeatmapCubit>().applyFilters(
        governorate: _selectedGovernorate,
        crimeType: crimeType,
      );
    }
  }

  Widget _buildFilteredStats() {
    return BlocBuilder<
      HeatmapCubit,
      HeatmapState
    >(
      builder: (context, state) {
        String? resultText;
        int? resultCount;
        VoidCallback? clearAction;

        if (state
            is HeatmapGovernorateFilterApplied) {
          resultText =
              'تم العثور على ${state.filteredReports.length} تقرير في ${state.selectedGovernorate}';
          resultCount =
              state.filteredReports.length;
          clearAction =
              () => _filterByGovernorate(null);
        } else if (state
            is HeatmapCrimeTypeFilterApplied) {
          resultText =
              'تم العثور على ${state.filteredReports.length} تقرير من نوع ${state.selectedCrimeType}';
          resultCount =
              state.filteredReports.length;
          clearAction =
              () => _filterByCrimeType(null);
        } else if (state
            is HeatmapCombinedFilterApplied) {
          String filters = '';
          if (state.selectedGovernorate != null &&
              state.selectedCrimeType != null) {
            filters =
                'في ${state.selectedGovernorate} من نوع ${state.selectedCrimeType}';
          } else if (state.selectedGovernorate !=
              null) {
            filters =
                'في ${state.selectedGovernorate}';
          } else if (state.selectedCrimeType !=
              null) {
            filters =
                'من نوع ${state.selectedCrimeType}';
          }
          resultText =
              'تم العثور على ${state.filteredReports.length} تقرير $filters';
          resultCount =
              state.filteredReports.length;
          clearAction = _clearAllFilters;
        }

        if (resultText != null &&
            resultCount != null) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor
                      .withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(
                12.r,
              ),
              border: Border.all(
                color: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(
                          8.r,
                        ),
                  ),
                  child: Icon(
                    Icons.search,
                    color:
                        Theme.of(
                          context,
                        ).primaryColor,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نتائج البحث',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                              FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        resultText,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color:
                              Theme.of(
                                context,
                              ).primaryColor,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: clearAction,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.red
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(
                            6.r,
                          ),
                    ),
                    child: Icon(
                      Icons.clear,
                      color: Colors.red[600],
                      size: 16.sp,
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
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                Icons.analytics,
                color:
                    Theme.of(
                      context,
                    ).primaryColor,
                size: 22.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'إحصائيات عامة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(
                        context,
                      ).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'إجمالي التقارير',
                  statistics?.totalReports
                          ?.toString() ??
                      '0',
                  Icons.report_problem,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'قيد المعالجة',
                  statistics?.pendingReports
                          ?.toString() ??
                      '0',
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'تم الحل',
                  statistics?.resolvedReports
                          ?.toString() ??
                      '0',
                  Icons.check_circle_outline,
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

  Widget _buildFilteredStatsCard(
    String title,
    int count,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(
              context,
            ).primaryColor.withOpacity(0.1),
            Theme.of(
              context,
            ).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(
            context,
          ).primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(
                12.r,
              ),
            ),
            child: Icon(
              icon,
              color:
                  Theme.of(context).primaryColor,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(
                          context,
                        ).primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$count تقرير',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
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
      height: 75.h,
      width: 160.w,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: color,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
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

    if (governorate == null &&
        _selectedCrimeType == null) {
      context
          .read<HeatmapCubit>()
          .loadHeatmapData();
    } else {
      // استخدام الفلتر المجمع
      context.read<HeatmapCubit>().applyFilters(
        governorate: governorate,
        crimeType: _selectedCrimeType,
      );
    }
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder:
          (context) => Container(
            height: 400.h,
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                    itemCount:
                        governorates.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final governorate =
                          governorates[index];
                      return ListTile(
                        title: Text(governorate),
                        onTap: () {
                          Navigator.pop(context);
                          _filterByGovernorate(
                            governorate,
                          );
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
}
