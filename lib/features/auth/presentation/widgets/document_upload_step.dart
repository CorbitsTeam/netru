import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/enhanced_document_scanner_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/extracted_document_data.dart';
import '../../domain/entities/identity_document_entity.dart';

class DocumentUploadStep extends StatelessWidget {
  final UserType userType;
  final List<File> selectedDocuments;
  final Function(List<File>) onDocumentsChanged;
  final Function(ExtractedDocumentData?)? onDataExtracted;
  final bool isProcessingOCR;

  const DocumentUploadStep({
    super.key,
    required this.userType,
    required this.selectedDocuments,
    required this.onDocumentsChanged,
    this.onDataExtracted,
    this.isProcessingOCR = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Title
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'رفع المستندات المطلوبة',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: Text(
                  _getSubtitle(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Requirements card
              _buildRequirementsCard(),

              SizedBox(height: 24.h),

              // Document picker
              _buildDocumentPicker(),

              if (isProcessingOCR) ...[
                SizedBox(height: 24.h),
                _buildOCRProcessingIndicator(),
              ],

              SizedBox(height: 24.h),

              // Tips card
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubtitle() {
    if (userType == UserType.citizen) {
      return 'سنحتاج إلى صور واضحة للوجه الأمامي والخلفي للبطاقة الشخصية';
    } else {
      return 'سنحتاج إلى صورة واضحة لصفحة البيانات في جواز السفر';
    }
  }

  Widget _buildRequirementsCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.info.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: AppColors.info,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'المتطلبات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...(_getRequirements().map((req) => _buildRequirementItem(req))),
          ],
        ),
      ),
    );
  }

  List<String> _getRequirements() {
    if (userType == UserType.citizen) {
      return [
        'الوجه الأمامي للبطاقة الشخصية',
        'الوجه الخلفي للبطاقة الشخصية',
        'الصور واضحة وغير مشوشة',
        'تظهر جميع البيانات بوضوح',
      ];
    } else {
      return [
        'صفحة البيانات في جواز السفر',
        'الصورة واضحة وغير مشوشة',
        'تظهر جميع البيانات بوضوح',
        'جواز السفر صالح وغير منتهي الصلاحية',
      ];
    }
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            margin: EdgeInsets.only(top: 6.h, left: 8.w),
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              requirement,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.info,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOCRProcessingIndicator() {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        margin: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.info.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'جاري قراءة البيانات من المستند...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'قد تستغرق هذه العملية بضع ثوانٍ',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.success.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.success,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'نصائح للحصول على أفضل النتائج',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '• تأكد من وضوح الإضاءة\n• احرص على استقامة المستند\n• تجنب الانعكاسات والظلال',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.success,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userType == UserType.citizen
              ? 'صور البطاقة الشخصية'
              : 'صورة جواز السفر',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          userType == UserType.citizen
              ? 'قم برفع صورة واضحة للوجه الأمامي والخلفي للبطاقة'
              : 'قم برفع صورة واضحة لصفحة البيانات في جواز السفر',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 16.h),

        // Upload buttons
        Row(
          children: [
            Expanded(
              child: _buildUploadButton(
                icon: Icons.document_scanner_outlined,
                label: 'مسح تلقائي',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildUploadButton(
                icon: Icons.photo_library_outlined,
                label: 'من المعرض',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),

        if (selectedDocuments.isNotEmpty) ...[
          SizedBox(height: 16.h),
          _buildPreview(),
        ],
      ],
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final int maxFiles = userType == UserType.citizen ? 2 : 1;
    final bool canAddMore = selectedDocuments.length < maxFiles;

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: GestureDetector(
        onTap: canAddMore ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color:
                canAddMore
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  canAddMore
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32.sp,
                color: canAddMore ? AppColors.primary : Colors.grey,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: canAddMore ? AppColors.primary : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصور المحددة (${selectedDocuments.length}/${userType == UserType.citizen ? 2 : 1})',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.2,
          ),
          itemCount: selectedDocuments.length,
          itemBuilder: (context, index) {
            return _buildPreviewItem(selectedDocuments[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildPreviewItem(File file, int index) {
    return FadeInUp(
      duration: Duration(milliseconds: 800 + (index * 100)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              // Image
              Positioned.fill(child: Image.file(file, fit: BoxFit.cover)),

              // Remove button
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.white),
                  ),
                ),
              ),

              // Image label
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    _getImageLabel(index),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getImageLabel(int index) {
    if (userType == UserType.citizen) {
      return index == 0 ? 'الوجه الأمامي' : 'الوجه الخلفي';
    }
    return 'جواز السفر';
  }

  /// Scan document using enhanced scanner with OCR (Camera only)
  // Future<void> _scanDocumentWithOCR() async {
  //   try {
  //     final int maxFiles = userType == UserType.citizen ? 2 : 1;
  //     if (selectedDocuments.length >= maxFiles) {
  //       return;
  //     }
  //
  //     final DocumentType documentType =
  //         userType == UserType.citizen
  //             ? DocumentType.nationalId
  //             : DocumentType.passport;
  //
  //     // Use camera scanning only
  //     final result = await EnhancedDocumentScannerService.scanDocument(
  //       documentType: documentType,
  //     );
  //     if (result != null) {
  //       final List<File> newFiles = List.from(selectedDocuments);
  //       newFiles.add(result.imageFile);
  //       onDocumentsChanged(newFiles);
  //
  //       // If we extracted data and have a callback, notify the parent
  //       if (result.extractedData != null && onDataExtracted != null) {
  //         onDataExtracted!(result.extractedData);
  //       }
  //
  //       print('📄 تم مسح المستند بنجاح باستخدام الكاميرا');
  //       print('📊 نسبة الضغط: ${result.compressionRatio.toStringAsFixed(1)}%');
  //       print(
  //         '💾 الحجم الأصلي: ${result.originalImageSize.toStringAsFixed(1)} KB',
  //       );
  //       print(
  //         '💾 الحجم المضغوط: ${result.compressedImageSize.toStringAsFixed(1)} KB',
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ خطأ في مسح المستند: $e');
  //   }
  // }

  /// Pick image from gallery (Simple image selection without OCR)
  Future<void> _pickFromGallery() async {
    try {
      final int maxFiles = userType == UserType.citizen ? 2 : 1;
      if (selectedDocuments.length >= maxFiles) {
        return;
      }

      // Use simple image picker for gallery selection
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        print('📄 لم يتم اختيار صورة');
        return;
      }

      final File imageFile = File(pickedFile.path);
      final List<File> newFiles = List.from(selectedDocuments);
      newFiles.add(imageFile);
      onDocumentsChanged(newFiles);

      print('📄 تم اختيار الصورة من المعرض بنجاح');
      print('📁 مسار الصورة: ${imageFile.path}');

      // Optional: Apply OCR if callback is provided for data extraction
      if (onDataExtracted != null) {
        print('📊 يمكن إضافة معالجة OCR هنا إذا لزم الأمر');
      }
    } catch (e) {
      print('❌ خطأ في اختيار الصورة من المعرض: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      // await _scanDocumentWithOCR();
    } else {
      await _pickFromGallery();
    }
  }

  void _removeImage(int index) {
    final List<File> newFiles = List.from(selectedDocuments);
    newFiles.removeAt(index);
    onDocumentsChanged(newFiles);
  }
}
