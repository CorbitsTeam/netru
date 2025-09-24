import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/email_verification_header.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/verification_actions.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final String password;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with TickerProviderStateMixin {
  late AnimationController _emailIconController;
  late AnimationController _checkController;
  late Animation<double> _emailIconAnimation;
  late Animation<double> _checkAnimation;

  Timer? _checkTimer;
  bool _isChecking = false;
  bool _isResending = false;
  bool _isVerified = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  // OTP input fields
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  String _otpCode = '';
  bool _isVerifyingOTP = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startPeriodicCheck();
    _listenToAuthChanges();
  }

  void _setupAnimations() {
    _emailIconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _emailIconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emailIconController, curve: Curves.elasticOut),
    );
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _emailIconController.forward();
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isVerified && mounted) {
        _checkEmailVerification();
      }
    });
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null && user.emailConfirmedAt != null && mounted) {
        _onEmailVerified();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    if (_isChecking || _isVerified) return;

    setState(() => _isChecking = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        _onEmailVerified();
      }
    } catch (e) {
      log('خطأ في فحص تأكيد البريد: $e');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _onEmailVerified() async {
    setState(() => _isVerified = true);
    _checkController.forward();
    _checkTimer?.cancel();

    // Sign in automatically with email and password to get authenticated user
    try {
      log('🔐 تسجيل دخول تلقائي بعد تأكيد الإيميل...');
      final authResponse = await Supabase.instance.client.auth
          .signInWithPassword(email: widget.email, password: widget.password);

      if (authResponse.session != null && authResponse.user != null) {
        log('✅ تم تسجيل الدخول تلقائياً بنجاح');

        // Navigate to complete profile after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              Routes.completeProfile,
              arguments: {'email': widget.email, 'password': widget.password},
            );
          }
        });
      } else {
        log('❌ فشل في تسجيل الدخول التلقائي');
        // Still navigate but show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأكيد الإيميل لكن فشل في تسجيل الدخول التلقائي'),
            backgroundColor: AppColors.warning,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              Routes.completeProfile,
              arguments: {'email': widget.email, 'password': widget.password},
            );
          }
        });
      }
    } catch (e) {
      log('❌ خطأ في تسجيل الدخول التلقائي: $e');
      // Still navigate but show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد الإيميل لكن حدث خطأ في تسجيل الدخول'),
          backgroundColor: AppColors.error,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            Routes.completeProfile,
            arguments: {'email': widget.email, 'password': widget.password},
          );
        }
      });
    }
  }

  // New method to verify OTP
  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز التحقق كاملاً (6 أرقام)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifyingOTP = true);

    try {
      log('🔍 التحقق من رمز OTP: $_otpCode');

      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        token: _otpCode,
        email: widget.email,
      );

      if (response.session != null && response.user != null) {
        log('✅ تم التحقق من OTP بنجاح');
        _onEmailVerified();
      } else {
        log('❌ فشل في التحقق من OTP');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رمز التحقق غير صحيح'),
            backgroundColor: AppColors.error,
          ),
        );
        _clearOTPFields();
      }
    } catch (e) {
      log('❌ خطأ في التحقق من OTP: $e');
      String errorMessage = 'رمز التحقق غير صحيح';

      if (e.toString().contains('expired')) {
        errorMessage = 'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد';
      } else if (e.toString().contains('invalid')) {
        errorMessage = 'رمز التحقق غير صحيح';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
      _clearOTPFields();
    } finally {
      if (mounted) setState(() => _isVerifyingOTP = false);
    }
  }

  // Clear OTP input fields
  void _clearOTPFields() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].clear();
    }
    setState(() {
      _otpCode = '';
    });
    // Focus on first field
    _otpFocusNodes[0].requestFocus();
  }


  Future<void> _resendVerificationEmail() async {
    if (_isResending || _resendCooldown > 0) return;

    setState(() => _isResending = true);

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إعادة إرسال رسالة التأكيد'),
          backgroundColor: AppColors.success,
        ),
      );

      _startCooldown();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إعادة الإرسال: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _emailIconController.dispose();
    _checkController.dispose();
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();

    // Dispose OTP controllers and focus nodes
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildContent(),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return EmailVerificationHeader(
      emailIconAnimation: _emailIconAnimation,
      checkAnimation: _checkAnimation,
      isVerified: _isVerified,
      email: widget.email,
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // OTP Input Fields (if not verified)
        if (!_isVerified) _buildOTPInput(),

        // Tips
        if (!_isVerified)
          FadeInUp(
            duration: const Duration(milliseconds: 1200),
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'نصائح مهمة',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildTip('تحقق من صندوق الرسائل الواردة'),
                  _buildTip('تحقق من مجلد الرسائل المزعجة (Spam)'),
                  _buildTip('قد تستغرق الرسالة دقائق قليلة للوصول'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Text(
            'أدخل رمز التحقق',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك الإلكتروني',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          OTPInputField(
            controllers: _otpControllers,
            focusNodes: _otpFocusNodes,
            onChanged: (value) {
              setState(() {
                _otpCode = value;
              });
            },
            onCompleted: (value) {
              setState(() {
                _otpCode = value;
              });
              if (value.length == 6) {
                _verifyOTP();
              }
            },
          ),
          SizedBox(height: 24.h),
          if (_isVerifyingOTP)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'جاري التحقق...',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              ],
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }


  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return VerificationActions(
      onVerifyOTP: _verifyOTP,
      onResend: _resendVerificationEmail,
      onContinue: () {
        Navigator.pushReplacementNamed(
          context,
          Routes.completeProfile,
          arguments: {'email': widget.email, 'password': widget.password},
        );
      },
      isVerified: _isVerified,
      isVerifyingOTP: _isVerifyingOTP,
      isResending: _isResending,
      resendCooldown: _resendCooldown,
      otpCode: _otpCode,
    );
  }
}
