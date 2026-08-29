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
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/ui/sitter/widgets/saved_address_section.dart';
import 'package:paw_around/ui/sitter/widgets/sitter_empty_state.dart';
import 'package:paw_around/ui/sitter/widgets/sitter_search_and_actions.dart';

/// Pet Sitters entry screen — shown before any address has been saved, so the
/// user is asked to set a location first. Once addresses exist, this makes
/// way for a "Saved Address" list below the action cards.
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
    context.pushNamed(AppRoutes.pickLocation, extra: true);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
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
              final addresses = state is AddressLoaded
                  ? state.addresses
                  : const <AddressModel>[];

              return Column(
                children: [
                  AppSpacing.vertical32,
                  const SitterEmptyState(),
                  SitterSearchAndActions(
                    onSearchTap: _onSearchTap,
                    onUseCurrentLocation: _onUseCurrentLocation,
                    onAddNewAddress: _onAddNewAddress,
                  ),
                  AppSpacing.vertical24,
                  if (addresses.isNotEmpty)
                    SavedAddressSection(addresses: addresses),
                  AppSpacing.vertical24,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
