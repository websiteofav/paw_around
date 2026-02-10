import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class LandingNavBar extends StatefulWidget {
  final bool isMobile;

  const LandingNavBar({
    super.key,
    required this.isMobile,
  });

  @override
  State<LandingNavBar> createState() => _LandingNavBarState();
}

class _LandingNavBarState extends State<LandingNavBar> {
  /// Tracks which navigation tab is currently active.
  /// 0 = Home, 1 = About, 2 = FAQ, 3 = Contact.
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.horizontalLarge.copyWith(
        top: AppConstants.space16,
        bottom: AppConstants.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: AppColors.navigationBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipOval(
                child: Container(
                  width: AppConstants.pawContainerSize,
                  height: AppConstants.pawContainerSize,
                  color: AppColors.iconBgLight,
                  child: Image.asset(
                    AppIcons.appIcon,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              AppSpacing.horizontal12,
              Text(
                AppStrings.appName,
                style: AppTextStyles.boldStyle700(
                  fontSize: 20,
                  fontColor: AppColors.navigationText,
                ),
              ),
            ],
          ),
          if (!widget.isMobile)
            Row(
              spacing: AppConstants.space24,
              children: [
                _NavItem(
                  label: AppStrings.landingNavHome,
                  index: 0,
                  isActive: _selectedIndex == 0,
                  onTap: _onItemTapped,
                ),
                _NavItem(
                  label: AppStrings.landingNavAbout,
                  index: 1,
                  isActive: _selectedIndex == 1,
                  onTap: _onItemTapped,
                ),
                _NavItem(
                  label: AppStrings.landingNavFaq,
                  index: 2,
                  isActive: _selectedIndex == 2,
                  onTap: _onItemTapped,
                ),
                _NavItem(
                  label: AppStrings.landingNavContact,
                  index: 3,
                  isActive: _selectedIndex == 3,
                  onTap: _onItemTapped,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final int index;
  final bool isActive;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.label,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.only(left: AppConstants.space24),
        child: Column(
          children: [
            Text(
              label,
              style: (isActive
                      ? AppTextStyles.semiBoldStyle600(
                          fontSize: 14,
                          fontColor: AppColors.primary,
                        )
                      : AppTextStyles.mediumStyle500(
                          fontSize: 14,
                          fontColor: AppColors.textSecondary,
                        ))
                  .copyWith(letterSpacing: 0.3),
            ),
            if (isActive)
              Container(
                width: 24,
                height: 2,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
