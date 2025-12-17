import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/auth/auth_bloc.dart';
import 'package:paw_around/bloc/auth/auth_event.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/profile/widgets/profile_header.dart';
import 'package:paw_around/ui/profile/widgets/profile_menu_item.dart';
import 'package:paw_around/ui/profile/widgets/profile_menu_section.dart';
import 'package:paw_around/ui/profile/widgets/profile_pets_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          AppStrings.profileTab,
          style: TextStyle(
            color: AppColors.navigationText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navigationBackground,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header with user info and stats
            _buildProfileHeader(context),

            const SizedBox(height: 16),

            // My Pets Section
            _buildPetsSection(context),

            const SizedBox(height: 24),

            // Activity Section
            ProfileMenuSection(
              title: AppStrings.activity.toUpperCase(),
              children: [
                ProfileMenuItem(
                  icon: Icons.article_outlined,
                  title: AppStrings.myPosts,
                  onTap: () {
                    _showComingSoon(context, AppStrings.myPosts);
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.bookmark_outline,
                  title: AppStrings.savedPlaces,
                  onTap: () {
                    _showComingSoon(context, AppStrings.savedPlaces);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Settings Section
            ProfileMenuSection(
              title: AppStrings.settings.toUpperCase(),
              children: [
                ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  title: AppStrings.notificationSettings,
                  onTap: () {
                    _showComingSoon(context, AppStrings.notificationSettings);
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.edit_outlined,
                  title: AppStrings.editProfile,
                  onTap: () {
                    _showComingSoon(context, AppStrings.editProfile);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Account Section
            ProfileMenuSection(
              title: AppStrings.account.toUpperCase(),
              children: [
                ProfileMenuItem(
                  icon: Icons.star_outline,
                  title: AppStrings.upgradeToPremium,
                  iconColor: AppColors.secondary,
                  onTap: () {
                    _showComingSoon(context, AppStrings.upgradeToPremium);
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: AppStrings.helpAndSupport,
                  onTap: () {
                    _showComingSoon(context, AppStrings.helpAndSupport);
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: AppStrings.privacyPolicy,
                  onTap: () {
                    _showComingSoon(context, AppStrings.privacyPolicy);
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.logout,
                  title: AppStrings.logout,
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  showChevron: false,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Version Footer
            Center(
              child: Text(
                '${AppStrings.appVersion} 0.1.0',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, petState) {
        final petCount = petState is PetListLoaded ? petState.pets.length : 0;

        return BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, communityState) {
            final postCount = communityState is CommunityLoaded ? communityState.posts.length : 0;

            return Container(
              color: AppColors.background,
              child: ProfileHeader(
                petCount: petCount,
                postCount: postCount,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPetsSection(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, state) {
        if (state is PetListLoaded) {
          return ProfilePetsSection(pets: state.pets);
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
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
        title: const Text(AppStrings.logout),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(SignOut());
            },
            child: Text(
              AppStrings.logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
