import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio();
    _dio.options = BaseOptions(
      baseUrl: 'https://yesjtlgciywmwrdpjqsr.supabase.co', // Replace with your Supabase URL
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inllc2p0bGdjaXl3bXdyZHBqcXNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1OTA0MDMsImV4cCI6MjA3MzE2NjQwM30.0CNthKQ6Ok2L-9JjReCAUoqEeRHSidxTMLmCl2eEPhw', // Replace with your Supabase anon key
      },
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('API Error: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  String? getAuthToken() {
    // Implement token retrieval from secure storage
    return null;
  }
}

class ApiEndpoints {
  static const String auth = '/auth/v1';
  static const String rest = '/rest/v1';

  // Auth endpoints
  static const String signUp = '$auth/signup';
  static const String signIn = '$auth/token?grant_type=password';
  static const String signOut = '$auth/logout';
  static const String resetPassword = '$auth/recover';

  // User endpoints
  static const String users = '$rest/users';
  static const String identityDocuments = '$rest/identity_documents';
  static const String governorates = '$rest/governorates';
  static const String cities = '$rest/cities';
  static const String districts = '$rest/districts';
  static const String userLogs = '$rest/user_logs';
}
