import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment_config.dart';
import 'logger_service.dart';

/// Service for securely managing API keys and sensitive configuration
class ApiKeyService {
  static const String _groqApiKeyKey = 'groq_api_key';

  final FlutterSecureStorage _secureStorage;
  final LoggerService _logger;
  final EnvironmentConfig _envConfig;

  ApiKeyService({
    required FlutterSecureStorage secureStorage,
    required LoggerService logger,
    EnvironmentConfig? envConfig,
  }) : _secureStorage = secureStorage,
       _logger = logger,
       _envConfig = envConfig ?? EnvironmentConfig.instance;

  /// Initialize the API key service
  /// This should be called during app startup
  Future<void> initialize() async {
    try {
      await _ensureGroqApiKey();
      _logger.logInfo('✅ API Key Service initialized successfully');
    } catch (e) {
      _logger.logError('❌ Failed to initialize API Key Service: $e');
      rethrow;
    }
  }

  /// Get the Groq API key
  /// First checks secure storage, then falls back to environment config
  Future<String> getGroqApiKey() async {
    try {
      // First try to get from secure storage
      final storedKey = await _secureStorage.read(key: _groqApiKeyKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        _logger.logInfo('✅ Groq API key retrieved from secure storage');
        return storedKey;
      }

      // Fallback to environment config
      final envKey = _envConfig.groqApiKey;
      if (envKey.isNotEmpty) {
        // Store it securely for future use
        await _storeGroqApiKey(envKey);
        _logger.logInfo(
          '✅ Groq API key retrieved from environment and stored securely',
        );
        return envKey;
      }

      throw Exception(
        'Groq API key not found in secure storage or environment',
      );
    } catch (e) {
      _logger.logError('❌ Failed to get Groq API key: $e');
      rethrow;
    }
  }

  /// Store the Groq API key securely
  Future<void> setGroqApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }

    try {
      await _storeGroqApiKey(apiKey);
      _logger.logInfo('✅ Groq API key stored securely');
    } catch (e) {
      _logger.logError('❌ Failed to store Groq API key: $e');
      rethrow;
    }
  }

  /// Remove the stored API key (for logout/reset scenarios)
  Future<void> clearApiKeys() async {
    try {
      await _secureStorage.delete(key: _groqApiKeyKey);
      _logger.logInfo('✅ API keys cleared from secure storage');
    } catch (e) {
      _logger.logError('❌ Failed to clear API keys: $e');
      rethrow;
    }
  }

  /// Check if API key is available
  Future<bool> hasGroqApiKey() async {
    try {
      final storedKey = await _secureStorage.read(key: _groqApiKeyKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        return true;
      }

      // Check environment as fallback
      try {
        final envKey = _envConfig.groqApiKey;
        return envKey.isNotEmpty;
      } catch (_) {
        return false;
      }
    } catch (e) {
      _logger.logError('❌ Failed to check for Groq API key: $e');
      return false;
    }
  }

  /// Private method to store API key securely
  Future<void> _storeGroqApiKey(String apiKey) async {
    await _secureStorage.write(
      key: _groqApiKeyKey,
      value: apiKey,
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  /// Ensure API key is available during initialization
  Future<void> _ensureGroqApiKey() async {
    final hasKey = await hasGroqApiKey();
    if (!hasKey) {
      // Try to get from environment and store it
      try {
        final envKey = _envConfig.groqApiKey;
        await _storeGroqApiKey(envKey);
        _logger.logInfo(
          '✅ Groq API key loaded from environment and stored securely',
        );
      } catch (e) {
        throw Exception(
          'No Groq API key found. Please set GROQ_API_KEY as an environment variable '
          'or use --dart-define GROQ_API_KEY=your_key when running the app. Error: $e',
        );
      }
    }
  }
}
