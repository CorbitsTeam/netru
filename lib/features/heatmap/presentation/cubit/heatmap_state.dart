abstract class HeatmapState {}

class HeatmapInitial extends HeatmapState {}

class HeatmapLoading extends HeatmapState {}

class HeatmapSuccess extends HeatmapState {
  // final result;
  // Success(this.result);
}

class HeatmapFailure extends HeatmapState {
  final String error;
  HeatmapFailure(this.error);
}
