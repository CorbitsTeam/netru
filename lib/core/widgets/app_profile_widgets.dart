import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/ui_constants.dart';
import '../theme/app_colors.dart';
import '../utils/user_data_helper.dart';

/// A reusable profile avatar widget with error handling
class AppProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double? radius;
  final VoidCallback? onTap;
  final bool showEditIcon;
  final IconData? fallbackIcon;

  const AppProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius,
    this.onTap,
    this.showEditIcon = false,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius ?? 40.r,
      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
      child:
          imageUrl != null && imageUrl!.isNotEmpty
              ? ClipOval(
                child: Image.network(
                  imageUrl!,
                  width: (radius ?? 40.r) * 2,
                  height: (radius ?? 40.r) * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      fallbackIcon ?? Icons.person,
                      size: radius ?? 40.r,
                      color: AppColors.primaryColor,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: (radius ?? 40.r) * 2,
                      height: (radius ?? 40.r) * 2,
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
              : Icon(
                fallbackIcon ?? Icons.person,
                size: radius ?? 40.r,
                color: AppColors.primaryColor,
              ),
    );

    if (showEditIcon) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.camera_alt, size: 16.r, color: Colors.white),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}

/// A reusable profile header widget
class AppProfileHeader extends StatelessWidget {
  final String? imageUrl;
  final String fullName;
  final String email;
  final VoidCallback? onEditPressed;
  final VoidCallback? onImageTap;
  final bool showEditButton;
  final EdgeInsets? padding;

  const AppProfileHeader({
    super.key,
    this.imageUrl,
    required this.fullName,
    required this.email,
    this.onEditPressed,
    this.onImageTap,
    this.showEditButton = true,
    this.padding,
  });

  factory AppProfileHeader.fromUser({
    VoidCallback? onEditPressed,
    VoidCallback? onImageTap,
    bool showEditButton = true,
    EdgeInsets? padding,
  }) {
    final userHelper = UserDataHelper();
    final user = userHelper.getCurrentUser();
    final userName = userHelper.getUserFullName();

    return AppProfileHeader(
      imageUrl: userHelper.getUserProfileImage(),
      fullName: userName,
      email: user?.email ?? '',
      onEditPressed: onEditPressed,
      onImageTap: onImageTap,
      showEditButton: showEditButton,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('profile_header_container'),
      width: double.infinity,
      padding: padding ?? UIConstants.paddingLarge,
      child: Column(
        children: [
          // Profile Image
          AppProfileAvatar(
            imageUrl: imageUrl,
            onTap: onImageTap,
            showEditIcon: onImageTap != null,
          ),
          UIConstants.verticalSpaceMedium,
          // User Name
          Text(
            fullName,
            style: TextStyle(
              fontSize: UIConstants.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            email,
            style: TextStyle(
              fontSize: UIConstants.fontSizeMedium,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          if (showEditButton && onEditPressed != null) ...[
            UIConstants.verticalSpaceMedium,
            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('edit_profile_button'),
                onPressed: onEditPressed,
                icon: Icon(
                  Icons.edit_outlined,
                  size: UIConstants.iconSizeSmall,
                ),
                label: Text(
                  'تعديل الملف الشخصي',
                  style: TextStyle(fontSize: UIConstants.fontSizeMedium),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: BorderSide(color: AppColors.primaryColor),
                  padding: UIConstants.paddingSymmetricMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: UIConstants.borderRadiusMedium,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
