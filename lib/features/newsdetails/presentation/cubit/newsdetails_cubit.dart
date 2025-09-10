import 'package:flutter_bloc/flutter_bloc.dart';
import 'newsdetails_state.dart';

class NewsDetailsCubit
    extends Cubit<NewsDetailsState> {
  NewsDetailsCubit()
      : super(NewsdetailsInitial());

  Future<void> doSomething() async {
    emit(NewsDetailsLoading());
    try {
      // Call usecase
      // emit(NewsdetailsSuccess(result));
    } catch (e) {
      emit(NewsDetailsFailure(e.toString()));
    }
  }
}
