import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/community/widgets/community_action_bottom_sheet.dart';
import 'package:paw_around/ui/community/widgets/lost_found_tab.dart';
import 'package:paw_around/ui/community/widgets/moments_tab.dart';
import 'package:paw_around/ui/widgets/dashboard_app_bar.dart';

class PawCircleScreen extends StatefulWidget {
  final int? initialTab;
  const PawCircleScreen({super.key, this.initialTab});

  @override
  State<PawCircleScreen> createState() => _PawCircleScreenState();
}

class _PawCircleScreenState extends State<PawCircleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab ?? 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom App Bar
          DashboardAppBar(
            title: AppStrings.communityTitle,
            showProfileAvatar: true,
            onProfileTap: () => context.pushNamed(AppRoutes.profileTab),
            actions: [
              DashboardAppBarAction(
                icon: Icons.add_circle_outline,
                onTap: () => CommunityActionBottomSheet.show(context),
              ),
            ],
          ),

          // Tab Bar
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.semiBoldStyle600(fontSize: 14),
              unselectedLabelStyle: AppTextStyles.mediumStyle500(fontSize: 14),
              tabs: const [
                Tab(text: AppStrings.lostAndFoundTab),
                Tab(text: AppStrings.momentsTab),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                LostFoundTab(),
                MomentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
