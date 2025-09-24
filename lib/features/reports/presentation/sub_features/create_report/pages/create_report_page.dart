import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart' as di;
import 'package:netru_app/core/utils/user_data_helper.dart';
import '../../../cubit/report_form_cubit.dart';
import '../../../cubit/report_form_state.dart';
import '../../../widgets/location_date_time_section.dart';
import '../../../widgets/media_section.dart';
import '../../../widgets/personal_info_section.dart';
import '../../../widgets/report_info_section.dart';
import '../widgets/create_report_app_bar.dart';
import '../widgets/report_form_submit_button.dart';
import '../widgets/report_submission_success_dialog.dart';
import '../widgets/report_creation_help_dialog.dart';

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
    context.read<ReportFormCubit>().loadReportTypes();
  }

  void _loadUserData() {
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
          if (state.isSubmitted && !state.isLoading) {
            _showSuccessDialog();
          } else if (state.errorMessage.isNotEmpty && !state.isLoading) {
            _showErrorSnackBar(state.errorMessage);
          }
        },
        child: CustomScrollView(
          slivers: [
            CreateReportAppBar(onHelpPressed: _showHelpDialog),
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PersonalInfoSection(
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          nationalIdController: _nationalIdController,
                          phoneController: _phoneController,
                        ),
                        SizedBox(height: 20.h),
                        ReportInfoSection(
                          reportDetailsController: _reportDetailsController,
                        ),
                        SizedBox(height: 20.h),
                        LocationDateTimeSection(
                          locationController: _locationController,
                          dateTimeController: _dateTimeController,
                        ),
                        SizedBox(height: 20.h),
                        const MediaSection(),
                        SizedBox(height: 40.h),
                        ReportFormSubmitButton(onSubmit: _submitForm),
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
      if (_locationController.text.isEmpty) {
        _showErrorSnackBar('يرجى تحديد الموقع الجغرافي');
        return;
      }

      if (_dateTimeController.text.isEmpty) {
        _showErrorSnackBar('يرجى اختيار التاريخ والوقت');
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
      _showErrorSnackBar('يرجى مراجعة البيانات المدخلة');
    }
  }

  void _showErrorSnackBar(String message) {
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

  void _showSuccessDialog() {
    ReportSubmissionSuccessDialog.show(
      context,
      onNewReport: () {
        Navigator.of(context).pop();
        _resetForm();
      },
      onGoBack: () {
        Navigator.of(context).pop();
        _resetForm();
      },
    );
  }

  void _showHelpDialog() {
    ReportCreationHelpDialog.show(context);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _nationalIdController.clear();
    _phoneController.clear();
    _reportDetailsController.clear();
    _locationController.clear();
    _dateTimeController.clear();

    try {
      context.read<ReportFormCubit>().reset();
    } catch (_) {
      // If cubit is not available, ignore
    }
  }
}
