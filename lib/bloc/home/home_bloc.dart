import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeTabChanged>(_onTabChanged);
    on<NavigateToMapWithFilter>(_onNavigateToMapWithFilter);
  }

  void _onTabChanged(HomeTabChanged event, Emitter<HomeState> emit) {
    emit(HomeTabSelected(event.tabIndex));
  }

  void _onNavigateToMapWithFilter(
    NavigateToMapWithFilter event,
    Emitter<HomeState> emit,
  ) {
    // Navigate to map tab (index 1) with the specified filter
    emit(HomeTabSelected(1, mapServiceFilter: event.filter));
  }
}
