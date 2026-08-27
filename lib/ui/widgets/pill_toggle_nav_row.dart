import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Nav row with a leading/trailing 40x40 slot and a centered 2-tab pill
/// toggle whose tabs are always equal width, regardless of label length.
/// Used by Paw Circle and My Posts to keep their headers identical.
class PillToggleNavRow extends StatelessWidget {
  final TabController tabController;
  final String firstTabLabel;
  final String secondTabLabel;
  final Widget leading;
  final Widget trailing;

  const PillToggleNavRow({
    super.key,
    required this.tabController,
    required this.firstTabLabel,
    required this.secondTabLabel,
    required this.leading,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          leading,
          Expanded(child: Center(child: _buildPillToggle())),
          trailing,
        ],
      ),
    );
  }

  Widget _buildPillToggle() {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: smoothDecoration(
          color: AppColors.grey1100,
          cornerRadius: 54,
        ),
        child: Row(
          children: [
            _pillTab(0, firstTabLabel),
            Container(width: 1, height: 20, color: AppColors.white),
            _pillTab(1, secondTabLabel),
          ],
        ),
      ),
    );
  }

  Widget _pillTab(int index, String label) {
    final isActive = tabController.index == index;
    return GestureDetector(
      onTap: () => tabController.animateTo(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.interBoldStyle700(
            fontSize: 16,
            fontColor: isActive ? AppColors.primary : AppColors.white,
          ),
        ),
      ),
    );
  }
}
