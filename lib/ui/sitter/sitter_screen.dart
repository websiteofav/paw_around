import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/addresses/address/address_bloc.dart';
import 'package:paw_around/bloc/addresses/address/address_event.dart';
import 'package:paw_around/bloc/addresses/address/address_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/location/pick_location_screen.dart';
import 'package:paw_around/ui/sitter/widgets/sitter_empty_state.dart';
import 'package:paw_around/ui/sitter/widgets/sitter_search_and_actions.dart';

/// Pet Sitters entry screen — shown before any address has been saved, so
/// the user is asked to set a location first. Dashboard itself switches
/// this tab over to BookSittersScreen once an address exists (see
/// Dashboard._buildSitterTab), so this screen only ever renders for the
/// no-address-yet case.
class SitterScreen extends StatefulWidget {
  const SitterScreen({super.key});

  @override
  State<SitterScreen> createState() => _SitterScreenState();
}

class _SitterScreenState extends State<SitterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const LoadAddresses());
  }

  void _onSearchTap() {
    context.pushNamed(AppRoutes.pickLocation);
  }

  void _onUseCurrentLocation() {
    // Still routes through the pin-confirm map — GPS fixes can drift a
    // building or two off, so the user gets a chance to nudge the pin.
    context.pushNamed(
      AppRoutes.pickLocation,
      extra: const PickLocationArgs(autoUseCurrentLocation: true),
    );
  }

  void _onAddNewAddress() {
    context.pushNamed(AppRoutes.pickLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.petSittersTitle,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 18,
            fontColor: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppEdgeInsets.horizontalLarge,
          child: BlocBuilder<AddressBloc, AddressState>(
            builder: (context, state) {
              final isResolving = state is AddressInitial || state is AddressLoading;

              // While we're still finding out whether an address already
              // exists, show a neutral loader instead of flashing this
              // onboarding UI for the ~1-2s the Firestore fetch takes —
              // Dashboard swaps this whole screen out for BookSittersScreen
              // once it resolves to a non-empty list, so this only settles
              // into the Column below for the genuinely-empty case.
              if (isResolving) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              return Column(
                children: [
                  AppSpacing.vertical32,
                  const SitterEmptyState(),
                  SitterSearchAndActions(
                    onSearchTap: _onSearchTap,
                    onUseCurrentLocation: _onUseCurrentLocation,
                    onAddNewAddress: _onAddNewAddress,
                  ),
                  // Clears Dashboard's floating bottom nav bar, which sits
                  // on top of tab content — matches HomeScreen's own fix
                  // for the same overlap.
                  const SizedBox(height: 120),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
