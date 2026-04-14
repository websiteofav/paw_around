import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/storage_service.dart';
import 'package:paw_around/ui/pets/widgets/pet_details_form_body.dart';
import 'package:paw_around/ui/pets/widgets/pet_image_picker_sheet.dart';

class AddPetDetailsScreen extends StatelessWidget {
  final PetModel pet;
  const AddPetDetailsScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) => _AddPetDetailsView(pet: pet);
}

class _AddPetDetailsView extends StatefulWidget {
  final PetModel pet;
  const _AddPetDetailsView({required this.pet});

  @override
  State<_AddPetDetailsView> createState() => _AddPetDetailsViewState();
}

class _AddPetDetailsViewState extends State<_AddPetDetailsView> {
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _colourController;
  late TextEditingController _aboutController;

  String? _selectedGender;
  String? _imagePath;
  bool _isImageLoading = false;
  bool _isSaving = false;
  List<String> _selectedPersonality = [];

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    _breedController = TextEditingController(text: p.breed);
    _weightController = TextEditingController(text: p.weight > 0 ? p.weight.toStringAsFixed(2) : '8.00');
    _heightController = TextEditingController(text: p.height > 0 ? p.height.toStringAsFixed(1) : '10.0');
    _colourController = TextEditingController(text: p.colour);
    _aboutController = TextEditingController(text: p.notes);
    _selectedGender = p.gender.isNotEmpty ? p.gender : AppStrings.male;
    _imagePath = p.imagePath;
    _selectedPersonality = List.from(p.personality);
  }

  @override
  void dispose() {
    for (final c in [_breedController, _weightController, _heightController, _colourController, _aboutController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      String? finalImagePath = _imagePath;
      if (_imagePath != null && _imagePath != widget.pet.imagePath && !_imagePath!.startsWith('http')) {
        finalImagePath = await sl<StorageService>().uploadPetImage(localPath: _imagePath!, petId: widget.pet.id);
        if (finalImagePath == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload pet image'), backgroundColor: AppColors.error),
            );
          }
          setState(() => _isSaving = false);
          return;
        }
      }
      final updatedPet = widget.pet.copyWith(
        breed: _breedController.text.trim(),
        gender: _selectedGender ?? '',
        weight: double.tryParse(_weightController.text.trim()) ?? widget.pet.weight,
        height: double.tryParse(_heightController.text.trim()) ?? widget.pet.height,
        colour: _colourController.text.trim(),
        notes: _aboutController.text.trim(),
        personality: _selectedPersonality,
        imagePath: finalImagePath ?? widget.pet.imagePath,
        updatedAt: DateTime.now(),
      );
      await sl<PetRepository>().updatePet(updatedPet);
      if (mounted) {
        HapticFeedback.mediumImpact();
        context.read<PetListBloc>().add(const LoadPetList());
        context.goNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PetDetailsFormBody(
                    breedController: _breedController,
                    colourController: _colourController,
                    aboutController: _aboutController,
                    weightValue: double.tryParse(_weightController.text) ?? 0,
                    heightValue: double.tryParse(_heightController.text) ?? 0,
                    selectedGender: _selectedGender,
                    imagePath: _imagePath,
                    isImageLoading: _isImageLoading,
                    isSaving: _isSaving,
                    selectedPersonality: _selectedPersonality,
                    onGenderChanged: (g) => setState(() => _selectedGender = g),
                    onPersonalityChanged: (tags) => setState(() => _selectedPersonality = tags),
                    onWeightChanged: (v) => setState(() => _weightController.text = v.toStringAsFixed(2)),
                    onHeightChanged: (v) => setState(() => _heightController.text = v.toStringAsFixed(1)),
                    onImageTap: () => _showImagePickerOptions(hasImage: _imagePath != null),
                    onSave: _isSaving ? null : _saveDetails,
                    onSkip: _isSaving ? null : () => context.goNamed(AppRoutes.home),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, size: 24, color: AppColors.grey1000),
          ),
          const SizedBox(width: 12),
          Text(AppStrings.addYourPet,
              style: AppTextStyles.boldStyle700(fontSize: 18, fontColor: AppColors.grey1000)),
        ],
      ),
    );
  }

  void _showImagePickerOptions({bool hasImage = false}) {
    PetImagePickerSheet.show(
      context: context,
      hasImage: hasImage,
      onCamera: () => _pickImage(ImageSource.camera),
      onGallery: () => _pickImage(ImageSource.gallery),
      onRemove: hasImage ? () => setState(() => _imagePath = null) : null,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isImageLoading = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (!mounted) return;
      setState(() {
        if (picked != null) _imagePath = picked.path;
        _isImageLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isImageLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
