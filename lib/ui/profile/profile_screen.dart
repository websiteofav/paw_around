import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/services/account_service.dart';
import 'package:paw_around/ui/profile/widgets/profile_account_section.dart';
import 'package:paw_around/ui/profile/widgets/profile_dialogs.dart';
import 'package:paw_around/ui/profile/widgets/profile_footer.dart';
import 'package:paw_around/ui/profile/widgets/profile_header.dart';
import 'package:paw_around/ui/profile/widgets/profile_pets_section.dart';
import 'package:paw_around/ui/widgets/animated_card.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/dashboard_app_bar.dart';
import 'package:paw_around/ui/widgets/loading_overlay.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _appVersion = '';
  bool _isDeletingAccount = false;
  final AccountService _accountService = AccountService();

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = 'v${packageInfo.version}');
    }
  }

  Future<void> _onRefresh() async {
    context.read<PetListBloc>().add(const LoadPetList());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    setState(() => _isDeletingAccount = true);

    try {
      await _accountService.deleteAccount();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
        if (e.code == 'requires-recent-login') {
          _handleReAuth();
        } else {
          _showError('Failed to delete account: ${e.message}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
        _showError('Failed to delete account: $e');
      }
    }
  }

  void _handleReAuth() {
    showReAuthDialog(
      context,
      hasGoogle: _accountService.hasGoogleProvider,
      hasPhone: _accountService.hasPhoneProvider,
      onGoogleTap: () async {
        try {
          await _accountService.reAuthWithGoogle();
          if (mounted) {
            await _handleDeleteAccount();
          }
        } catch (e) {
          if (mounted) {
            _showError('Re-authentication failed: $e');
          }
        }
      },
      onPhoneTap: () {
        context.read<AuthBloc>().add(SignOut());
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          body: Column(
            children: [
              DashboardAppBar(
                title: AppStrings.profileTab,
                actions: [
                  DashboardAppBarAction(
                    icon: Icons.settings_outlined,
                    onTap: () => _showComingSoon(AppStrings.settings),
                  ),
                ],
              ),
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
                        AnimatedCard(
                          index: 0,
                          child: ProfileHeader(
                            onEditTap: () => context.pushNamed(AppRoutes.editProfile),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedCard(
                          index: 1,
                          child: BlocBuilder<PetListBloc, PetListState>(
                            builder: (context, state) {
                              final List<PetModel> pets = state is PetListLoaded ? state.pets : [];
                              return ProfilePetsSection(pets: pets);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedCard(
                          index: 2,
                          child: ProfileAccountSection(
                            onAccountSettingsTap: () => _showComingSoon(AppStrings.accountSettings),
                            onNotificationsTap: () => _showComingSoon(AppStrings.notifications),
                            onPrivacyTap: () => _showComingSoon(AppStrings.privacyAndSecurity),
                            onHelpTap: () => _showComingSoon(AppStrings.helpAndSupport),
                            onDeleteAccountTap: () => showDeleteAccountDialog(
                              context,
                              onConfirm: _handleDeleteAccount,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        AnimatedCard(
                          index: 3,
                          child: _buildLogoutButton(),
                        ),
                        const SizedBox(height: 24),
                        ProfileFooter(appVersion: _appVersion),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isDeletingAccount) LoadingOverlay(message: AppStrings.deletingAccount),
      ],
    );
  }

  Widget _buildLogoutButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CommonButton(
          text: AppStrings.logout,
          variant: ButtonVariant.danger,
          size: ButtonSize.medium,
          icon: Icons.logout,
          onPressed: () => showLogoutDialog(context),
        ),
      );
}
