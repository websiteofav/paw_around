abstract class OnboardingEvent {}

class OnboardingNextPage extends OnboardingEvent {}

class OnboardingSkip extends OnboardingEvent {}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  OnboardingPageChanged(this.pageIndex);
}
