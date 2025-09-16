import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/routes.dart';
import '../../utils/onboarding_prefs.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingInitial());

  final PageController pageController = PageController();
  int _currentIndex = 0;
  static const int _totalPages = 3;

  int get currentIndex => _currentIndex;
  bool get isLastPage => _currentIndex == _totalPages - 1;

  /// Navigate to next page or complete onboarding if on last page
  void nextPage() {
    if (isLastPage) {
      completeOnboarding();
    } else {
      _currentIndex++;
      pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(
        OnboardingPageChanged(
          currentIndex: _currentIndex,
          isLastPage: isLastPage,
        ),
      );
    }
  }

  /// Navigate to previous page
  void previousPage() {
    if (_currentIndex > 0) {
      _currentIndex--;
      pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(
        OnboardingPageChanged(
          currentIndex: _currentIndex,
          isLastPage: isLastPage,
        ),
      );
    }
  }

  /// Navigate to specific page when dot is tapped
  void goToPage(int index) {
    if (index >= 0 && index < _totalPages) {
      _currentIndex = index;
      pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(
        OnboardingPageChanged(
          currentIndex: _currentIndex,
          isLastPage: isLastPage,
        ),
      );
    }
  }

  /// Called when PageView changes (swipe gesture)
  void onPageChanged(int index) {
    _currentIndex = index;
    emit(
      OnboardingPageChanged(
        currentIndex: _currentIndex,
        isLastPage: isLastPage,
      ),
    );
  }

  /// Skip onboarding and go to login
  void skipOnboarding() {
    completeOnboarding();
  }

  /// Complete onboarding and navigate to login screen
  Future<void> completeOnboarding() async {
    emit(const OnboardingLoading());

    try {
      // Save onboarding completion state using OnboardingPrefs
      final success = await OnboardingPrefs.setOnboardingSeen();

      if (success) {
        emit(const OnboardingCompleted());
      } else {
        // Still allow navigation even if saving failed
        emit(const OnboardingCompleted());
      }
    } catch (e) {
      // If saving fails, still allow navigation
      emit(const OnboardingCompleted());
    }
  }

  /// Navigate to login screen (called by UI when listening to OnboardingCompleted)
  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
