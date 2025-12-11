abstract class HomeState {}

class HomeInitial extends HomeState {
  final int currentTabIndex;

  HomeInitial({this.currentTabIndex = 0});
}

class HomeTabSelected extends HomeState {
  final int currentTabIndex;

  HomeTabSelected(this.currentTabIndex);
}
