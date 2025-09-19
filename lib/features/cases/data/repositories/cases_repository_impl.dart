import '../../domain/repositories/cases_repository.dart';
import '../datasources/cases_remote_datasource.dart';
import '../models/case_model.dart';

class CasesRepositoryImpl implements CasesRepository {
  final CasesRemoteDataSource remoteDataSource;

  CasesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CaseModel>> getLatestCases({int limit = 10}) async {
    try {
      return await remoteDataSource.getLatestCases(limit: limit);
    } catch (e) {
      throw Exception('فشل في جلب أحدث القضايا: $e');
    }
  }

  @override
  Future<List<CaseModel>> getTrendingCases({int limit = 10}) async {
    try {
      return await remoteDataSource.getTrendingCases(limit: limit);
    } catch (e) {
      throw Exception('فشل في جلب القضايا الرائجة: $e');
    }
  }

  @override
  Future<CaseModel?> getCaseById(String id) async {
    try {
      final caseModel = await remoteDataSource.getCaseById(id);
      if (caseModel != null) {
        // زيادة عدد المشاهدات عند جلب قضية محددة
        await remoteDataSource.incrementCaseViewCount(id);
        return caseModel;
      }
      return null;
    } catch (e) {
      throw Exception('فشل في جلب القضية: $e');
    }
  }
}
