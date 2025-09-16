import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/location_service.dart';

class LocationSelectorModal extends StatefulWidget {
  final String title;
  final LocationType type;
  final int? parentId; // For cities, this would be governorate_id
  final Function(dynamic) onSelected;

  const LocationSelectorModal({
    super.key,
    required this.title,
    required this.type,
    this.parentId,
    required this.onSelected,
  });

  @override
  State<LocationSelectorModal> createState() => _LocationSelectorModalState();
}

class _LocationSelectorModalState extends State<LocationSelectorModal> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      switch (widget.type) {
        case LocationType.governorate:
          final result = await _locationService.getGovernorates();
          result.fold((failure) => _error = failure.message, (governorates) {
            _allItems = governorates;
            _filteredItems = governorates;
          });
          break;
        case LocationType.city:
          final pid = widget.parentId;
          if (pid != null) {
            final result = await _locationService.getCities(pid);
            result.fold((failure) => _error = failure.message, (cities) {
              _allItems = cities;
              _filteredItems = cities;
            });
          }
          break;
        case LocationType.district:
          final pid = widget.parentId;
          if (pid != null) {
            final result = await _locationService.getDistricts(pid);
            result.fold((failure) => _error = failure.message, (districts) {
              _allItems = districts;
              _filteredItems = districts;
            });
          }
          break;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل البيانات';
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems =
            _allItems.where((item) {
              final name = item.name.toLowerCase();
              return name.contains(query);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          FadeInDown(
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Search field
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن ${widget.title}...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 16.w,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Content
          Flexible(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return SizedBox(
        height: 200.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 200.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                _error ?? '',
                style: TextStyle(fontSize: 16.sp, color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16.h),
              Text(
                'لا توجد نتائج للبحث',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 400.h),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return _buildListItem(item, index);
        },
      ),
    );
  }

  Widget _buildListItem(dynamic item, int index) {
    return SlideInRight(
      duration: Duration(milliseconds: 300 + (index * 50)),
      child: ListTile(
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: AppColors.textSecondary,
        ),
        onTap: () {
          widget.onSelected(item);
          Navigator.pop(context);
        },
      ),
    );
  }
}
