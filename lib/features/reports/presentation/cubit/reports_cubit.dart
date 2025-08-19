import 'package:flutter_bloc/flutter_bloc.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(ReportsInitial());

  Future<void> doSomething() async {
    emit(ReportsLoading());
    try {
      // Call usecase
      // emit(ReportsSuccess(result));
    } catch (e) {
      emit(ReportsFailure(e.toString()));
    }
  }
}
