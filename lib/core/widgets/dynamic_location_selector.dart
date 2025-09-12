import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';

class DynamicLocationSelector extends StatefulWidget {
  final Function(GovernorateModel?) onGovernorateSelected;
  final Function(CityModel?) onCitySelected;
  final Function(DistrictModel?) onDistrictSelected;
  final GovernorateModel? selectedGovernorate;
  final CityModel? selectedCity;
  final DistrictModel? selectedDistrict;

  const DynamicLocationSelector({
    super.key,
    required this.onGovernorateSelected,
    required this.onCitySelected,
    required this.onDistrictSelected,
    this.selectedGovernorate,
    this.selectedCity,
    this.selectedDistrict,
  });

  @override
  State<DynamicLocationSelector> createState() =>
      _DynamicLocationSelectorState();
}

class _DynamicLocationSelectorState extends State<DynamicLocationSelector> {
  final LocationService _locationService = LocationService();
  List<GovernorateModel> _governorates = [];
  List<CityModel> _cities = [];
  List<DistrictModel> _districts = [];
  bool _isLoadingGovernorates = false;
  bool _isLoadingCities = false;
  bool _isLoadingDistricts = false;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  Future<void> _loadGovernorates() async {
    setState(() => _isLoadingGovernorates = true);

    final result = await _locationService.getGovernorates();
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.red,
          ),
        );
      },
      (governorates) {
        setState(() {
          _governorates = governorates;
        });
      },
    );

    setState(() => _isLoadingGovernorates = false);
  }

  Future<void> _loadCities(int governorateId) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _districts = [];
    });

    final result = await _locationService.getCities(governorateId);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.red,
          ),
        );
      },
      (cities) {
        setState(() {
          _cities = cities;
        });
      },
    );

    setState(() => _isLoadingCities = false);
  }

  Future<void> _loadDistricts(int cityId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
    });

    final result = await _locationService.getDistricts(cityId);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.red,
          ),
        );
      },
      (districts) {
        setState(() {
          _districts = districts;
        });
      },
    );

    setState(() => _isLoadingDistricts = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Governorate Dropdown
        _buildDropdown<GovernorateModel>(
          label: "المحافظة",
          hint: "اختر المحافظة",
          value: widget.selectedGovernorate,
          items: _governorates,
          isLoading: _isLoadingGovernorates,
          itemBuilder: (governorate) => governorate.name,
          onChanged: (governorate) {
            widget.onGovernorateSelected(governorate);
            widget.onCitySelected(null);
            widget.onDistrictSelected(null);
            if (governorate != null) {
              _loadCities(governorate.id);
            } else {
              setState(() {
                _cities = [];
                _districts = [];
              });
            }
          },
        ),

        if (widget.selectedGovernorate != null) ...[
          SizedBox(height: 16.h),
          // City Dropdown
          _buildDropdown<CityModel>(
            label: "المدينة",
            hint: "اختر المدينة",
            value: widget.selectedCity,
            items: _cities,
            isLoading: _isLoadingCities,
            itemBuilder: (city) => city.name,
            onChanged: (city) {
              widget.onCitySelected(city);
              widget.onDistrictSelected(null);
              if (city != null) {
                _loadDistricts(city.id);
              } else {
                setState(() {
                  _districts = [];
                });
              }
            },
          ),
        ],

        if (widget.selectedCity != null) ...[
          SizedBox(height: 16.h),
          // District Dropdown
          _buildDropdown<DistrictModel>(
            label: "الحي/المنطقة",
            hint: "اختر الحي",
            value: widget.selectedDistrict,
            items: _districts,
            isLoading: _isLoadingDistricts,
            itemBuilder: (district) => district.name,
            onChanged: (district) {
              widget.onDistrictSelected(district);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required bool isLoading,
    required String Function(T) itemBuilder,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12.w),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey[400],
                  size: 22.sp,
                ),
              ),
              suffixIcon:
                  isLoading
                      ? Container(
                        padding: EdgeInsets.all(12.w),
                        child: SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        ),
                      )
                      : null,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
            ),
            items:
                items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemBuilder(item),
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: isLoading ? null : onChanged,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[400],
              size: 24.sp,
            ),
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            elevation: 8,
          ),
        ),
      ],
    );
  }
}
