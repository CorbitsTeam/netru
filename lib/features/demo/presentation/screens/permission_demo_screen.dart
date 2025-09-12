import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/cubit/permission/permission_cubit.dart';

class PermissionDemoScreen extends StatelessWidget {
  const PermissionDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission System Demo'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<PermissionCubit, PermissionState>(
        listener: (context, state) {
          if (state is PermissionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PermissionGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.permission?.displayName} permission granted!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.permission?.displayName} permission denied',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Display
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(state),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getStatusIcon(state),
                        size: 48.sp,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _getStatusText(state),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Individual Permission Buttons
                Text(
                  'Request Individual Permissions:',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16.h),

                _buildPermissionButton(
                  context,
                  'Camera Permission',
                  Icons.camera_alt,
                  Colors.purple,
                  () =>
                      context.read<PermissionCubit>().requestCameraPermission(),
                  state is PermissionLoading,
                ),

                SizedBox(height: 12.h),

                _buildPermissionButton(
                  context,
                  'Location Permission',
                  Icons.location_on,
                  Colors.green,
                  () =>
                      context
                          .read<PermissionCubit>()
                          .requestLocationPermission(),
                  state is PermissionLoading,
                ),

                SizedBox(height: 12.h),

                _buildPermissionButton(
                  context,
                  'Storage Permission',
                  Icons.storage,
                  Colors.orange,
                  () =>
                      context
                          .read<PermissionCubit>()
                          .requestStoragePermission(),
                  state is PermissionLoading,
                ),

                SizedBox(height: 12.h),

                _buildPermissionButton(
                  context,
                  'Notification Permission',
                  Icons.notifications,
                  Colors.blue,
                  () =>
                      context
                          .read<PermissionCubit>()
                          .requestNotificationPermission(),
                  state is PermissionLoading,
                ),

                SizedBox(height: 24.h),

                // Batch Actions
                Text(
                  'Batch Actions:',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16.h),

                _buildPermissionButton(
                  context,
                  'Request All Essential Permissions',
                  Icons.security,
                  Colors.indigo,
                  () =>
                      context
                          .read<PermissionCubit>()
                          .requestEssentialPermissions(),
                  state is PermissionLoading,
                ),

                SizedBox(height: 12.h),

                _buildPermissionButton(
                  context,
                  'Check All Permissions Status',
                  Icons.check_circle,
                  Colors.teal,
                  () =>
                      context.read<PermissionCubit>().getAllPermissionsStatus(),
                  state is PermissionLoading,
                ),

                SizedBox(height: 12.h),

                _buildPermissionButton(
                  context,
                  'Open App Settings',
                  Icons.settings,
                  Colors.grey,
                  () => context.read<PermissionCubit>().openAppSettings(),
                  state is PermissionLoading,
                ),

                const Spacer(),

                // Info Text
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    'This demo shows the Clean Architecture permission system in action. '
                    'All permissions are handled through use cases, repositories, and cubits.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isLoading,
  ) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon:
          isLoading
              ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Color _getStatusColor(PermissionState state) {
    if (state is PermissionLoading) return Colors.orange;
    if (state is PermissionGranted) return Colors.green;
    if (state is PermissionDenied) return Colors.red;
    if (state is PermissionError) return Colors.red.shade800;
    if (state is MultiplePermissionsResult) {
      return state.granted.isNotEmpty ? Colors.green : Colors.red;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(PermissionState state) {
    if (state is PermissionLoading) return Icons.hourglass_empty;
    if (state is PermissionGranted) return Icons.check_circle;
    if (state is PermissionDenied) return Icons.cancel;
    if (state is PermissionError) return Icons.error;
    if (state is MultiplePermissionsResult) {
      return state.granted.isNotEmpty ? Icons.check_circle : Icons.cancel;
    }
    return Icons.info;
  }

  String _getStatusText(PermissionState state) {
    if (state is PermissionLoading) {
      return 'Processing permission request...';
    }
    if (state is PermissionGranted) {
      return '✅ Permission Granted\n${state.permission?.displayName ?? "Permission"} is now available';
    }
    if (state is PermissionDenied) {
      return '❌ Permission Denied\n${state.permission?.displayName ?? "Permission"} was not granted';
    }
    if (state is PermissionError) {
      return '⚠️ Error\n${state.message}';
    }
    if (state is MultiplePermissionsResult) {
      return '📊 Multiple Permissions Result\n'
          '✅ Granted: ${state.granted.length}\n'
          '❌ Denied: ${state.denied.length}';
    }
    if (state is AllPermissionsStatus) {
      final granted = state.permissions.where((p) => p.isGranted).length;
      final total = state.permissions.length;
      return '📊 All Permissions Status\n'
          '$granted of $total permissions granted';
    }
    return 'Ready to request permissions\nUse the buttons below to test the system';
  }
}
