import '../repositories/cases_repository.dart';
import '../../data/models/case_model.dart';

class CasesUseCase {
  final CasesRepository repository;

  CasesUseCase(this.repository);

  Future<List<CaseModel>> getLatestCases({int limit = 10}) async {
    return await repository.getLatestCases(limit: limit);
  }

  Future<List<CaseModel>> getTrendingCases({int limit = 10}) async {
    return await repository.getTrendingCases(limit: limit);
  }

  Future<CaseModel?> getCaseById(String id) async {
    return await repository.getCaseById(id);
  }
}
