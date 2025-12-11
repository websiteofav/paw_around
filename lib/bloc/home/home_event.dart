abstract class HomeEvent {}

class HomeTabChanged extends HomeEvent {
  final int tabIndex;

  HomeTabChanged(this.tabIndex);
}
