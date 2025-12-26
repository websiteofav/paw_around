import 'package:paw_around/models/places/service_type.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {
  final int currentTabIndex;

  HomeInitial({this.currentTabIndex = 0});
}

class HomeTabSelected extends HomeState {
  final int currentTabIndex;
  final ServiceType? mapServiceFilter;

  HomeTabSelected(this.currentTabIndex, {this.mapServiceFilter});
}
