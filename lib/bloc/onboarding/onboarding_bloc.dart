import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingSkip>(_onSkip);
    on<OnboardingPageChanged>(_onPageChanged);
  }

  void _onNextPage(OnboardingNextPage event, Emitter<OnboardingState> emit) {
    if (state.currentPage < 2) {
      emit(OnboardingPageChangedState(state.currentPage + 1));
    } else {
      emit(const OnboardingCompleted());
    }
  }

  void _onSkip(OnboardingSkip event, Emitter<OnboardingState> emit) {
    emit(const OnboardingCompleted());
  }

  void _onPageChanged(OnboardingPageChanged event, Emitter<OnboardingState> emit) {
    emit(OnboardingPageChangedState(event.pageIndex));
  }
}
