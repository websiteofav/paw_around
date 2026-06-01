import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey100,
      highlightColor: AppColors.white,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 60, height: 14),
                        const SizedBox(height: 6),
                        _box(width: 140, height: 20),
                      ],
                    ),
                    const Spacer(),
                    _circle(26),
                    const SizedBox(width: 12),
                    _circle(48),
                  ],
                ),
              ),
              // My Babies title
              _box(width: 120, height: 18),
              const SizedBox(height: 12),
              // Pet avatars row
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _rounded(width: 86, height: 86, radius: 24),
                        const SizedBox(height: 12),
                        _box(width: 60, height: 14),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions title
              _box(width: 130, height: 18),
              const SizedBox(height: 12),
              // Quick Actions grid
              Row(
                children: [
                  Expanded(child: _rounded(height: 160, radius: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: _rounded(height: 160, radius: 20)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _rounded(height: 160, radius: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: _rounded(height: 160, radius: 20)),
                ],
              ),
              const SizedBox(height: 24),
              // Moments title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _box(width: 180, height: 18),
                  _box(width: 60, height: 14),
                ],
              ),
              const SizedBox(height: 12),
              // Moments row
              SizedBox(
                height: 312,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _rounded(width: 260, height: 312, radius: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Nearby services title
              _box(width: 160, height: 18),
              const SizedBox(height: 12),
              // Place cards
              ...List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _rounded(height: 140, radius: 24),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: smoothDecoration(
        cornerRadius: 6,
        color: AppColors.white,
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _rounded({double? width, required double height, double radius = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: smoothDecoration(
        cornerRadius: radius,
        color: AppColors.white,
      ),
    );
  }
}
