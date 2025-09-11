import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/identity_document.dart';

class DocumentTypeSelector extends StatefulWidget {
  final Function(DocumentType) onDocumentTypeSelected;

  const DocumentTypeSelector({super.key, required this.onDocumentTypeSelected});

  @override
  State<DocumentTypeSelector> createState() => _DocumentTypeSelectorState();
}

class _DocumentTypeSelectorState extends State<DocumentTypeSelector> {
  DocumentType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDocumentOption(
          type: DocumentType.nationalId,
          title: 'بطاقة الرقم القومي',
          subtitle: 'للمواطنين المصريين',
          icon: Icons.credit_card,
          isEgyptian: true,
        ),
        SizedBox(height: 16.h),
        _buildDocumentOption(
          type: DocumentType.passport,
          title: 'جواز السفر',
          subtitle: 'للمواطنين الأجانب',
          icon: Icons.import_contacts,
          isEgyptian: false,
        ),
      ],
    );
  }

  Widget _buildDocumentOption({
    required DocumentType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isEgyptian,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
        widget.onDocumentTypeSelected(type);
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.grey,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? AppColors.primaryColor
                                  : Colors.black,
                        ),
                      ),
                      if (isEgyptian) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag,
                                size: 12.sp,
                                color: AppColors.green,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'مصري',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryColor : Colors.grey[400],
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}
