import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_about_section.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_app_bar.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_contact_section.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_location_section.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_pet_selector.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_photo_section.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_result_listener.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_section_divider.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_submit_button.dart';
import 'package:paw_around/ui/community/widgets/create_post/create_post_submit_service.dart';
import 'package:paw_around/ui/community/widgets/create_post/last_seen_picker.dart';
import 'package:paw_around/ui/community/widgets/create_post/pet_type_selector.dart';

class CreatePostScreen extends StatefulWidget {
  final PostType? initialType;

  const CreatePostScreen({super.key, this.initialType});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  late PostType _postType;
  PetModel? _selectedPet;
  String? _localImagePath;
  double? _latitude;
  double? _longitude;
  DateTime _lastSeenDateTime = DateTime.now();
  bool _isJustNow = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _postType = widget.initialType ?? PostType.lost;
    context.read<PetListBloc>().add(const LoadPetList());
    final phone = sl<AuthRepository>().currentUser?.phoneNumber;
    if (phone != null) _phoneController.text = phone;
  }

  @override
  void dispose() {
    _breedController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onPetSelected(PetModel pet) {
    setState(() {
      _selectedPet = pet;
      _breedController.text = pet.breed;
      _colorController.text = pet.colour;
      _descriptionController.text = pet.personality.isNotEmpty ? pet.personality.join(', ') : pet.notes;
      _localImagePath = null;
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseSetLocation)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final post = await CreatePostSubmitService.buildPost(
      postType: _postType,
      selectedPet: _selectedPet,
      localImagePath: _localImagePath,
      breedController: _breedController,
      colorController: _colorController,
      descriptionController: _descriptionController,
      locationController: _locationController,
      phoneController: _phoneController,
      latitude: _latitude!,
      longitude: _longitude!,
      lastSeenAt: _isJustNow ? DateTime.now() : _lastSeenDateTime,
    );

    if (post == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.failedToUploadImage)),
        );
        setState(() => _isSubmitting = false);
      }
      return;
    }
    if (mounted) context.read<CommunityBloc>().add(CreatePost(post));
  }

  @override
  Widget build(BuildContext context) {
    return CreatePostResultListener(
      onSubmittingDone: () => setState(() => _isSubmitting = false),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const CreatePostAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PetTypeSelector(
                  postType: _postType,
                  onChanged: (type) => setState(() {
                    _postType = type;
                    if (type == PostType.found) _selectedPet = null;
                  }),
                ),
                const SizedBox(height: 8),
                const CreatePostSectionDivider(),
                const SizedBox(height: 32),
                if (_postType == PostType.lost) ...[
                  CreatePostPetSelector(
                    selectedPetId: _selectedPet?.id,
                    onSelect: _onPetSelected,
                  ),
                  const SizedBox(height: 24),
                ],
                CreatePostPhotoSection(
                  localImagePath: _localImagePath,
                  existingImageUrl: _selectedPet?.imagePath,
                  onImagePicked: (path) => setState(() => _localImagePath = path),
                ),
                const SizedBox(height: 24),
                CreatePostAboutSection(
                  petName: _selectedPet?.name,
                  breedController: _breedController,
                  colorController: _colorController,
                  descriptionController: _descriptionController,
                ),
                const SizedBox(height: 24),
                CreatePostLocationSection(
                  petName: _selectedPet?.name,
                  controller: _locationController,
                  onPlaceSelected: (address, latitude, longitude) {
                    setState(() {
                      _latitude = latitude;
                      _longitude = longitude;
                    });
                  },
                ),
                const SizedBox(height: 24),
                LastSeenPicker(
                  petName: _selectedPet?.name,
                  value: _lastSeenDateTime,
                  isJustNow: _isJustNow,
                  onJustNowChanged: (v) => setState(() => _isJustNow = v),
                  onChanged: (dt) => setState(() => _lastSeenDateTime = dt),
                ),
                const SizedBox(height: 24),
                CreatePostContactSection(controller: _phoneController),
                const SizedBox(height: 32),
                CreatePostSubmitButton(
                  postType: _postType,
                  isSubmitting: _isSubmitting,
                  onPressed: _submitPost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
