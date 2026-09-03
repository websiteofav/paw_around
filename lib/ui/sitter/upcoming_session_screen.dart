import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/sitters/upcoming_session_model.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_bottom_bar.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_detail_row.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_pet_row.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_sitter_section.dart';
import 'package:paw_around/ui/widgets/info_banner.dart';

/// Shows the booking summary after "Book Sitters" is tapped. UI only — no
/// booking backend exists yet, [session] is mock data. See
/// UpcomingSessionModel's doc comment.
class UpcomingSessionScreen extends StatelessWidget {
  final UpcomingSessionModel session;

  const UpcomingSessionScreen({super.key, required this.session});

  String get _infoBannerText => session.isSitterAssigned
      ? '${session.sitterName} ${AppStrings.sitterWillArriveSuffix}'
      : AppStrings.sitterAssignmentNotice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.upcomingSessionTitle,
          style: AppTextStyles.semiBoldStyle600(
              fontSize: 18, fontColor: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_rounded,
                color: AppColors.secondaryCTA),
            onPressed: () => context.pushNamed(AppRoutes.helpSupport),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppEdgeInsets.horizontalMedium,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: smoothDecoration(
            cornerRadius: 36,
            color: AppColors.white,
            side: const BorderSide(color: AppColors.grey100),
            shadows: [
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.051),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.039),
                blurRadius: 13,
                offset: const Offset(0, 13),
              ),
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.031),
                blurRadius: 18,
                offset: const Offset(0, 30),
              ),
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.012),
                blurRadius: 21,
                offset: const Offset(0, 54),
              ),
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.0),
                blurRadius: 23,
                offset: const Offset(0, 84),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatusBanner(),
              Padding(
                padding: AppEdgeInsets.allMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UpcomingSessionPetRow(session: session),
                    AppSpacing.vertical20,
                    UpcomingSessionSitterSection(session: session),
                    _divider(),
                    UpcomingSessionDetailRow(
                      iconAsset: AppIcons.sitterClockIcon,
                      title:
                          '${session.sessionDayLabel} - ${session.sessionTimeLabel}',
                      subtitle: session.startsInLabel,
                    ),
                    _divider(),
                    UpcomingSessionDetailRow(
                      iconAsset: AppIcons.sitterHomePinIcon,
                      title: session.locationLabel,
                      subtitle: session.locationAddress,
                      trailingLabel: AppStrings.viewOnMap,
                      onTrailingTap: () {},
                    ),
                    _divider(),
                    UpcomingSessionDetailRow(
                      iconAsset: AppIcons.sitterCardIcon,
                      title:
                          '₹${session.totalAmount} ${AppStrings.totalAmountSuffix}',
                      trailingLabel: AppStrings.viewBreakdown,
                      onTrailingTap: () {},
                    ),
                    _divider(),
                    AppSpacing.vertical16,
                    InfoBanner(text: _infoBannerText),
                    AppSpacing.vertical24,
                    const UpcomingSessionBottomBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: smoothDecoration(
        borderRadius: AppSmoothRadius.topOnly(36),
        color: AppColors.confirmedGreen,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.white),
          AppSpacing.horizontal8,
          Text(
            '${AppStrings.confirmedForPrefix} ${session.confirmedDateLabel}',
            style: AppTextStyles.interSemiBoldStyle600(
                fontSize: 12, fontColor: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: AppColors.grey100, height: 1),
    );
  }
}
