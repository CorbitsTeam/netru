import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:netru_app/features/verification/presentation/cubit/verification_cubit.dart';
import 'package:netru_app/features/verification/presentation/cubit/verification_state.dart';
import 'package:netru_app/features/verification/presentation/pages/document_scan_page.dart';
import 'package:netru_app/features/verification/presentation/pages/profile_page.dart';

/// Example showing how to integrate the verification system into your app
class VerificationIntegrationExample extends StatelessWidget {
  const VerificationIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Netru Identity Verification',
      home: MultiBlocProvider(
        providers: [
          // Provide VerificationCubit to the widget tree
          BlocProvider<VerificationCubit>(
            create: (context) => GetIt.instance<VerificationCubit>(),
          ),
          // Add your existing AuthCubit and other cubits here
          // BlocProvider<AuthCubit>(
          //   create: (context) => GetIt.instance<AuthCubit>(),
          // ),
        ],
        child: const DocumentScanPage(),
      ),
    );
  }
}

/// Example of how to navigate to verification pages
class VerificationNavigationHelper {
  /// Navigate to document scanning page
  static void navigateToDocumentScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (context) => GetIt.instance<VerificationCubit>(),
              child: const DocumentScanPage(),
            ),
      ),
    );
  }

  /// Navigate to profile page with verification status
  static void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => GetIt.instance<VerificationCubit>(),
                ),
                // Add your AuthCubit provider here
                // BlocProvider.value(value: context.read<AuthCubit>()),
              ],
              child: const ProfilePage(),
            ),
      ),
    );
  }
}

/// Widget to check verification status and show appropriate UI
class VerificationStatusChecker extends StatefulWidget {
  final String userId;
  final Widget Function(bool isVerified) builder;

  const VerificationStatusChecker({
    super.key,
    required this.userId,
    required this.builder,
  });

  @override
  State<VerificationStatusChecker> createState() =>
      _VerificationStatusCheckerState();
}

class _VerificationStatusCheckerState extends State<VerificationStatusChecker> {
  @override
  void initState() {
    super.initState();
    // Check verification status when widget loads
    context.read<VerificationCubit>().checkVerificationStatus(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerificationCubit, VerificationState>(
      builder: (context, state) {
        if (state is VerificationStatusLoaded) {
          return widget.builder(state.isVerified);
        } else if (state is VerificationStatusLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          // Default to not verified if status is unknown
          return widget.builder(false);
        }
      },
    );
  }
}

/// Example usage in your existing app screens
class ExampleUsageInApp extends StatelessWidget {
  const ExampleUsageInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Netru App')),
      body: Column(
        children: [
          // Check if user is verified and show different UI
          BlocProvider(
            create: (context) => GetIt.instance<VerificationCubit>(),
            child: VerificationStatusChecker(
              userId: 'current-user-id', // Get from your auth system
              builder: (isVerified) {
                if (isVerified) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(Icons.verified, color: Colors.green),
                      title: Text('تم التحقق من الهوية'),
                      subtitle: Text('يمكنك الآن استخدام جميع الخدمات'),
                    ),
                  );
                } else {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.orange),
                      title: const Text('لم يتم التحقق من الهوية'),
                      subtitle: const Text('يرجى تحميل وثيقة هويتك'),
                      trailing: ElevatedButton(
                        onPressed:
                            () =>
                                VerificationNavigationHelper.navigateToDocumentScan(
                                  context,
                                ),
                        child: const Text('تحقق الآن'),
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          // Button to open profile page
          ElevatedButton(
            onPressed:
                () => VerificationNavigationHelper.navigateToProfile(context),
            child: const Text('الملف الشخصي'),
          ),
        ],
      ),
    );
  }
}

/// Utility class for verification-related operations
class VerificationUtils {
  /// Check if user needs verification for specific features
  static bool requiresVerificationForFeature(String featureName) {
    const verificationRequiredFeatures = [
      'report_incident',
      'emergency_contact',
      'sensitive_location_access',
    ];

    return verificationRequiredFeatures.contains(featureName);
  }

  /// Show verification prompt dialog
  static void showVerificationRequiredDialog(
    BuildContext context,
    String featureName,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('التحقق من الهوية مطلوب'),
            content: Text(
              'لاستخدام ميزة $featureName، يجب التحقق من هويتك أولاً.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('لاحقاً'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  VerificationNavigationHelper.navigateToDocumentScan(context);
                },
                child: const Text('تحقق الآن'),
              ),
            ],
          ),
    );
  }
}

/// Custom widget to wrap features that require verification
class VerificationGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String userId;

  const VerificationGate({
    super.key,
    required this.child,
    required this.featureName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (!VerificationUtils.requiresVerificationForFeature(featureName)) {
      return child;
    }

    return BlocProvider(
      create: (context) => GetIt.instance<VerificationCubit>(),
      child: VerificationStatusChecker(
        userId: userId,
        builder: (isVerified) {
          if (isVerified) {
            return child;
          } else {
            return GestureDetector(
              onTap:
                  () => VerificationUtils.showVerificationRequiredDialog(
                    context,
                    featureName,
                  ),
              child: Stack(
                children: [
                  Opacity(opacity: 0.5, child: child),
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 48, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'يتطلب التحقق من الهوية',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
