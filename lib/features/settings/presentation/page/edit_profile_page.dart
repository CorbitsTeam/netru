import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netru_app/core/widgets/app_widgets.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';

import 'package:netru_app/features/settings/presentation/widgets/profile_form_widgets.dart';

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
            fontSize: UIConstants.fontSizeExtraLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'حفظ',
              style: TextStyle(
                fontSize: UIConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color:
                    _isLoading ? Colors.grey : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              UIConstants.verticalSpaceLarge,

              // Profile Image Section
              ProfileFormSection(
                title: 'الصورة الشخصية',
                children: [
                  ProfileImagePicker(
                    selectedImage: _selectedImage,
                    currentImageUrl: _currentImageUrl,
                    isUploading: _isImageUploading,
                    onPickImage: _showImagePicker,
                  ),
                ],
              ),

              // Personal Information Section
              ProfileFormSection(
                title: 'المعلومات الشخصية',
                children: [
                  AppFormField(
                    controller: _fullNameController,
                    label: 'الاسم الكامل',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال الاسم الكامل';
                      }
                      return null;
                    },
                  ),
                  UIConstants.verticalSpaceMedium,
                  AppFormField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              // Location Information Section
              ProfileFormSection(
                title: 'معلومات الموقع',
                children: [
                  AppFormField(
                    controller: _locationController,
                    label: 'المدينة',
                    icon: Icons.location_city,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال المدينة';
                      }
                      return null;
                    },
                  ),
                  UIConstants.verticalSpaceMedium,
                  AppFormField(
                    controller: _addressController,
                    label: 'العنوان التفصيلي',
                    icon: Icons.home,
                    maxLines: 3,
                    hintText: 'اكتب عنوانك التفصيلي (اختياري)',
                  ),
                ],
              ),

              UIConstants.verticalSpaceLarge,

              // Save Button
              SaveProfileButton(isLoading: _isLoading, onPressed: _saveProfile),

              UIConstants.verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker() {
    ImageSourceBottomSheet.show(context, onSourceSelected: _pickImage);
  }

  Future<void> _pickImage(ImageSource source) async {
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
            content: Text('خطأ في اختيار الصورة: $e'),
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
        throw Exception('لم يتم العثور على بيانات المستخدم');
      }

      // TODO: Implement unified auth repository upload functionality
      // Upload functionality will be added later
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رفع الصورة معطل مؤقتاً'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userHelper = UserDataHelper();
      final user = userHelper.getCurrentUser();

      if (user?.id == null) {
        throw Exception('لم يتم العثور على بيانات المستخدم');
      }

      final updateData = {
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
      };

      // Add profile image URL if it was updated
      if (_currentImageUrl != null && _currentImageUrl != user!.profileImage) {
        updateData['profile_image'] = _currentImageUrl!;
      }

      // TODO: Implement unified auth repository update functionality
      // Update functionality will be added later
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تحديث الملف الشخصي معطل مؤقتاً'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تحديث الملف الشخصي: $e'),
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
