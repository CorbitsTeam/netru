import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cases_usecase.dart';
import 'cases_state.dart';

class CasesCubit extends Cubit<CasesState> {
  final CasesUseCase casesUseCase;

  CasesCubit(this.casesUseCase) : super(CasesInitial());

  Future<void> loadLatestCases({int limit = 5}) async {
    emit(CasesLoading());
    try {
      final cases = await casesUseCase.getLatestCases(limit: limit);
      emit(LatestCasesLoaded(cases: cases));
    } catch (e) {
      emit(
        CasesError(message: 'حدث خطأ في تحميل أحدث القضايا: ${e.toString()}'),
      );
    }
  }

  Future<void> loadTrendingCases({int limit = 5}) async {
    emit(CasesLoading());
    try {
      final cases = await casesUseCase.getTrendingCases(limit: limit);
      emit(TrendingCasesLoaded(cases: cases));
    } catch (e) {
      emit(
        CasesError(
          message: 'حدث خطأ في تحميل القضايا الرائجة: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadCaseById(String id) async {
    emit(CasesLoading());
    try {
      final caseModel = await casesUseCase.getCaseById(id);
      if (caseModel != null) {
        emit(CaseDetailsLoaded(caseModel: caseModel));
      } else {
        emit(const CasesError(message: 'لم يتم العثور على القضية'));
      }
    } catch (e) {
      emit(
        CasesError(message: 'حدث خطأ في تحميل تفاصيل القضية: ${e.toString()}'),
      );
    }
  }
}
