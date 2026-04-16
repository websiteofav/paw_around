import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/bloc/places_bloc.dart';
import 'package:paw_around/bloc/bloc/places_event.dart';
import 'package:paw_around/bloc/bloc/places_state.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/ui/home/widgets/home_header.dart';
import 'package:paw_around/ui/home/widgets/home_hero_banner.dart';
import 'package:paw_around/ui/home/widgets/home_moments_section.dart';
import 'package:paw_around/ui/home/widgets/home_my_babies_section.dart';
import 'package:paw_around/ui/home/widgets/home_quick_actions_grid.dart';
import 'package:paw_around/ui/home/widgets/lost_pets_section.dart';
import 'package:paw_around/ui/home/widgets/place_card.dart';
import 'package:paw_around/ui/home/widgets/home_shimmer.dart';
import 'package:paw_around/ui/home/widgets/welcome_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = sl<LocationService>();
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _loadLocationAndData();
  }

  Future<void> _loadLocationAndData() async {
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _userPosition = result.isSuccess ? result.position : null);
    context.read<CommunityBloc>().add(_userPosition != null
        ? LoadPosts(userLocation: _userPosition, radiusMeters: 50000)
        : const LoadPosts());
    context.read<PetMomentsBloc>().add(const LoadMoments());
    if (_userPosition != null) {
      context.read<PlacesBloc>().add(LoadNearbyPlaces(
            latitude: _userPosition!.latitude,
            longitude: _userPosition!.longitude,
          ));
    }
  }

  Future<void> _onRefresh() async {
    await _loadLocationAndData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<PetListBloc, PetListState>(
          builder: (context, petState) {
            if (petState is PetListInitial || petState is PetListLoading) {
              return const HomeShimmer();
            }
            final hasPets =
                petState is PetListLoaded && petState.pets.isNotEmpty;
            final firstPet = hasPets ? petState.pets.first : null;
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: hasPets
                  ? _buildDashboard(context, firstPet: firstPet)
                  : _buildWelcomeState(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height - 160),
        child: const Center(child: WelcomeCard()),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, {PetModel? firstPet}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            HomeHeader(
                onProfileTap: () =>
                    context.read<HomeBloc>().add(HomeTabChanged(3))),
            const SizedBox(height: 24),
            const HomeMyBabiesSection(),
            const SizedBox(height: 24),
            HomeQuickActionsGrid(
              onVaccines: () => context.pushNamed(AppRoutes.addVaccine),
              onTickFlea: () => context.pushNamed(AppRoutes.tickFleaSettings,
                  extra: firstPet),
              onGrooming: () => context.pushNamed(AppRoutes.groomingSettings,
                  extra: firstPet),
              onReportLost: () => context.pushNamed(AppRoutes.createPost),
            ),
            const SizedBox(height: 24),
            _buildLostPetsSection(),
            const SizedBox(height: 24),
            HomeMomentsSection(
                onSeeAll: () => context
                    .read<HomeBloc>()
                    .add(HomeTabChanged(2, pawCircleInitialTab: 1))),
            const SizedBox(height: 24),
            _buildNearbyServicesSection(),
            const SizedBox(height: 24),
            const HomeHeroBanner(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildLostPetsSection() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is! CommunityLoaded) return const SizedBox.shrink();
        final lostPets = state.posts
            .where((p) => p.type == PostType.lost && !p.isResolved)
            .take(3)
            .map(
              (p) => LostPetItem(
                  id: p.id,
                  name: p.petName,
                  distance: _getDistanceText(p),
                  imageUrl: p.imagePath,
                  missingDays: DateTime.now().difference(p.createdAt).inDays,
                  breed: p.breed,
                  color: p.color),
            )
            .toList();
        return LostPetsSection(
            pets: lostPets,
            onSeeAllTap: () => context.read<HomeBloc>().add(HomeTabChanged(2)),
            onPetTap: (pet) => context.push('/community/${pet.id}'));
      },
    );
  }

  Widget _buildNearbyServicesSection() {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        if (state is! PlacesLoaded || state.places.isEmpty) {
          return const SizedBox.shrink();
        }
        void onExploreTap() => context.read<HomeBloc>().add(HomeTabChanged(1));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppStrings.nearbyServices,
                style: AppTextStyles.boldStyle700(
                    fontSize: 18, fontColor: AppColors.grey1000)),
            GestureDetector(
                onTap: onExploreTap,
                child: Row(children: [
                  Text(AppStrings.exploreAll,
                      style: AppTextStyles.interBoldStyle700(
                          fontSize: 16, fontColor: AppColors.secondaryCTA)),
                  const Icon(Icons.chevron_right,
                      color: AppColors.secondaryCTA, size: 18),
                ])),
          ]),
          const SizedBox(height: 12),
          ...state.places.take(3).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PlaceCard(place: p, onDirectionsTap: onExploreTap),
              )),
        ]);
      },
    );
  }

  String _getDistanceText(LostFoundPost post) {
    if (_userPosition == null) return AppStrings.nearby;
    final dist = _locationService.calculateDistance(
      startLatitude: _userPosition!.latitude,
      startLongitude: _userPosition!.longitude,
      endLatitude: post.latitude,
      endLongitude: post.longitude,
    );
    final km = dist / 1000;
    return '${km < 1 ? '< 1' : km.toStringAsFixed(1)} ${AppStrings.kmAway}';
  }
}
