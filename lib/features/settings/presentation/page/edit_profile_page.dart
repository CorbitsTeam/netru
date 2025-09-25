import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:netru_app/core/di/injection_container.dart' as di;
import 'package:netru_app/features/auth/domain/usecases/update_user_profile.dart';
import 'package:netru_app/features/auth/domain/usecases/upload_profile_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userHelper = UserDataHelper();
    final user = userHelper.getCurrentUser();

    if (user != null) {
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _locationController.text = user.location;
      _addressController.text = user.address ?? '';
      _currentImageUrl = user.profileImage;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'تعديل الملف الشخصي',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child:
                _isLoading
                    ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    )
                    : Text(
                      'حفظ',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'صورة الملف الشخصي',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50.r,
                            backgroundColor: Colors.grey[200],
                            child: _buildProfileImage(),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap:
                                  _isImageUploading ? null : _showImagePicker,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child:
                                    _isImageUploading
                                        ? SizedBox(
                                          width: 16.w,
                                          height: 16.h,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                        )
                                        : Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16.sp,
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'اضغط لتغيير الصورة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),

                // Personal Information Section
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المعلومات الشخصية',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Full Name Field
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'الاسم الكامل',
                        icon: Icons.person,
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'يرجى إدخال الاسم الكامل';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15.h),

                      // Phone Field
                      _buildTextField(
                        controller: _phoneController,
                        label: 'رقم الهاتف',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'يرجى إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Location Field
                      _buildTextField(
                        controller: _locationController,
                        label: 'الموقع',
                        icon: Icons.location_on,
                      ),
                      SizedBox(height: 16.h),

                      // Address Field
                      _buildTextField(
                        controller: _addressController,
                        label: 'العنوان',
                        icon: Icons.home,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: 100.r,
          height: 100.r,
          fit: BoxFit.cover,
        ),
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _currentImageUrl!,
          width: 100.r,
          height: 100.r,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, size: 50.r, color: Colors.grey[600]);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        ),
      );
    } else {
      return Icon(Icons.person, size: 50.r, color: Colors.grey[600]);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(8.w),
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر مصدر الصورة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'الكاميرا',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'المعرض',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40.sp, color: AppColors.primaryColor),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop(); // Close bottom sheet

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Upload image immediately
        await _uploadProfileImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء اختيار الصورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isImageUploading = true;
    });

    try {
      final userHelper = UserDataHelper();
      final user = userHelper.getCurrentUser();

      if (user?.id == null) {
        throw Exception('لا يمكن العثور على معرف المستخدم');
      }

      // Generate unique filename
      final fileName =
          'profile_${user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final uploadUseCase = di.sl<UploadProfileImageUseCase>();
      final result = await uploadUseCase(
        UploadProfileImageParams(
          imageFile: _selectedImage!,
          fileName: fileName,
        ),
      );

      result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (imageUrl) async {
          // Optimistically update the UI so user sees the uploaded image
          setState(() {
            _currentImageUrl = imageUrl;
          });

          // Update the profile_image field in the database immediately
          try {
            final updateUseCase = di.sl<UpdateUserProfileUseCase>();
            final updateResult = await updateUseCase(
              UpdateUserProfileParams(
                userId: user.id.toString(),
                userData: {'profile_image': imageUrl},
              ),
            );

            updateResult.fold(
              (updateFailure) {
                throw Exception(
                  'فشل في تحديث الملف الشخصي: ${updateFailure.message}',
                );
              },
              (updatedUser) async {
                // Force complete refresh from database to ensure all data is current
                final refreshSuccess = await userHelper.forceCompleteRefresh();

                if (refreshSuccess) {
                  final freshUser = userHelper.getCurrentUser();
                  setState(() {
                    _currentImageUrl = freshUser?.profileImage;
                  });
                } else {
                  // Fallback: save the updated user we got from the use case
                  await userHelper.saveCurrentUser(updatedUser);
                  setState(() {
                    _currentImageUrl = updatedUser.profileImage;
                  });
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم رفع الصورة وتحديث الملف الشخصي بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            );
          } catch (e) {
            // If updating the database fails, show error but keep the uploaded image in UI
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم رفع الصورة لكن فشل في تحديث قاعدة البيانات: $e',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            // Keep optimistic UI state
            setState(() {
              _currentImageUrl = imageUrl;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في رفع الصورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userHelper = UserDataHelper();
      final user = userHelper.getCurrentUser();

      if (user?.id == null) {
        throw Exception('لا يمكن العثور على معرف المستخدم');
      }

      final updateData = {
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        // 'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
      };

      // Add profile image URL if it was updated
      if (_currentImageUrl != null && _currentImageUrl != user!.profileImage) {
        updateData['profile_image'] = _currentImageUrl!;
      }

      final updateUseCase = di.sl<UpdateUserProfileUseCase>();
      final result = await updateUseCase(
        UpdateUserProfileParams(
          userId: user!.id.toString(),
          userData: updateData,
        ),
      );

      result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (updatedUser) async {
          // Force complete refresh from database to ensure all data is current
          final refreshSuccess = await userHelper.forceCompleteRefresh();

          if (refreshSuccess) {
            final freshUser = userHelper.getCurrentUser();
            setState(() {
              _currentImageUrl = freshUser?.profileImage;
            });
          } else {
            // Fallback: save the updated user we got from the use case
            await userHelper.saveCurrentUser(updatedUser);
            setState(() {
              _currentImageUrl = updatedUser.profileImage;
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ التغييرات بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حفظ التغييرات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
