import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_pet_selector.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/create_moment_app_bar.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/create_moment_details_section.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/create_moment_location_section.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/create_moment_photo_section.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/moment_draft.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class CreateMomentScreen extends StatefulWidget {
  const CreateMomentScreen({super.key});

  @override
  State<CreateMomentScreen> createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends State<CreateMomentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _imagePath;
  PetModel? _selectedPet;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    context.read<PetListBloc>().add(const LoadPetList());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _onPreview() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseSelectImage),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseSelectPet),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final draft = MomentDraft(
      imagePath: _imagePath!,
      title: _titleController.text.trim(),
      caption: _captionController.text.trim(),
      pet: _selectedPet!,
      locationName: _locationController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
    );

    final posted =
        await context.pushNamed(AppRoutes.momentPreview, extra: draft);
    if (posted == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CreateMomentAppBar(hasPhoto: _imagePath != null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateMomentPhotoSection(
                imagePath: _imagePath,
                onImagePicked: (path) => setState(() => _imagePath = path),
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 24),
                CreateMomentDetailsSection(
                  petName: _selectedPet?.name,
                  titleController: _titleController,
                  captionController: _captionController,
                ),
                const SizedBox(height: 24),
                CreatePostPetSelector(
                  selectedPetId: _selectedPet?.id,
                  onSelect: (pet) => setState(() => _selectedPet = pet),
                ),
                const SizedBox(height: 24),
                CreateMomentLocationSection(
                  controller: _locationController,
                  onPlaceSelected: (address, lat, lng) => setState(() {
                    _latitude = lat;
                    _longitude = lng;
                  }),
                ),
                const SizedBox(height: 32),
                CommonButton(
                  text: AppStrings.preview,
                  onPressed: _onPreview,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
