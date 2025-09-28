// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:animate_do/animate_do.dart';
// import '../../../../../core/theme/app_colors.dart';
// import '../cubit/forgot_password_cubit.dart';
// import '../cubit/forgot_password_state.dart';

// class PasscodeInputForm extends StatefulWidget {
//   final String email;

//   const PasscodeInputForm({super.key, required this.email});

//   @override
//   State<PasscodeInputForm> createState() => _PasscodeInputFormState();
// }

// class _PasscodeInputFormState extends State<PasscodeInputForm> {
//   final List<TextEditingController> _controllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     for (final controller in _controllers) {
//       controller.dispose();
//     }
//     for (final focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }

//   void _handleSubmit() {
//     if (_formKey.currentState?.validate() ?? false) {
//       final passcode = _controllers.map((c) => c.text).join();
//       context.read<ForgotPasswordCubit>().verifyPasscode(
//         widget.email,
//         passcode,
//       );
//     }
//   }

//   void _onPasscodeChanged(int index, String value) {
//     if (value.isNotEmpty && index < 5) {
//       _focusNodes[index + 1].requestFocus();
//     }

//     // Auto-submit when all fields are filled
//     if (index == 5 && value.isNotEmpty) {
//       _handleSubmit();
//     }
//   }

//   void _resendPasscode() {
//     context.read<ForgotPasswordCubit>().resendPasscode(widget.email);

//     // Clear all fields
//     for (final controller in _controllers) {
//       controller.clear();
//     }
//     _focusNodes[0].requestFocus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeInUp(
//       duration: const Duration(milliseconds: 600),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 40.h),

//             // Instructions
//             Text(
//               'أدخل رمز التحقق المرسل إلى:',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 color: const Color(0xFF6B7280),
//                 fontFamily: 'Almarai',
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               widget.email,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Almarai',
//               ),
//               textAlign: TextAlign.center,
//             ),

//             SizedBox(height: 32.h),

//             // Passcode Input Fields
//             Directionality(
//               textDirection: TextDirection.ltr,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(
//                   6,
//                   (index) => _buildPasscodeField(index),
//                 ),
//               ),
//             ),

//             SizedBox(height: 24.h),

//             // Resend Code Button
//             GestureDetector(
//               onTap: _resendPasscode,
//               child: Text(
//                 'إعادة إرسال الرمز',
//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'Almarai',
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),

//             SizedBox(height: 32.h),

//             // Verify Button
//             BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
//               builder: (context, state) {
//                 final isLoading = state is ForgotPasswordLoading;
//                 return SizedBox(
//                   width: double.infinity,
//                   height: 50.h,
//                   child: ElevatedButton(
//                     onPressed: isLoading ? null : _handleSubmit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16.r),
//                       ),
//                     ),
//                     child:
//                         isLoading
//                             ? SizedBox(
//                               width: 24.w,
//                               height: 24.h,
//                               child: const CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                             : Text(
//                               'تحقق من الرمز',
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                                 fontFamily: 'Almarai',
//                               ),
//                             ),
//                   ),
//                 );
//               },
//             ),

//             SizedBox(height: 24.h),

//             // Back Button
//             GestureDetector(
//               onTap: () => context.read<ForgotPasswordCubit>().resetState(),
//               child: Text(
//                 'العودة لإدخال البريد الإلكتروني',
//                 style: TextStyle(
//                   color: const Color(0xFF6B7280),
//                   fontSize: 14.sp,
//                   fontFamily: 'Almarai',
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPasscodeField(int index) {
//     return Container(
//       width: 45.w,
//       height: 56.h,
//       decoration: BoxDecoration(
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: TextFormField(
//         controller: _controllers[index],
//         focusNode: _focusNodes[index],
//         textAlign: TextAlign.center,
//         keyboardType: TextInputType.number,
//         maxLength: 1,
//         style: TextStyle(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimary,
//           fontFamily: 'Almarai',
//         ),
//         decoration: const InputDecoration(
//           counterText: '',
//           border: InputBorder.none,
//           focusedBorder: InputBorder.none,
//           enabledBorder: InputBorder.none,
//         ),
//         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//         onChanged: (value) => _onPasscodeChanged(index, value),
//         onTap: () {
//           // Clear the field when tapped
//           _controllers[index].clear();
//         },
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return '';
//           }
//           return null;
//         },
//         onFieldSubmitted: (_) {
//           if (index < 5) {
//             _focusNodes[index + 1].requestFocus();
//           } else {
//             _handleSubmit();
//           }
//         },
//         onEditingComplete: () {
//           if (index < 5) {
//             _focusNodes[index + 1].requestFocus();
//           }
//         },
//       ),
//     );
//   }
// }
