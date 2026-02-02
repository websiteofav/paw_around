import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/moments/widgets/moment_card.dart';
import 'package:paw_around/ui/moments/widgets/moment_comments.dart';
import 'package:paw_around/ui/widgets/dashboard_app_bar.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';

class PetMomentsScreen extends StatefulWidget {
  const PetMomentsScreen({super.key});

  @override
  State<PetMomentsScreen> createState() => _PetMomentsScreenState();
}

class _PetMomentsScreenState extends State<PetMomentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PetMomentsBloc>().add(const LoadMoments());
  }

  void _handleLike(PetMoment moment) {
    final currentUser = sl<AuthRepository>().currentUser;
    if (currentUser == null) return;

    context.read<PetMomentsBloc>().add(
          LikeMoment(
            momentId: moment.id,
            userId: currentUser.uid,
          ),
        );
  }

  void _handleComment(PetMoment moment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => MomentComments(
          moment: moment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PetMomentsBloc, PetMomentsState>(
      listener: (context, state) {
        if (state is MomentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.momentPosted),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state is MomentDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.momentDeleted),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Custom App Bar
            DashboardAppBar(
              title: AppStrings.momentsTab,
              actions: [
                DashboardAppBarAction(
                  icon: Icons.add_circle_outline,
                  onTap: () async {
                    await context.pushNamed(AppRoutes.createMoment);
                    if (mounted) {
                      context.read<PetMomentsBloc>().add(const LoadMoments());
                    }
                  },
                ),
              ],
            ),

            // Content
            Expanded(
              child: BlocBuilder<PetMomentsBloc, PetMomentsState>(
                builder: (context, state) {
                  if (state is PetMomentsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (state is PetMomentsError) {
                    return _buildError(state.message);
                  }
                  if (state is PetMomentsLoaded) {
                    if (state.moments.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildMomentsList(state.moments);
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.pushNamed(AppRoutes.createMoment);
            if (mounted) {
              context.read<PetMomentsBloc>().add(const LoadMoments());
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(
            Icons.add,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PetMomentsBloc>().add(const LoadMoments());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                AppStrings.retry,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 14,
                  fontColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.auto_awesome,
      title: AppStrings.noMomentsYet,
      subtitle: AppStrings.noMomentsDescription,
      actionText: AppStrings.createMoment,
      onAction: () async {
        await context.pushNamed(AppRoutes.createMoment);
        if (mounted) {
          context.read<PetMomentsBloc>().add(const LoadMoments());
        }
      },
    );
  }

  Widget _buildMomentsList(List<PetMoment> moments) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: moments.length,
      itemBuilder: (context, index) {
        final moment = moments[index];
        return MomentCard(
          moment: moment,
          onLike: () => _handleLike(moment),
          onComment: () => _handleComment(moment),
        );
      },
    );
  }
}
