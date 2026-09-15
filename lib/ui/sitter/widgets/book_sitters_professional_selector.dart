import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/professional_list/professional_list_bloc.dart';
import 'package:paw_around/bloc/sitters/professional_list/professional_list_event.dart';
import 'package:paw_around/bloc/sitters/professional_list/professional_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/sitters/professional_model.dart';
import 'package:paw_around/repositories/professional_repository.dart';

/// "Select Professional" row on the Book Sitters screen — fetches the
/// available sitters from Firestore.
class BookSittersProfessionalSelector extends StatefulWidget {
  final ProfessionalModel? selected;
  final ValueChanged<ProfessionalModel> onSelect;

  const BookSittersProfessionalSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<BookSittersProfessionalSelector> createState() =>
      _BookSittersProfessionalSelectorState();
}

class _BookSittersProfessionalSelectorState
    extends State<BookSittersProfessionalSelector> {
  late final ProfessionalListBloc _bloc = ProfessionalListBloc(
    professionalRepository: sl<ProfessionalRepository>(),
  )..add(const LoadProfessionals());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectProfessional,
            style: AppTextStyles.interRegularStyle400(
              fontSize: 14,
              fontColor: AppColors.grey1000,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<ProfessionalListBloc, ProfessionalListState>(
            builder: (context, state) => _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ProfessionalListState state) {
    if (state is ProfessionalListLoaded) {
      if (state.professionals.isEmpty) {
        return Text(
          AppStrings.noProfessionalsAvailable,
          style: AppTextStyles.interRegularStyle400(
              fontSize: 14, fontColor: AppColors.grey600),
        );
      }
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: state.professionals.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final professional = state.professionals[index];
            return _ProfessionalCard(
              professional: professional,
              isSelected: professional.id == widget.selected?.id,
              onTap: () => widget.onSelect(professional),
            );
          },
        ),
      );
    }
    if (state is ProfessionalListError) {
      return Text(
        AppStrings.failedToLoadProfessionals,
        style: AppTextStyles.interRegularStyle400(
            fontSize: 14, fontColor: AppColors.error),
      );
    }
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final ProfessionalModel professional;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfessionalCard({
    required this.professional,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = professional.isAvailable;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        height: 180,
        decoration: smoothDecoration(
            side: BorderSide(
                color: isSelected ? AppColors.secondaryCTA : AppColors.grey100),
            borderRadius: AppSmoothRadius.custom(24)),
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 72,
              color:
                  isAvailable ? AppColors.secondaryCTA : AppColors.textDisabled,
            ),
            const SizedBox(height: 6),
            Text(
              professional.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.interBoldStyle700(
                fontSize: 16,
                fontColor: AppColors.grey1000,
              ),
            ),
            if (!isAvailable) ...[
              const SizedBox(height: 6),
              Text(
                AppStrings.unavailable,
                style: AppTextStyles.interMediumStyle500(
                  fontSize: 14,
                  fontColor: AppColors.grey1000,
                ).copyWith(decoration: TextDecoration.underline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
