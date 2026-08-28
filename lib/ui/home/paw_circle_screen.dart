import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/community/widgets/community_action_bottom_sheet.dart';
import 'package:paw_around/ui/community/widgets/lost_found_tab.dart';
import 'package:paw_around/ui/community/widgets/moments_tab.dart';
import 'package:paw_around/ui/widgets/pill_toggle_nav_row.dart';

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
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
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
                MomentsTab(),
                LostFoundTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow(BuildContext context) {
    return PillToggleNavRow(
      tabController: _tabController,
      firstTabLabel: AppStrings.momentsTab,
      secondTabLabel: AppStrings.lostAndFoundTab,
      leading: const SizedBox(width: 40),
      trailing: GestureDetector(
        onTap: () => CommunityActionBottomSheet.show(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
              color: AppColors.grey1100, shape: BoxShape.circle),
          child: const Icon(Icons.add, size: 20, color: AppColors.white),
        ),
      ),
    );
  }
}
