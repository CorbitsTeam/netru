import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final VoidCallback? onTap;

  const ChatMessageBubble({super.key, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isError = message.type == MessageType.error;
    final isLoading = message.isLoading;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) _buildAssistantAvatar(),
            if (!isUser) SizedBox(width: 8.w),
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 280.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _getBubbleColor(isUser, isError),
                  borderRadius: _getBubbleBorderRadius(isUser),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      offset: Offset(0, 2.h),
                      blurRadius: 4.r,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      _buildTypingIndicator()
                    else
                      _buildMessageContent(isUser, isError),
                    SizedBox(height: 4.h),
                    _buildMessageTime(isUser),
                  ],
                ),
              ),
            ),
            if (isUser) SizedBox(width: 8.w),
            if (isUser) _buildUserAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantAvatar() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.smart_toy, color: Colors.white, size: 20.sp),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.white, size: 20.sp),
    );
  }

  Widget _buildMessageContent(bool isUser, bool isError) {
    return SelectableText(
      message.content,
      style: AppTextStyles.bodyMedium.copyWith(
        color:
            isUser
                ? Colors.white
                : isError
                ? AppColors.error
                : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        SizedBox(width: 4.w),
        _buildDot(1),
        SizedBox(width: 4.w),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageTime(bool isUser) {
    return Text(
      _formatTime(message.timestamp),
      style: AppTextStyles.labelSmall.copyWith(
        color: isUser ? Colors.white70 : AppColors.textSecondary,
      ),
    );
  }

  Color _getBubbleColor(bool isUser, bool isError) {
    if (isError) return AppColors.errorLight.withOpacity(0.1);
    if (isUser) return AppColors.primary;
    return AppColors.surface;
  }

  BorderRadius _getBubbleBorderRadius(bool isUser) {
    return BorderRadius.only(
      topLeft: Radius.circular(16.r),
      topRight: Radius.circular(16.r),
      bottomLeft: isUser ? Radius.circular(16.r) : Radius.circular(4.r),
      bottomRight: isUser ? Radius.circular(4.r) : Radius.circular(16.r),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}د';
    } else {
      return 'الآن';
    }
  }
}
