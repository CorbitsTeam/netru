import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final String searchHint;
  final List<T> items;
  final T? selectedItem;
  final Function(T?) onChanged;
  final String Function(T) displayText;
  final String Function(T) searchText;
  final bool isLoading;
  final String? errorText;
  final bool isRequired;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.searchHint,
    required this.items,
    required this.onChanged,
    required this.displayText,
    required this.searchText,
    this.selectedItem,
    this.isLoading = false,
    this.errorText,
    this.isRequired = false,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isOpen) {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    setState(() {
      _isOpen = true;
      _filteredItems = widget.items;
      _searchController.clear();
    });
  }

  void _closeDropdown() {
    setState(() {
      _isOpen = false;
      _searchController.clear();
    });
    _focusNode.unfocus();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems =
            widget.items
                .where(
                  (item) => widget
                      .searchText(item)
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _selectItem(T item) {
    widget.onChanged(item);
    _closeDropdown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Text(
                widget.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),

          // Main container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.r),
                bottom: Radius.circular(_isOpen ? 0 : 12.r),
              ),
              border: Border.all(
                color:
                    hasError
                        ? AppColors.error
                        : _isOpen
                        ? AppColors.primary
                        : AppColors.border,
                width: _isOpen ? 2 : 1,
              ),
              color: theme.colorScheme.surface,
            ),
            child: Column(
              children: [
                // Main input/display area
                InkWell(
                  onTap: widget.isLoading ? null : _openDropdown,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              widget.isLoading
                                  ? Row(
                                    children: [
                                      SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'جاري التحميل...',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                      ),
                                    ],
                                  )
                                  : Text(
                                    widget.selectedItem != null
                                        ? widget.displayText(
                                          widget.selectedItem!,
                                        )
                                        : widget.hint,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color:
                                          widget.selectedItem != null
                                              ? theme.colorScheme.onSurface
                                              : theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                    ),
                                  ),
                        ),
                        Icon(
                          _isOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ),

                // Dropdown content
                if (_isOpen) _buildDropdownContent(theme),
              ],
            ),
          ),

          // Error text
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: 8.h, left: 4.w),
              child: Text(
                widget.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownContent(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Search field
          Container(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: Icon(Icons.search, size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                isDense: true,
              ),
            ),
          ),

          // Items list
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            child:
                _filteredItems.isEmpty
                    ? Container(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'لا توجد نتائج',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = widget.selectedItem == item;

                        return InkWell(
                          onTap: () => _selectItem(item),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.displayText(item),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : theme.colorScheme.onSurface,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                    size: 20.sp,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
