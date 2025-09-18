import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;
  final String? hintText;

  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
    this.hintText,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isMessageEmpty = true;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isMessageEmpty = _textController.text.trim().isEmpty;
    });
  }

  void _sendMessage() {
    final message = _textController.text.trim();
    if (message.isNotEmpty && widget.isEnabled) {
      widget.onSendMessage(message);
      _textController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.w)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quick action button
            _buildQuickActionButton(),
            SizedBox(width: 12.w),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.border, width: 1.w),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        enabled: widget.isEnabled,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        onSubmitted: (_) => _sendMessage(),
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? 'اكتب رسالتك هنا...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                    // Attachment button
                  ],
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Send button
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton() {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border, width: 1.w),
      ),
      child: IconButton(
        onPressed: widget.isEnabled ? _showQuickActions : null,
        icon: Icon(
          Icons.add,
          color: widget.isEnabled ? AppColors.primary : AppColors.disabled,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color:
            _isMessageEmpty || !widget.isEnabled
                ? AppColors.disabled
                : AppColors.primary,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: IconButton(
        onPressed: _isMessageEmpty || !widget.isEnabled ? null : _sendMessage,
        icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => _QuickActionsBottomSheet(
            onActionSelected: (action) {
              Navigator.pop(context);
              widget.onSendMessage(action);
            },
          ),
    );
  }
}

class _QuickActionsBottomSheet extends StatelessWidget {
  final Function(String) onActionSelected;

  const _QuickActionsBottomSheet({required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'إجراءات سريعة',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildQuickActionTile(
            icon: Icons.help_outline,
            title: 'عرض المساعدة',
            action: 'مساعدة',
          ),
          _buildQuickActionTile(
            icon: Icons.gavel,
            title: 'القوانين الجنائية',
            action: 'قوانين جنائي',
          ),
          _buildQuickActionTile(
            icon: Icons.traffic,
            title: 'قوانين المرور',
            action: 'قوانين مرور',
          ),
          _buildQuickActionTile(
            icon: Icons.security,
            title: 'حماية البيانات',
            action: 'قوانين بيانات',
          ),
          _buildQuickActionTile(
            icon: Icons.phone,
            title: 'معلومات التطبيق',
            action: 'ما هو تطبيق نترو؟',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String action,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      onTap: () => onActionSelected(action),
    );
  }
}
