import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _passportController = TextEditingController();
  final _nationalityController = TextEditingController();

  bool _isEgyptian = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      if (_isEgyptian) {
        context.read<AuthCubit>().registerCitizen(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          nationalId: _nationalIdController.text.trim(),
          phone: _phoneController.text.trim(),
          address:
              _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
        );
      } else {
        context.read<AuthCubit>().registerForeigner(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          passportNumber: _passportController.text.trim(),
          nationality: _nationalityController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }
    }
  }

  void _googleSignUp() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != _passwordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[700],
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "إنشاء حساب جديد",
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          } else if (state is CitizenRegistrationSuccess ||
              state is ForeignerRegistrationSuccess ||
              state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("تم إنشاء الحساب بنجاح!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
            context.pushNamedAndRemoveUntil(Routes.customBottomBar);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),

                // Header
                const AuthHeader(
                  title: "انضم إلى نترو",
                  subtitle:
                      "أنشئ حسابك للاستفادة من جميع خدمات الأمان والحماية",
                ),

                SizedBox(height: 30.h),

                // User Type Selection
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "نوع المستخدم",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Egyptian/Foreigner Toggle
                      Row(
                        children: [
                          Expanded(
                            child: _UserTypeOption(
                              title: "مواطن مصري",
                              subtitle: "للمواطنين المصريين",
                              icon: Icons.flag,
                              isSelected: _isEgyptian,
                              onTap: () => setState(() => _isEgyptian = true),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _UserTypeOption(
                              title: "مقيم أجنبي",
                              subtitle: "للمقيمين الأجانب",
                              icon: Icons.public,
                              isSelected: !_isEgyptian,
                              onTap: () => setState(() => _isEgyptian = false),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Common Fields
                      AuthTextField(
                        label: "الاسم الكامل",
                        hint: "أدخل اسمك الكامل",
                        controller: _fullNameController,
                        prefixIcon: Icons.person_outline,
                        validator: context.read<AuthCubit>().validateFullName,
                      ),

                      SizedBox(height: 20.h),

                      AuthTextField(
                        label: "البريد الإلكتروني",
                        hint: "أدخل بريدك الإلكتروني",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: context.read<AuthCubit>().validateEmail,
                      ),

                      SizedBox(height: 20.h),

                      AuthTextField(
                        label: "رقم الهاتف",
                        hint: "01xxxxxxxxx",
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: context.read<AuthCubit>().validatePhone,
                      ),

                      SizedBox(height: 20.h),

                      // Conditional Fields based on user type
                      if (_isEgyptian) ...[
                        AuthTextField(
                          label: "الرقم القومي",
                          hint: "أدخل الرقم القومي (14 رقم)",
                          controller: _nationalIdController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.credit_card,
                          validator:
                              context.read<AuthCubit>().validateNationalId,
                        ),

                        SizedBox(height: 20.h),

                        AuthTextField(
                          label: "العنوان (اختياري)",
                          hint: "أدخل عنوانك",
                          controller: _addressController,
                          prefixIcon: Icons.location_on_outlined,
                        ),
                      ] else ...[
                        AuthTextField(
                          label: "رقم جواز السفر",
                          hint: "أدخل رقم جواز السفر",
                          controller: _passportController,
                          prefixIcon: Icons.assignment_ind_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'رقم جواز السفر مطلوب';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20.h),

                        AuthTextField(
                          label: "الجنسية",
                          hint: "أدخل جنسيتك",
                          controller: _nationalityController,
                          prefixIcon: Icons.public,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الجنسية مطلوبة';
                            }
                            return null;
                          },
                        ),
                      ],

                      SizedBox(height: 20.h),

                      AuthTextField(
                        label: "كلمة المرور",
                        hint: "أدخل كلمة مرور قوية",
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: context.read<AuthCubit>().validatePassword,
                      ),

                      SizedBox(height: 20.h),

                      AuthTextField(
                        label: "تأكيد كلمة المرور",
                        hint: "أعد إدخال كلمة المرور",
                        controller: _confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: _validateConfirmPassword,
                      ),

                      SizedBox(height: 32.h),

                      // Sign Up Button
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return AuthButton(
                            text: "إنشاء الحساب",
                            onPressed: _signUp,
                            isLoading: state is AuthLoading,
                            icon: Icons.person_add,
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              "أو",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Google Sign Up Button
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return SocialButton(
                            text: "إنشاء حساب بجوجل",
                            iconPath: "assets/icons/google.svg",
                            onPressed: _googleSignUp,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "لديك حساب بالفعل؟ ",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushNamed(Routes.loginScreen);
                      },
                      child: Text(
                        "تسجيل الدخول",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : Colors.grey[500],
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryColor : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
