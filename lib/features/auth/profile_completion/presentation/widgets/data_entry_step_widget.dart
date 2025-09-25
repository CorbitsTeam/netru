import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/profile_completion_cubit.dart';
import '../cubit/profile_completion_state.dart';
import 'validation_message_widget.dart';
import 'validated_text_field.dart';

class DataEntryStepWidget extends StatelessWidget {
  const DataEntryStepWidget({super.key});

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
                'البيانات الشخصية',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى إدخال بياناتك الشخصية بدقة',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Validation Messages
              if (state is ProfileCompletionValidationError)
                ValidationMessageWidget(
                  message: state.errorMessage,
                  type: ValidationType.error,
                ),

              if (state is ProfileCompletionValidating)
                ValidationMessageWidget(
                  message: state.message,
                  type: ValidationType.loading,
                ),

              const SizedBox(height: 16),

              // Full Name
              ValidatedTextField(
                controller: cubit.fullNameController,
                label: 'الاسم الكامل',
                hint: 'أدخل اسمك الكامل كما هو مكتوب في البطاقة',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) => value?.isEmpty == true ? 'الاسم الكامل مطلوب' : null,
              ),
              
              const SizedBox(height: 16),

              // Email
              ValidatedTextField(
                controller: cubit.emailController,
                label: 'البريد الإلكتروني',
                hint: 'أدخل بريدك الإلكتروني',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => value?.isEmpty == true ? 'البريد الإلكتروني مطلوب' : null,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    cubit.validateEmailInRealTime(value);
                  }
                },
              ),
              
              const SizedBox(height: 16),

              // Phone
              ValidatedTextField(
                controller: cubit.phoneController,
                label: 'رقم التليفون',
                hint: 'أدخل رقم التليفون',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) => value?.isEmpty == true ? 'رقم التليفون مطلوب' : null,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    cubit.validatePhoneInRealTime(value);
                  }
                },
              ),
              
              const SizedBox(height: 24),

              // User Type Selection
              _buildUserTypeSection(context, cubit),
              
              const SizedBox(height: 16),

              // National ID (for Citizens)
              if (cubit.userFormData['user_type'] != 'foreigner')
                Column(
                  children: [
                    ValidatedTextField(
                      controller: cubit.nationalIdController,
                      label: 'الرقم القومي',
                      hint: 'أدخل الرقم القومي (14 رقم)',
                      prefixIcon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (cubit.userFormData['user_type'] != 'foreigner' && 
                            (value?.isEmpty == true)) {
                          return 'الرقم القومي مطلوب للمواطنين';
                        }
                        if (value != null && value.isNotEmpty && value.length != 14) {
                          return 'الرقم القومي يجب أن يكون 14 رقم';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          cubit.validateNationalIdInRealTime(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Passport (for Foreigners)
              if (cubit.userFormData['user_type'] == 'foreigner')
                Column(
                  children: [
                    ValidatedTextField(
                      controller: cubit.passportController,
                      label: 'رقم جواز السفر',
                      hint: 'أدخل رقم جواز السفر',
                      prefixIcon: Icons.flight_takeoff_outlined,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (cubit.userFormData['user_type'] == 'foreigner' && 
                            (value?.isEmpty == true)) {
                          return 'رقم جواز السفر مطلوب للأجانب';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          cubit.validatePassportInRealTime(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserTypeSection(BuildContext context, ProfileCompletionCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع المستخدم',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildUserTypeOption(
                context: context,
                title: 'مواطن مصري',
                subtitle: 'لديك رقم قومي مصري',
                icon: Icons.flag_outlined,
                value: 'citizen',
                selectedValue: cubit.userFormData['user_type'],
                onChanged: (value) {
                  cubit.onDataChanged({'user_type': value!});
                  // Clear the other field when switching
                  if (value == 'citizen') {
                    cubit.passportController.clear();
                  } else {
                    cubit.nationalIdController.clear();
                  }
                },
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: _buildUserTypeOption(
                context: context,
                title: 'أجنبي',
                subtitle: 'لديك جواز سفر',
                icon: Icons.public_outlined,
                value: 'foreigner',
                selectedValue: cubit.userFormData['user_type'],
                onChanged: (value) {
                  cubit.onDataChanged({'user_type': value!});
                  // Clear the other field when switching
                  if (value == 'citizen') {
                    cubit.passportController.clear();
                  } else {
                    cubit.nationalIdController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = selectedValue == value;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}