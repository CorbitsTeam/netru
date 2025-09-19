import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/widgets/custom_text_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {
  final TextEditingController
  _currentPasswordController =
      TextEditingController();
  final TextEditingController
  _newPasswordController =
      TextEditingController();
  final TextEditingController
  _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'تغيير كلمة السر',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),

                // Current Password Field
                CustomTextField(
                  controller:
                      _currentPasswordController,
                  label: 'الرقم السري الحالي',
                  isPassword: true,
                  keyboardType:
                      TextInputType
                          .visiblePassword,
                  textAlign: TextAlign.right,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'يرجى إدخال كلمة السر الحالية';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15.h),

                // New Password Field
                CustomTextField(
                  controller:
                      _newPasswordController,
                  label: 'الرقم السري الجديد',
                  isPassword: true,
                  keyboardType:
                      TextInputType
                          .visiblePassword,
                  textAlign: TextAlign.right,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'يرجى إدخال كلمة السر الجديدة';
                    }
                    if (value.length < 6) {
                      return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15.h),

                // Confirm New Password Field
                CustomTextField(
                  controller:
                      _confirmPasswordController,
                  label:
                      'تأكيد الرقم السري الجديد',
                  isPassword: true,
                  keyboardType:
                      TextInputType
                          .visiblePassword,
                  textAlign: TextAlign.right,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'يرجى تأكيد كلمة السر الجديدة';
                    }
                    if (value !=
                        _newPasswordController
                            .text) {
                      return 'كلمة السر غير متطابقة';
                    }
                    return null;
                  },
                ),

                // Forgot Password Link
                Align(
                  alignment:
                      Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        _showForgotPasswordDialog,
                    child: Text(
                      'نسيت الرقم السري ؟',
                      style: TextStyle(
                        color: const Color(
                          0xFFFFB800,
                        ),
                        fontSize: 12.sp,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                // Change Password Button
                SizedBox(
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!
                          .validate()) {
                        _handlePasswordChange();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              4.r,
                            ),
                      ),
                      elevation: 0,
                      shadowColor:
                          Colors.transparent,
                    ),
                    child: Text(
                      'تغيير كلمة السر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16.r,
            ),
          ),
          title: Text(
            'نسيت كلمة السر',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email_outlined,
                size: 48.sp,
                color: const Color(0xFFFFB800),
              ),
              SizedBox(height: 16.h),
              Text(
                'سيتم إرسال رابط إعادة تعيين كلمة السر إلى بريدك الإلكتروني المسجل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        () =>
                            Navigator.of(
                              context,
                            ).pop(),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(
                            vertical: 12.h,
                          ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              8.r,
                            ),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: const Color(
                          0xFF666666,
                        ),
                        fontSize: 14.sp,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _handleForgotPassword();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFB800),
                      padding:
                          EdgeInsets.symmetric(
                            vertical: 12.h,
                          ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              8.r,
                            ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'إرسال',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            const Expanded(
              child: Text(
                'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFB800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.r,
          ),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
      ),
    );
  }

  void _handlePasswordChange() {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16.r),
              ),
              child: Container(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          const AlwaysStoppedAnimation<
                            Color
                          >(Color(0xFF1E3A8A)),
                      strokeWidth: 3.w,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'جاري تغيير كلمة السر...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(
                          0xFF333333,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    // Simulate API call
    Future.delayed(
      const Duration(seconds: 2),
      () {
        Navigator.pop(context); // Close loading
        _showSuccessDialog();
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20.r,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                20.r,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Animation Container
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                          colors: [
                            Color(0xFF4CAF50),
                            Color(0xFF45A049),
                          ],
                          begin:
                              Alignment.topLeft,
                          end:
                              Alignment
                                  .bottomRight,
                        ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green
                            .withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(
                          0,
                          10,
                        ),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),

                SizedBox(height: 24.h),

                // Success Title
                Text(
                  'تم بنجاح!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(
                      0xFF333333,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Success Message
                Text(
                  'تم تغيير كلمة السر بنجاح\nيمكنك الآن استخدام كلمة السر الجديدة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(
                      0xFF666666,
                    ),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 32.h),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(); // Close dialog
                      Navigator.of(
                        context,
                      ).pop(); // Go back to previous page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              12.r,
                            ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'حسناً',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
