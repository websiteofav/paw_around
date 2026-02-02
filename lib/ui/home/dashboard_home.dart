import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/models/places/service_type.dart';
import 'package:paw_around/ui/home/home_screen.dart';
import 'package:paw_around/ui/home/map_screen.dart';
import 'package:paw_around/ui/home/paw_circle_screen.dart';
import 'package:paw_around/ui/profile/profile_screen.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  @override
  void initState() {
    super.initState();
    // Load pets when dashboard home is shown
    context.read<PetListBloc>().add(const LoadPetList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final currentIndex =
            state is HomeTabSelected ? state.currentTabIndex : 0;
        final mapFilter =
            state is HomeTabSelected ? state.mapServiceFilter : null;

        return _getTabContent(currentIndex, mapFilter: mapFilter);
      },
    );
  }

  Widget _getTabContent(int currentIndex, {ServiceType? mapFilter}) {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return MapScreen(initialFilter: mapFilter);
      case 2:
        return const PawCircleScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
