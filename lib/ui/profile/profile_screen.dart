import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paw_around/bloc/auth/auth_bloc.dart';
import 'package:paw_around/bloc/auth/auth_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/profile/widgets/profile_header.dart';
import 'package:paw_around/ui/profile/widgets/profile_pets_section.dart';
import 'package:paw_around/ui/widgets/animated_card.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/dashboard_app_bar.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}';
    });
  }

  Future<void> _onRefresh() async {
    context.read<PetListBloc>().add(const LoadPetList());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Custom App Bar
          DashboardAppBar(
            title: AppStrings.profileTab,
            actions: [
              DashboardAppBarAction(
                icon: Icons.settings_outlined,
                onTap: () {
                  _showComingSoon(context, AppStrings.settings);
                },
              ),
            ],
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // User Info Card
                    AnimatedCard(
                      index: 0,
                      child: ProfileHeader(
                        onEditTap: () {
                          context.pushNamed(AppRoutes.editProfile);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // My Pets Section
                    AnimatedCard(
                      index: 1,
                      child: _buildPetsSection(context),
                    ),

                    const SizedBox(height: 20),

                    // Account Section
                    AnimatedCard(
                      index: 2,
                      child: _buildAccountSection(context),
                    ),

                    const SizedBox(height: 32),

                    // Logout Button
                    AnimatedCard(
                      index: 3,
                      child: _buildLogoutButton(context),
                    ),

                    const SizedBox(height: 24),

                    // App Version Footer
                    _buildAppVersionFooter(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsSection(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, state) {
        if (state is PetListLoaded) {
          return ProfilePetsSection(pets: state.pets);
        }
        return const ProfilePetsSection(pets: const []);
      },
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Account settings
          _buildAccountItem(
            icon: Icons.settings_outlined,
            title: AppStrings.accountSettings,
            onTap: () {
              _showComingSoon(context, AppStrings.accountSettings);
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          // Notifications
          _buildAccountItem(
            icon: Icons.notifications_outlined,
            title: AppStrings.notifications,
            onTap: () {
              _showComingSoon(context, AppStrings.notifications);
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          // Privacy & Security
          _buildAccountItem(
            icon: Icons.shield_outlined,
            title: AppStrings.privacyAndSecurity,
            onTap: () {
              _showComingSoon(context, AppStrings.privacyAndSecurity);
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          // Help & support
          _buildAccountItem(
            icon: Icons.help_outline,
            title: AppStrings.helpAndSupport,
            onTap: () {
              _showComingSoon(context, AppStrings.helpAndSupport);
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return ScaleButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            // Leading icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CommonButton(
        text: AppStrings.logout,
        variant: ButtonVariant.danger,
        size: ButtonSize.medium,
        icon: Icons.logout,
        onPressed: () => _showLogoutDialog(context),
      ),
    );
  }

  Widget _buildAppVersionFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              AppStrings.appName,
              style: AppTextStyles.regularStyle400(
                  fontSize: 13, fontColor: AppColors.textSecondary.withValues(alpha: 0.7)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _appVersion,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.logOutConfirmTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.logOutConfirmMessage,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      AppStrings.cancel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<AuthBloc>().add(SignOut());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      AppStrings.logout,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
