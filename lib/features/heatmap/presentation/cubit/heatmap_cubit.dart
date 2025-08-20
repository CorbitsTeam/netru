import 'package:flutter_bloc/flutter_bloc.dart';
import 'heatmap_state.dart';

class HeatmapCubit extends Cubit<HeatmapState> {
  HeatmapCubit() : super(HeatmapInitial());

  Future<void> doSomething() async {
    emit(HeatmapLoading());
    try {
      // Call usecase
      // emit(HeatmapSuccess(result));
    } catch (e) {
      emit(HeatmapFailure(e.toString()));
    }
  }
}
