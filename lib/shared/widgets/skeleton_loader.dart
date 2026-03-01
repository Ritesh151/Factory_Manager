import 'package:flutter/material.dart';

/// Reusable skeleton loader component with Animation
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color backgroundColor;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Card-like skeleton loader
class SkeletonCard extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsets padding;

  const SkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: SkeletonLoader(
          width: width,
          height: height,
        ),
      ),
    );
  }
}

/// List tile skeleton
class SkeletonListTile extends StatelessWidget {
  final double height;
  final EdgeInsets padding;

  const SkeletonListTile({
    super.key,
    this.height = 80,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          // Avatar skeletons
          SkeletonLoader(
            width: 50,
            height: 50,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
          ),
          const SizedBox(width: 12),
          // Text skeletons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 150, height: 14),
                const SizedBox(height: 8),
                SkeletonLoader(width: double.infinity, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action skeleton
          SkeletonLoader(width: 40, height: 40),
        ],
      ),
    );
  }
}

/// Grid item skeleton
class SkeletonGridItem extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonGridItem({
    super.key,
    this.width = 160,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoader(width: width, height: height * 0.7),
        const SizedBox(height: 8),
        SkeletonLoader(width: width * 0.8, height: 12),
        const SizedBox(height: 4),
        SkeletonLoader(width: width * 0.6, height: 12),
      ],
    );
  }
}

/// Stat card skeleton
class SkeletonStatCard extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonStatCard({
    super.key,
    this.width = 200,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(width: width * 0.6, height: 14),
            const SizedBox(height: 12),
            SkeletonLoader(width: width * 0.8, height: 24),
            const SizedBox(height: 8),
            SkeletonLoader(width: width * 0.5, height: 12),
          ],
        ),
      ),
    );
  }
}
