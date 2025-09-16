import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/location_service.dart';
import 'location_selector_modal.dart';

class SimpleLocationStep extends StatefulWidget {
  final GovernorateModel? selectedGovernorate;
  final CityModel? selectedCity;
  final Function(GovernorateModel?) onGovernorateChanged;
  final Function(CityModel?) onCityChanged;

  const SimpleLocationStep({
    super.key,
    this.selectedGovernorate,
    this.selectedCity,
    required this.onGovernorateChanged,
    required this.onCityChanged,
  });

  @override
  State<SimpleLocationStep> createState() => _SimpleLocationStepState();
}

class _SimpleLocationStepState extends State<SimpleLocationStep> {
  void _showGovernorateSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => LocationSelectorModal(
            title: 'اختر المحافظة',
            type: LocationType.governorate,
            onSelected: (governorate) {
              widget.onGovernorateChanged(governorate as GovernorateModel);
              // Reset city when governorate changes
              widget.onCityChanged(null);
            },
          ),
    );
  }

  void _showCitySelector() {
    if (widget.selectedGovernorate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المحافظة أولاً')),
      );
      return;
    }

    final parentId = widget.selectedGovernorate?.id;
    if (parentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '\u064a\u0631\u062c\u0649 \u0627\u062e\u062a\u064a\u0627\u0631 \u0627\u0644\u0645\u062d\u0627\u0641\u0638\u0629 \u0623\u0648\u0644\u0627\u064b',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => LocationSelectorModal(
            title: 'اختر المدينة',
            type: LocationType.city,
            parentId: parentId,
            onSelected: (city) {
              widget.onCityChanged(city as CityModel);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'اختر العنوان',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          SizedBox(height: 8.h),

          FadeInDown(
            duration: const Duration(milliseconds: 700),
            child: Text(
              'اختر المحافظة والمدينة التي تقيم بها',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 32.h),

          // Governorate selector
          _buildLocationCard(
            title: 'المحافظة',
            subtitle: widget.selectedGovernorate?.name ?? 'اختر المحافظة',
            icon: Icons.location_city,
            isSelected: widget.selectedGovernorate != null,
            onTap: _showGovernorateSelector,
            delay: 800,
          ),

          SizedBox(height: 16.h),

          // City selector
          _buildLocationCard(
            title: 'المدينة',
            subtitle: widget.selectedCity?.name ?? 'اختر المدينة',
            icon: Icons.business,
            isSelected: widget.selectedCity != null,
            onTap: _showCitySelector,
            delay: 900,
            enabled: widget.selectedGovernorate != null,
          ),

          SizedBox(height: 32.h),

          // Summary
          if (widget.selectedGovernorate != null || widget.selectedCity != null)
            _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required int delay,
    bool enabled = true,
  }) {
    return SlideInLeft(
      duration: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color:
                enabled
                    ? (isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.white)
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color:
                  enabled
                      ? (isSelected ? AppColors.primary : AppColors.border)
                      : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color:
                      enabled
                          ? (isSelected
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.1))
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color:
                      enabled
                          ? (isSelected ? Colors.white : AppColors.primary)
                          : Colors.grey.shade500,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 16.w),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            enabled
                                ? AppColors.textPrimary
                                : Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color:
                            enabled
                                ? (isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary)
                                : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: enabled ? AppColors.textSecondary : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العنوان المحدد',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _buildAddressText(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildAddressText() {
    List<String> parts = [];
    if (widget.selectedCity != null) parts.add(widget.selectedCity!.name);
    if (widget.selectedGovernorate != null) {
      parts.add(widget.selectedGovernorate!.name);
    }
    return parts.isNotEmpty ? parts.join(' - ') : 'لم يتم تحديد العنوان';
  }
}
