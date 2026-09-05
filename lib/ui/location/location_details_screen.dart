import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/addresses/address/address_bloc.dart';
import 'package:paw_around/bloc/addresses/address/address_event.dart';
import 'package:paw_around/bloc/addresses/address/address_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/models/addresses/picked_location.dart';
import 'package:paw_around/ui/location/widgets/location_change_thumbnail.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';

/// Screen 2 of the address-picking flow: Building/Street/Area/label form,
/// persisted to Firestore on save.
class LocationDetailsScreen extends StatefulWidget {
  final PickedLocation pickedLocation;

  const LocationDetailsScreen({super.key, required this.pickedLocation});

  @override
  State<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buildingController = TextEditingController();
  final _streetController = TextEditingController();
  late final _areaController =
      TextEditingController(text: widget.pickedLocation.address);
  final _saveAsController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _buildingController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _saveAsController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) =>
      (value == null || value.trim().isEmpty) ? AppStrings.required : null;

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final address = AddressModel(
      id: '',
      latitude: widget.pickedLocation.latitude,
      longitude: widget.pickedLocation.longitude,
      formattedAddress: widget.pickedLocation.address,
      buildingFloor: _buildingController.text.trim(),
      street: _streetController.text.trim(),
      area: _areaController.text.trim(),
      label: _saveAsController.text.trim(),
      placeId: widget.pickedLocation.placeId,
      createdAt: now,
      updatedAt: now,
    );
    // AddressBloc reloads the list itself after a successful add — see
    // _onAddressBlocChange for the pop side effect.
    context.read<AddressBloc>().add(AddAddress(address: address));
  }

  void _onAddressBlocChange(BuildContext context, AddressState state) {
    if (state is AddressSaved) {
      HapticFeedback.mediumImpact();
      // Pop back through Screen 1 to the Dashboard — the sitter tab is now
      // address-aware and shows BookSittersScreen itself once AddressBloc's
      // reload (triggered by AddAddress) reflects the new address, so no
      // explicit navigation there is needed from here.
      while (context.canPop()) {
        context.pop();
      }
    } else if (state is AddressSaveError) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.failedToSaveAddress)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: _onAddressBlocChange,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            AppStrings.locationDetailsTitle,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 18,
              fontColor: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppEdgeInsets.screenAll,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonFormField(
                    controller: _buildingController,
                    label: AppStrings.buildingFloorLabel,
                    hintText: AppStrings.buildingFloorHint,
                    isRequired: true,
                    asteriskColor: AppColors.requiredIndicator,
                    validator: _requiredValidator,
                  ),
                  AppSpacing.vertical20,
                  CommonFormField(
                    controller: _streetController,
                    label: AppStrings.streetLabel,
                    hintText: AppStrings.streetHint,
                    isRequired: true,
                    asteriskColor: AppColors.requiredIndicator,
                    validator: _requiredValidator,
                  ),
                  AppSpacing.vertical20,
                  CommonFormField(
                    controller: _areaController,
                    label: AppStrings.areaLabel,
                    maxLines: 2,
                    isRequired: true,
                    asteriskColor: AppColors.requiredIndicator,
                    validator: _requiredValidator,
                    trailing: LocationChangeThumbnail(
                      onTap: () => context.pop(),
                      mapSnapshot: widget.pickedLocation.mapSnapshot,
                    ),
                  ),
                  AppSpacing.vertical20,
                  CommonFormField(
                    controller: _saveAsController,
                    label: AppStrings.saveAddressAsLabel,
                    hintText: AppStrings.saveAddressAsHint,
                    isRequired: true,
                    asteriskColor: AppColors.requiredIndicator,
                    validator: _requiredValidator,
                  ),
                  AppSpacing.vertical32,
                  CommonButton(
                    text: AppStrings.saveAddressButton,
                    onPressed: _isSaving ? null : _onSave,
                    isLoading: _isSaving,
                    customColor: AppColors.secondaryCTA,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
