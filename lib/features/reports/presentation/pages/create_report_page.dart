import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart' as di;
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import '../cubit/report_form_cubit.dart';
import '../cubit/report_form_state.dart';
import '../widgets/location_date_time_section.dart';
import '../widgets/media_section.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/report_info_section.dart';
import '../widgets/progress_dialog.dart';

class CreateReportPage extends StatelessWidget {
  const CreateReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ReportFormCubit(
            createReportUseCase: di.sl(),
            reportTypesService: di.sl(),
          ),
      child: const ReportFormView(),
    );
  }
}

class ReportFormView extends StatefulWidget {
  const ReportFormView({super.key});

  @override
  State<ReportFormView> createState() => _ReportFormViewState();
}

class _ReportFormViewState extends State<ReportFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _isProgressDialogShown = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reportDetailsController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Load report types when the page initializes
    context.read<ReportFormCubit>().loadReportTypes();
  }

  void _loadUserData() {
    // Pre-fill form with user data if available - using placeholder methods
    // You can uncomment and modify these lines once the methods are implemented
    final userHelper = UserDataHelper();
    _firstNameController.text = userHelper.getUserFirstName();
    _lastNameController.text = userHelper.getUserLastName();
    _nationalIdController.text = userHelper.getUserNationalId() ?? '';
    _phoneController.text = userHelper.getUserPhone() ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _reportDetailsController.dispose();
    _locationController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ReportFormCubit, ReportFormState>(
        listener: (context, state) {
          // Handle progress dialog
          if (state.isLoading &&
              state.submissionProgress > 0 &&
              !_isProgressDialogShown) {
            _isProgressDialogShown = true;
            ProgressDialog.show(
              context,
              progress: state.submissionProgress,
              currentStep: state.currentStep,
              isUploading: state.isUploadingMedia,
              uploadedFiles: state.uploadedFilesCount,
              totalFiles: state.totalFilesCount,
            );
          } else if (state.isLoading && _isProgressDialogShown) {
            // Update existing dialog
            Navigator.pop(context);
            ProgressDialog.show(
              context,
              progress: state.submissionProgress,
              currentStep: state.currentStep,
              isUploading: state.isUploadingMedia,
              uploadedFiles: state.uploadedFilesCount,
              totalFiles: state.totalFilesCount,
            );
          } else if (!state.isLoading && _isProgressDialogShown) {
            _isProgressDialogShown = false;
            ProgressDialog.hide(context);

            if (state.isSubmitted) {
              _showSuccessDialog(context);
            } else if (state.errorMessage.isNotEmpty) {
              _showErrorSnackBar(context, state.errorMessage);
            }
          }
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 40.h,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'تقديم بلاغ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
              ),
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              //   onPressed: () => Navigator.of(context).pop(),
              // ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.black),
                  onPressed: () => _showHelpDialog(context),
                ),
              ],
            ),

            // Form Content
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Personal Information Section
                        PersonalInfoSection(
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          nationalIdController: _nationalIdController,
                          phoneController: _phoneController,
                        ),
                        SizedBox(height: 20.h),

                        // Report Information Section
                        ReportInfoSection(
                          reportDetailsController: _reportDetailsController,
                        ),
                        SizedBox(height: 20.h),

                        // Location and Date/Time Section
                        LocationDateTimeSection(
                          locationController: _locationController,
                          dateTimeController: _dateTimeController,
                        ),
                        SizedBox(height: 20.h),

                        // Media Section
                        const MediaSection(),
                        SizedBox(height: 40.h),

                        // Submit Button
                        BlocBuilder<ReportFormCubit, ReportFormState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state.isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                elevation: 3,
                              ),
                              child:
                                  state.isLoading
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20.w,
                                            height: 20.h,
                                            child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Text(
                                            'جاري الإرسال...',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send, size: 20.sp),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'إرسال البلاغ',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                            );
                          },
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Check required fields that might not be validated by form
      if (_locationController.text.isEmpty) {
        _showErrorSnackBar(context, 'يرجى تحديد الموقع الجغرافي');
        return;
      }

      if (_dateTimeController.text.isEmpty) {
        _showErrorSnackBar(context, 'يرجى اختيار التاريخ والوقت');
        return;
      }

      context.read<ReportFormCubit>().submitReport(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        nationalId: _nationalIdController.text,
        phone: _phoneController.text,
        reportDetails: _reportDetailsController.text,
      );
    } else {
      _showErrorSnackBar(context, 'يرجى مراجعة البيانات المدخلة');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                    'شكراً لك على إرسال البلاغ. سيتم مراجعته من قبل فريقنا في أقرب وقت ممكن.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            _resetForm(); // Reset form for new report
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.blue[800]!),
                          ),
                          child: Text(
                            'بلاغ جديد',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            _resetForm(); // Reset form for new report
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'العودة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _resetForm() {
    // Clear form fields
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _nationalIdController.clear();
    _phoneController.clear();
    _reportDetailsController.clear();
    _locationController.clear();
    _dateTimeController.clear();

    // Reset the cubit state so selected report type, media, coords, etc. are cleared
    try {
      context.read<ReportFormCubit>().reset();
    } catch (_) {
      // If cubit is not available, ignore
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.blue[800],
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'مساعدة إنشاء البلاغ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Help Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHelpItem(
                        '📝 املأ جميع البيانات الشخصية المطلوبة',
                        'تأكد من صحة الاسم الأول والأخير ورقم الهوية ورقم الهاتف',
                      ),
                      _buildHelpItem(
                        '📍 حدد الموقع بدقة',
                        'استخدم GPS أو أدخل العنوان يدوياً للحصول على أفضل خدمة',
                      ),
                      _buildHelpItem(
                        '📅 اختر التاريخ والوقت الصحيح',
                        'حدد متى وقع الحدث بالضبط لمساعدتنا في المتابعة',
                      ),
                      _buildHelpItem(
                        '📸 أرفق صور أو مقاطع فيديو',
                        'الأدلة البصرية تساعد في سرعة معالجة البلاغ',
                      ),
                      _buildHelpItem(
                        '✅ راجع البيانات قبل الإرسال',
                        'تأكد من جميع المعلومات قبل الضغط على "إرسال البلاغ"',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'فهمت',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, left: 8),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
