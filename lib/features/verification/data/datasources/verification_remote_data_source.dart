import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/identity_document_model.dart';
import '../../domain/entities/identity_document.dart';
import '../../domain/entities/extracted_document_data.dart';

abstract class VerificationRemoteDataSource {
  Future<String> uploadDocumentImage({
    required File imageFile,
    required String userId,
    required DocumentType documentType,
  });

  Future<IdentityDocumentModel> saveIdentityDocument({
    required String userId,
    required DocumentType documentType,
    required ExtractedDocumentData extractedData,
    required String imageUrl,
  });

  Future<List<IdentityDocumentModel>> getUserDocuments(String userId);
  Future<IdentityDocumentModel> getDocumentById(String documentId);
  Future<IdentityDocumentModel> updateDocumentStatus({
    required String documentId,
    required DocumentStatus status,
    String? rejectionReason,
  });
  Future<void> deleteDocument(String documentId);
  Future<bool> hasVerifiedIdentity(String userId);
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final SupabaseClient _supabaseClient;
  final Uuid _uuid;

  VerificationRemoteDataSourceImpl({
    required SupabaseClient supabaseClient,
    required Uuid uuid,
  }) : _supabaseClient = supabaseClient,
       _uuid = uuid;

  @override
  Future<String> uploadDocumentImage({
    required File imageFile,
    required String userId,
    required DocumentType documentType,
  }) async {
    try {
      final fileName =
          '${userId}_${documentType.name}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'identity_docs/$userId/$fileName';

      await _supabaseClient.storage
          .from('identity_docs')
          .upload(path, imageFile);

      final url = _supabaseClient.storage
          .from('identity_docs')
          .getPublicUrl(path);

      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<IdentityDocumentModel> saveIdentityDocument({
    required String userId,
    required DocumentType documentType,
    required ExtractedDocumentData extractedData,
    required String imageUrl,
  }) async {
    try {
      final documentId = _uuid.v4();
      final now = DateTime.now();

      final data = {
        'id': documentId,
        'user_id': userId,
        'document_type': documentType.name,
        'document_number': extractedData.documentNumber,
        'full_name': extractedData.fullName,
        'date_of_birth': extractedData.dateOfBirth,
        'nationality': extractedData.nationality,
        'expiry_date': extractedData.expiryDate,
        'issue_date': extractedData.issueDate,
        'place_of_birth': extractedData.placeOfBirth,
        'image_url': imageUrl,
        'extracted_data_json': extractedData.toJson(),
        'status': DocumentStatus.pending.name,
        'created_at': now.toIso8601String(),
      };

      final response =
          await _supabaseClient
              .from('identity_documents')
              .insert(data)
              .select()
              .single();

      return IdentityDocumentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to save identity document: $e');
    }
  }

  @override
  Future<List<IdentityDocumentModel>> getUserDocuments(String userId) async {
    try {
      final response = await _supabaseClient
          .from('identity_documents')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((doc) => IdentityDocumentModel.fromJson(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user documents: $e');
    }
  }

  @override
  Future<IdentityDocumentModel> getDocumentById(String documentId) async {
    try {
      final response =
          await _supabaseClient
              .from('identity_documents')
              .select()
              .eq('id', documentId)
              .single();

      return IdentityDocumentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  @override
  Future<IdentityDocumentModel> updateDocumentStatus({
    required String documentId,
    required DocumentStatus status,
    String? rejectionReason,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        'verified_at':
            status == DocumentStatus.verified
                ? DateTime.now().toIso8601String()
                : null,
        'rejection_reason': rejectionReason,
      };

      final response =
          await _supabaseClient
              .from('identity_documents')
              .update(updateData)
              .eq('id', documentId)
              .select()
              .single();

      return IdentityDocumentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update document status: $e');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _supabaseClient
          .from('identity_documents')
          .delete()
          .eq('id', documentId);
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  @override
  Future<bool> hasVerifiedIdentity(String userId) async {
    try {
      final response = await _supabaseClient
          .from('identity_documents')
          .select('id')
          .eq('user_id', userId)
          .eq('status', DocumentStatus.verified.name)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check verification status: $e');
    }
  }
}
