import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_session_entity.dart';

class ChatSessionTile extends StatelessWidget {
  final ChatSessionEntity session;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isSelected;

  const ChatSessionTile({
    super.key,
    required this.session,
    required this.onTap,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage =
        session.messages.isNotEmpty ? session.messages.last : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.primaryLight.withOpacity(0.1)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1.w,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: _buildSessionIcon(),
        title: Text(
          session.title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle:
            lastMessage != null
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Text(
                      lastMessage.content,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatTime(session.updatedAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                )
                : Text(
                  'محادثة جديدة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
        trailing:
            onDelete != null
                ? PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: AppColors.error,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'حذف',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  onSelected: (value) {
                    if (value == 'delete' && onDelete != null) {
                      _showDeleteConfirmation(context);
                    }
                  },
                )
                : Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
      ),
    );
  }

  Widget _buildSessionIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.primary
                : AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Icon(
        Icons.chat_bubble_outline,
        color: isSelected ? Colors.white : AppColors.primary,
        size: 20.sp,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('حذف المحادثة', style: AppTextStyles.titleLarge),
            content: Text(
              'هل أنت متأكد من حذف هذه المحادثة؟ لا يمكن التراجع عن هذا الإجراء.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
                child: Text(
                  'حذف',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} أيام';
      } else {
        return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
