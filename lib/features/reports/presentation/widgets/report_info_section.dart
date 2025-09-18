import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/helper/validation_helper.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'custom_text_field.dart';

class ReportInfoSection extends StatelessWidget {
  final TextEditingController reportTypeController;
  final TextEditingController reportDetailsController;
  final List<String> reportTypes;

  const ReportInfoSection({
    super.key,
    required this.reportTypeController,
    required this.reportDetailsController,
    required this.reportTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات البلاغ',
          style: TextStyle(fontSize: 16.sp, color: AppColors.primaryColor),
        ),
        SizedBox(height: 10.h),
        // Report Type Dropdown with Search
        SearchableDropdown(
          controller: reportTypeController,
          label: 'نوع البلاغ',
          items: reportTypes,
          validator: ValidationHelper.validateReportType,
          hintText: 'اختر نوع البلاغ',
          searchHint: 'ابحث عن نوع البلاغ',
        ),
        SizedBox(height: 10.h),

        // Report Details Field
        CustomTextField(
          controller: reportDetailsController,
          label: 'تفاصيل البلاغ',
          hintText: 'اكتب تفاصيل البلاغ هنا... (اختياري)',
          maxLines: 5,
          isRequired: false,
          validator: ValidationHelper.validateReportDetails,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

// Enhanced SearchableDropdown widget with beautiful design
class SearchableDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final List<String> items;
  final String? Function(String?)? validator;
  final String hintText;
  final String searchHint;

  const SearchableDropdown({
    super.key,
    required this.controller,
    required this.label,
    required this.items,
    this.validator,
    required this.hintText,
    this.searchHint = 'ابحث...',
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    
    // Listen to search controller changes
    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBottomSheet(BuildContext context) {
    _searchController.clear();
    _filteredItems = widget.items;
    _isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void updateSearch(String query) {
              setModalState(() {
                if (query.isEmpty) {
                  _filteredItems = widget.items;
                } else {
                  _filteredItems = widget.items
                      .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                }
                _isSearching = query.isNotEmpty;
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Draggable handle with better design
                  Container(
                    width: 60.w,
                    height: 5.h,
                    margin: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  
                  // Header with title and close button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 24.sp),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Search field with beautiful design
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: widget.searchHint,
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: Icon(Icons.close, size: 20.sp),
                                  onPressed: () {
                                    _searchController.clear();
                                    updateSearch('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: updateSearch,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Results count
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_filteredItems.length} نتيجة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Divider
                  Divider(height: 1, color: Colors.grey[300]),
                  
                  // List of items with beautiful animation
                  Expanded(
                    child: _filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'لا توجد نتائج',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'حاول استخدام كلمات بحث مختلفة',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              bottom: 16.h,
                            ),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                margin: EdgeInsets.only(bottom: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    item,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    widget.controller.text = item;
                                    Navigator.pop(context);
                                  },
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      validator: widget.validator,
      onTap: () => _showBottomSheet(context),
    );
  }
}