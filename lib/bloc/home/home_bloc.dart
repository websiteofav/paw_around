import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeTabChanged>(_onTabChanged);
  }

  void _onTabChanged(HomeTabChanged event, Emitter<HomeState> emit) {
    emit(HomeTabSelected(event.tabIndex));
  }
}
