import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/bloc/places_bloc.dart';
import 'package:paw_around/bloc/bloc/places_event.dart';
import 'package:paw_around/bloc/bloc/places_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/places/service_type.dart';

/// Filter chips for map screen service type filtering
class MapFilterChips extends StatelessWidget {
  const MapFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        if (state is! PlacesLoaded) {
          return const SizedBox.shrink();
        }
        return _FilterChipsView(state: state);
      },
    );
  }
}

class _FilterChipsView extends StatelessWidget {
  final PlacesLoaded state;

  const _FilterChipsView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ServiceType.values.map((type) {
            final isSelected = state.selectedServiceType == type;
            final count = type == ServiceType.all
                ? state.places.length
                : state.places.where((p) => type.matchesTypes(p.types, placeName: p.name)).length;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                type: type,
                isSelected: isSelected,
                count: count,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final ServiceType type;
  final bool isSelected;
  final int count;

  const _FilterChip({
    required this.type,
    required this.isSelected,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<PlacesBloc>().add(FilterByServiceType(type));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? type.color : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? type.color : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: AppTextStyles.mediumStyle500(
                fontSize: 14,
                fontColor: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white.withValues(alpha: 0.2) : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 12,
                  fontColor: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
