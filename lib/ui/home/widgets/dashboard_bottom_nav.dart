import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Dashboard's floating bottom nav bar (Home/Explore/Paw Circle/Sitters),
/// extracted so screens pushed on top of Dashboard — like BookSittersScreen
/// — can show the same tab bar rather than losing it entirely.
class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: smoothDecoration(
        cornerRadius: 24,
        color: AppColors.grey1000,
        side: const BorderSide(width: 0.6, color: AppColors.grey600),
        shadows: [
          BoxShadow(
            color: AppColors.navBarShadow.withValues(alpha: 0.98),
            offset: const Offset(0, 3),
            blurRadius: 7,
          ),
          BoxShadow(
            color: AppColors.navBarShadow.withValues(alpha: 0.85),
            offset: const Offset(0, 12),
            blurRadius: 12,
          ),
          BoxShadow(
            color: AppColors.navBarShadow.withValues(alpha: 0.50),
            offset: const Offset(0, 27),
            blurRadius: 16,
          ),
          BoxShadow(
            color: AppColors.navBarShadow.withValues(alpha: 0.15),
            offset: const Offset(0, 48),
            blurRadius: 19,
          ),
          BoxShadow(
            color: AppColors.navBarShadow.withValues(alpha: 0.02),
            offset: const Offset(0, 76),
            blurRadius: 21,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: AppIcons.dashboardHomeIcon,
                label: AppStrings.homeTab,
                index: 0,
                isSelected: currentIndex == 0,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: AppIcons.dashboardExploreIcon,
                label: AppStrings.explore,
                index: 1,
                isSelected: currentIndex == 1,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: AppIcons.dashboardPawCircleIcon,
                label: AppStrings.pawCircle,
                index: 2,
                isSelected: currentIndex == 2,
                onTap: onTabSelected,
              ),
              _NavItem(
                // TODO: swap for the Sitter SVG once designs land
                materialIcon: Icons.volunteer_activism_outlined,
                label: AppStrings.sitter,
                index: 3,
                isSelected: currentIndex == 3,
                onTap: onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String? icon;
  final IconData? materialIcon;
  final String label;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _NavItem({
    this.icon,
    this.materialIcon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  }) : assert(icon != null || materialIcon != null, 'Provide either an SVG asset path or a materialIcon');

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.navigationInactive;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              SvgPicture.asset(
                icon!,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                height: 24,
                width: 24,
              )
            else
              Icon(materialIcon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isSelected
                  ? AppTextStyles.semiBoldStyle600(fontSize: 12, fontColor: AppColors.primary)
                  : AppTextStyles.mediumStyle500(fontSize: 12, fontColor: AppColors.navigationInactive),
            ),
          ],
        ),
      ),
    );
  }
}
