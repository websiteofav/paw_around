import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

enum SetupItemType {
  vaccines,
  grooming,
  tickFlea,
}

class SetupItem {
  final SetupItemType type;
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const SetupItem({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class SetupReminderCard extends StatelessWidget {
  final String petName;
  final List<SetupItem> missingItems;
  final int totalItems;

  const SetupReminderCard({
    super.key,
    required this.petName,
    required this.missingItems,
    this.totalItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (missingItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedCount = totalItems - missingItems.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Icon in circular background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.completeHealthDetails.replaceAll('%s', petName),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${missingItems.length} ${missingItems.length == 1 ? AppStrings.itemRemaining : AppStrings.itemsRemaining}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress dots
                Row(
                  children: List.generate(totalItems, (index) {
                    final isCompleted = index < completedCount;
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.primary : AppColors.border,
                        shape: BoxShape.circle,
                        border: isCompleted ? null : Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                      ),
                      child: isCompleted ? const Icon(Icons.check, size: 8, color: AppColors.white) : null,
                    );
                  }),
                ),
              ],
            ),
          ),

          // Setup items list with padding
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: missingItems.asMap().entries.map((entry) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (entry.key * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _buildSetupItem(entry.value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupItem(SetupItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ScaleButton(
        onPressed: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getGradientStart(item.type).withValues(alpha: 0.06),
                _getGradientEnd(item.type).withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getIconColor(item.type).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getIconColor(item.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: _getIconColor(item.type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Label and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Time badge and arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      AppStrings.quickSetup,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: _getIconColor(item.type),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradientStart(SetupItemType type) {
    switch (type) {
      case SetupItemType.vaccines:
        return AppColors.urgentGradientStart;
      case SetupItemType.grooming:
        return AppColors.groomingGradientStart;
      case SetupItemType.tickFlea:
        return AppColors.cardBlueIcon;
    }
  }

  Color _getGradientEnd(SetupItemType type) {
    switch (type) {
      case SetupItemType.vaccines:
        return AppColors.urgentGradientEnd;
      case SetupItemType.grooming:
        return AppColors.groomingGradientEnd;
      case SetupItemType.tickFlea:
        return AppColors.cardBlueIcon;
    }
  }

  Color _getIconColor(SetupItemType type) {
    switch (type) {
      case SetupItemType.vaccines:
        return AppColors.urgentGradientStart;
      case SetupItemType.grooming:
        return AppColors.groomingGradientStart;
      case SetupItemType.tickFlea:
        return AppColors.cardBlueIcon;
    }
  }
}
