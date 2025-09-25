import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/profile_completion_cubit.dart';
import '../cubit/profile_completion_state.dart';
import 'validation_message_widget.dart';

class ReviewStepWidget extends StatelessWidget {
  const ReviewStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCompletionCubit, ProfileCompletionState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCompletionCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Header
              Text(
                'مراجعة البيانات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى مراجعة البيانات المدخلة والتأكد من صحتها قبل إتمام التسجيل',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Validation Messages
              if (state is ProfileCompletionValidationError)
                ValidationMessageWidget(
                  message: state.errorMessage,
                  type: ValidationType.error,
                ),

              if (state is ProfileCompletionLoading)
                ValidationMessageWidget(
                  message: 'جارِ إتمام التسجيل...',
                  type: ValidationType.loading,
                ),

              if (state is ProfileCompletionSuccess)
                ValidationMessageWidget(
                  message: state.message,
                  type: ValidationType.success,
                ),

              const SizedBox(height: 16),

              // Personal Information Section
              _buildPersonalInfoSection(context, cubit),

              const SizedBox(height: 24),

              // Location Section
              _buildLocationSection(context, cubit),

              const SizedBox(height: 24),

              // Work Information Section
              _buildWorkSection(context, cubit),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(context, cubit, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalInfoSection(
    BuildContext context,
    ProfileCompletionCubit cubit,
  ) {
    return _buildReviewSection(
      context: context,
      title: 'البيانات الشخصية',
      icon: Icons.person_outline,
      children: [
        _buildReviewItem(
          context,
          'الاسم الكامل',
          cubit.fullNameController.text,
          Icons.person,
        ),
        _buildReviewItem(
          context,
          'البريد الإلكتروني',
          cubit.emailController.text,
          Icons.email,
        ),
        _buildReviewItem(
          context,
          'رقم التليفون',
          cubit.phoneController.text,
          Icons.phone,
        ),
        if (cubit.nationalIdController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'الرقم القومي',
            cubit.nationalIdController.text,
            Icons.credit_card,
          ),
        if (cubit.passportController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'رقم جواز السفر',
            cubit.passportController.text,
            Icons.flight_takeoff,
          ),
      ],
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    ProfileCompletionCubit cubit,
  ) {
    return _buildReviewSection(
      context: context,
      title: 'معلومات السكن',
      icon: Icons.location_on_outlined,
      children: [
        if (cubit.governorateController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'المحافظة',
            cubit.governorateController.text,
            Icons.map,
          ),
        if (cubit.cityController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'المدينة / المركز',
            cubit.cityController.text,
            Icons.location_city,
          ),
        if (cubit.areaController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'المنطقة / الحي',
            cubit.areaController.text,
            Icons.home_work,
          ),
        if (cubit.detailedAddressController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'العنوان التفصيلي',
            cubit.detailedAddressController.text,
            Icons.home,
          ),
      ],
    );
  }

  Widget _buildWorkSection(BuildContext context, ProfileCompletionCubit cubit) {
    return _buildReviewSection(
      context: context,
      title: 'معلومات العمل',
      icon: Icons.work_outline,
      children: [
        if (cubit.jobTitleController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'المهنة / المسمى الوظيفي',
            cubit.jobTitleController.text,
            Icons.badge,
          ),
        if (cubit.companyNameController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'اسم الشركة / جهة العمل',
            cubit.companyNameController.text,
            Icons.business,
          ),
        if (cubit.workAddressController.text.isNotEmpty)
          _buildReviewItem(
            context,
            'عنوان العمل',
            cubit.workAddressController.text,
            Icons.work,
          ),
      ],
    );
  }

  Widget _buildReviewSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Section Content
          if (children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: children),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'لم يتم إدخال بيانات لهذا القسم',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ProfileCompletionCubit cubit,
    ProfileCompletionState state,
  ) {
    final isLoading = state is ProfileCompletionLoading;
    final isSuccess = state is ProfileCompletionSuccess;

    return Column(
      children: [
        // Complete Registration Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
                isLoading || isSuccess
                    ? null
                    : () {
                      // You would pass the auth user ID here
                      cubit.completeProfile('current_user_id');
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child:
                isLoading
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'جارِ إتمام التسجيل...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text(
                          'إتمام التسجيل',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),

        const SizedBox(height: 12),

        // Back Button
        if (!isSuccess)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed:
                  isLoading
                      ? null
                      : () {
                        cubit.previousStep();
                      },
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 8),
                  Text(
                    'رجوع للخطوة السابقة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
