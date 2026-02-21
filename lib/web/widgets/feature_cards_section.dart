import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class FeatureCardsSection extends StatelessWidget {
  const FeatureCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final maxWidth = outerConstraints.maxWidth;
        final isMobile = maxWidth < 600;
        final verticalPadding =
            isMobile ? AppConstants.space60 : AppConstants.space40 * 2;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.iconBgLight.withValues(alpha: 0.2),
              ],
            ),
          ),
          child: Padding(
            padding: AppEdgeInsets.horizontalLarge.copyWith(
              top: verticalPadding,
              bottom: verticalPadding,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final constrainedWidth = constraints.maxWidth;
                    final headingFontSize = isMobile ? 32.0 : 40.0;
                    final cardWidth = _cardWidth(constrainedWidth);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.landingFeatureSectionTitle,
                          style: AppTextStyles.boldStyle700(
                            fontSize: headingFontSize,
                            fontColor: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.vertical12,
                        Text(
                          AppStrings.landingFeatureSectionSubtitle,
                          style: AppTextStyles.regularStyle400(
                            fontSize: 16,
                            fontColor: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.vertical48,
                        Wrap(
                          spacing: AppConstants.space24,
                          runSpacing: AppConstants.space24,
                          alignment: WrapAlignment.center,
                          children: [
                            _FeatureCard(
                              index: 0,
                              icon: Icons.event_available_outlined,
                              title: AppStrings
                                  .landingFeaturePetCareRemindersTitle,
                              description:
                                  AppStrings.landingFeaturePetCareRemindersBody,
                              width: cardWidth,
                              iconGradientColors: [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.primaryLight.withValues(alpha: 0.2),
                              ],
                            ),
                            _FeatureCard(
                              index: 1,
                              icon: Icons.qr_code_2_outlined,
                              title: AppStrings.landingFeatureLostFoundTitle,
                              description:
                                  AppStrings.landingFeatureLostFoundBody,
                              width: cardWidth,
                              iconGradientColors: [
                                AppColors.cardBlueIconBg.withValues(alpha: 0.5),
                                AppColors.cardBlueIcon.withValues(alpha: 0.2),
                              ],
                            ),
                            _FeatureCard(
                              index: 2,
                              icon: Icons.location_on_outlined,
                              title: AppStrings.landingFeatureNearbyVetsTitle,
                              description:
                                  AppStrings.landingFeatureNearbyVetsBody,
                              width: cardWidth,
                              iconGradientColors: [
                                AppColors.cardRedIconBg.withValues(alpha: 0.5),
                                AppColors.cardRedIcon.withValues(alpha: 0.2),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _cardWidth(double maxWidth) {
    const spacing = AppConstants.space24;

    if (maxWidth < 600) {
      return maxWidth;
    }

    if (maxWidth < 900) {
      const columns = 2;
      final totalSpacing = spacing;
      return (maxWidth - totalSpacing) / columns;
    }

    const columns = 3;
    final totalSpacing = spacing * (columns - 1);
    return (maxWidth - totalSpacing) / columns;
  }
}

class _FeatureCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final String description;
  final double width;
  final List<Color>? iconGradientColors;

  const _FeatureCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.description,
    required this.width,
    this.iconGradientColors,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + widget.index * 150),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: Semantics(
        label: '${widget.title}: ${widget.description}',
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -8.0 : 0.0)
              ..scale(_isHovered ? 1.02 : 1.0),
            child: SizedBox(
              width: widget.width,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.space28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppBorderRadius.lg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowOverlay.withValues(alpha: 0.08),
                      blurRadius: _isHovered ? 24 : 16,
                      spreadRadius: -2,
                      offset:
                          _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.iconGradientColors ??
                              [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.primaryLight.withValues(alpha: 0.2),
                              ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.space16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space20),
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBoldStyle600(
                        fontSize: 20,
                        fontColor: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.space12),
                    Text(
                      widget.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regularStyle400(
                        fontSize: 15,
                        fontColor: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
