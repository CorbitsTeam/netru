import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/chat_message_bubble.dart';

class ChatPage extends StatefulWidget {
  final String? sessionId;

  const ChatPage({super.key, this.sessionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();

    // Load existing session or create new one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.sessionId != null) {
        _chatCubit.loadSession(widget.sessionId!);
      } else {
        _chatCubit.createNewSession();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatSessionLoaded) {
            _scrollToBottom();
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildChatContent(state)),
              _buildInputSection(state),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.sp),
      ),
      title: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatSessionLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المساعد الذكي سوبيك',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (state.isTyping)
                  Text(
                    'يكتب...',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                else
                  Text(
                    'متصل',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
              ],
            );
          }
          return Text(
            'المساعد الذكي سوبيك',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatContent(ChatState state) {
    if (state is ChatLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is ChatError) {
      return _buildErrorState(state.message);
    }

    if (state is ChatSessionLoaded) {
      return _buildMessagesList(state);
    }

    if (state is ChatHelpDisplayed) {
      return _buildHelpContent(state.helpContent);
    }

    return _buildEmptyState();
  }

  Widget _buildMessagesList(ChatSessionLoaded state) {
    if (state.session.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: state.session.messages.length,
      itemBuilder: (context, index) {
        final message = state.session.messages[index];
        return ChatMessageBubble(
          message: message,
          onTap: () => _showMessageOptions(message.content),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy, size: 40.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'مرحباً! أنا سوبيك',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'مساعدك الذكي في تطبيق نترو\nاسألني عن أي شيء!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.error),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _chatCubit.createNewSession(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('المحاولة مرة أخرى'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpContent(String helpContent) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المساعدة',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(helpContent, style: AppTextStyles.bodyMedium),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _chatCubit.clearCurrentSession(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('العودة للمحادثة'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ChatState state) {
    final isEnabled = state is ChatSessionLoaded && !state.isTyping;

    return ChatInputField(
      onSendMessage: (message) => _chatCubit.sendMessage(message),
      isEnabled: isEnabled,
      hintText:
          isEnabled
              ? 'اسأل عن تطبيق نترو أو القوانين المصرية...'
              : 'انتظر حتى ينتهي المساعد من الكتابة...',
    );
  }

  void _showMessageOptions(String message) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'خيارات الرسالة',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(Icons.copy, color: AppColors.primary),
                  title: Text('نسخ', style: AppTextStyles.bodyMedium),
                  onTap: () {
                    Navigator.pop(context);
                    // Copy message to clipboard
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: AppColors.primary),
                  title: Text('مشاركة', style: AppTextStyles.bodyMedium),
                  onTap: () {
                    Navigator.pop(context);
                    // Share message
                  },
                ),
              ],
            ),
          ),
    );
  }
}
