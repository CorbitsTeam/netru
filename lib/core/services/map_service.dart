import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

/// Service for opening maps applications with coordinates
class MapService {
  /// Open coordinates in the default maps application
  static Future<bool> openLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    try {
      // Try different map applications in order of preference

      // 1. Try Google Maps first (most reliable)
      final googleMapsUrl = _buildGoogleMapsUrl(
        latitude,
        longitude,
        locationName,
      );
      if (await _launchUrl(googleMapsUrl)) {
        return true;
      }

      // 2. Try Apple Maps on iOS
      if (Platform.isIOS) {
        final appleMapsUrl = _buildAppleMapsUrl(
          latitude,
          longitude,
          locationName,
        );
        if (await _launchUrl(appleMapsUrl)) {
          return true;
        }
      }

      // 3. Try generic geo: URL
      final geoUrl = _buildGeoUrl(latitude, longitude, locationName);
      if (await _launchUrl(geoUrl)) {
        return true;
      }

      // 4. Fallback to web Google Maps
      final webMapsUrl = _buildWebGoogleMapsUrl(
        latitude,
        longitude,
        locationName,
      );
      return await _launchUrl(webMapsUrl);
    } catch (e) {
      print('Error opening maps: $e');
      return false;
    }
  }

  /// Build Google Maps URL for native app
  static String _buildGoogleMapsUrl(
    double latitude,
    double longitude,
    String? locationName,
  ) {
    if (Platform.isIOS) {
      return 'comgooglemaps://?q=$latitude,$longitude&center=$latitude,$longitude&zoom=15';
    } else {
      // Android
      final query =
          locationName != null
              ? Uri.encodeComponent(locationName)
              : '$latitude,$longitude';
      return 'google.navigation:q=$query&mode=d';
    }
  }

  /// Build Apple Maps URL (iOS only)
  static String _buildAppleMapsUrl(
    double latitude,
    double longitude,
    String? locationName,
  ) {
    final query =
        locationName != null
            ? Uri.encodeComponent(locationName)
            : '$latitude,$longitude';
    return 'maps://maps.apple.com/?q=$query&ll=$latitude,$longitude&z=15';
  }

  /// Build generic geo: URL
  static String _buildGeoUrl(
    double latitude,
    double longitude,
    String? locationName,
  ) {
    if (locationName != null) {
      return 'geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(locationName)})';
    } else {
      return 'geo:$latitude,$longitude?z=15';
    }
  }

  /// Build web Google Maps URL (fallback)
  static String _buildWebGoogleMapsUrl(
    double latitude,
    double longitude,
    String? locationName,
  ) {
    final query =
        locationName != null
            ? Uri.encodeComponent(locationName)
            : '$latitude,$longitude';
    return 'https://www.google.com/maps/search/?api=1&query=$query';
  }

  /// Launch URL with proper error handling
  static Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Failed to launch URL: $url, Error: $e');
    }
    return false;
  }

  /// Check if any maps application is available
  static Future<bool> isMapsAvailable() async {
    try {
      // Test with a dummy coordinate
      const testLat = 24.7136;
      const testLng = 46.6753; // Riyadh coordinates

      final googleMapsUrl = _buildGoogleMapsUrl(testLat, testLng, null);
      final uri = Uri.parse(googleMapsUrl);

      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Get a user-friendly location string for display
  static String getLocationDisplayString({
    required double latitude,
    required double longitude,
    String? locationName,
  }) {
    if (locationName != null && locationName.isNotEmpty) {
      return locationName;
    }

    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Format coordinates for sharing
  static String formatCoordinatesForSharing({
    required double latitude,
    required double longitude,
    String? locationName,
  }) {
    final coords =
        '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

    if (locationName != null && locationName.isNotEmpty) {
      return '$locationName\nالإحداثيات: $coords';
    }

    return 'الإحداثيات: $coords';
  }

  /// Generate a maps URL for sharing (web compatible)
  static String getShareableMapUrl({
    required double latitude,
    required double longitude,
    String? locationName,
  }) {
    return _buildWebGoogleMapsUrl(latitude, longitude, locationName);
  }
}
