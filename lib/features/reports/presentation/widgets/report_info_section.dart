import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/helper/validation_helper.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/reports/data/models/report_type_model.dart';
import 'package:netru_app/features/reports/presentation/cubit/report_form_cubit.dart';
import 'package:netru_app/features/reports/presentation/cubit/report_form_state.dart';
import 'custom_text_field.dart';

class ReportInfoSection extends StatelessWidget {
  final TextEditingController reportDetailsController;

  /// When provided, the widget becomes read-only and shows [readOnlyReportType]
  /// instead of trying to access the [ReportFormCubit]. This is used by
  /// `ReportDetailsPage` where no cubit/provider is available.
  final String? readOnlyReportType;
  final bool readOnly;

  const ReportInfoSection({
    super.key,
    required this.reportDetailsController,
    this.readOnlyReportType,
    this.readOnly = false,
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
        // Report Type Dropdown with Search.
        // If a ReportFormCubit provider is present we render the interactive
        // dropdown, otherwise we render a read-only field using
        // [readOnlyReportType]. This avoids provider lookup errors when this
        // widget is used inside routes that don't provide the cubit (e.g.
        // ReportDetailsPage).
        Builder(
          builder: (ctx) {
            // detect presence of ReportFormCubit safely
            late final bool hasCubit;
            try {
              // This will throw if no provider is found
              ctx.read<ReportFormCubit>();
              hasCubit = true;
            } catch (_) {
              hasCubit = false;
            }

            if (!hasCubit || readOnly) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.category_outlined,
                            color: AppColors.primaryColor,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'نوع البلاغ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        readOnlyReportType ?? 'نوع البلاغ غير محدد',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<ReportFormCubit, ReportFormState>(
              builder: (context, state) {
                return SearchableDropdown(
                  label: 'نوع البلاغ',
                  reportTypes: state.reportTypes,
                  selectedReportType: state.selectedReportType,
                  isLoading: state.isLoadingReportTypes,
                  onReportTypeSelected: (reportType) {
                    context.read<ReportFormCubit>().setSelectedReportType(
                      reportType,
                    );
                  },
                  hintText: 'اختر نوع البلاغ',
                  searchHint: 'ابحث عن نوع البلاغ',
                );
              },
            );
          },
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

// Enhanced SearchableDropdown widget with ReportTypeModel support
class SearchableDropdown extends StatefulWidget {
  final String label;
  final List<ReportTypeModel> reportTypes;
  final ReportTypeModel? selectedReportType;
  final bool isLoading;
  final Function(ReportTypeModel) onReportTypeSelected;
  final String hintText;
  final String searchHint;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.reportTypes,
    required this.selectedReportType,
    required this.isLoading,
    required this.onReportTypeSelected,
    required this.hintText,
    this.searchHint = 'ابحث...',
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<ReportTypeModel> _filteredItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.reportTypes;

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
    _filteredItems = widget.reportTypes;
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
                  _filteredItems = widget.reportTypes;
                } else {
                  _filteredItems =
                      widget.reportTypes
                          .where(
                            (item) =>
                                item.nameAr.toLowerCase().contains(
                                  query.toLowerCase(),
                                ) ||
                                item.name.toLowerCase().contains(
                                  query.toLowerCase(),
                                ),
                          )
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
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
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          suffixIcon:
                              _isSearching
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
                    child:
                        _filteredItems.isEmpty
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
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      item.nameAr,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      widget.onReportTypeSelected(item);
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
    if (widget.isLoading) {
      return Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.selectedReportType?.nameAr ?? widget.hintText,
        suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
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
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      validator: (value) {
        if (widget.selectedReportType == null) {
          return 'يرجى اختيار نوع البلاغ';
        }
        return null;
      },
      onTap:
          widget.reportTypes.isNotEmpty
              ? () => _showBottomSheet(context)
              : null,
    );
  }
}
