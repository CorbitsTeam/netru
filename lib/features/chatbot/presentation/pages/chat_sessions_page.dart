import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/routes.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_session_tile.dart';

class ChatSessionsPage extends StatefulWidget {
  const ChatSessionsPage({super.key});

  @override
  State<ChatSessionsPage> createState() => _ChatSessionsPageState();
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();

    // Load user sessions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatCubit.loadUserSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
      floatingActionButton: _buildNewChatFab(),
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
      title: Text(
        'المحادثات',
        style: AppTextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showOptionsMenu(),
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ChatState state) {
    if (state is ChatLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is ChatError) {
      return _buildErrorState(state.message);
    }

    if (state is ChatSessionsLoaded) {
      return _buildSessionsList(state);
    }

    return _buildEmptyState();
  }

  Widget _buildSessionsList(ChatSessionsLoaded state) {
    if (state.sessions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _chatCubit.loadUserSessions();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: state.sessions.length,
        itemBuilder: (context, index) {
          final session = state.sessions[index];
          return ChatSessionTile(
            session: session,
            onTap: () => _openChatSession(session.id),
            onDelete: () => _deleteSession(session.id),
          );
        },
      ),
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
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد محادثات',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ابدأ محادثة جديدة مع المساعد الذكي سوبيك',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _createNewChat(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            icon: Icon(Icons.add, size: 20.sp),
            label: const Text('محادثة جديدة'),
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
            onPressed: () => _chatCubit.loadUserSessions(),
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

  Widget _buildNewChatFab() {
    return FloatingActionButton(
      onPressed: _createNewChat,
      backgroundColor: AppColors.primary,
      child: Icon(Icons.add, color: Colors.white, size: 24.sp),
    );
  }

  void _openChatSession(String sessionId) {
    Navigator.pushNamed(
      context,
      Routes.chatPage,
      arguments: {'sessionId': sessionId},
    );
  }

  void _createNewChat() {
    Navigator.pushNamed(context, Routes.chatPage);
  }

  void _deleteSession(String sessionId) {
    // This would be handled by the repository
    _chatCubit.loadUserSessions(); // Refresh list
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'خيارات المحادثات',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.primary),
                  title: Text('تحديث', style: AppTextStyles.bodyMedium),
                  onTap: () {
                    Navigator.pop(context);
                    _chatCubit.loadUserSessions();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.primary),
                  title: Text('المساعدة', style: AppTextStyles.bodyMedium),
                  onTap: () {
                    Navigator.pop(context);
                    _chatCubit.showHelp();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text(
                    'حول المساعد الذكي',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('المساعد الذكي سوبيك', style: AppTextStyles.titleLarge),
            content: Text(
              'سوبيك هو المساعد الذكي لتطبيق نترو. يساعدك في معرفة المزيد عن التطبيق والقوانين المصرية المتعلقة بالأمان والبلاغات.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'حسناً',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
