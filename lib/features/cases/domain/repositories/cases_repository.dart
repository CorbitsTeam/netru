import '../../data/models/case_model.dart';

abstract class CasesRepository {
  Future<List<CaseModel>> getLatestCases({int limit = 10});
  Future<List<CaseModel>> getTrendingCases({int limit = 10});
  Future<CaseModel?> getCaseById(String id);
}
