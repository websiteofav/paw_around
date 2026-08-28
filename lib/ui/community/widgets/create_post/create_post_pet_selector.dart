import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/community/widgets/create_post/pet_selector_row.dart';

/// Wraps [PetSelectorRow] with the [PetListBloc] state; renders nothing
/// while pets are loading or if the user has none yet.
class CreatePostPetSelector extends StatelessWidget {
  final String? selectedPetId;
  final ValueChanged<PetModel> onSelect;

  const CreatePostPetSelector({
    super.key,
    required this.selectedPetId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, state) {
        if (state is! PetListLoaded || state.pets.isEmpty) {
          return const SizedBox.shrink();
        }
        return PetSelectorRow(
          pets: state.pets,
          selectedPetId: selectedPetId,
          onSelect: onSelect,
          onAddPet: () => context.pushNamed(AppRoutes.addPet),
        );
      },
    );
  }
}
