import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Hero section for public pet profile: image, name, status, urgency, action buttons.
class PublicPetHeroSection extends StatefulWidget {
  final PetModel pet;
  final bool isWideLayout;
  final String? ownerPhone;
  final String? ownerWhatsApp;
  final DateTime? lastSeenAt;
  final String? lastSeenLocation;
  final String? distinctiveMarks;

  const PublicPetHeroSection({
    super.key,
    required this.pet,
    this.isWideLayout = true,
    this.ownerPhone,
    this.ownerWhatsApp,
    this.lastSeenAt,
    this.lastSeenLocation,
    this.distinctiveMarks,
  });

  @override
  State<PublicPetHeroSection> createState() => _PublicPetHeroSectionState();
}

class _PublicPetHeroSectionState extends State<PublicPetHeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _callOwner() async {
    final phone = widget.ownerPhone?.trim().replaceAll(' ', '');
    if (phone == null || phone.isEmpty) {
      _showNoContactSnackBar();
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _messageOwner() {
    final phone = widget.ownerPhone?.trim().replaceAll(' ', '');
    final whatsapp = widget.ownerWhatsApp?.trim().replaceAll(' ', '');
    if ((phone == null || phone.isEmpty) &&
        (whatsapp == null || whatsapp.isEmpty)) {
      _showNoContactSnackBar();
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              Text(
                AppStrings.publicPetHeroMessageChoiceTitle,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 18,
                  fontColor: AppColors.textPrimary,
                ),
              ),
              AppSpacing.vertical16,
              if (phone != null && phone.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.message_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    AppStrings.publicPetHeroSendSms,
                    style: AppTextStyles.mediumStyle500(
                      fontSize: 16,
                      fontColor: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final body =
                        Uri.encodeComponent('Hi, regarding ${widget.pet.name}');
                    final uri = Uri.parse('sms:$phone?body=$body');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              if (whatsapp != null && whatsapp.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.chat_outlined,
                    color: AppColors.success,
                  ),
                  title: Text(
                    AppStrings.publicPetHeroWhatsApp,
                    style: AppTextStyles.mediumStyle500(
                      fontSize: 16,
                      fontColor: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final text =
                        Uri.encodeComponent('Hi, regarding ${widget.pet.name}');
                    final uri = Uri.parse('https://wa.me/$whatsapp?text=$text');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareLocation() async {
    final phone = widget.ownerPhone?.trim().replaceAll(' ', '');
    if (phone == null || phone.isEmpty) {
      _showNoContactSnackBar();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.xl,
        ),
        title: Text(
          AppStrings.publicPetHeroShareLocationConfirmTitle,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 20,
            fontColor: AppColors.textPrimary,
          ),
        ),
        content: Text(
          AppStrings.publicPetHeroShareLocationConfirmContent,
          style: AppTextStyles.regularStyle400(
            fontSize: 14,
            fontColor: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.mediumStyle500(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text(
              AppStrings.publicPetHeroShareLocationConfirmButton,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 14,
                fontColor: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final mapsLink =
          'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
      final body = Uri.encodeComponent(
          'I found ${widget.pet.name}! I\'m here: $mapsLink');
      final uri = Uri.parse('sms:$phone?body=$body');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.publicPetHeroLocationShared,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.publicPetHeroLocationError,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.white,
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openPlayStore() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.pawaround.app';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showNoContactSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.publicPetHeroNoContactAvailable,
          style: AppTextStyles.regularStyle400(
            fontSize: 14,
            fontColor: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = widget.isWideLayout;
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    final imageSize = isDesktop ? 360.0 : 280.0;
    final nameSize = isDesktop ? 36.0 : 28.0;
    final padding = isDesktop ? 32.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.lg,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(imageSize),
                AppSpacing.horizontal24,
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _buildDetails(nameSize),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(imageSize),
                AppSpacing.vertical24,
                _buildDetails(nameSize),
              ],
            ),
    );
  }

  Widget _buildImage(double size) {
    return Container(
      width: widget.isWideLayout ? size : null,
      height: size,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.lg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.lg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.pet.imagePath != null &&
                widget.pet.imagePath!.startsWith('http'))
              Image.network(
                widget.pet.imagePath!,
                fit: BoxFit.cover,
                width: widget.isWideLayout ? size : null,
                height: size,
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                      color: AppColors.primary,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            else
              _placeholder(),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.iconBgLight,
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 64,
            color: AppColors.textLight,
          ),
          AppSpacing.vertical8,
          Text(
            AppStrings.publicPetHeroNoPhotoAvailable,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(double nameFontSize) {
    final breedDisplay = widget.pet.breed.trim().isEmpty
        ? AppStrings.valueNotSet
        : widget.pet.breed;
    final ageDisplay =
        (widget.pet.ageInMonths == 0 && widget.pet.ageInYears == 0)
            ? AppStrings.valueNotSet
            : widget.pet.ageString;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.publicPetHeroPetProfile,
          style: AppTextStyles.regularStyle400(
            fontSize: 12,
            fontColor: AppColors.textSecondary,
          ),
        ),
        AppSpacing.vertical4,
        Text(
          widget.pet.name,
          style: AppTextStyles.boldStyle700(
            fontSize: nameFontSize,
            fontColor: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        AppSpacing.vertical8,
        Text(
          breedDisplay,
          style: AppTextStyles.regularStyle400(
            fontSize: 16,
            fontColor: AppColors.textSecondary,
          ),
        ),
        Text(
          ageDisplay,
          style: AppTextStyles.regularStyle400(
            fontSize: 16,
            fontColor: AppColors.textSecondary,
          ),
        ),
        if (widget.distinctiveMarks != null &&
            widget.distinctiveMarks!.isNotEmpty) ...[
          AppSpacing.vertical8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.publicPetHeroLookFor
                      .replaceFirst('%s', widget.distinctiveMarks!),
                  style: AppTextStyles.regularStyle400(
                    fontSize: 14,
                    fontColor: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
        AppSpacing.vertical16,
        _StatusBadge(
          isLost: widget.pet.isLost,
          lastSeenAt: widget.lastSeenAt,
          pulseController: _pulseController,
        ),
        if (widget.pet.isLost &&
            widget.lastSeenAt != null &&
            _urgencySubtext(widget.lastSeenAt!) != null) ...[
          AppSpacing.vertical8,
          _UrgencyRow(text: _urgencySubtext(widget.lastSeenAt!)!),
        ],
        if (widget.pet.isLost &&
            widget.lastSeenLocation != null &&
            widget.lastSeenLocation!.isNotEmpty) ...[
          AppSpacing.vertical4,
          _LastSeenLocationRow(location: widget.lastSeenLocation!),
        ],
        AppSpacing.vertical24,
        PublicPetHeroActions(
          isWideLayout: widget.isWideLayout,
          isLost: widget.pet.isLost,
          onCall: _callOwner,
          onMessage: _messageOwner,
          onShareLocation: _shareLocation,
          onDownloadApp: _openPlayStore,
        ),
      ],
    );
  }

  String? _urgencySubtext(DateTime lastSeenAt) {
    final diff = DateTime.now().difference(lastSeenAt);
    final hours = diff.inHours;
    final days = diff.inDays;
    if (hours < 6) return AppStrings.publicPetHeroMissingRecently;
    if (hours < 24) {
      return AppStrings.publicPetHeroMissingHours.replaceFirst('%s', '$hours');
    }
    return AppStrings.publicPetHeroMissingDays.replaceFirst('%s', '$days');
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isLost;
  final DateTime? lastSeenAt;
  final AnimationController pulseController;

  const _StatusBadge({
    required this.isLost,
    this.lastSeenAt,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = isLost &&
        lastSeenAt != null &&
        DateTime.now().difference(lastSeenAt!).inHours >= 24;
    final prefix = isUrgent ? AppStrings.publicPetHeroUrgentPrefix : '';
    final text = isLost
        ? '$prefix${AppStrings.publicPetStatusMissing}'
        : AppStrings.publicPetStatusSafeAtHome;
    final color = isLost ? AppColors.error : AppColors.success;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = isLost ? 0.95 + (pulseController.value * 0.1) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppBorderRadius.sm,
              boxShadow: isLost
                  ? [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLost ? Icons.warning_amber_rounded : Icons.check_circle,
                  size: 20,
                  color: AppColors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: AppTextStyles.semiBoldStyle600(
                    fontSize: 14,
                    fontColor: AppColors.white,
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

class _UrgencyRow extends StatelessWidget {
  final String text;

  const _UrgencyRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.mediumStyle500(
            fontSize: 14,
            fontColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LastSeenLocationRow extends StatelessWidget {
  final String location;

  const _LastSeenLocationRow({required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppStrings.publicPetHeroLastSeenLocation
                .replaceFirst('%s', location),
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class PublicPetHeroActions extends StatelessWidget {
  final bool isWideLayout;
  final bool isLost;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onShareLocation;
  final VoidCallback onDownloadApp;

  const PublicPetHeroActions({
    super.key,
    required this.isWideLayout,
    required this.isLost,
    required this.onCall,
    required this.onMessage,
    required this.onShareLocation,
    required this.onDownloadApp,
  });

  @override
  Widget build(BuildContext context) {
    if (isWideLayout) {
      return Row(
        children: [
          if (isLost) ...[
            Expanded(
              child: CommonButton(
                text: AppStrings.publicPetHeroIFoundYourPet,
                icon: Icons.location_on_outlined,
                onPressed: onShareLocation,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                isFullWidth: true,
              ),
            ),
            AppSpacing.horizontal16,
            Expanded(
              child: CommonButton(
                text: AppStrings.callOwner,
                icon: Icons.phone,
                onPressed: onCall,
                variant: ButtonVariant.primary,
                customColor: AppColors.cardBlueIcon,
                size: ButtonSize.large,
                isFullWidth: true,
              ),
            ),
            AppSpacing.horizontal16,
            Expanded(
              child: CommonButton(
                text: AppStrings.messageOwner,
                icon: Icons.message_outlined,
                onPressed: onMessage,
                variant: ButtonVariant.outline,
                size: ButtonSize.large,
                isFullWidth: true,
              ),
            ),
          ] else ...[
            Expanded(
              child: CommonButton(
                text: AppStrings.callOwner,
                icon: Icons.phone,
                onPressed: onCall,
                variant: ButtonVariant.primary,
                customColor: AppColors.cardBlueIcon,
                size: ButtonSize.large,
                isFullWidth: true,
              ),
            ),
            AppSpacing.horizontal16,
            Expanded(
              child: CommonButton(
                text: AppStrings.messageOwner,
                icon: Icons.message_outlined,
                onPressed: onMessage,
                variant: ButtonVariant.outline,
                size: ButtonSize.large,
                isFullWidth: true,
              ),
            ),
          ],
        ],
      );
    }
    if (isLost) {
      return Column(
        children: [
          CommonButton(
            text: AppStrings.publicPetHeroIFoundYourPet,
            icon: Icons.location_on_outlined,
            onPressed: onShareLocation,
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
            isFullWidth: true,
          ),
          AppSpacing.vertical16,
          CommonButton(
            text: AppStrings.callOwner,
            icon: Icons.phone,
            onPressed: onCall,
            variant: ButtonVariant.primary,
            customColor: AppColors.cardBlueIcon,
            size: ButtonSize.large,
            isFullWidth: true,
          ),
          AppSpacing.vertical16,
          CommonButton(
            text: AppStrings.messageOwner,
            icon: Icons.message_outlined,
            onPressed: onMessage,
            variant: ButtonVariant.outline,
            size: ButtonSize.large,
            isFullWidth: true,
          ),
        ],
      );
    }
    return Column(
      children: [
        CommonButton(
          text: AppStrings.callOwner,
          icon: Icons.phone,
          onPressed: onCall,
          variant: ButtonVariant.primary,
          customColor: AppColors.cardBlueIcon,
          size: ButtonSize.large,
          isFullWidth: true,
        ),
        AppSpacing.vertical16,
        CommonButton(
          text: AppStrings.messageOwner,
          icon: Icons.message_outlined,
          onPressed: onMessage,
          variant: ButtonVariant.outline,
          size: ButtonSize.large,
          isFullWidth: true,
        ),
      ],
    );
  }
}
