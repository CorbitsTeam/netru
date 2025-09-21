import '../../../../core/network/api_client.dart';
import '../../../../core/services/supabase_edge_functions_service.dart';
import '../models/admin_user_model.dart';

abstract class AdminUserRemoteDataSource {
  Future<List<AdminUserModel>> getAllUsers({
    int? page,
    int? limit,
    String? search,
    String? userType,
    String? verificationStatus,
  });

  Future<AdminUserModel> getUserById(String userId);

  Future<AdminUserModel> updateUser(
    String userId,
    Map<String, dynamic> updates,
  );

  Future<void> deleteUser(String userId);

  Future<AdminUserModel> verifyUser(
    String userId, {
    required bool approved,
    String? notes,
  });

  Future<List<AdminUserModel>> getPendingVerifications();

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  Future<void> sendNotificationToUserGroup({
    required List<String> userGroups,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? governorate,
    String? city,
  });
}

class AdminUserRemoteDataSourceImpl implements AdminUserRemoteDataSource {
  final ApiClient apiClient;
  final SupabaseEdgeFunctionsService edgeFunctionsService;

  AdminUserRemoteDataSourceImpl({
    required this.apiClient,
    required this.edgeFunctionsService,
  });

  @override
  Future<List<AdminUserModel>> getAllUsers({
    int? page,
    int? limit,
    String? search,
    String? userType,
    String? verificationStatus,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'select': '''
          id, email, full_name, national_id, passport_number, user_type, role, 
          phone, governorate, city, district, address, nationality, profile_image,
          verification_status, verified_at, created_at, updated_at
        ''',
      };

      if (page != null && limit != null) {
        queryParams['offset'] = page * limit;
        queryParams['limit'] = limit;
      }

      if (userType != null) {
        queryParams['user_type'] = 'eq.$userType';
      }

      if (verificationStatus != null) {
        queryParams['verification_status'] = 'eq.$verificationStatus';
      }

      if (search != null && search.isNotEmpty) {
        queryParams['or'] =
            'full_name.ilike.*$search*,email.ilike.*$search*,national_id.ilike.*$search*';
      }

      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/users',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => AdminUserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  @override
  Future<AdminUserModel> getUserById(String userId) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/users',
        queryParameters: {
          'id': 'eq.$userId',
          'select': '''
            id, email, full_name, national_id, passport_number, user_type, role, 
            phone, governorate, city, district, address, nationality, profile_image,
            verification_status, verified_at, created_at, updated_at
          ''',
        },
      );

      final users = response.data as List;
      if (users.isEmpty) {
        throw Exception('User not found');
      }

      return AdminUserModel.fromJson(users.first);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  @override
  Future<AdminUserModel> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final updateData = Map<String, dynamic>.from(updates);
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await apiClient.dio.patch(
        '${ApiEndpoints.rest}/users',
        queryParameters: {'id': 'eq.$userId'},
        data: updateData,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Fetch updated user
        return await getUserById(userId);
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final response = await apiClient.dio.delete(
        '${ApiEndpoints.rest}/users',
        queryParameters: {'id': 'eq.$userId'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<AdminUserModel> verifyUser(
    String userId, {
    required bool approved,
    String? notes,
  }) async {
    try {
      final updateData = {
        'verification_status': approved ? 'verified' : 'rejected',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (approved) {
        updateData['verified_at'] = DateTime.now().toIso8601String();
      }

      await apiClient.dio.patch(
        '${ApiEndpoints.rest}/users',
        queryParameters: {'id': 'eq.$userId'},
        data: updateData,
      );

      // Log the verification action
      await apiClient.dio.post(
        '${ApiEndpoints.rest}/user_logs',
        data: {
          'user_id': userId,
          'action':
              'User verification status changed to ${approved ? "verified" : "rejected"}${notes != null ? " - $notes" : ""}',
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Return updated user
      return await getUserById(userId);
    } catch (e) {
      throw Exception('Failed to verify user: $e');
    }
  }

  @override
  Future<List<AdminUserModel>> getPendingVerifications() async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/users',
        queryParameters: {
          'verification_status': 'eq.pending',
          'select': '''
            id, email, full_name, national_id, passport_number, user_type, role, 
            phone, governorate, city, district, address, nationality, profile_image,
            verification_status, verified_at, created_at, updated_at
          ''',
          'order': 'created_at.desc',
        },
      );

      return (response.data as List)
          .map((json) => AdminUserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending verifications: $e');
    }
  }

  @override
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await edgeFunctionsService.sendBulkNotifications(
        userIds: [userId],
        title: title,
        body: body,
        data: data,
        type: 'user_notification',
      );
    } catch (e) {
      throw Exception('Failed to send notification to user: $e');
    }
  }

  @override
  Future<void> sendNotificationToUserGroup({
    required List<String> userGroups,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? governorate,
    String? city,
  }) async {
    try {
      await edgeFunctionsService.sendNotificationToGroups(
        userGroups: userGroups,
        title: title,
        body: body,
        data: data,
        type: 'group_notification',
        governorate: governorate,
        city: city,
      );
    } catch (e) {
      throw Exception('Failed to send notification to user group: $e');
    }
  }
}
