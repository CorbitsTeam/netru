import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) displayText;
  final Function(T?) onChanged;
  final String hintText;
  final String label;
  final IconData? prefixIcon;
  final bool enabled;
  final bool isLoading;
  final Widget Function(T)? customItemBuilder;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.displayText,
    required this.onChanged,
    required this.hintText,
    required this.label,
    this.selectedItem,
    this.prefixIcon,
    this.enabled = true,
    this.isLoading = false,
    this.customItemBuilder,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set initial value if selected
    if (widget.selectedItem != null) {
      _searchController.text = widget.displayText(widget.selectedItem as T);
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_isExpanded) {
        _expand();
      }
    });
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
    }
    if (widget.selectedItem != oldWidget.selectedItem) {
      if (widget.selectedItem != null) {
        _searchController.text = widget.displayText(widget.selectedItem as T);
      } else {
        _searchController.clear();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _isExpanded = true);
    _animationController.forward();
  }

  void _collapse() {
    setState(() => _isExpanded = false);
    _animationController.reverse();
    _focusNode.unfocus();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredItems =
          widget.items
              .where(
                (item) => widget
                    .displayText(item)
                    .toLowerCase()
                    .contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _selectItem(T item) {
    _searchController.text = widget.displayText(item);
    widget.onChanged(item);
    _collapse();
  }

  void _clearSelection() {
    _searchController.clear();
    widget.onChanged(null);
    setState(() {
      _filteredItems = widget.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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
            boxShadow:
                _isExpanded
                    ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
          ),
          child: Column(
            children: [
              // Search Field
              TextFormField(
                controller: _searchController,
                focusNode: _focusNode,
                enabled: widget.enabled && !widget.isLoading,
                onChanged: _onSearchChanged,
                onTap: _expand,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon:
                      widget.prefixIcon != null
                          ? Container(
                            padding: EdgeInsets.all(12.w),
                            child: Icon(
                              widget.prefixIcon,
                              color:
                                  _isExpanded
                                      ? AppColors.primaryColor
                                      : Colors.grey[400],
                              size: 22.sp,
                            ),
                          )
                          : null,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isLoading)
                        Container(
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
                      else if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: _clearSelection,
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[400],
                            size: 20.sp,
                          ),
                        ),
                      IconButton(
                        onPressed: _isExpanded ? _collapse : _expand,
                        icon: AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color:
                                _isExpanded
                                    ? AppColors.primaryColor
                                    : Colors.grey[400],
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: _isExpanded ? Colors.white : Colors.grey[50],
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
              ),

              // Dropdown List
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 250.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                    border: Border.all(color: AppColors.primaryColor, width: 2),
                  ),
                  child:
                      _filteredItems.isEmpty
                          ? Container(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  color: Colors.grey[400],
                                  size: 32.sp,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'لا توجد نتائج',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            itemCount: _filteredItems.length,
                            separatorBuilder:
                                (context, index) =>
                                    Divider(height: 1, color: Colors.grey[200]),
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isSelected = item == widget.selectedItem;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _selectItem(item),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 12.h,
                                    ),
                                    color:
                                        isSelected
                                            ? AppColors.primaryColor.withValues(
                                              alpha: 0.05,
                                            )
                                            : null,
                                    child:
                                        widget.customItemBuilder != null
                                            ? widget.customItemBuilder!(item)
                                            : Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    widget.displayText(item),
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color:
                                                          isSelected
                                                              ? AppColors
                                                                  .primaryColor
                                                              : Colors
                                                                  .grey[700],
                                                      fontWeight:
                                                          isSelected
                                                              ? FontWeight.w600
                                                              : FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check,
                                                    color:
                                                        AppColors.primaryColor,
                                                    size: 20.sp,
                                                  ),
                                              ],
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
