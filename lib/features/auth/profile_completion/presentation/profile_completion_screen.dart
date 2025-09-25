import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/profile_completion_cubit.dart';
import 'cubit/profile_completion_state.dart';
import 'widgets/data_entry_step_widget.dart';
import 'widgets/location_step_widget.dart';
import 'widgets/review_step_widget.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'إكمال الملف الشخصي',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ProfileCompletionCubit, ProfileCompletionState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCompletionCubit>();

          return Column(
            children: [
              // Step Progress Indicator
              _buildStepIndicator(context, cubit.currentStep),

              // Content
              Expanded(
                child: PageView(
                  controller: cubit.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    DataEntryStepWidget(),
                    LocationStepWidget(),
                    ReviewStepWidget(),
                  ],
                ),
              ),

              // Navigation Buttons
              if (cubit.currentStep < 2)
                _buildNavigationButtons(context, cubit, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int currentStep) {
    final steps = ['البيانات الشخصية', 'السكن والعمل', 'المراجعة النهائية'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(
          steps.length,
          (index) => Expanded(
            child: Row(
              children: [
                // Step Circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        index <= currentStep
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        index < currentStep
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                            : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color:
                                    index <= currentStep
                                        ? Colors.white
                                        : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                  ),
                ),

                // Step Label
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            index < currentStep
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    ProfileCompletionCubit cubit,
    ProfileCompletionState state,
  ) {
    final isLoading =
        state is ProfileCompletionValidating ||
        state is ProfileCompletionLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          if (cubit.currentStep > 0)
            Expanded(
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'رجوع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

          if (cubit.currentStep > 0) const SizedBox(width: 16),

          // Next Button
          Expanded(
            child: ElevatedButton(
              onPressed:
                  isLoading
                      ? null
                      : () {
                        cubit.nextStep();
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              child: Text(
                cubit.currentStep == 1 ? 'المراجعة' : 'التالي',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
