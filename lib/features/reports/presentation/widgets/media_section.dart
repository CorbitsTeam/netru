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
                return _buildMultiMediaUploadArea(context, state);
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

  Widget _buildMultiMediaUploadArea(
    BuildContext context,
    ReportFormState state,
  ) {
    return Column(
      children: [
        // Upload Container
        InkWell(
          onTap: () => _pickMultipleMedia(context),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: double.infinity,
            height: state.selectedMediaFiles.isEmpty ? 150.h : 120.h,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color:
                    state.selectedMediaFiles.isNotEmpty
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[300]!,
                width: state.selectedMediaFiles.isNotEmpty ? 2 : 1.5,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                state.selectedMediaFiles.isEmpty
                    ? _buildMultiUploadPlaceholder()
                    : _buildAddMoreMediaButton(),
          ),
        ),

        // Display selected media files
        if (state.selectedMediaFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildMediaGrid(context, state.selectedMediaFiles),
          const SizedBox(height: 12),
          _buildMediaSummary(state.selectedMediaFiles, context),
        ],

        // Maintain backward compatibility with single media
        if (state.selectedMedia != null &&
            state.selectedMediaFiles.isEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'تم اختيار ملف واحد. استخدم الخيار الجديد لإضافة المزيد',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Convert single media to multi-media
                    if (state.selectedMedia != null) {
                      context.read<ReportFormCubit>().addMediaFile(
                        state.selectedMedia!,
                      );
                      context.read<ReportFormCubit>().removeMedia();
                    }
                  },
                  child: const Text('تحويل', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildMultiUploadPlaceholder() {
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
            Icons.perm_media_outlined,
            size: 40,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'اضغط لرفع عدة ملفات',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'يمكنك اختيار صور وفيديوهات متعددة معاً',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAddMoreMediaButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            size: 30,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'إضافة ملفات أخرى',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(BuildContext context, List<File> mediaFiles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final file = mediaFiles[index];
        return _buildMediaThumbnail(context, file, index);
      },
    );
  }

  Widget _buildMediaThumbnail(BuildContext context, File file, int index) {
    final String extension = file.path.split('.').last.toLowerCase();
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                isImage
                    ? Image.file(
                      file,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                    : Container(
                      color: Colors.grey[100],
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_file_outlined,
                            size: 30,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'فيديو',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => context.read<ReportFormCubit>().removeMediaFile(file),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        // File number
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSummary(List<File> mediaFiles, BuildContext context) {
    final imageCount =
        mediaFiles.where((file) {
          final extension = file.path.split('.').last.toLowerCase();
          return [
            'jpg',
            'jpeg',
            'png',
            'gif',
            'bmp',
            'webp',
          ].contains(extension);
        }).length;
    final videoCount = mediaFiles.length - imageCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'تم اختيار ${mediaFiles.length} ملف${mediaFiles.length > 1 ? '' : ''} '
              '${imageCount > 0 ? '($imageCount صورة${imageCount > 1 ? '' : ''})' : ''}'
              '${videoCount > 0 ? '($videoCount فيديو${videoCount > 1 ? '' : ''})' : ''}',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          TextButton.icon(
            onPressed:
                () => context.read<ReportFormCubit>().clearAllMediaFiles(),
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            label: const Text(
              'حذف الكل',
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

  void _pickMultipleMedia(BuildContext context) async {
    final result = await showModalBottomSheet<List<XFile>?>(
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
                  'اختيار ملفات متعددة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Multiple Images Option
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
                  title: const Text('اختيار صور متعددة'),
                  subtitle: const Text('من معرض الصور'),
                  onTap: () async {
                    final picker = ImagePicker();
                    final files = await picker.pickMultipleMedia(
                      limit: 10,
                      imageQuality: 85,
                    );
                    Navigator.pop(context, files);
                  },
                ),

                // Single Image Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.photo_outlined, color: Colors.blue[600]),
                  ),
                  title: const Text('اختيار صورة واحدة'),
                  subtitle: const Text('من معرض الصور'),
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );
                    Navigator.pop(context, file != null ? [file] : null);
                  },
                ),

                // Single Video Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.videocam_outlined,
                      color: Colors.purple[600],
                    ),
                  ),
                  title: const Text('اختيار فيديو'),
                  subtitle: const Text('من معرض الفيديوهات'),
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickVideo(
                      source: ImageSource.gallery,
                    );
                    Navigator.pop(context, file != null ? [file] : null);
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
    );

    if (result != null && result.isNotEmpty) {
      List<File> validFiles = [];

      for (final xfile in result) {
        final file = File(xfile.path);

        // Validate file exists and is accessible
        if (!await file.exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'الملف ${xfile.name} غير موجود أو لا يمكن الوصول إليه',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          continue;
        }

        final fileSize = await file.length();

        // Check file size (50MB = 52428800 bytes)
        if (fileSize > 52428800) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'الملف ${xfile.name} كبير جداً. الحد الأقصى 50 ميجا',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          continue;
        }

        // Check if file is empty
        if (fileSize == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الملف ${xfile.name} فارغ'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          continue;
        }

        validFiles.add(file);
      }

      if (validFiles.isNotEmpty) {
        context.read<ReportFormCubit>().addMultipleMediaFiles(validFiles);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة ${validFiles.length} ملف بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
