import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class VaccineReminderCard extends StatelessWidget {
  final bool setReminder;
  final ValueChanged<bool> onChanged;

  const VaccineReminderCard({
    super.key,
    required this.setReminder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neutral300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5065, 1.0],
                  colors: [Colors.white, Colors.transparent],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  AppIcons.dogAlarmIcon,
                  width: double.infinity,
                  height: 172,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.reminderNotification,
                      style: AppTextStyles.interBoldStyle700(
                          fontSize: 14, fontColor: AppColors.grey1000),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.getNotifiedBeforeNextDose,
                      style: AppTextStyles.interMediumStyle500(
                          fontSize: 12, fontColor: AppColors.grey1000),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1,
                child: Switch(
                  value: setReminder,
                  onChanged: onChanged,
                  activeThumbColor: AppColors.secondaryCTA,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                  inactiveThumbColor: AppColors.neutral700,
                  inactiveTrackColor: AppColors.neutral100,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
