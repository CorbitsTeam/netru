abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsSuccess extends ReportsState {
  // final result;
  // Success(this.result);
}

class ReportsFailure extends ReportsState {
  final String error;
  ReportsFailure(this.error);
}
