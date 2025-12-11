abstract class OnboardingState {
  final int currentPage;

  const OnboardingState(this.currentPage);
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial() : super(0);
}

class OnboardingPageChangedState extends OnboardingState {
  const OnboardingPageChangedState(super.currentPage);
}

class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted() : super(2);
}
