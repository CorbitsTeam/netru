import 'dart:io';

/// Environment configuration class to handle sensitive data
/// and environment-specific settings
class EnvironmentConfig {
  // Private constructor
  EnvironmentConfig._();

  static EnvironmentConfig? _instance;

  /// Singleton instance
  static EnvironmentConfig get instance {
    _instance ??= EnvironmentConfig._();
    return _instance!;
  }

  /// Get environment variable with fallback
  String getEnvVar(String key, {String? fallback}) {
    return Platform.environment[key] ?? fallback ?? '';
  }

  /// Check if running in debug mode
  bool get isDebug => const bool.fromEnvironment('DEBUG', defaultValue: true);

  /// Check if running in production
  bool get isProduction =>
      const bool.fromEnvironment('PRODUCTION', defaultValue: false);

  /// Get current environment name
  String get environment {
    if (isProduction) return 'production';
    if (isDebug) return 'debug';
    return 'development';
  }

  /// Groq API Key - can be set via environment variable or compile-time constant
  String get groqApiKey {
    // First try to get from environment variable
    final envKey = getEnvVar('GROQ_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }

    // Fallback to compile-time constant
    const compileTimeKey = String.fromEnvironment('GROQ_API_KEY');
    if (compileTimeKey.isNotEmpty) {
      return compileTimeKey;
    }

    // No hardcoded fallback for security reasons
    // API key must be provided via environment variable or compile-time constant

    // Return empty string and let validation handle the error
    return '';
  }

  /// Validate that all required environment variables are set
  void validateEnvironment() {
    final apiKey = groqApiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'GROQ_API_KEY not found. Please set it as an environment variable '
        'or compile-time constant using --dart-define GROQ_API_KEY=your_key. '
        'See API_KEY_SETUP.md for detailed instructions.',
      );
    }
  }
}
