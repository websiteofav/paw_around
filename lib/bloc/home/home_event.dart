import 'package:paw_around/models/places/service_type.dart';

abstract class HomeEvent {}

class HomeTabChanged extends HomeEvent {
  final int tabIndex;

  HomeTabChanged(this.tabIndex);
}

/// Navigate to map tab with a specific service filter pre-selected
class NavigateToMapWithFilter extends HomeEvent {
  final ServiceType filter;

  NavigateToMapWithFilter(this.filter);
}
