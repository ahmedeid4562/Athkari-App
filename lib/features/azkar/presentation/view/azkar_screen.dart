import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/azkar_category_model.dart';
import '../view_model/azkar_cubit.dart';
import 'azkar_details_screen.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => AzkarCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الأذكار',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<AzkarCubit, List<AzkarCategoryModel>>(
            builder: (context, categories) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _buildFeaturedCard(context),
                        const SizedBox(height: 28),
                        Text(
                          'جميع الأذكار',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'اختر القسم الذي تريد قراءته',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildCategoryCard(
                          context,
                          categories[index],
                          index,
                        );
                      }, childCount: categories.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.88,
                          ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 25)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حصّن يومك بذكر الله',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر من مجموعة الأذكار اليومية واجعل ذكر الله رفيقك في كل وقت.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF247A60), Color(0xFF176B55), Color(0xFF0D493B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -15,
            top: -25,
            child: Icon(
              Icons.mosque_rounded,
              size: 125,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFD6B76C),
                    size: 27,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'نور يومك',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  height: 1.9,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'سورة الرعد - الآية 28',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 45,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6B76C),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    AzkarCategoryModel category,
    int index,
  ) {
    final theme = Theme.of(context);

    final decorations = [
      Icons.wb_sunny_rounded,
      Icons.nightlight_round,
      Icons.mosque_rounded,
      Icons.bedtime_rounded,
      Icons.wb_twilight_rounded,
      Icons.auto_awesome_rounded,
    ];

    final backgroundColors = [
      const Color(0xFFE7F3E9),
      const Color(0xFFE9E9F5),
      const Color(0xFFF4EDDF),
      const Color(0xFFE6EDF7),
      const Color(0xFFF8EDDF),
      const Color(0xFFF3E8F0),
    ];

    final decoration = decorations[index % decorations.length];
    final background = backgroundColors[index % backgroundColors.length];

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(23),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AzkarDetailsScreen(category: category),
            ),
          );
        },
        child: Stack(
          children: [
            Positioned(
              left: -20,
              top: -20,
              child: Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 15,
              child: Icon(
                decoration,
                size: 75,
                color: category.color.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(category.icon, color: category.color, size: 29),
                  ),
                  const Spacer(),
                  Text(
                    category.title,
                    maxLines: 2,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 15,
                          color: category.color,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 25,
                        height: 3,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
