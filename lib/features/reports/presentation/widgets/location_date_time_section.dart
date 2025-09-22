import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:netru_app/core/helper/validation_helper.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/services/location_service.dart';
import '../cubit/report_form_cubit.dart';
import '../cubit/report_form_state.dart';
import 'custom_text_field.dart';

class LocationDateTimeSection
    extends StatefulWidget {
  final TextEditingController locationController;
  final TextEditingController dateTimeController;

  const LocationDateTimeSection({
    super.key,
    required this.locationController,
    required this.dateTimeController,
  });

  @override
  State<LocationDateTimeSection> createState() =>
      _LocationDateTimeSectionState();
}

class _LocationDateTimeSectionState
    extends State<LocationDateTimeSection> {
  double? _currentLatitude;
  double? _currentLongitude;
  String _locationDetails = '';

  @override
  void initState() {
    super.initState();
    _setCurrentDateTime();
  }

  void _setCurrentDateTime() {
    final now = DateTime.now();
    final timeOfDay = TimeOfDay.fromDateTime(now);

    // Format time manually to avoid context dependency in initState
    final hour = timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute
        .toString()
        .padLeft(2, '0');
    final period =
        timeOfDay.period == DayPeriod.am
            ? 'ص'
            : 'م';

    widget.dateTimeController.text =
        '${now.day}/${now.month}/${now.year} - $hour:$minute $period';

    // Set the current time in the cubit as well
    WidgetsBinding.instance.addPostFrameCallback((
      _,
    ) {
      if (mounted) {
        context
            .read<ReportFormCubit>()
            .setDateTime(now);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'الموقع والتوقيت',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 10.h),

        // Location Field with Button
        BlocBuilder<
          ReportFormCubit,
          ReportFormState
        >(
          builder: (context, state) {
            return _buildLocationField(
              context,
              state,
            );
          },
        ),
        SizedBox(height: 10.h),

        // Display location details if available
        if (_locationDetails.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(
                8.r,
              ),
              border: Border.all(
                color: Colors.blue[200]!,
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
                      Icons.location_on,
                      color: Colors.blue[600],
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'تفاصيل الموقع:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const Spacer(),
                    if (_currentLatitude !=
                            null &&
                        _currentLongitude != null)
                      InkWell(
                        onTap:
                            () =>
                                _openLocationInMaps(),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                          decoration: BoxDecoration(
                            color:
                                Colors.blue[600],
                            borderRadius:
                                BorderRadius.circular(
                                  4.r,
                                ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map,
                                color:
                                    Colors.white,
                                size: 12.sp,
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                'عرض في الخريطة',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color:
                                      Colors
                                          .white,
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  _locationDetails,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

        // DateTime Field
        CustomTextField(
          controller: widget.dateTimeController,
          label: 'التاريخ والوقت',
          hintText: 'اختر التاريخ والوقت',
          validator:
              ValidationHelper.validateDateTime,
          readOnly: true,
          onTap: () => _selectDateTime(context),
          suffixIcon: const Icon(
            Icons.access_time_outlined,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // دوال مساعدة للوصول إلى الإحداثيات المحفوظة
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude =>
      _currentLongitude;
  String get locationDetails => _locationDetails;

  // دالة للحصول على الإحداثيات كـ Map
  Map<String, double>? get coordinates {
    if (_currentLatitude != null &&
        _currentLongitude != null) {
      return {
        'latitude': _currentLatitude!,
        'longitude': _currentLongitude!,
      };
    }
    return null;
  }

  Widget _buildLocationField(
    BuildContext context,
    ReportFormState state,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // Location input with button
        Row(
          children: [
            // Text Field
            Expanded(
              child: TextFormField(
                controller:
                    widget.locationController,
                validator:
                    ValidationHelper
                        .validateLocation,
                textAlign: TextAlign.right,
                readOnly: true,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'الموقع الجغرافي',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],

                  // Default border
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.only(
                          topRight:
                              Radius.circular(
                                8.r,
                              ),
                          bottomRight:
                              Radius.circular(
                                8.r,
                              ),
                        ),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),

                  // Enabled border
                  enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                            BorderRadius.only(
                              topRight:
                                  Radius.circular(
                                    8.r,
                                  ),
                              bottomRight:
                                  Radius.circular(
                                    8.r,
                                  ),
                            ),
                        borderSide: BorderSide(
                          color:
                              Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),

                  // Focused border
                  focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                            BorderRadius.only(
                              topRight:
                                  Radius.circular(
                                    8.r,
                                  ),
                              bottomRight:
                                  Radius.circular(
                                    8.r,
                                  ),
                            ),
                        borderSide:
                            const BorderSide(
                              color: Color(
                                0xFF1E3A8A,
                              ),
                              width: 2,
                            ),
                      ),

                  // Error border
                  errorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.only(
                          topRight:
                              Radius.circular(
                                8.r,
                              ),
                          bottomRight:
                              Radius.circular(
                                8.r,
                              ),
                        ),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                  ),

                  contentPadding:
                      EdgeInsets.symmetric(
                        horizontal: 10.w,
                      ),

                  // Error style
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            // Location Button
            Container(
              height: 41.h,
              width: 130.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  bottomLeft: Radius.circular(
                    8.r,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    bottomLeft: Radius.circular(
                      8.r,
                    ),
                  ),
                  onTap:
                      state.isGettingLocation
                          ? null
                          : () =>
                              _getCurrentLocation(
                                context,
                              ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                    ),
                    child:
                        state.isGettingLocation
                            ? const Center(
                              child:
                                  CircularProgressIndicator(
                                    color:
                                        Colors
                                            .white,
                                    strokeWidth:
                                        2,
                                  ),
                            )
                            : Center(
                              child: Text(
                                "تحديد الموقع تلقائيا",
                                style: TextStyle(
                                  color:
                                      Colors
                                          .white,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Location status
        if (widget
            .locationController
            .text
            .isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'تم تحديد الموقع بنجاح',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _getCurrentLocation(
    BuildContext context,
  ) async {
    try {
      final cubit =
          context.read<ReportFormCubit>();
      cubit.setGettingLocation(true);

      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
        if (permission ==
            LocationPermission.denied) {
          throw 'تم رفض إذن الموقع';
        }
      }

      if (permission ==
          LocationPermission.deniedForever) {
        throw 'تم رفض إذن الموقع نهائياً. يرجى تفعيله من الإعدادات';
      }

      // استخدام LocationService المحدث
      final locationService = LocationService();
      final location =
          await locationService
              .getCurrentLocation();

      if (location != null) {
        // حفظ الإحداثيات في المتغيرات
        _currentLatitude = location.latitude;
        _currentLongitude = location.longitude;

        // الحصول على تفاصيل العنوان باستخدام الخدمة المحسنة
        final locationResult =
            await locationService
                .getLocationByCoordinates(
                  location.latitude,
                  location.longitude,
                );

        String locationName =
            'الموقع: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';

        locationResult.fold(
          (failure) {
            // Fallback to coordinates if service fails
            widget.locationController.text =
                locationName;
            _locationDetails =
                ''; // إخفاء التفاصيل إذا فشل الحصول عليها
          },
          (locationDetails) {
            // عرض معلومات العنوان المفصلة
            widget.locationController.text =
                locationDetails.displayName;

            // بناء سلسلة نصية تحتوي على تفاصيل العنوان
            String details = '';
            if (locationDetails.street != null &&
                locationDetails
                    .street!
                    .isNotEmpty &&
                locationDetails.street !=
                    'غير محدد') {
              details +=
                  'الشارع: ${locationDetails.street}\n';
            }
            if (locationDetails.city != null &&
                locationDetails
                    .city!
                    .isNotEmpty &&
                locationDetails.city !=
                    'غير محدد') {
              details +=
                  'المدينة: ${locationDetails.city}\n';
            }
            if (locationDetails.state != null &&
                locationDetails
                    .state!
                    .isNotEmpty &&
                locationDetails.state !=
                    'غير محدد') {
              details +=
                  'المحافظة: ${locationDetails.state}\n';
            }
            if (locationDetails.country != null &&
                locationDetails
                    .country!
                    .isNotEmpty &&
                locationDetails.country !=
                    'غير محدد') {
              details +=
                  'الدولة: ${locationDetails.country}\n';
            }

            // إضافة الإحداثيات في النهاية
            details +=
                'الإحداثيات: ${_currentLatitude!.toStringAsFixed(6)}, ${_currentLongitude!.toStringAsFixed(6)}';

            setState(() {
              _locationDetails = details;
            });
          },
        );

        // إرسال البيانات إلى الـ cubit مع العنوان الكامل
        cubit.setLocation(
          location.latitude,
          location.longitude,
          widget.locationController.text,
        );
      } else {
        throw 'فشل في الحصول على الموقع';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطأ في تحديد الموقع: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
        ),
      );
    } finally {
      context
          .read<ReportFormCubit>()
          .setGettingLocation(false);
    }
  }

  void _selectDateTime(
    BuildContext context,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme:
                  const ColorScheme.light(
                    primary: Color(0xFF1E3A8A),
                    onPrimary: Colors.white,
                  ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        widget.dateTimeController.text =
            '${date.day}/${date.month}/${date.year} - ${time.format(context)}';
        context
            .read<ReportFormCubit>()
            .setDateTime(dateTime);
      }
    }
  }

  // دالة لفتح الموقع في تطبيق الخرائط
  void _openLocationInMaps() async {
    if (_currentLatitude != null &&
        _currentLongitude != null) {
      try {
        await LocationService.openInGoogleMaps(
          _currentLatitude!,
          _currentLongitude!,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في فتح الخرائط: $e',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
          ),
        );
      }
    }
  }
}
