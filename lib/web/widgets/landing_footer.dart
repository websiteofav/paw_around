import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Section index for scroll callback: 0=home, 1=features, 2=qrSafety, 3=download, 4=footer
typedef FooterScrollCallback = void Function(int sectionIndex);

class LandingFooter extends StatefulWidget {
  final FooterScrollCallback? onScrollToSection;

  const LandingFooter({
    super.key,
    this.onScrollToSection,
  });

  @override
  State<LandingFooter> createState() => _LandingFooterState();
}

class _LandingFooterState extends State<LandingFooter> {
  final TextEditingController _emailController = TextEditingController();
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Container(
          color: AppColors.background,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.space24,
              vertical: isMobile ? 40 : 60,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isMobile
                        ? _buildMobileFooter(context)
                        : _buildDesktopFooter(context),
                    AppSpacing.vertical40,
                    Divider(color: AppColors.divider, height: 1),
                    AppSpacing.vertical24,
                    _buildBottomBar(context, isMobile),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    const columnSpacing = 56.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _CompanyColumn(onScrollToSection: widget.onScrollToSection),
        ),
        const SizedBox(width: columnSpacing),
        Expanded(
          child: _ProductColumn(onScrollToSection: widget.onScrollToSection),
        ),
        const SizedBox(width: columnSpacing),
        Expanded(
          child:
              _CompanyLinksColumn(onScrollToSection: widget.onScrollToSection),
        ),
        const SizedBox(width: columnSpacing),
        Expanded(
          flex: 2,
          child: _DownloadColumn(
            onScrollToSection: widget.onScrollToSection,
            newsletterController: _emailController,
            onNewsletterSubmit: _submitNewsletter,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CompanyColumn(
          onScrollToSection: widget.onScrollToSection,
          centerAlign: true,
        ),
        AppSpacing.vertical32,
        _ProductColumn(
          onScrollToSection: widget.onScrollToSection,
          centerAlign: true,
        ),
        AppSpacing.vertical32,
        _CompanyLinksColumn(
          onScrollToSection: widget.onScrollToSection,
          centerAlign: true,
        ),
        AppSpacing.vertical32,
        _DownloadColumn(
          onScrollToSection: widget.onScrollToSection,
          newsletterController: _emailController,
          onNewsletterSubmit: _submitNewsletter,
          centerAlign: true,
        ),
      ],
    );
  }

  void _submitNewsletter() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.landingFooterNewsletterInvalid),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _emailController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.landingFooterNewsletterSuccess),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _FooterLinkRow(
            onScrollToSection: widget.onScrollToSection,
            onPrivacyTap: () => _launchUrl(
              AppStrings.privacyPolicyUrl,
              AppStrings.landingFooterPrivacyPolicy,
            ),
            onTermsTap: () => _launchUrl(
              AppStrings.termsOfServiceUrl,
              AppStrings.landingFooterTermsOfService,
            ),
            centerAlign: true,
          ),
          AppSpacing.vertical12,
          Text(
            AppStrings.landingFooterCopyright,
            style: AppTextStyles.regularStyle400(
              fontSize: 13,
              fontColor: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppStrings.landingFooterCopyright,
          style: AppTextStyles.regularStyle400(
            fontSize: 13,
            fontColor: AppColors.textLight,
          ),
        ),
        _FooterLinkRow(
          onScrollToSection: widget.onScrollToSection,
          onPrivacyTap: () => _launchUrl(
            AppStrings.privacyPolicyUrl,
            AppStrings.landingFooterPrivacyPolicy,
          ),
          onTermsTap: () => _launchUrl(
            AppStrings.termsOfServiceUrl,
            AppStrings.landingFooterTermsOfService,
          ),
          centerAlign: false,
        ),
        const SizedBox(width: 80),
      ],
    );
  }

  Future<void> _launchUrl(String url, String fallbackLabel) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fallbackLabel – could not open link'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _CompanyColumn extends StatelessWidget {
  final FooterScrollCallback? onScrollToSection;
  final bool centerAlign;

  const _CompanyColumn({
    this.onScrollToSection,
    this.centerAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      crossAxisAlignment:
          centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                AppIcons.appIcon,
                fit: BoxFit.contain,
                width: 44,
                height: 44,
              ),
            ),
            AppSpacing.horizontal10,
            Text(
              AppStrings.appName,
              style: AppTextStyles.boldStyle700(
                fontSize: 20,
                fontColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        AppSpacing.vertical12,
        Text(
          AppStrings.landingFooterTagline,
          style: AppTextStyles.mediumStyle500(
            fontSize: 14,
            fontColor: AppColors.textSecondary,
          ),
          textAlign: centerAlign ? TextAlign.center : TextAlign.start,
        ),
        AppSpacing.vertical8,
        Text(
          AppStrings.landingFooterCompanyDescription,
          style: AppTextStyles.regularStyle400(
            fontSize: 13,
            fontColor: AppColors.textLight,
            height: 1.5,
          ),
          textAlign: centerAlign ? TextAlign.center : TextAlign.start,
        ),
      ],
    );
    return child;
  }
}

class _ProductColumn extends StatelessWidget {
  final FooterScrollCallback? onScrollToSection;
  final bool centerAlign;

  const _ProductColumn({
    this.onScrollToSection,
    this.centerAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    return _FooterSection(
      heading: AppStrings.landingFooterProduct,
      centerAlign: centerAlign,
      links: [
        (AppStrings.landingFooterFeatures, 1),
        (AppStrings.landingFooterHowItWorks, 2),
        //  (AppStrings.landingFooterPricing, null),
        //  (AppStrings.landingFooterFaq, null),
        //  (AppStrings.landingFooterHelpCenter, null),
      ],
      onScrollToSection: onScrollToSection,
      onExternalTap: (label) {
        String? path;
        if (label == AppStrings.landingFooterPricing) path = 'pricing';
        if (label == AppStrings.landingFooterFaq) path = 'faq';
        if (label == AppStrings.landingFooterHelpCenter) path = 'help';
        if (path != null) {
          launchUrl(
            Uri.parse('https://pawaround.com/$path'),
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );
  }
}

class _CompanyLinksColumn extends StatelessWidget {
  final FooterScrollCallback? onScrollToSection;
  final bool centerAlign;

  const _CompanyLinksColumn({
    this.onScrollToSection,
    this.centerAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    return _FooterSection(
      heading: AppStrings.landingFooterCompany,
      centerAlign: centerAlign,
      links: [
        (AppStrings.landingFooterAbout, 0),
        (AppStrings.landingFooterCareers, null),
        (AppStrings.landingFooterContact, null),
        (AppStrings.landingFooterBlog, null),
      ],
      onScrollToSection: onScrollToSection,
      onExternalTap: (label) {
        if (label == AppStrings.landingFooterContact) {
          launchUrl(
            Uri.parse('mailto:${AppStrings.landingFooterSupportEmail}'),
            mode: LaunchMode.externalApplication,
          );
        } else if (label == AppStrings.landingFooterCareers ||
            label == AppStrings.landingFooterBlog) {
          launchUrl(
            Uri.parse('https://pawaround.com'),
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );
  }
}

class _FooterSection extends StatelessWidget {
  final String heading;
  final List<(String label, int?)> links;
  final bool centerAlign;
  final FooterScrollCallback? onScrollToSection;
  final void Function(String label)? onExternalTap;

  const _FooterSection({
    required this.heading,
    required this.links,
    this.centerAlign = false,
    this.onScrollToSection,
    this.onExternalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          heading,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 15,
            fontColor: AppColors.textPrimary,
          ),
        ),
        AppSpacing.vertical16,
        ...links.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.space12),
            child: _FooterLink(
              label: e.$1,
              onTap: () {
                final sectionIndex = e.$2;
                if (sectionIndex != null && onScrollToSection != null) {
                  onScrollToSection!(sectionIndex);
                } else {
                  onExternalTap?.call(e.$1);
                }
              },
              centerAlign: centerAlign,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool centerAlign;

  const _FooterLink({
    required this.label,
    required this.onTap,
    this.centerAlign = false,
  });

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppBorderRadius.sm,
        child: Text(
          widget.label,
          style: AppTextStyles.mediumStyle500(
            fontSize: 14,
            fontColor: _hovered ? AppColors.primary : AppColors.textSecondary,
            decoration: _hovered ? TextDecoration.underline : null,
          ),
          textAlign: widget.centerAlign ? TextAlign.center : TextAlign.start,
        ),
      ),
    );
  }
}

class _FooterLinkRow extends StatelessWidget {
  final FooterScrollCallback? onScrollToSection;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onTermsTap;
  final bool centerAlign;

  const _FooterLinkRow({
    this.onScrollToSection,
    this.onPrivacyTap,
    this.onTermsTap,
    this.centerAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          centerAlign ? MainAxisAlignment.center : MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FooterLink(
          label: AppStrings.landingFooterAbout,
          onTap: () => onScrollToSection?.call(0),
          centerAlign: false,
        ),
        AppSpacing.horizontal16,
        _FooterLink(
          label: AppStrings.landingFooterPrivacyPolicy,
          onTap: onPrivacyTap ?? () {},
          centerAlign: false,
        ),
        AppSpacing.horizontal16,
        _FooterLink(
          label: AppStrings.landingFooterTermsOfService,
          onTap: onTermsTap ?? () {},
          centerAlign: false,
        ),
      ],
    );
  }
}

class _DownloadColumn extends StatelessWidget {
  final FooterScrollCallback? onScrollToSection;
  final TextEditingController newsletterController;
  final VoidCallback onNewsletterSubmit;
  final bool centerAlign;

  const _DownloadColumn({
    this.onScrollToSection,
    required this.newsletterController,
    required this.onNewsletterSubmit,
    this.centerAlign = false,
  });

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.pawaround.app';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.landingFooterStayUpdated,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 15,
            fontColor: AppColors.textPrimary,
          ),
        ),
        AppSpacing.vertical16,
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: newsletterController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.landingFooterNewsletterHint,
                  hintStyle: AppTextStyles.regularStyle400(
                    fontSize: 14,
                    fontColor: AppColors.textLight,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.sm,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.space12,
                    vertical: AppConstants.space12,
                  ),
                ),
              ),
            ),
            AppSpacing.horizontal8,
            CommonButton(
              text: AppStrings.landingFooterSubscribe,
              onPressed: onNewsletterSubmit,
              size: ButtonSize.small,
              variant: ButtonVariant.primary,
              isFullWidth: false,
            ),
          ],
        ),
        AppSpacing.vertical24,
        Text(
          AppStrings.landingFooterDownload,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 15,
            fontColor: AppColors.textPrimary,
          ),
        ),
        AppSpacing.vertical16,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => launchUrl(
                Uri.parse(_playStoreUrl),
                mode: LaunchMode.externalApplication,
              ),
              borderRadius: AppBorderRadius.sm,
              child: Image.asset(
                AppIcons.playStoreIcon,
                height: 40,
                fit: BoxFit.fitHeight,
              ),
            ),
            AppSpacing.horizontal12,
            Opacity(
              opacity: 0.7,
              child: Image.asset(
                AppIcons.appStoreIcon,
                height: 40,
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
        AppSpacing.vertical20,
        //  _SocialIcons(),
      ],
    );
  }
}

class _SocialIcons extends StatelessWidget {
  static final _socials = [
    (
      FaIcon(FontAwesomeIcons.facebookF, size: 18, color: AppColors.white),
      'https://facebook.com/pawaround',
      AppStrings.landingFooterFacebook,
    ),
    (
      FaIcon(FontAwesomeIcons.instagram, size: 18, color: AppColors.white),
      'https://instagram.com/pawaround',
      AppStrings.landingFooterInstagram,
    ),
    (
      FaIcon(FontAwesomeIcons.xTwitter, size: 18, color: AppColors.white),
      'https://twitter.com/pawaround',
      AppStrings.landingFooterTwitter,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in _socials) ...[
          _SocialIcon(
            icon: e.$1,
            url: e.$2,
            tooltip: e.$3,
          ),
          if (e != _socials.last) AppSpacing.horizontal12,
        ],
      ],
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final Widget icon;
  final String url;
  final String tooltip;

  const _SocialIcon({
    required this.icon,
    required this.url,
    required this.tooltip,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => launchUrl(
            Uri.parse(widget.url),
            mode: LaunchMode.externalApplication,
          ),
          child: AnimatedScale(
            scale: _hovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: AppBorderRadius.full,
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color:
                              AppColors.shadowOverlay.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(child: widget.icon),
            ),
          ),
        ),
      ),
    );
  }
}
