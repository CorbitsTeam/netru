import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import '../../../../core/utils/image_compression_utils.dart';

class DocumentPicker extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<File> selectedFiles;
  final Function(List<File>) onFilesSelected;
  final int maxFiles;
  final bool showPreview;

  const DocumentPicker({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedFiles,
    required this.onFilesSelected,
    this.maxFiles = 2,
    this.showPreview = true,
  });

  @override
  State<DocumentPicker> createState() => _DocumentPickerState();
}

class _DocumentPickerState extends State<DocumentPicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final file = File(image.path);

        // Compress the image
        final compressedFile = await ImageCompressionUtils.compressImageToSize(
          file,
          targetSizeKB: 1024,
        );

        final fileToAdd = compressedFile ?? file;
        final updatedFiles = List<File>.from(widget.selectedFiles);

        if (updatedFiles.length < widget.maxFiles) {
          updatedFiles.add(fileToAdd);
          widget.onFilesSelected(updatedFiles);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeImage(int index) {
    final updatedFiles = List<File>.from(widget.selectedFiles);
    updatedFiles.removeAt(index);
    widget.onFilesSelected(updatedFiles);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _buildImageSourceSheet(),
    );
  }

  Widget _buildImageSourceSheet() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'اختر مصدر الصورة',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildSourceOption(
                  icon: Icons.camera_alt,
                  title: 'الكاميرا',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSourceOption(
                  icon: Icons.photo_library,
                  title: 'المعرض',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: AppColors.primary),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.subtitle,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          if (widget.selectedFiles.isEmpty) _buildEmptyState(),
          if (widget.selectedFiles.isNotEmpty && widget.showPreview)
            _buildPreviewGrid(),
          if (widget.selectedFiles.length < widget.maxFiles) _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _isLoading ? null : _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.surfaceVariant.withOpacity(0.3),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 48.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'اضغط لإضافة صورة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildPreviewGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1,
          ),
          itemCount: widget.selectedFiles.length,
          itemBuilder: (context, index) {
            return _buildImagePreview(widget.selectedFiles[index], index);
          },
        ),
        if (widget.selectedFiles.isNotEmpty) SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildImagePreview(File file, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              file,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8.w,
          right: 8.w,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.primary.withOpacity(0.1),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'إضافة صورة أخرى',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
