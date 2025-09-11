import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/extracted_document_data.dart';

class ScanPreviewWidget extends StatelessWidget {
  final ExtractedDocumentData extractedData;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const ScanPreviewWidget({
    super.key,
    required this.extractedData,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getConfidenceIcon(),
                  color: _getConfidenceColor(),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نتائج المسح',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'دقة المسح: ${(extractedData.confidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _getConfidenceColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Confidence indicator
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _getConfidenceColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: _getConfidenceColor().withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  _getConfidenceIcon(),
                  color: _getConfidenceColor(),
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getConfidenceTitle(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _getConfidenceColor(),
                        ),
                      ),
                      if (!extractedData.isHighConfidence) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _getConfidenceMessage(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _getConfidenceColor(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Extracted data
          Text(
            'البيانات المستخرجة',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),

          _buildDataCard(),

          const Spacer(),

          // Action buttons
          if (extractedData.isLowConfidence) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.orange),
                  foregroundColor: AppColors.orange,
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          Row(
            children: [
              if (!extractedData.isLowConfidence) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('إعادة المحاولة'),
                  ),
                ),
                SizedBox(width: 16.w),
              ],
              Expanded(
                flex: extractedData.isLowConfidence ? 1 : 1,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        extractedData.isLowConfidence
                            ? AppColors.orange
                            : AppColors.primaryColor,
                  ),
                  child: Text(
                    extractedData.isLowConfidence
                        ? 'المتابعة رغم انخفاض الدقة'
                        : 'تأكيد البيانات',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDataRow('الاسم الكامل', extractedData.fullName),
          if (extractedData.documentNumber.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildDataRow('رقم الوثيقة', extractedData.documentNumber),
          ],
          if (extractedData.dateOfBirth.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildDataRow('تاريخ الميلاد', extractedData.dateOfBirth),
          ],
          if (extractedData.nationality != null) ...[
            SizedBox(height: 16.h),
            _buildDataRow('الجنسية', extractedData.nationality!),
          ],
          if (extractedData.expiryDate != null) ...[
            SizedBox(height: 16.h),
            _buildDataRow('تاريخ انتهاء الصلاحية', extractedData.expiryDate!),
          ],
          if (extractedData.gender != null) ...[
            SizedBox(height: 16.h),
            _buildDataRow('النوع', extractedData.gender!),
          ],
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'غير متوفر',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: value.isNotEmpty ? Colors.black : AppColors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor() {
    if (extractedData.isHighConfidence) {
      return AppColors.green;
    } else if (extractedData.isMediumConfidence) {
      return AppColors.orange;
    } else {
      return AppColors.red;
    }
  }

  IconData _getConfidenceIcon() {
    if (extractedData.isHighConfidence) {
      return Icons.check_circle;
    } else if (extractedData.isMediumConfidence) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  String _getConfidenceTitle() {
    if (extractedData.isHighConfidence) {
      return 'دقة عالية';
    } else if (extractedData.isMediumConfidence) {
      return 'دقة متوسطة';
    } else {
      return 'دقة منخفضة';
    }
  }

  String _getConfidenceMessage() {
    if (extractedData.isMediumConfidence) {
      return 'يرجى مراجعة البيانات قبل التأكيد';
    } else {
      return 'ننصح بإعادة التصوير للحصول على نتائج أفضل';
    }
  }
}
