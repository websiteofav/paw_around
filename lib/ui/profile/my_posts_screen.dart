import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/profile/widgets/my_moments_tab.dart';
import 'package:paw_around/ui/profile/widgets/my_posts_tab.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(height: topPad + 8),
          _buildNavRow(context),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MyPostsTab(),
                MyMomentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 22,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(child: Center(child: _buildPillToggle())),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPillToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: smoothDecoration(
        color: AppColors.grey1100,
        cornerRadius: 54,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pillTab(0, AppStrings.posts),
          Container(width: 1, height: 20, color: AppColors.white),
          _pillTab(1, AppStrings.myMoments),
        ],
      ),
    );
  }

  Widget _pillTab(int index, String label) {
    final isActive = _tabController.index == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text(
          label,
          style: AppTextStyles.interBoldStyle700(
            fontSize: 16,
            fontColor: isActive ? AppColors.primary : AppColors.white,
          ),
        ),
      ),
    );
  }
}
