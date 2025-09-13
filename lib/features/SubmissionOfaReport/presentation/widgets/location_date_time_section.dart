import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:netru_app/core/helper/validation_helper.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/cubit/submission_report_cubit.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/cubit/submission_report_state.dart';
import 'custom_text_field.dart';

class LocationDateTimeSection
    extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController dateTimeController;

  const LocationDateTimeSection({
    super.key,
    required this.locationController,
    required this.dateTimeController,
  });

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

        // DateTime Field
        CustomTextField(
          controller: dateTimeController,
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
                controller: locationController,
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
              height: 43.h,
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
        if (locationController.text.isNotEmpty)
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

      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy:
                LocationAccuracy.high,
          );

      locationController.text =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      cubit.setLocation(
        position.latitude,
        position.longitude,
      );
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

        dateTimeController.text =
            '${date.day}/${date.month}/${date.year} - ${time.format(context)}';
        context
            .read<ReportFormCubit>()
            .setDateTime(dateTime);
      }
    }
  }
}
