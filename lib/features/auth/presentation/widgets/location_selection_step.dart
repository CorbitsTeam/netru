import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';

class LocationSelectionStep extends StatefulWidget {
  final Map<String, String> selectedLocation;
  final Function(Map<String, String>) onLocationChanged;

  const LocationSelectionStep({
    super.key,
    required this.selectedLocation,
    required this.onLocationChanged,
  });

  @override
  State<LocationSelectionStep> createState() => _LocationSelectionStepState();
}

class _LocationSelectionStepState extends State<LocationSelectionStep> {
  final Map<String, List<String>> _egyptGovernorates = {
    'القاهرة': [
      'مدينة نصر',
      'الزمالك',
      'مصر الجديدة',
      'المعادي',
      'حدائق القبة',
      'شبرا',
    ],
    'الجيزة': [
      'الدقي',
      'المهندسين',
      'الهرم',
      'فيصل',
      'العجوزة',
      'بولاق الدكرور',
    ],
    'الإسكندرية': [
      'المنتزه',
      'الرمل',
      'وسط البلد',
      'كرموز',
      'الجمرك',
      'الأزاريطة',
    ],
    'الدقهلية': ['المنصورة', 'طلخا', 'ميت غمر', 'بلقاس', 'دكرنس', 'منية النصر'],
    'البحيرة': ['دمنهور', 'كفر الدوار', 'رشيد', 'إدكو', 'أبو حمص', 'الدلنجات'],
    'الفيوم': ['الفيوم', 'سنورس', 'طامية', 'إطسا', 'يوسف الصديق', 'أبشواي'],
    'الغربية': [
      'طنطا',
      'المحلة الكبرى',
      'كفر الزيات',
      'زفتى',
      'السنطة',
      'بسيون',
    ],
    'الإسماعيلية': [
      'الإسماعيلية',
      'فايد',
      'القنطرة شرق',
      'القنطرة غرب',
      'أبو صوير',
      'القصاصين',
    ],
    'المنيا': ['المنيا', 'ملوي', 'سمالوط', 'بني مزار', 'مطاي', 'أبو قرقاص'],
    'القليوبية': [
      'بنها',
      'القناطر الخيرية',
      'شبرا الخيمة',
      'القليوب',
      'كفر شكر',
      'طوخ',
    ],
    'الشرقية': [
      'الزقازيق',
      'بلبيس',
      'مشتول السوق',
      'فاقوس',
      'الحسينية',
      'أبو حماد',
    ],
    'أسوان': ['أسوان', 'إدفو', 'كوم أمبو', 'دراو', 'نصر النوبة', 'أبو سمبل'],
    'أسيوط': ['أسيوط', 'ديروط', 'منفلوط', 'القوصية', 'أبنوب', 'ساحل سليم'],
    'بني سويف': ['بني سويف', 'الواسطى', 'ناصر', 'إهناسيا', 'ببا', 'الفشن'],
    'جنوب سيناء': [
      'شرم الشيخ',
      'دهب',
      'نويبع',
      'طور سيناء',
      'سانت كاترين',
      'أبو رديس',
    ],
    'دمياط': [
      'دمياط',
      'رأس البر',
      'الزرقا',
      'فارسكور',
      'كفر سعد',
      'عزبة البرج',
    ],
    'سوهاج': ['سوهاج', 'طهطا', 'المراغة', 'طما', 'جرجا', 'البلينا'],
    'شمال سيناء': ['العريش', 'الشيخ زويد', 'نخل', 'بئر العبد', 'الحسنة', 'رفح'],
    'قنا': ['قنا', 'الأقصر', 'إسنا', 'أرمنت', 'الطود', 'نجع حمادي'],
    'كفر الشيخ': ['كفر الشيخ', 'دسوق', 'فوه', 'مطوبس', 'برج البرلس', 'الحامول'],
    'مطروح': ['مرسى مطروح', 'الضبعة', 'العلمين', 'سيوة', 'النجيلة', 'براني'],
    'الوادي الجديد': [
      'الخارجة',
      'الداخلة',
      'الفرافرة',
      'باريس',
      'موط',
      'تنيدة',
    ],
    'البحر الأحمر': [
      'الغردقة',
      'سفاجا',
      'القصير',
      'مرسى علم',
      'الشلاتين',
      'حلايب',
    ],
  };

  String? _selectedGovernorate;
  String? _selectedCity;
  List<String> _districts = [];

  @override
  void initState() {
    super.initState();
    _selectedGovernorate = widget.selectedLocation['governorate'];
    _selectedCity = widget.selectedLocation['city'];

    if (_selectedGovernorate != null) {
      _loadCities(_selectedGovernorate!);
    }
    if (_selectedCity != null) {
      _loadDistricts(_selectedCity!);
    }
  }

  void _loadCities(String governorate) {
    setState(() {
      _selectedCity = null;
      _districts = [];
    });
    _updateLocation();
  }

  void _loadDistricts(String city) {
    setState(() {
      _districts = [
        'الحي الأول',
        'الحي الثاني',
        'الحي الثالث',
        'الحي الرابع',
        'الحي الخامس',
        'المنطقة الصناعية',
        'المنطقة التجارية',
        'المنطقة السكنية',
      ];
    });
  }

  void _updateLocation() {
    final location = <String, String>{};
    if (_selectedGovernorate != null)
      location['governorate'] = _selectedGovernorate!;
    if (_selectedCity != null) location['city'] = _selectedCity!;
    if (widget.selectedLocation['district'] != null &&
        _selectedCity == widget.selectedLocation['city']) {
      location['district'] = widget.selectedLocation['district']!;
    }
    widget.onLocationChanged(location);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),

          // Title
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'اختيار العنوان',
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
              'حدد محافظتك ومدينتك والحي الذي تقيم فيه',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 32.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Governorate Selection
                  _buildSelectionCard(
                    title: 'المحافظة',
                    subtitle: 'اختر محافظتك',
                    icon: Icons.location_city_outlined,
                    value: _selectedGovernorate,
                    items: _egyptGovernorates.keys.toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGovernorate = value;
                        _selectedCity = null;
                        _districts = [];
                      });
                      _loadCities(value!);
                    },
                    animationDelay: 0,
                  ),

                  SizedBox(height: 20.h),

                  // City Selection
                  _buildSelectionCard(
                    title: 'المدينة',
                    subtitle: 'اختر مدينتك',
                    icon: Icons.location_on_outlined,
                    value: _selectedCity,
                    items:
                        _selectedGovernorate != null
                            ? _egyptGovernorates[_selectedGovernorate!] ?? []
                            : [],
                    onChanged:
                        _selectedGovernorate != null
                            ? (value) {
                              setState(() {
                                _selectedCity = value;
                              });
                              _loadDistricts(value!);
                              _updateLocation();
                            }
                            : null,
                    animationDelay: 100,
                    enabled: _selectedGovernorate != null,
                  ),

                  SizedBox(height: 20.h),

                  // District Selection
                  _buildSelectionCard(
                    title: 'الحي / المنطقة',
                    subtitle: 'اختر الحي أو المنطقة',
                    icon: Icons.place_outlined,
                    value: widget.selectedLocation['district'],
                    items: _districts,
                    onChanged:
                        _selectedCity != null
                            ? (value) {
                              final location = Map<String, String>.from(
                                widget.selectedLocation,
                              );
                              location['district'] = value!;
                              widget.onLocationChanged(location);
                            }
                            : null,
                    animationDelay: 200,
                    enabled: _selectedCity != null,
                  ),

                  SizedBox(height: 32.h),

                  // Location Summary
                  if (_selectedGovernorate != null) _buildLocationSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
    required int animationDelay,
    bool enabled = true,
  }) {
    return FadeInUp(
      duration: Duration(milliseconds: 800 + animationDelay),
      child: Container(
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                enabled
                    ? (value != null
                        ? AppColors.primary
                        : AppColors.grey.withOpacity(0.3))
                    : AppColors.grey.withOpacity(0.2),
          ),
          boxShadow:
              enabled
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color:
                          enabled
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      icon,
                      color: enabled ? AppColors.primary : AppColors.grey,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                enabled
                                    ? AppColors.textPrimary
                                    : AppColors.grey,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                enabled
                                    ? AppColors.textSecondary
                                    : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (enabled)
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                ],
              ),
            ),

            // Dropdown
            if (enabled && items.isNotEmpty)
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.grey.withOpacity(0.2)),
                ),
                child: DropdownButtonFormField<String>(
                  value: value,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    border: InputBorder.none,
                    hintText: 'اختر $title',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  icon: const SizedBox.shrink(),
                  isExpanded: true,
                  items:
                      items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: onChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSummary() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.success.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'ملخص العنوان المحدد',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              _buildAddressText(),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.success,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildAddressText() {
    final parts = <String>[];

    if (widget.selectedLocation['district'] != null) {
      parts.add(widget.selectedLocation['district']!);
    }
    if (_selectedCity != null) {
      parts.add(_selectedCity!);
    }
    if (_selectedGovernorate != null) {
      parts.add(_selectedGovernorate!);
    }

    return parts.isNotEmpty ? parts.join(' - ') : 'لم يتم تحديد العنوان بعد';
  }
}
