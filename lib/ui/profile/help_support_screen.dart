import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/utils/url_utils.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<_FaqItem> _faqItems = [
    _FaqItem(
      question: AppStrings.faqAddPetQuestion,
      answer: AppStrings.faqAddPetAnswer,
    ),
    _FaqItem(
      question: AppStrings.faqVaccineRemindersQuestion,
      answer: AppStrings.faqVaccineRemindersAnswer,
    ),
    _FaqItem(
      question: AppStrings.faqLostFoundQuestion,
      answer: AppStrings.faqLostFoundAnswer,
    ),
    _FaqItem(
      question: AppStrings.faqFindVetsQuestion,
      answer: AppStrings.faqFindVetsAnswer,
    ),
    _FaqItem(
      question: AppStrings.faqDeleteAccountQuestion,
      answer: AppStrings.faqDeleteAccountAnswer,
    ),
    _FaqItem(
      question: AppStrings.faqContactSupportQuestion,
      answer: AppStrings.faqContactSupportAnswer,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.helpAndSupport,
          style: AppTextStyles.semiBoldStyle600(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFaqSection(),
            const SizedBox(height: 24),
            _buildContactSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.frequentlyAskedQuestions,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 16,
              fontColor: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: _faqItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == _faqItems.length - 1;
                return _buildFaqTile(item, showDivider: !isLast);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqTile(_FaqItem item, {required bool showDivider}) {
    return Column(
      children: [
        ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            item.question,
            style: AppTextStyles.mediumStyle500(
              fontSize: 15,
              fontColor: AppColors.textPrimary,
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          children: [
            Text(
              item.answer,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.stillNeedHelp,
            style: AppTextStyles.semiBoldStyle600(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.sendUsEmail,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CommonButton(
            text: AppStrings.emailSupport,
            onPressed: () => UrlUtils.openEmail(
              AppStrings.supportEmail,
              subject: 'PawAround Support Request',
            ),
            variant: ButtonVariant.primary,
            icon: Icons.email_outlined,
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
}
