import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/pets/widgets/circular_photo_picker.dart';
import 'package:paw_around/ui/pets/widgets/pet_type_selector.dart';
import 'package:paw_around/ui/pets/widgets/birthdate_age_selector.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';

class AddPetScreen extends StatelessWidget {
  final PetModel? petToEdit;
  const AddPetScreen({super.key, this.petToEdit});

  @override
  Widget build(BuildContext context) {
    return _AddPetView(petToEdit: petToEdit);
  }
}

class _AddPetView extends StatefulWidget {
  final PetModel? petToEdit;
  const _AddPetView({this.petToEdit});

  @override
  State<_AddPetView> createState() => _AddPetViewState();
}

class _AddPetViewState extends State<_AddPetView> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.petToEdit?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: BlocListener<PetFormBloc, PetFormState>(
            listener: (context, state) {
              if (state.status == PetFormStatus.success) {
                HapticFeedback.mediumImpact();
                if (widget.petToEdit != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pet updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.read<PetListBloc>().add(const LoadPetList());
                  context.pushNamed(AppRoutes.home);
                } else {
                  context.read<PetListBloc>().add(const LoadPetList());
                  if (state.savedPet != null) {
                    context.pushNamed(AppRoutes.addPetDetails,
                        extra: state.savedPet);
                  }
                }
              } else if (state.status == PetFormStatus.error &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.error),
                );
              }
            },
            child: BlocBuilder<PetFormBloc, PetFormState>(
              builder: (context, state) => _buildBody(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PetFormState state) {
    if (_nameController.text != state.name) {
      _nameController.text = state.name;
    }
    final isSaving = state.status == PetFormStatus.saving;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          _buildAppBar(context, state),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const _StepIndicator(current: 0, total: 2),
                  const SizedBox(height: 36),

                  // Photo picker
                  Center(
                    child: CircularPhotoPicker(
                      imagePath: state.imagePath,
                      isLoading: state.isImageLoading,
                      onTap: () => _showImagePickerOptions(context,
                          hasImage: state.imagePath != null),
                    ),
                  ),
                  const SizedBox(height: 36),

                  CommonFormField(
                    label: AppStrings.petName,
                    hintText: AppStrings.petNameHint,
                    controller: _nameController,
                    isRequired: true,
                    enabled: !isSaving,
                    onChanged: (v) =>
                        context.read<PetFormBloc>().add(UpdateName(v)),
                    errorText: state.errors['name'],
                  ),
                  const SizedBox(height: 36),

                  // Pet Type
                  IgnorePointer(
                    ignoring: isSaving,
                    child: const PetTypeSelector(),
                  ),
                  const SizedBox(height: 36),

                  // Birth Date
                  const _FieldLabel(AppStrings.dateOfBirth, required: true),
                  const SizedBox(height: 8),
                  IgnorePointer(
                    ignoring: isSaving,
                    child: const BirthdateAgeSelector(),
                  ),

                  const SizedBox(height: 32),

                  // Save & Continue
                  CommonButton(
                    text: AppStrings.saveAndContinue,
                    onPressed: isSaving
                        ? null
                        : () => context
                            .read<PetFormBloc>()
                            .add(SubmitForm(petToEdit: widget.petToEdit)),
                    isLoading: isSaving,
                    textStyle: AppTextStyles.interBoldStyle700(
                      fontSize: 16,
                      fontColor: AppColors.grey1000,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, PetFormState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.canPop()
                ? context.pop()
                : context.pushNamed(AppRoutes.home),
            child: const Icon(Icons.arrow_back,
                size: 24, color: AppColors.grey1000),
          ),
          const SizedBox(width: 12),
          Text(
            widget.petToEdit != null
                ? AppStrings.editPetDetails
                : AppStrings.addYourPet,
            style: AppTextStyles.boldStyle700(
                fontSize: 18, fontColor: AppColors.grey1000),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, {bool hasImage = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2))),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary),
                  title: Text(AppStrings.takePhoto,
                      style: AppTextStyles.regularStyle400(
                          fontSize: 16, fontColor: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary),
                  title: Text(AppStrings.chooseFromGallery,
                      style: AppTextStyles.regularStyle400(
                          fontSize: 16, fontColor: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                if (hasImage) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    title: Text(AppStrings.removePhoto,
                        style: AppTextStyles.regularStyle400(
                            fontSize: 16, fontColor: AppColors.error)),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.read<PetFormBloc>().add(const SelectImage(null));
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final bloc = context.read<PetFormBloc>();
    final messenger = ScaffoldMessenger.of(context);
    bloc.add(const SetImageLoading(true));
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
          source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (!mounted) return;
      if (picked != null) {
        bloc.add(SelectImage(picked.path));
      } else {
        bloc.add(const SetImageLoading(false));
      }
    } catch (e) {
      if (!mounted) return;
      bloc.add(const SetImageLoading(false));
      messenger.showSnackBar(
        SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error),
      );
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey1000)),
        if (required)
          Text(' *',
              style: AppTextStyles.interRegularStyle400(
                  fontSize: 14, fontColor: AppColors.grey1000)),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 32 : 24,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
