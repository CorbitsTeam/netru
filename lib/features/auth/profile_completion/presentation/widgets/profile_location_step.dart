import 'package:flutter/material.dart';
import 'package:netru_app/features/auth/widgets/simple_location_step.dart';
import '../../../../../core/services/location_service.dart';

class ProfileLocationStep extends StatelessWidget {
  final GovernorateModel? selectedGovernorate;
  final CityModel? selectedCity;
  final Function(GovernorateModel?) onGovernorateChanged;
  final Function(CityModel?) onCityChanged;

  const ProfileLocationStep({
    super.key,
    this.selectedGovernorate,
    this.selectedCity,
    required this.onGovernorateChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleLocationStep(
      selectedGovernorate: selectedGovernorate,
      selectedCity: selectedCity,
      onGovernorateChanged: onGovernorateChanged,
      onCityChanged: onCityChanged,
    );
  }
}
