import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

/// Action item for the dashboard app bar
class DashboardAppBarAction {
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool isActive;

  const DashboardAppBarAction({
    required this.icon,
    this.activeIcon,
    required this.onTap,
    this.badgeCount,
    this.isActive = false,
  });
}

/// Unified app bar for all dashboard tabs
class DashboardAppBar extends StatelessWidget {
  /// Custom widget for the left side (avatar, logo, etc.)
  final Widget? leftWidget;

  /// URL for avatar image (used if leftWidget is null)
  final String? avatarImageUrl;

  /// Whether to show the default paw logo if no leftWidget/avatarImageUrl
  final bool showDefaultLogo;

  /// Main title text
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// List of action buttons on the right
  final List<DashboardAppBarAction>? actions;

  /// Whether to show the notification bell
  final bool showNotificationBell;

  /// Notification count for badge
  final int? notificationCount;

  /// Callback when notification bell is tapped
  final VoidCallback? onNotificationTap;

  const DashboardAppBar({
    super.key,
    this.leftWidget,
    this.avatarImageUrl,
    this.showDefaultLogo = true,
    required this.title,
    this.subtitle,
    this.actions,
    this.showNotificationBell = false,
    this.notificationCount,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left: Avatar or Logo
              _buildLeftWidget(),

              const SizedBox(width: 12),

              // Center-left: Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              // Right: Actions
              ..._buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftWidget() {
    if (leftWidget != null) {
      return leftWidget!;
    }

    // Build avatar with image or default logo
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.groomingGradientStart,
            AppColors.groomingGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.groomingGradientStart.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: avatarImageUrl != null && avatarImageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                avatarImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPawIcon(),
              ),
            )
          : _buildPawIcon(),
    );
  }

  Widget _buildPawIcon() {
    return const Center(
      child: Text(
        '🐾',
        style: TextStyle(fontSize: 22),
      ),
    );
  }

  List<Widget> _buildActions() {
    final List<Widget> actionWidgets = [];

    // Add custom actions
    if (actions != null) {
      for (final action in actions!) {
        actionWidgets.add(const SizedBox(width: 8));
        actionWidgets.add(_buildActionButton(action));
      }
    }

    // Add notification bell if enabled
    if (showNotificationBell) {
      actionWidgets.add(const SizedBox(width: 8));
      actionWidgets.add(_buildNotificationBell());
    }

    return actionWidgets;
  }

  Widget _buildActionButton(DashboardAppBarAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: action.isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.progressBarBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              action.isActive ? (action.activeIcon ?? action.icon) : action.icon,
              color: action.isActive ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            if (action.badgeCount != null && action.badgeCount! > 0)
              Positioned(
                top: 6,
                right: 6,
                child: _buildBadge(action.badgeCount!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: onNotificationTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.progressBarBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            if (notificationCount != null && notificationCount! > 0)
              Positioned(
                top: 6,
                right: 6,
                child: _buildBadge(notificationCount!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

