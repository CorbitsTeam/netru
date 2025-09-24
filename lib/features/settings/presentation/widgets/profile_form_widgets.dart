import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netru_app/core/widgets/app_widgets.dart';

/// Reusable form field widget with consistent styling
class AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? hintText;

  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        contentPadding: UIConstants.paddingSymmetricMedium,
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMedium,
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMedium,
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMedium,
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: UIConstants.borderRadiusMedium,
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}

/// Image picker widget for profile image
class ProfileImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? currentImageUrl;
  final bool isUploading;
  final VoidCallback onPickImage;
  final double size;

  const ProfileImagePicker({
    super.key,
    this.selectedImage,
    this.currentImageUrl,
    required this.isUploading,
    required this.onPickImage,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: UIConstants.defaultShadow,
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          if (isUploading)
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: isUploading ? null : onPickImage,
              child: Container(
                padding: UIConstants.paddingSmall,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: UIConstants.defaultShadow,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: UIConstants.iconSizeMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover);
    } else if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      return Image.network(
        currentImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
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
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: size * 0.6, color: Colors.grey[600]);
        },
      );
    } else {
      return Icon(Icons.person, size: size * 0.6, color: Colors.grey[600]);
    }
  }
}

/// Image source selection bottom sheet
class ImageSourceBottomSheet extends StatelessWidget {
  final Function(ImageSource) onSourceSelected;

  const ImageSourceBottomSheet({super.key, required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: UIConstants.paddingLarge,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: UIConstants.borderRadiusExtraLarge.topLeft,
          topRight: UIConstants.borderRadiusExtraLarge.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          UIConstants.verticalSpaceLarge,
          Text(
            'اختر مصدر الصورة',
            style: TextStyle(
              fontSize: UIConstants.fontSizeExtraLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          UIConstants.verticalSpaceLarge,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageSourceOption(
                context,
                icon: Icons.camera_alt,
                label: 'الكاميرا',
                onTap: () {
                  Navigator.of(context).pop();
                  onSourceSelected(ImageSource.camera);
                },
              ),
              _buildImageSourceOption(
                context,
                icon: Icons.photo_library,
                label: 'المعرض',
                onTap: () {
                  Navigator.of(context).pop();
                  onSourceSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
          UIConstants.verticalSpaceLarge,
        ],
      ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: UIConstants.paddingLarge,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: UIConstants.borderRadiusMedium,
          boxShadow: UIConstants.defaultShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: UIConstants.iconSizeExtraLarge,
              color: Theme.of(context).primaryColor,
            ),
            UIConstants.verticalSpaceSmall,
            Text(
              label,
              style: TextStyle(
                fontSize: UIConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the image source selection bottom sheet
  static void show(
    BuildContext context, {
    required Function(ImageSource) onSourceSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              ImageSourceBottomSheet(onSourceSelected: onSourceSelected),
    );
  }
}

/// Profile form section widget
class ProfileFormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets? padding;

  const ProfileFormSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: UIConstants.paddingHorizontalMedium.copyWith(bottom: 16),
      child: Padding(
        padding: padding ?? UIConstants.paddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: UIConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            UIConstants.verticalSpaceMedium,
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Save profile button widget
class SaveProfileButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const SaveProfileButton({super.key, required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: UIConstants.paddingHorizontalMedium,
      child: AppGradientButton(
        text: 'حفظ التغييرات',
        onPressed: onPressed,
        isLoading: isLoading,
        icon: isLoading ? null : const Icon(Icons.save, color: Colors.white),
        height: 50,
        gradientColors: [
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor.withValues(alpha: 0.8),
        ],
      ),
    );
  }
}
