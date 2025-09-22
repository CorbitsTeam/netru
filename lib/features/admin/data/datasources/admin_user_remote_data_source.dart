import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_edge_functions_service.dart';
import '../models/admin_user_model.dart';
import '../models/user_profile_detail_model.dart';

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

  Future<UserProfileDetailModel> getUserDetailedProfile(String userId);
}

class AdminUserRemoteDataSourceImpl implements AdminUserRemoteDataSource {
  final SupabaseClient supabaseClient;
  final SupabaseEdgeFunctionsService edgeFunctionsService;

  AdminUserRemoteDataSourceImpl({
    required this.supabaseClient,
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
      PostgrestFilterBuilder<PostgrestList> query = supabaseClient
          .from('users')
          .select('''
            id, email, full_name, national_id, passport_number, user_type, role, 
            phone, governorate, city, district, address, nationality, profile_image,
            verification_status, verified_at, created_at, updated_at
          ''');

      // Apply filters
      if (userType != null) {
        query = query.eq('user_type', userType);
      }

      if (verificationStatus != null) {
        query = query.eq('verification_status', verificationStatus);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%$search%,email.ilike.%$search%,national_id.ilike.%$search%',
        );
      }

      // Apply order and pagination correctly
      PostgrestTransformBuilder<PostgrestList> finalQuery = query.order(
        'created_at',
        ascending: false,
      );

      if (page != null && limit != null) {
        final start = page * limit;
        final end = start + limit - 1;
        finalQuery = finalQuery.range(start, end);
      }

      final response = await finalQuery;

      return (response as List)
          .map((json) => AdminUserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  @override
  Future<AdminUserModel> getUserById(String userId) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('''
            id, email, full_name, national_id, passport_number, user_type, role, 
            phone, governorate, city, district, address, nationality, profile_image,
            verification_status, verified_at, created_at, updated_at
          ''')
              .eq('id', userId)
              .single();

      return AdminUserModel.fromJson(response);
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

      await supabaseClient.from('users').update(updateData).eq('id', userId);

      // Return updated user
      return await getUserById(userId);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await supabaseClient.from('users').delete().eq('id', userId);
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

      await supabaseClient.from('users').update(updateData).eq('id', userId);

      // Log the verification action
      await supabaseClient.from('user_logs').insert({
        'user_id': userId,
        'action':
            'User verification status changed to ${approved ? "verified" : "rejected"}${notes != null ? " - $notes" : ""}',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Return updated user
      return await getUserById(userId);
    } catch (e) {
      throw Exception('Failed to verify user: $e');
    }
  }

  @override
  Future<List<AdminUserModel>> getPendingVerifications() async {
    try {
      final response = await supabaseClient
          .from('users')
          .select('''
            id, email, full_name, national_id, passport_number, user_type, role, 
            phone, governorate, city, district, address, nationality, profile_image,
            verification_status, verified_at, created_at, updated_at
          ''')
          .eq('verification_status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
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

  @override
  Future<UserProfileDetailModel> getUserDetailedProfile(String userId) async {
    try {
      // Get user basic data
      final userResponse =
          await supabaseClient
              .from('users')
              .select('''
            id, email, full_name, national_id, passport_number, user_type, role, 
            phone, governorate, city, district, address, nationality, profile_image,
            verification_status, verified_at, created_at, updated_at
          ''')
              .eq('id', userId)
              .single();

      // Get identity documents
      final documentsResponse = await supabaseClient
          .from('identity_documents')
          .select('*')
          .eq('user_id', userId);

      // Get reports summary with counts
      final reportsResponse = await supabaseClient
          .from('reports')
          .select('''
            id, report_details, report_status, priority_level, submitted_at, updated_at,
            report_types(name),
            assigned_to:users!reports_assigned_to_fkey(full_name)
          ''')
          .eq('user_id', userId)
          .order('submitted_at', ascending: false)
          .limit(10);

      // Get reports counts
      final totalReportsCountResponse =
          await supabaseClient
              .from('reports')
              .select('id')
              .eq('user_id', userId)
              .count();

      final pendingReportsCountResponse =
          await supabaseClient
              .from('reports')
              .select('id')
              .eq('user_id', userId)
              .inFilter('report_status', [
                'pending',
                'under_investigation',
                'received',
              ])
              .count();

      final resolvedReportsCountResponse =
          await supabaseClient
              .from('reports')
              .select('id')
              .eq('user_id', userId)
              .eq('report_status', 'resolved')
              .count();

      final totalReportsCount = totalReportsCountResponse.count;
      final pendingReportsCount = pendingReportsCountResponse.count;
      final resolvedReportsCount = resolvedReportsCountResponse.count;

      // Build the detailed profile
      final Map<String, dynamic> profileData = Map<String, dynamic>.from(
        userResponse,
      );

      profileData['identity_documents'] = documentsResponse;
      profileData['reports'] =
          (reportsResponse as List).map((report) {
            final reportDetails = report['report_details']?.toString() ?? '';
            return {
              'id': report['id'],
              'title':
                  reportDetails.length > 50
                      ? '${reportDetails.substring(0, 50)}...'
                      : reportDetails.isEmpty
                      ? 'بلاغ'
                      : reportDetails,
              'description': reportDetails,
              'status': report['report_status'] ?? 'pending',
              'priority': report['priority_level'] ?? 'medium',
              'category_name': report['report_types']?['name'],
              'governorate': null, // Remove governorate from reports
              'city': null, // Remove city from reports
              'created_at': report['submitted_at'],
              'updated_at': report['updated_at'],
              'assigned_to_name': report['assigned_to']?['full_name'],
              'media_count': 0, // You might want to count media separately
              'comments_count':
                  0, // You might want to count comments separately
            };
          }).toList();

      profileData['total_reports_count'] = totalReportsCount;
      profileData['pending_reports_count'] = pendingReportsCount;
      profileData['resolved_reports_count'] = resolvedReportsCount;
      profileData['permissions'] = []; // Add logic to get permissions if needed
      profileData['activity_stats'] = {
        'total_reports': totalReportsCount,
        'pending_reports': pendingReportsCount,
        'resolved_reports': resolvedReportsCount,
      };

      return UserProfileDetailModel.fromJson(profileData);
    } catch (e) {
      throw Exception('Failed to get user detailed profile: $e');
    }
  }
}
