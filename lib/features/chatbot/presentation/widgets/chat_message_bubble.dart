import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'typing_animation_widget.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageBubble extends StatefulWidget {
  final ChatMessageEntity message;
  final VoidCallback? onTap;

  const ChatMessageBubble({super.key, required this.message, this.onTap});

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    final isUser = widget.message.type == MessageType.user;
    _slideAnimation = Tween<Offset>(
      begin: Offset(isUser ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.type == MessageType.user;
    final isError = widget.message.type == MessageType.error;
    final isLoading = widget.message.isLoading;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getBubbleColor(isUser, isError),
                          borderRadius: _getBubbleBorderRadius(isUser),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              offset: Offset(0, 2.h),
                              blurRadius: 6.r,
                            ),
                            if (!isUser && widget.message.isStreaming)
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                offset: const Offset(0, 0),
                                blurRadius: 8.r,
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
            ),
          ),
        );
      },
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
    // For assistant messages with streaming enabled
    if (!isUser && widget.message.isStreaming) {
      return TypingAnimationWithSummary(
        text: widget.message.content,
        summary: widget.message.summary,
        textStyle: AppTextStyles.bodyMedium.copyWith(
          color: isError ? AppColors.error : AppColors.textPrimary,
        ),
        typingSpeed: const Duration(milliseconds: 15),
        autoStart: true,
        showCursor: true,
        enableWaveEffect: true,
        isStreaming: true,
        progress: widget.message.streamingProgress,
      );
    }

    // For regular messages (user messages or completed assistant messages)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          widget.message.content,
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                isUser
                    ? Colors.white
                    : isError
                    ? AppColors.error
                    : AppColors.textPrimary,
          ),
        ),
        if (!isUser &&
            widget.message.summary != null &&
            widget.message.summary!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight.withValues(alpha: 0.15),
                  AppColors.primaryLight.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.4),
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'الملخص الذكي',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SelectableText(
                  widget.message.summary!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const TypingIndicator(
              size: 6.0,
              color: AppColors.primary,
              dotCount: 3,
            ),
            SizedBox(width: 8.w),
            Text(
              'جارٍ الكتابة...',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildMessageTime(bool isUser) {
    return Text(
      _formatTime(widget.message.timestamp),
      style: AppTextStyles.labelSmall.copyWith(
        color: isUser ? Colors.white70 : AppColors.textSecondary,
      ),
    );
  }

  Color _getBubbleColor(bool isUser, bool isError) {
    if (isError) return AppColors.errorLight.withValues(alpha: 0.1);
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
