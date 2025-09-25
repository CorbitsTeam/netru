import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/identity_document_entity.dart';

class IdentityDocumentsWidget extends StatelessWidget {
  final List<IdentityDocumentEntity> documents;
  final String? nationality; // إضافة الجنسية لتحديد الوثائق المطلوبة
  final String? userNationalId; // الرقم القومي للمصريين
  final Function(String imageUrl, String title)?
  onImageTap; // callback لعرض الصورة

  const IdentityDocumentsWidget({
    super.key,
    required this.documents,
    this.nationality,
    this.userNationalId,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final requiredDocs = _getRequiredDocuments();
    final missingDocs = _getMissingDocuments(requiredDocs);

    return Column(
      children: [
        // عرض الوثائق الموجودة
        ...documents.map((doc) => _buildDocumentCard(doc)),

        // عرض الوثائق المفقودة
        if (missingDocs.isNotEmpty)
          ...missingDocs
              .map((docType) => _buildMissingDocumentCard(docType))
              ,

        // حالة خاصة عندما لا توجد وثائق على الإطلاق
        if (documents.isEmpty && requiredDocs.isNotEmpty) _buildEmptyState(),
      ],
    );
  }

  List<DocumentType> _getRequiredDocuments() {
    // تحديد الوثائق المطلوبة حسب الجنسية
    bool isEgyptian = _isEgyptianUser();

    if (isEgyptian) {
      return [DocumentType.nationalId]; // البطاقة الشخصية للمصريين
    } else {
      return [DocumentType.passport]; // جواز السفر للأجانب
    }
  }

  bool _isEgyptianUser() {
    // أولاً: تحقق من الوثائق الموجودة - إذا كان لديه بطاقة شخصية فهو مصري
    if (documents.any((doc) => doc.docType == DocumentType.nationalId)) {
      return true;
    }

    // ثانياً: تحقق من الرقم القومي المصري (14 رقم)
    if (userNationalId != null && userNationalId!.isNotEmpty) {
      // التحقق من صحة الرقم القومي المصري (14 رقم)
      final cleanId = userNationalId!.replaceAll(RegExp(r'\D'), '');
      if (cleanId.length == 14) {
        return true; // رقم قومي مصري صحيح
      }
    }

    // ثالثاً: تحقق من الجنسية
    if (nationality != null) {
      bool isEgyptianNationality =
          nationality!.toLowerCase().contains('مصر') ||
          nationality!.toLowerCase().contains('egypt') ||
          nationality!.toLowerCase().contains('egyptian');
      if (isEgyptianNationality) {
        return true;
      }
    }

    // رابعاً: إذا كان لديه جواز سفر فقط فهو أجنبي
    if (documents.any((doc) => doc.docType == DocumentType.passport)) {
      return false;
    }

    return true; // افتراضي مصري إذا لم تتوفر معلومات واضحة
  }

  List<DocumentType> _getMissingDocuments(List<DocumentType> requiredDocs) {
    final uploadedTypes = documents.map((doc) => doc.docType).toSet();
    return requiredDocs.where((type) => !uploadedTypes.contains(type)).toList();
  }

  Widget _buildEmptyState() {
    final isEgyptian = _isEgyptianUser();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وثائق هوية مفقودة (إجبارية)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isEgyptian
                          ? 'يجب على المستخدم رفع صورة البطاقة الشخصية (وجه أمامي وخلفي)'
                          : 'يجب على المستخدم رفع صورة جواز السفر',
                      style: TextStyle(fontSize: 12.sp, color: Colors.red[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissingDocumentCard(DocumentType docType) {
    final isEgyptian = _isEgyptianUser();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getDocumentIcon(docType), color: Colors.red, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                docType.arabicName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const Spacer(),
              Chip(
                label: Text(
                  'مفقود',
                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                ),
                backgroundColor: Colors.red,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // عرض الصور المطلوبة
          if (docType == DocumentType.nationalId && isEgyptian)
            Row(
              children: [
                Expanded(child: _buildMissingImagePlaceholder('الوجه الأمامي')),
                SizedBox(width: 8.w),
                Expanded(child: _buildMissingImagePlaceholder('الوجه الخلفي')),
              ],
            )
          else if (docType == DocumentType.passport)
            _buildMissingImagePlaceholder('صورة جواز السفر'),

          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.info, size: 14.sp, color: Colors.red[600]),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  isEgyptian && docType == DocumentType.nationalId
                      ? 'مطلوب رفع صورة واضحة للوجه الأمامي والخلفي للبطاقة الشخصية'
                      : 'مطلوب رفع صورة واضحة لجواز السفر',
                  style: TextStyle(fontSize: 11.sp, color: Colors.red[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissingImagePlaceholder(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.red[700],
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
            color: Colors.red.withOpacity(0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.red, size: 32.sp),
              SizedBox(height: 4.h),
              Text(
                'غير مرفوع',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(IdentityDocumentEntity document) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getDocumentIcon(document.docType),
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                document.docType.arabicName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text(
                  'مرفوع',
                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                ),
                backgroundColor: Colors.green,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Document images
          _buildDocumentImages(document),

          SizedBox(height: 12.h),

          // Upload date
          Row(
            children: [
              Icon(Icons.upload_file, size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                'تم الرفع: ${_formatDateTime(document.uploadedAt)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentImages(IdentityDocumentEntity document) {
    if (document.docType == DocumentType.nationalId) {
      // البطاقة الشخصية المصرية - وجه أمامي وخلفي
      return Column(
        children: [
          // معلومات الوثيقة
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'تم رفع البطاقة الشخصية في ${_formatDateTime(document.uploadedAt)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // صور البطاقة
          Row(
            children: [
              if (document.frontImageUrl != null)
                Expanded(
                  child: _buildDocumentImage(
                    'وجه البطاقة الأمامي',
                    document.frontImageUrl!,
                  ),
                ),
              if (document.frontImageUrl == null)
                Expanded(
                  child: _buildMissingImagePlaceholder('وجه البطاقة الأمامي'),
                ),
              SizedBox(width: 8.w),
              if (document.backImageUrl != null)
                Expanded(
                  child: _buildDocumentImage(
                    'ظهر البطاقة',
                    document.backImageUrl!,
                  ),
                ),
              if (document.backImageUrl == null)
                Expanded(child: _buildMissingImagePlaceholder('ظهر البطاقة')),
            ],
          ),
        ],
      );
    } else {
      // جواز السفر للأجانب
      return Column(
        children: [
          // معلومات الوثيقة
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.flight, color: Colors.green[600], size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'تم رفع جواز السفر في ${_formatDateTime(document.uploadedAt)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // صورة جواز السفر
          document.frontImageUrl != null
              ? _buildDocumentImage('جواز السفر', document.frontImageUrl!)
              : _buildMissingImagePlaceholder('جواز السفر'),
        ],
      );
    }
  }

  Widget _buildDocumentImage(String title, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: GestureDetector(
              onTap: () {
                if (onImageTap != null) {
                  onImageTap!(imageUrl, title);
                }
              },
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 24.sp),
                          SizedBox(height: 4.h),
                          Text(
                            'خطأ في تحميل الصورة',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
        return Icons.badge;
      case DocumentType.passport:
        return Icons.flight;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
