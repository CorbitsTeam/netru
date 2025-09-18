import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netru_app/core/theme/app_colors.dart' show AppColors;
import 'dart:io';
import '../cubit/report_form_cubit.dart';
import '../cubit/report_form_state.dart';

class MediaSection extends StatelessWidget {
  const MediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'الوسائط',
          style: TextStyle(fontSize: 16.sp, color: AppColors.primaryColor),
        ),
        SizedBox(height: 10.h),

        // Media Upload Area
        // If a ReportFormCubit provider exists in the widget tree we use it.
        // Otherwise render a non-interactive read-only media placeholder
        Builder(
          builder: (context) {
            final cubit = _maybeReportFormCubit(context);
            if (cubit == null) {
              return _buildMediaUploadAreaReadOnly(context);
            }

            return BlocBuilder<ReportFormCubit, ReportFormState>(
              builder: (context, state) {
                return _buildMediaUploadArea(context, state);
              },
            );
          },
        ),
      ],
    );
  }

  ReportFormCubit? _maybeReportFormCubit(BuildContext context) {
    try {
      return context.read<ReportFormCubit>();
    } catch (_) {
      return null;
    }
  }

  Widget _buildMediaUploadAreaReadOnly(BuildContext context) {
    // Non-interactive, read-only placeholder for pages that don't provide a cubit
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150.h,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildUploadPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildMediaUploadArea(BuildContext context, ReportFormState state) {
    return Column(
      children: [
        // Upload Container
        InkWell(
          onTap: () => _pickMedia(context),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              color:
                  state.selectedMedia != null
                      ? Colors.grey[50]
                      : Colors.grey[50],
              border: Border.all(
                color:
                    state.selectedMedia != null
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[300]!,
                width: state.selectedMedia != null ? 2 : 1.5,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                state.selectedMedia != null
                    ? _buildSelectedMedia(state.selectedMedia!)
                    : _buildUploadPlaceholder(),
          ),
        ),

        // Media Info and Actions
        if (state.selectedMedia != null) ...[
          const SizedBox(height: 12),
          _buildMediaInfo(context, state.selectedMedia!),
        ] else
          ...[],
      ],
    );
  }

  Widget _buildSelectedMedia(File mediaFile) {
    final String extension = mediaFile.path.split('.').last.toLowerCase();
    final bool isImage = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
    ].contains(extension);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child:
                isImage
                    ? Image.file(mediaFile, fit: BoxFit.cover)
                    : Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_file_outlined,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ملف فيديو',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ),

        // Success overlay
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            size: 40,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'اضغط لرفع الوسائط',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'الحد الأقصى 50 ميغابايت للملفات المسموح بها',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMediaInfo(BuildContext context, File mediaFile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تم اختيار الملف بنجاح',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                FutureBuilder<int>(
                  future: mediaFile.length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final sizeInMB = (snapshot.data! / (1024 * 1024))
                          .toStringAsFixed(2);
                      return Text(
                        'حجم الملف: $sizeInMB ميجا',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => context.read<ReportFormCubit>().removeMedia(),
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            label: const Text(
              'إزالة',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  void _pickMedia(BuildContext context) async {
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'اختيار وسائط',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Options
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: Colors.green[600],
                    ),
                  ),
                  title: const Text('اختيار صورة'),
                  subtitle: const Text('من معرض الصور'),
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );
                    Navigator.pop(context, file);
                  },
                ),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.videocam_outlined,
                      color: Colors.blue[600],
                    ),
                  ),
                  title: const Text('اختيار فيديو'),
                  subtitle: const Text('من معرض الفيديوهات'),
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickVideo(
                      source: ImageSource.gallery,
                    );
                    Navigator.pop(context, file);
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
    );

    if (result != null) {
      final file = File(result.path);

      // Validate file exists and is accessible
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'الملف المحدد غير موجود أو لا يمكن الوصول إليه',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final fileSize = await file.length();

      // Check file size (50MB = 52428800 bytes)
      if (fileSize > 52428800) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('حجم الملف كبير جداً. الحد الأقصى 50 ميجا'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      // Check if file is empty
      if (fileSize == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الملف المحدد فارغ. يرجى اختيار ملف صالح'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      context.read<ReportFormCubit>().setMedia(file);
    }
  }
}
