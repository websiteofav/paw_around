import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/services/image_service.dart';

class PetPhotoSelection extends StatelessWidget {
  const PetPhotoSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetFormBloc, PetFormState>(
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
              child: _buildImageContent(state.imagePath),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageContent(String? imagePath) {
    if (imagePath == null) {
      return const Icon(
        Icons.camera_alt,
        size: 40,
        color: Color(0xFFFFD700),
      );
    }

    // Check if it's a network URL
    if (imagePath.startsWith('http')) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imagePath,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.camera_alt,
            size: 40,
            color: Color(0xFFFFD700),
          ),
        ),
      );
    }

    // Local file
    return ClipOval(
      child: Image.file(
        File(imagePath),
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
    );
  }

  void _selectImage(BuildContext context) {
    ImageService.pickPetImage().then((image) {
      if (image != null) {
        context.read<PetFormBloc>().add(SelectImage(image.path));
      }
    });
  }
}
