import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/profile_completion_cubit.dart';
import '../cubit/profile_completion_state.dart';
import 'validation_message_widget.dart';
import 'validated_text_field.dart';

class LocationStepWidget extends StatelessWidget {
  const LocationStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCompletionCubit, ProfileCompletionState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCompletionCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Header
            Text(
              'معلومات السكن والعمل',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى إدخال عنوان السكن ومعلومات العمل',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Validation Message
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

            // Address Fields
            _buildAddressSection(context, cubit),

            const SizedBox(height: 24),

            // Work Information
            _buildWorkSection(context, cubit),
          ],
        );
      },
    );
  }

  Widget _buildAddressSection(
    BuildContext context,
    ProfileCompletionCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عنوان السكن',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Governorate
        ValidatedTextField(
          controller: cubit.governorateController,
          label: 'المحافظة',
          hint: 'اختر المحافظة',
          readOnly: true,
          suffixIcon: Icons.keyboard_arrow_down_rounded,
          onTap: () => _showGovernorateSelection(context, cubit),
        ),

        const SizedBox(height: 16),

        // City
        ValidatedTextField(
          controller: cubit.cityController,
          label: 'المدينة / المركز',
          hint: 'اختر المدينة أو المركز',
          readOnly: true,
          suffixIcon: Icons.keyboard_arrow_down_rounded,
          onTap: () => _showCitySelection(context, cubit),
          enabled: cubit.selectedGovernorate != null,
        ),

        const SizedBox(height: 16),

        // Area
        ValidatedTextField(
          controller: cubit.areaController,
          label: 'المنطقة / الحي',
          hint: 'اختر المنطقة أو الحي',
          readOnly: true,
          suffixIcon: Icons.keyboard_arrow_down_rounded,
          onTap: () => _showAreaSelection(context, cubit),
          enabled: cubit.selectedCity != null,
        ),

        const SizedBox(height: 16),

        // Detailed Address
        ValidatedTextField(
          controller: cubit.detailedAddressController,
          label: 'العنوان التفصيلي',
          hint: 'رقم المبنى، اسم الشارع، معالم مميزة',
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildWorkSection(BuildContext context, ProfileCompletionCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات العمل',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Job Title
        ValidatedTextField(
          controller: cubit.jobTitleController,
          label: 'المهنة / المسمى الوظيفي',
          hint: 'مثل: مهندس، طبيب، معلم',
        ),

        const SizedBox(height: 16),

        // Company Name
        ValidatedTextField(
          controller: cubit.companyNameController,
          label: 'اسم الشركة / جهة العمل',
          hint: 'اسم الشركة أو المؤسسة',
        ),

        const SizedBox(height: 16),

        // Work Address
        ValidatedTextField(
          controller: cubit.workAddressController,
          label: 'عنوان العمل',
          hint: 'عنوان مكان العمل',
          maxLines: 2,
        ),
      ],
    );
  }

  void _showGovernorateSelection(
    BuildContext context,
    ProfileCompletionCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _GovernorateSelectionSheet(
            onGovernorateSelected: (governorate) {
              cubit.selectGovernorate(governorate);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showCitySelection(BuildContext context, ProfileCompletionCubit cubit) {
    if (cubit.selectedGovernorate == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CitySelectionSheet(
            governorate: cubit.selectedGovernorate!.name,
            onCitySelected: (city) {
              cubit.selectCity(city);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showAreaSelection(BuildContext context, ProfileCompletionCubit cubit) {
    if (cubit.selectedCity == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _AreaSelectionSheet(
            city: cubit.selectedCity!.name,
            onAreaSelected: (area) {
              cubit.selectArea(area);
              Navigator.pop(context);
            },
          ),
    );
  }
}

class _GovernorateSelectionSheet extends StatelessWidget {
  final Function(String) onGovernorateSelected;

  const _GovernorateSelectionSheet({required this.onGovernorateSelected});

  @override
  Widget build(BuildContext context) {
    final governorates = [
      'القاهرة',
      'الجيزة',
      'الإسكندرية',
      'الدقهلية',
      'الشرقية',
      'القليوبية',
      'كفر الشيخ',
      'الغربية',
      'المنوفية',
      'البحيرة',
      'الإسماعيلية',
      'بور سعيد',
      'السويس',
      'المنيا',
      'بني سويف',
      'الفيوم',
      'أسيوط',
      'سوهاج',
      'قنا',
      'الأقصر',
      'أسوان',
      'البحر الأحمر',
      'الوادي الجديد',
      'مطروح',
      'شمال سيناء',
      'جنوب سيناء',
      'دمياط',
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'اختر المحافظة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: governorates.length,
              itemBuilder: (context, index) {
                final governorate = governorates[index];
                return ListTile(
                  title: Text(
                    governorate,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () => onGovernorateSelected(governorate),
                  trailing: const Icon(Icons.keyboard_arrow_left_rounded),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CitySelectionSheet extends StatelessWidget {
  final String governorate;
  final Function(String) onCitySelected;

  const _CitySelectionSheet({
    required this.governorate,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    // This would typically come from a data source
    final cities = _getCitiesForGovernorate(governorate);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'اختر المدينة / المركز - $governorate',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return ListTile(
                  title: Text(city, style: const TextStyle(fontSize: 16)),
                  onTap: () => onCitySelected(city),
                  trailing: const Icon(Icons.keyboard_arrow_left_rounded),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getCitiesForGovernorate(String governorate) {
    // Sample data - in real app, this would come from a proper data source
    switch (governorate) {
      case 'القاهرة':
        return [
          'مصر الجديدة',
          'المعادي',
          'الزمالك',
          'مدينة نصر',
          'التجمع الخامس',
        ];
      case 'الجيزة':
        return ['الدقي', 'المهندسين', 'العجوزة', 'الشيخ زايد', '6 أكتوبر'];
      case 'الإسكندرية':
        return ['المنتزه', 'سيدي جابر', 'محطة الرمل', 'ميامي', 'العامرية'];
      default:
        return ['المركز', 'المدينة'];
    }
  }
}

class _AreaSelectionSheet extends StatelessWidget {
  final String city;
  final Function(String) onAreaSelected;

  const _AreaSelectionSheet({required this.city, required this.onAreaSelected});

  @override
  Widget build(BuildContext context) {
    final areas = _getAreasForCity(city);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'اختر المنطقة / الحي - $city',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: areas.length,
              itemBuilder: (context, index) {
                final area = areas[index];
                return ListTile(
                  title: Text(area, style: const TextStyle(fontSize: 16)),
                  onTap: () => onAreaSelected(area),
                  trailing: const Icon(Icons.keyboard_arrow_left_rounded),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getAreasForCity(String city) {
    // Sample data - in real app, this would come from a proper data source
    return ['الحي الأول', 'الحي الثاني', 'الحي الثالث', 'المنطقة المركزية'];
  }
}
