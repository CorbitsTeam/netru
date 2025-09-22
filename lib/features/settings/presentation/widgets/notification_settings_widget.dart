import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/services/notification_preferences_service.dart';
import 'package:netru_app/core/services/settings_service.dart';
import 'package:netru_app/features/settings/presentation/bloc/settings_bloc.dart';

class NotificationSettingsWidget
    extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  State<NotificationSettingsWidget>
  createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  final _notificationService =
      NotificationPreferencesService();

  bool _reportsNotifications = true;
  bool _newsNotifications = true;
  bool _securityNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final reportsNotifications =
          await _notificationService
              .isReportsNotificationsEnabled();
      final newsNotifications =
          await _notificationService
              .isNewsNotificationsEnabled();
      final securityNotifications =
          await _notificationService
              .isSecurityNotificationsEnabled();

      if (mounted) {
        setState(() {
          _reportsNotifications =
              reportsNotifications;
          _newsNotifications = newsNotifications;
          _securityNotifications =
              securityNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateNotificationsSetting(
    bool value,
  ) async {
    if (!value) {
      final shouldDisable =
          await _showDisableConfirmationDialog();
      if (!shouldDisable) return;
    }

    context.read<SettingsBloc>().add(
      SettingsNotificationChanged(value),
    );
    await _notificationService
        .setNotificationsEnabled(value);

    if (value) {
      final hasPermission =
          await _notificationService
              .checkNotificationPermission();
      if (!hasPermission) {
        final granted =
            await _notificationService
                .requestNotificationPermission();
        if (!granted && mounted) {
          _showPermissionDeniedDialog();
        }
      }
    }
  }

  Future<bool>
  _showDisableConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text(
                  'تعطيل الإشعارات',
                ),
                content: const Text(
                  'هل أنت متأكد من تعطيل جميع الإشعارات؟ لن تتلقى أي تنبيهات مهمة حول التقارير أو التحديثات الأمنية.',
                ),
                actions: [
                  TextButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pop(false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pop(true),
                    child: const Text('تعطيل'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تم رفض الصلاحية'),
            content: const Text(
              'لتفعيل الإشعارات، يرجى الذهاب إلى إعدادات التطبيق وتفعيل صلاحية الإشعارات.',
            ),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(
                          context,
                        ).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _notificationService
                      .openNotificationSettings();
                },
                child: const Text('إعدادات'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return BlocBuilder<
      SettingsBloc,
      SettingsState
    >(
      buildWhen: (previous, current) {
        // Only rebuild when notification-related settings change
        if (previous is SettingsLoaded &&
            current is SettingsLoaded) {
          return previous
                      .settings
                      .notificationsEnabled !=
                  current
                      .settings
                      .notificationsEnabled ||
              previous.settings.soundEnabled !=
                  current.settings.soundEnabled ||
              previous
                      .settings
                      .vibrationEnabled !=
                  current
                      .settings
                      .vibrationEnabled;
        }
        return true;
      },
      builder: (context, state) {
        final notificationsEnabled =
            state is SettingsLoaded
                ? state
                    .settings
                    .notificationsEnabled
                : true;
        final soundEnabled =
            state is SettingsLoaded
                ? state.settings.soundEnabled
                : true;
        final vibrationEnabled =
            state is SettingsLoaded
                ? state.settings.vibrationEnabled
                : true;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildNotificationTile(
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              subtitle:
                  'تفعيل أو إلغاء جميع الإشعارات',
              value: notificationsEnabled,
              onChanged:
                  _updateNotificationsSetting,
            ),

            if (notificationsEnabled) ...[
              SizedBox(height: 16.h),

              _buildNotificationTile(
                icon: Icons.volume_up_outlined,
                title: 'الصوت',
                subtitle:
                    'تشغيل الصوت مع الإشعارات',
                value: soundEnabled,
                onChanged: (value) async {
                  SettingsService().updateSound(
                    context,
                    value,
                  );
                  await _notificationService
                      .setSoundEnabled(value);
                },
              ),

              SizedBox(height: 16.h),

              _buildNotificationTile(
                icon: Icons.vibration_outlined,
                title: 'الاهتزاز',
                subtitle:
                    'تفعيل الاهتزاز مع الإشعارات',
                value: vibrationEnabled,
                onChanged: (value) async {
                  SettingsService()
                      .updateVibration(
                        context,
                        value,
                      );
                  await _notificationService
                      .setVibrationEnabled(value);
                },
              ),

              SizedBox(height: 24.h),

              Text(
                'أنواع الإشعارات',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.color,
                ),
              ),

              SizedBox(height: 16.h),

              _buildNotificationTile(
                icon: Icons.report_outlined,
                title: 'إشعارات التقارير',
                subtitle:
                    'تحديثات حول التقارير المقدمة',
                value: _reportsNotifications,
                onChanged: (value) async {
                  setState(() {
                    _reportsNotifications = value;
                  });
                  await _notificationService
                      .setReportsNotificationsEnabled(
                        value,
                      );
                },
              ),

              SizedBox(height: 16.h),

              _buildNotificationTile(
                icon: Icons.article_outlined,
                title: 'إشعارات الأخبار',
                subtitle:
                    'آخر الأخبار والتحديثات',
                value: _newsNotifications,
                onChanged: (value) async {
                  setState(() {
                    _newsNotifications = value;
                  });
                  await _notificationService
                      .setNewsNotificationsEnabled(
                        value,
                      );
                },
              ),

              SizedBox(height: 16.h),

              _buildNotificationTile(
                icon: Icons.security_outlined,
                title: 'التنبيهات الأمنية',
                subtitle:
                    'تنبيهات هامة حول الأمان',
                value: _securityNotifications,
                onChanged: (value) async {
                  setState(() {
                    _securityNotifications =
                        value;
                  });
                  await _notificationService
                      .setSecurityNotificationsEnabled(
                        value,
                      );
                },
                isImportant: true,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isImportant = false,
  }) {
    // Create a unique key based on the title
    final switchKey = ValueKey(
      '${title.replaceAll(' ', '_')}_switch',
    );

    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color,
                    ),
                  ),
                  if (isImportant) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.star,
                      color: AppColors.orange,
                      size: 14.sp,
                    ),
                  ],
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color,
                ),
              ),
            ],
          ),
        ),
        Switch(
          key: switchKey,
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
          activeTrackColor: AppColors.primaryColor
              .withOpacity(0.3),
        ),
      ],
    );
  }
}
