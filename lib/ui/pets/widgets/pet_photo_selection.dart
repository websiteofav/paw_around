import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/services/image_service.dart';

class PetPhotoSelection extends StatelessWidget {
  const PetPhotoSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) {
        return Center(
          child: GestureDetector(
            onTap: () => _selectImage(context),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
              ),
              child: state is PetFormState && state.imagePath != null
                  ? ClipOval(
                      child: Image.file(
                        File(state.imagePath!),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Color(0xFFFFD700),
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Color(0xFFFFD700),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _selectImage(BuildContext context) {
    ImageService.pickPetImage().then((image) {
      if (image != null) {
        context.read<PetsBloc>().add(SelectPetImage(imagePath: image.path));
      }
    });
  }
}
