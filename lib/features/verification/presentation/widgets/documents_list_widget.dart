import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/identity_document.dart';

class DocumentsListWidget extends StatelessWidget {
  final List<IdentityDocument> documents;

  const DocumentsListWidget({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children:
          documents.map((document) => _buildDocumentItem(document)).toList(),
    );
  }

  Widget _buildDocumentItem(IdentityDocument document) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: _getStatusColor(document.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getDocumentIcon(document.type),
                  color: _getStatusColor(document.status),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDocumentTypeName(document.type),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      document.fullName,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(document.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _getStatusName(document.status),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getStatusColor(document.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildInfoChip('رقم الوثيقة', document.documentNumber),
              SizedBox(width: 8.w),
              _buildInfoChip('تاريخ الرفع', _formatDate(document.createdAt)),
            ],
          ),
          if (document.status == DocumentStatus.rejected &&
              document.rejectionReason != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: AppColors.red, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سبب الرفض:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          document.rejectionReason!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 10.sp, color: AppColors.grey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 48.sp, color: AppColors.grey),
          SizedBox(height: 16.h),
          Text(
            'لا توجد وثائق',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم رفع أي وثائق بعد',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppColors.green;
      case DocumentStatus.pending:
        return AppColors.orange;
      case DocumentStatus.rejected:
        return AppColors.red;
    }
  }

  String _getStatusName(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return 'تم التحقق';
      case DocumentStatus.pending:
        return 'قيد المراجعة';
      case DocumentStatus.rejected:
        return 'مرفوض';
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
        return Icons.credit_card;
      case DocumentType.passport:
        return Icons.import_contacts;
    }
  }

  String _getDocumentTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
        return 'بطاقة الرقم القومي';
      case DocumentType.passport:
        return 'جواز السفر';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
