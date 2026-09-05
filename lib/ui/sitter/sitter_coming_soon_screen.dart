import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';

/// Placeholder shown for the Sitter tab while Book Sitters is gated for
/// release — the real flow (SitterScreen/BookSittersScreen/
/// UpcomingSessionScreen) is fully built, just not ready to ship yet. See
/// Dashboard._buildSitterTab.
class SitterComingSoonScreen extends StatelessWidget {
  const SitterComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.petSittersTitle,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 18,
            fontColor: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: AppEdgeInsets.horizontalLarge,
          child: Column(
            children: [
              AppSpacing.vertical60,
              EmptyStateWidget(
                icon: Icons.pets_rounded,
                title: AppStrings.petSittersComingSoonTitle,
                subtitle: AppStrings.petSittersComingSoonSubtitle,
              ),
              // Clears Dashboard's floating bottom nav bar, which sits on
              // top of tab content.
              SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
