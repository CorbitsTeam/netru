import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {
  final int currentIndex;

  const OnboardingInitial({this.currentIndex = 0});

  @override
  List<Object> get props => [currentIndex];
}

class OnboardingPageChanged extends OnboardingState {
  final int currentIndex;
  final bool isLastPage;

  const OnboardingPageChanged({
    required this.currentIndex,
    required this.isLastPage,
  });

  @override
  List<Object> get props => [currentIndex, isLastPage];
}

class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}
