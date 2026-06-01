import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class LocationSearchSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selected;

  const LocationSearchSheet({
    super.key,
    required this.title,
    required this.items,
    this.selected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> items,
    String? selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationSearchSheet(
        title: title,
        items: items,
        selected: selected,
      ),
    );
  }

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  late List<String> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((item) => item.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: smoothDecoration(
          borderRadius: AppSmoothRadius.topOnly(24),
          color: AppColors.white,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: smoothDecoration(
                cornerRadius: 2,
                color: AppColors.border,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.title,
                style: AppTextStyles.boldStyle700(
                  fontSize: 18,
                  fontColor: AppColors.grey1000,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  hintStyle: AppTextStyles.regularStyle400(
                    fontColor: AppColors.textSecondary,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.neutral300, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (_, index) {
                  final item = _filtered[index];
                  final isSelected = item == widget.selected;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: AppTextStyles.interMediumStyle500(
                                fontSize: 15,
                                fontColor: isSelected
                                    ? AppColors.secondaryCTA
                                    : AppColors.grey1000,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.secondaryCTA,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
