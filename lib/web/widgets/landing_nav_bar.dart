import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class LandingNavBar extends StatefulWidget {
  final bool isMobile;
  final ValueChanged<int> onNavSelected;

  const LandingNavBar({
    super.key,
    required this.isMobile,
    required this.onNavSelected,
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
    widget.onNavSelected(index);
  }

  static const double _navBarLogoSize = 48;
  static const double _navBarMaxWidth = 1280;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.horizontalLarge.copyWith(
        top: AppConstants.space20,
        bottom: AppConstants.space20,
      ),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _navBarMaxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildLogo(context, _navBarLogoSize),
                  AppSpacing.horizontal8,
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.boldStyle700(
                      fontSize: 24,
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
                )
              else
                Semantics(
                  button: true,
                  label: 'Open navigation menu',
                  child: IconButton(
                    icon: const Icon(
                      Icons.menu,
                      size: 24,
                      color: AppColors.navigationText,
                    ),
                    tooltip: 'Open navigation menu',
                    onPressed: () {
                      _showMobileMenu(context);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, double size) {
    return Semantics(
      button: true,
      label: AppStrings.landingNavHome,
      child: InkWell(
        onTap: () => _onItemTapped(0),
        borderRadius: BorderRadius.circular(size / 2),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        focusColor: AppColors.primary.withValues(alpha: 0.08),
        child: ClipOval(
          child: Image.asset(
            AppIcons.appIcon,
            fit: BoxFit.contain,
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(AppConstants.space24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.topXl,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildLogo(context, 40),
                        AppSpacing.horizontal8,
                        Text(
                          AppStrings.appName,
                          style: AppTextStyles.boldStyle700(
                            fontSize: 20,
                            fontColor: AppColors.navigationText,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.navigationText,
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close menu',
                    ),
                  ],
                ),
                AppSpacing.vertical24,
                Expanded(
                  child: ListView.separated(
                    itemCount: 4,
                    separatorBuilder: (_, __) => AppSpacing.vertical8,
                    itemBuilder: (context, index) {
                      final labels = [
                        AppStrings.landingNavHome,
                        AppStrings.landingNavAbout,
                        AppStrings.landingNavFaq,
                        AppStrings.landingNavContact,
                      ];
                      return _MobileNavItem(
                        label: labels[index],
                        isActive: _selectedIndex == index,
                        onTap: () {
                          Navigator.of(context).pop();
                          _onItemTapped(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      child: Material(
        color: isActive ? AppColors.iconBgLight : Colors.transparent,
        borderRadius: AppBorderRadius.sm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.sm,
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space16,
              vertical: AppConstants.space16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: isActive
                        ? AppTextStyles.semiBoldStyle600(
                            fontSize: 16,
                            fontColor: AppColors.primary,
                          )
                        : AppTextStyles.mediumStyle500(
                            fontSize: 16,
                            fontColor: AppColors.textPrimary,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        label: label,
        selected: isActive,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: AppBorderRadius.xs,
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          focusColor: AppColors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space12,
              vertical: AppConstants.space16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: (isActive
                          ? AppTextStyles.semiBoldStyle600(
                              fontSize: 15,
                              fontColor: AppColors.primary,
                            )
                          : AppTextStyles.mediumStyle500(
                              fontSize: 15,
                              fontColor: AppColors.textSecondary,
                            ))
                      .copyWith(letterSpacing: 0.3),
                ),
                if (isActive) ...[
                  AppSpacing.vertical4,
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
