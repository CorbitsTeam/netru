import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/cubit/submission_report_cubit.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/cubit/submission_report_state.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/widgets/location_date_time_section.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/widgets/media_section.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/widgets/personal_info_section.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/widgets/report_info_section.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/widgets/submit_button.dart';

class SubmissionOfaReportPage
    extends StatelessWidget {
  const SubmissionOfaReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportFormCubit(),
      child: const ReportFormView(),
    );
  }
}

class ReportFormView extends StatefulWidget {
  const ReportFormView({super.key});

  @override
  State<ReportFormView> createState() =>
      _ReportFormViewState();
}

class _ReportFormViewState
    extends State<ReportFormView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController =
      TextEditingController();
  final _lastNameController =
      TextEditingController();
  final _nationalIdController =
      TextEditingController();
  final _phoneController =
      TextEditingController();
  final _reportTypeController =
      TextEditingController();
  final _reportDetailsController =
      TextEditingController();
  final _locationController =
      TextEditingController();
  final _dateTimeController =
      TextEditingController();

  final List<String> _reportTypes = [
    'سرقة',
    'عنف أسري',
    'بلاغ مفقودات',
    'أعمال شغب او تجمع غير قانوني',
    'حادث مروري جسيم',
    'حريق / محاولة تخريب',
    'رشوة / فساد مالي',
    'جريمة إلكترونية ( اختراق - نصب إلكتروني )',
    'ابتزاز  / تهديد',
    'خطف / إختفاء',
    'أسلحة غير مرخصة',
    'مخدرات ( تعاطي - اتجار - تصنيع )',
    'اعتداء جسدي',
    'إرهاب / نشاط مشبوه',
    'قتل / محاولة قتل',
    'سطو مسلح',
    'بلاغ آخر',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _reportTypeController.dispose();
    _reportDetailsController.dispose();
    _locationController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocConsumer<
        ReportFormCubit,
        ReportFormState
      >(
        listener: (context, state) {
          if (state.isSubmitted) {
            _showSuccessDialog(context);
          }
          if (state.errorMessage.isNotEmpty) {
            _showErrorSnackBar(
              context,
              state.errorMessage,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                ),
                child: Column(
                  children: [
                    // Personal Information Section
                    PersonalInfoSection(
                      firstNameController:
                          _firstNameController,
                      lastNameController:
                          _lastNameController,
                      nationalIdController:
                          _nationalIdController,
                      phoneController:
                          _phoneController,
                    ),
                    SizedBox(height: 10.h),

                    // Report Information Section
                    ReportInfoSection(
                      reportTypeController:
                          _reportTypeController,
                      reportDetailsController:
                          _reportDetailsController,
                      reportTypes: _reportTypes,
                    ),
                    SizedBox(height: 10.h),

                    // Location & DateTime Section
                    LocationDateTimeSection(
                      locationController:
                          _locationController,
                      dateTimeController:
                          _dateTimeController,
                    ),
                    SizedBox(height: 10.h),

                    // Media Section
                    const MediaSection(),
                    SizedBox(height: 20.h),

                    // Submit Section
                    SubmitButton(
                      onSubmit: _submitForm,
                    ),
                    SizedBox(height: 18.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black87,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'تقديم بلاغ',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.help_outline,
            color: Color(0xFF1E3A8A),
            size: 20,
          ),
          onPressed:
              () => _showHelpDialog(context),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Check required fields that might not be validated by form
      if (_locationController.text.isEmpty) {
        _showErrorSnackBar(
          context,
          'يرجى تحديد الموقع الجغرافي',
        );
        return;
      }

      if (_dateTimeController.text.isEmpty) {
        _showErrorSnackBar(
          context,
          'يرجى اختيار التاريخ والوقت',
        );
        return;
      }

      context
          .read<ReportFormCubit>()
          .submitReport(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            nationalId:
                _nationalIdController.text,
            phone: _phoneController.text,
            reportType:
                _reportTypeController.text,
            reportDetails:
                _reportDetailsController.text,
          );
    } else {
      _showErrorSnackBar(
        context,
        'يرجى مراجعة البيانات المدخلة',
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Animation Container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 60,
                      color: Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Success Title
                  const Text(
                    'تم إرسال البلاغ بنجاح',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Success Message
                  Text(
                    'شكراً لك، سيتم مراجعة بلاغك والرد عليك في أقرب وقت',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // OK Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop(); // Close dialog
                        Navigator.of(
                          context,
                        ).pop(); // Go back to home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                              0xFF1E3A8A,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                        ),
                      ),
                      child: const Text(
                        'العودة للرئيسية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showErrorSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Help Title
                  const Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Color(0xFF1E3A8A),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'مساعدة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Help Content
                  _buildHelpItem(
                    '1. املأ جميع البيانات المطلوبة بدقة',
                    Icons.edit_outlined,
                  ),
                  _buildHelpItem(
                    '2. حدد موقعك الجغرافي بالضغط على زر الموقع',
                    Icons.location_on_outlined,
                  ),
                  _buildHelpItem(
                    '3. اختر التاريخ والوقت المناسب',
                    Icons.access_time_outlined,
                  ),
                  _buildHelpItem(
                    '4. يمكنك إضافة صور أو فيديوهات (اختياري)',
                    Icons.photo_camera_outlined,
                  ),
                  _buildHelpItem(
                    '5. تأكد من صحة البيانات ثم اضغط إرسال',
                    Icons.send_outlined,
                  ),

                  const SizedBox(height: 16),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed:
                          () => Navigator.pop(
                            context,
                          ),
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                      ),
                      child: const Text(
                        'فهمت',
                        style: TextStyle(
                          color: Color(
                            0xFF1E3A8A,
                          ),
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHelpItem(
    String text,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(
                0xFF1E3A8A,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                6,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
