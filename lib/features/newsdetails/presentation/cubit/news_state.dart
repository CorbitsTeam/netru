import 'package:equatable/equatable.dart';
import '../../data/models/news_model.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsModel> newsList;
  final NewsModel? selectedNews;

  const NewsLoaded({required this.newsList, this.selectedNews});

  @override
  List<Object?> get props => [newsList, selectedNews];

  NewsLoaded copyWith({List<NewsModel>? newsList, NewsModel? selectedNews}) {
    return NewsLoaded(
      newsList: newsList ?? this.newsList,
      selectedNews: selectedNews ?? this.selectedNews,
    );
  }
}

class NewsError extends NewsState {
  final String message;

  const NewsError({required this.message});

  @override
  List<Object> get props => [message];
}
