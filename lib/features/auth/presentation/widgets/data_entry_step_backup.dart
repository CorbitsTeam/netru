// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:animate_do/animate_do.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/widgets/custom_text_field.dart';
// import '../../domain/entities/user_entity.dart';
// import '../../domain/entities/extracted_document_data.dart';

// class DataEntryStep extends StatefulWidget {
//   final UserType userType;
//   final ExtractedDocumentData? extractedData;
//   final Function(Map<String, String>) onDataChanged;
//   final Map<String, String> currentData;
//   final String? username; // The username from first step (email or phone)
//   final bool
//   isEmailMode; // Whether the username is email (true) or phone (false)
//   final String? initialPassword; // Password from first step

//   const DataEntryStep({
//     super.key,
//     required this.userType,
//     this.extractedData,
//     required this.onDataChanged,
//     required this.currentData,
//     this.username,
//     this.isEmailMode = true,
//     this.initialPassword,
//   });

//   @override
//   State<DataEntryStep> createState() => _DataEntryStepState();
// }

// class _DataEntryStepState extends State<DataEntryStep> {
//   late final Map<String, TextEditingController> _controllers;
//   bool _isPopulating = false;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _populateFromExtractedData();
//     _addControllerListeners();
//   }

//   void _initializeControllers() {
//     // Pre-fill email or phone from username entered in first step
//     String emailValue = '';
//     String phoneValue = '';

//     if (widget.username != null) {
//       if (widget.isEmailMode) {
//         emailValue = widget.username!;
//         phoneValue = widget.currentData['phone'] ?? '';
//       } else {
//         phoneValue = widget.username!;
//         emailValue = widget.currentData['email'] ?? '';
//       }
//     } else {
//       emailValue = widget.currentData['email'] ?? '';
//       phoneValue = widget.currentData['phone'] ?? '';
//     }

//     _controllers = {
//       'fullName': TextEditingController(
//         text: widget.currentData['fullName'] ?? '',
//       ),
//       'nationalId': TextEditingController(
//         text: widget.currentData['nationalId'] ?? '',
//       ),
//       'birthDate': TextEditingController(
//         text: widget.currentData['birthDate'] ?? '',
//       ),
//       'phone': TextEditingController(text: phoneValue),
//       'email': TextEditingController(text: emailValue),
//       'password': TextEditingController(
//         text: widget.currentData['password'] ?? widget.initialPassword ?? '',
//       ),
//     };
//     if (widget.userType == UserType.foreigner) {
//       _controllers.addAll({
//         'passportNumber': TextEditingController(
//           text: widget.currentData['passportNumber'] ?? '',
//         ),
//         'nationality': TextEditingController(
//           text: widget.currentData['nationality'] ?? '',
//         ),
//         'passportIssueDate': TextEditingController(
//           text: widget.currentData['passportIssueDate'] ?? '',
//         ),
//         'passportExpiryDate': TextEditingController(
//           text: widget.currentData['passportExpiryDate'] ?? '',
//         ),
//       });
//     }
//   }

//   void _addControllerListeners() {
//     // Attach listeners after initial population to avoid firing during build
//     _controllers.forEach((key, controller) {
//       controller.addListener(() {
//         if (_isPopulating)
//           return; // ignore changes during programmatic population
//         final updatedData = Map<String, String>.from(widget.currentData);
//         updatedData[key] = controller.text;

//         // Schedule parent update after the current frame to avoid calling setState during build
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (!mounted) return;
//           widget.onDataChanged(updatedData);
//         });
//       });
//     });
//   }

//   void _populateFromExtractedData() {
//     if (widget.extractedData != null) {
//       _isPopulating = true;
//       final data = widget.extractedData!;

//       _controllers['fullName']?.text = data.fullName ?? '';
//       _controllers['nationalId']?.text = data.nationalId ?? '';
//       _controllers['birthDate']?.text =
//           data.birthDate?.toString().split(' ')[0] ?? '';

//       if (widget.userType == UserType.foreigner) {
//         _controllers['passportNumber']?.text = data.passportNumber ?? '';
//         _controllers['nationality']?.text = data.nationality ?? '';
//         _controllers['passportIssueDate']?.text =
//             data.passportIssueDate?.toString().split(' ')[0] ?? '';
//         _controllers['passportExpiryDate']?.text =
//             data.passportExpiryDate?.toString().split(' ')[0] ?? '';
//       }
//       // allow listeners again
//       _isPopulating = false;
//     }
//   }

//   @override
//   void dispose() {
//     _controllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Padding(
//         padding: EdgeInsets.all(24.w),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20.h),

//               // Title
//               FadeInDown(
//                 duration: const Duration(milliseconds: 600),
//                 child: Text(
//                   'تأكيد البيانات الشخصية',
//                   style: TextStyle(
//                     fontSize: 24.sp,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),

//               SizedBox(height: 8.h),

//               FadeInDown(
//                 duration: const Duration(milliseconds: 700),
//                 child: Text(
//                   'تأكد من صحة البيانات المستخرجة من المستند وقم بتعديلها إذا لزم الأمر',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     color: AppColors.textSecondary,
//                     height: 1.5,
//                   ),
//                 ),
//               ),

//               SizedBox(height: 32.h),

//               // Basic Information Section
//               _buildSectionTitle('البيانات الأساسية', 0),
//               SizedBox(height: 16.h),
//               _buildBasicFields(),

//               SizedBox(height: 32.h),

//               // Contact Information Section
//               _buildSectionTitle('بيانات التواصل', 1),
//               SizedBox(height: 16.h),
//               _buildContactFields(),

//               if (widget.userType == UserType.foreigner) ...[
//                 SizedBox(height: 32.h),
//                 _buildSectionTitle('بيانات جواز السفر', 2),
//                 SizedBox(height: 16.h),
//                 _buildPassportFields(),
//               ],

//               SizedBox(height: 80.h), // Extra space for bottom padding
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, int index) {
//     return FadeInUp(
//       duration: Duration(milliseconds: 800 + (index * 100)),
//       child: Row(
//         children: [
//           Container(
//             width: 4.w,
//             height: 24.h,
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               borderRadius: BorderRadius.circular(2.r),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBasicFields() {
//     return Column(
//       children: [
//         _buildAnimatedField(
//           controller: _controllers['fullName']!,
//           label: 'الاسم الكامل',
//           hint: 'أدخل الاسم الكامل كما هو مكتوب في المستند',
//           prefixIcon: Icons.person_outline,
//           animationDelay: 0,
//           validator: (value) {
//             if (value?.trim().isEmpty ?? true) {
//               return 'الاسم الكامل مطلوب';
//             }
//             return null;
//           },
//         ),

//         SizedBox(height: 16.h),

//         _buildAnimatedField(
//           controller: _controllers['nationalId']!,
//           label:
//               widget.userType == UserType.citizen
//                   ? 'الرقم القومي'
//                   : 'رقم الهوية',
//           hint:
//               widget.userType == UserType.citizen
//                   ? 'أدخل الرقم القومي (14 رقم)'
//                   : 'أدخل رقم الهوية',
//           prefixIcon: Icons.badge_outlined,
//           animationDelay: 100,
//           keyboardType: TextInputType.number,
//           validator: (value) {
//             if (value?.trim().isEmpty ?? true) {
//               return 'رقم الهوية مطلوب';
//             }
//             final v = value ?? '';
//             if (widget.userType == UserType.citizen && v.length != 14) {
//               return 'الرقم القومي يجب أن يكون 14 رقم';
//             }
//             return null;
//           },
//         ),

//         SizedBox(height: 16.h),

//         // Birth Date with improved design
//         FadeInUp(
//           duration: const Duration(milliseconds: 1000),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border.all(
//                 color: AppColors.primary.withOpacity(0.2),
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primary.withOpacity(0.08),
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: InkWell(
//               onTap: () => _selectDate(context, _controllers['birthDate']!),
//               borderRadius: BorderRadius.circular(16.r),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(8.w),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: Icon(
//                         Icons.calendar_today_outlined,
//                         color: AppColors.primary,
//                         size: 20.sp,
//                       ),
//                     ),
//                     SizedBox(width: 16.w),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'تاريخ الميلاد',
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                           SizedBox(height: 4.h),
//                           Text(
//                             _controllers['birthDate']!.text.isEmpty
//                                 ? 'اختر تاريخ الميلاد'
//                                 : _formatDisplayDate(
//                                   _controllers['birthDate']!.text,
//                                 ),
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.w600,
//                               color:
//                                   _controllers['birthDate']!.text.isEmpty
//                                       ? Colors.grey[500]
//                                       : AppColors.textPrimary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_drop_down,
//                       color: AppColors.primary,
//                       size: 24.sp,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildContactFields() {
//     return Column(
//       children: [
//         // Phone Field with consistent design
//         _buildAnimatedField(
//           controller: _controllers['phone']!,
//           label: 'رقم الهاتف',
//           hint: widget.isEmailMode
//               ? 'أدخل رقم الهاتف'
//               : '📱 رقم الهاتف المستخدم في التسجيل',
//           prefixIcon: Icons.phone_outlined,
//           animationDelay: 500,
//           keyboardType: TextInputType.phone,
//           readOnly: !widget.isEmailMode, // Read-only if phone was used for signup
//           validator: (value) {
//             if (value?.trim().isEmpty ?? true) {
//               return 'رقم الهاتف مطلوب';
//             }
//             if (!RegExp(r'^\+?[0-9]{10,15}$')
//                 .hasMatch(value!.replaceAll(RegExp(r'[\s-]'), ''))) {
//               return 'رقم الهاتف غير صحيح';
//             }
//             return null;
//           },
//         ),

//         SizedBox(height: 20.h),

//         // Email Field with consistent design
//         _buildAnimatedField(
//           controller: _controllers['email']!,
//           label: 'البريد الإلكتروني',
//           hint: widget.isEmailMode
//               ? '📧 البريد الإلكتروني المستخدم في التسجيل'
//               : 'أدخل البريد الإلكتروني',
//           prefixIcon: Icons.email_outlined,
//           animationDelay: 600,
//           keyboardType: TextInputType.emailAddress,
//           readOnly: widget.isEmailMode, // Read-only if email was used for signup
//           validator: (value) {
//             if (value?.trim().isEmpty ?? true) {
//               return 'البريد الإلكتروني مطلوب';
//             }
//             if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                 .hasMatch(value!)) {
//               return 'البريد الإلكتروني غير صحيح';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPassportFields() {
//     return Column(
//       children: [
//               return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPassportFields() {
//     return Column(
//       children: [
//         _buildAnimatedField(
//           controller: _controllers['passportNumber']!,
//           label: 'رقم جواز السفر',
//           hint: 'أدخل رقم جواز السفر',
//           prefixIcon: Icons.assignment_outlined,
//           animationDelay: 600,
//           validator: (value) {
//             if (value?.trim().isEmpty ?? true) {
//               return 'رقم جواز السفر مطلوب';
//             }
//             return null;
//           },
//         ),

//         SizedBox(height: 16.h),

//         _buildAnimatedField(
//           controller: _controllers['nationality']!,
//           label: 'الجنسية',
//           hint: 'أدخل الجنسية',
//           prefixIcon: Icons.flag_outlined,
//           animationDelay: 700,
//           validator: (value) {
//             if (value?.trim().isEmpty ?? true) {
//               return 'الجنسية مطلوبة';
//             }
//             return null;
//           },
//         ),

//         SizedBox(height: 16.h),

//         Row(
//           children: [
//             Expanded(
//               child: _buildAnimatedField(
//                 controller: _controllers['passportIssueDate']!,
//                 label: 'تاريخ إصدار الجواز',
//                 hint: 'YYYY-MM-DD',
//                 prefixIcon: Icons.calendar_today_outlined,
//                 animationDelay: 800,
//                 readOnly: true,
//                 onTap:
//                     () => _selectDate(
//                       context,
//                       _controllers['passportIssueDate']!,
//                     ),
//                 validator: (value) {
//                   if (value?.trim().isEmpty ?? true) {
//                     return 'تاريخ إصدار الجواز مطلوب';
//                   }
//                   return null;
//                 },
//               ),
//             ),

//             SizedBox(width: 12.w),

//             Expanded(
//               child: _buildAnimatedField(
//                 controller: _controllers['passportExpiryDate']!,
//                 label: 'تاريخ انتهاء الجواز',
//                 hint: 'YYYY-MM-DD',
//                 prefixIcon: Icons.calendar_today_outlined,
//                 animationDelay: 900,
//                 readOnly: true,
//                 onTap:
//                     () => _selectDate(
//                       context,
//                       _controllers['passportExpiryDate']!,
//                     ),
//                 validator: (value) {
//                   if (value?.trim().isEmpty ?? true) {
//                     return 'تاريخ انتهاء الجواز مطلوب';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildAnimatedField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData prefixIcon,
//     required int animationDelay,
//     String? Function(String?)? validator,
//     TextInputType? keyboardType,
//     bool readOnly = false,
//     VoidCallback? onTap,
//     int maxLines = 1,
//     bool obscureText = false,
//   }) {
//     return FadeInUp(
//       duration: Duration(milliseconds: 800 + animationDelay),
//       child: GestureDetector(
//         onTap: readOnly ? onTap : null,
//         child: AbsorbPointer(
//           absorbing: readOnly,
//           child: CustomTextField(
//             controller: controller,
//             label: label,
//             hint: hint,
//             prefixIcon: prefixIcon,
//             validator: validator,
//             keyboardType: keyboardType ?? TextInputType.text,
//             maxLines: maxLines,
//             obscureText: obscureText,
//             enabled: !readOnly,
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDate(
//     BuildContext context,
//     TextEditingController controller,
//   ) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       controller.text = picked.toString().split(' ')[0];
//     }
//   }

//   // Format date for display
//   String _formatDisplayDate(String dateString) {
//     if (dateString.isEmpty) return '';

//     try {
//       final date = DateTime.parse(dateString);
//       final months = [
//         'يناير',
//         'فبراير',
//         'مارس',
//         'أبريل',
//         'مايو',
//         'يونيو',
//         'يوليو',
//         'أغسطس',
//         'سبتمبر',
//         'أكتوبر',
//         'نوفمبر',
//         'ديسمبر',
//       ];

//       return '${date.day} ${months[date.month - 1]} ${date.year}';
//     } catch (e) {
//       return dateString;
//     }
//   }

//   bool get isValid => _formKey.currentState?.validate() ?? false;
// }
