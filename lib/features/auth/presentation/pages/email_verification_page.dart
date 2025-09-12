import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../widgets/animated_button.dart';

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
      print('خطأ في فحص تأكيد البريد: $e');
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
      print('🔐 تسجيل دخول تلقائي بعد تأكيد الإيميل...');
      final authResponse = await Supabase.instance.client.auth
          .signInWithPassword(email: widget.email, password: widget.password);

      if (authResponse.session != null && authResponse.user != null) {
        print('✅ تم تسجيل الدخول تلقائياً بنجاح');

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
        print('❌ فشل في تسجيل الدخول التلقائي');
        // Still navigate but show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
      print('❌ خطأ في تسجيل الدخول التلقائي: $e');
      // Still navigate but show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        SnackBar(
          content: Text('يرجى إدخال رمز التحقق كاملاً (6 أرقام)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifyingOTP = true);

    try {
      print('🔍 التحقق من رمز OTP: $_otpCode');

      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        token: _otpCode,
        email: widget.email,
      );

      if (response.session != null && response.user != null) {
        print('✅ تم التحقق من OTP بنجاح');
        _onEmailVerified();
      } else {
        print('❌ فشل في التحقق من OTP');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('رمز التحقق غير صحيح'),
            backgroundColor: AppColors.error,
          ),
        );
        _clearOTPFields();
      }
    } catch (e) {
      print('❌ خطأ في التحقق من OTP: $e');
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

  // Update OTP code from individual controllers
  void _updateOTPCode() {
    final code = _otpControllers.map((controller) => controller.text).join();
    setState(() {
      _otpCode = code;
    });

    // Auto-verify when all 6 digits are entered
    if (code.length == 6) {
      _verifyOTP();
    }
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
        SnackBar(
          content: const Text('تم إعادة إرسال رسالة التأكيد'),
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
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          children: [
            Icon(Icons.security, size: 40.sp, color: AppColors.primary),
            SizedBox(height: 8.h),
            Text(
              'وزارة الداخلية',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'جمهورية مصر العربية',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Email Icon
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          child: AnimatedBuilder(
            animation: _emailIconAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _emailIconAnimation.value,
                child: Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isVerified ? AppColors.success : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (_isVerified
                                ? AppColors.success
                                : AppColors.primary)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!_isVerified)
                        Icon(
                          Icons.email_outlined,
                          size: 60.sp,
                          color: Colors.white,
                        ),
                      if (_isVerified)
                        AnimatedBuilder(
                          animation: _checkAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _checkAnimation.value,
                              child: Icon(
                                Icons.check_circle,
                                size: 60.sp,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      if (_isChecking)
                        SizedBox(
                          width: 80.w,
                          height: 80.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 40.h),

        // Title and Description
        FadeInUp(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 200),
          child: Column(
            children: [
              Text(
                _isVerified ? 'تم التأكيد بنجاح!' : 'تأكيد البريد الإلكتروني',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      _isVerified ? AppColors.success : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                _isVerified
                    ? 'تم تأكيد البريد الإلكتروني بنجاح. جاري توجيهك لإكمال البيانات...'
                    : 'لقد أرسلنا رسالة تأكيد إلى بريدك الإلكتروني\nيرجى فتح الرسالة والضغط على رابط التأكيد',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 40.h),

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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
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
          _buildOTPInputBoxes(),
          SizedBox(height: 24.h),
          if (_isVerifyingOTP)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
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

  Widget _buildOTPInputBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 45.w,
          height: 55.h,
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  _otpControllers[index].text.isNotEmpty
                      ? AppColors.primary
                      : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.white,
          ),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // Move to next field
                if (index < 5) {
                  _otpFocusNodes[index + 1].requestFocus();
                }
              } else {
                // Move to previous field if backspace
                if (index > 0) {
                  _otpFocusNodes[index - 1].requestFocus();
                }
              }
              _updateOTPCode();
            },
          ),
        );
      }),
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
    if (_isVerified) {
      return FadeInUp(
        duration: const Duration(milliseconds: 800),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 30.w,
                height: 30.h,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'جاري التوجيه...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          // Resend Button
          AnimatedButton(
            text:
                _resendCooldown > 0
                    ? 'إعادة الإرسال خلال $_resendCooldown ثانية'
                    : 'إعادة إرسال رسالة التأكيد',
            onPressed: _resendCooldown > 0 ? null : _resendVerificationEmail,
            isLoading: _isResending,
            isEnabled: _resendCooldown == 0,
            backgroundColor: AppColors.secondary,
            width: double.infinity,
            height: 50.h,
          ),

          SizedBox(height: 16.h),

          // Back Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'العودة للصفحة السابقة',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
