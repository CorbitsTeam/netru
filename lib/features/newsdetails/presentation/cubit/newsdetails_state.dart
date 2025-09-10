abstract class NewsDetailsState {}

class NewsdetailsInitial
    extends NewsDetailsState {}

class NewsDetailsLoading
    extends NewsDetailsState {}

class NewsdetailsSuccess
    extends NewsDetailsState {
  // final result;
  // Success(this.result);
}

class NewsDetailsFailure
    extends NewsDetailsState {
  final String error;
  NewsDetailsFailure(this.error);
}
