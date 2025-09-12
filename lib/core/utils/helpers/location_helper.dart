import 'package:geolocator/geolocator.dart';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_snack_bar.dart';

class LocationHelper {
  static Future<Position?> determineCurrentPosition(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    //* Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('Location services are disabled.');
      showModernSnackBar(
        context,
        message: "location_services_disabled".tr(),
        type: SnackBarType.error,
      );
    }

    //* Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('Location permissions are denied.');
        showModernSnackBar(
          context,
          message: "location_permission_denied".tr(),
          type: SnackBarType.error,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('Location permissions are permanently denied.');
      showModernSnackBar(
        context,
        message: "location_permission_permanently_denied".tr(),
        type: SnackBarType.error,
      );
      openLocationSettings();
      return null;
    }

    //* Try to get the last known position first for faster feedback
    Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      log(
        'Using last known position: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}',
      );
      return lastKnownPosition;
    }

    //* If no last known position is available, get the current position
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      log(
        'Current position: ${currentPosition.latitude}, ${currentPosition.longitude}',
      );
      return currentPosition;
    } catch (err) {
      log('Error getting current position: $err');
      showModernSnackBar(
        context,
        message: "Error getting current position.",
        type: SnackBarType.error,
      );
      return null;
    }
  }

  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      log('Error opening location settings: $e');
      return false;
    }
  }
}
