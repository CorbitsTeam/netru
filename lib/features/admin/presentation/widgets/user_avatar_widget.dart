import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String userName;
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  const UserAvatarWidget({
    super.key,
    this.imageUrl,
    required this.userName,
    this.radius = 25,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // إذا كانت الصورة موجودة، عرضها
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius.r,
        backgroundColor: backgroundColor,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: (radius * 2).w,
            height: (radius * 2).h,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
            errorWidget: (context, url, error) => _buildInitialAvatar(),
          ),
        ),
      );
    }

    // إذا لم تكن الصورة موجودة، عرض أول حرف من الاسم
    return _buildInitialAvatar();
  }

  Widget _buildInitialAvatar() {
    return CircleAvatar(
      radius: radius.r,
      backgroundColor: backgroundColor,
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: (radius * 0.7).sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
