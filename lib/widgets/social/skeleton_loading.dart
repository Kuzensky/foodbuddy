import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final Widget child;

  const SkeletonLoading({super.key, required this.child});

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class PostSkeleton extends StatelessWidget {
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header skeleton
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Image skeleton
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons skeleton
            Row(
              children: [
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Text skeleton
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationSkeleton extends StatelessWidget {
  const ConversationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 12,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultSkeleton extends StatelessWidget {
  const SearchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 32,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStatsSkeleton extends StatelessWidget {
  const ProfileStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 30,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Additional skeleton widgets for other sections

class SessionCardSkeleton extends StatelessWidget {
  const SessionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Host header skeleton
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title skeleton
            Container(
              height: 18,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Description skeleton
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 14,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Restaurant image skeleton
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            // Info chips skeleton
            Row(
              children: [
                Container(
                  height: 24,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 24,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MatchCardSkeleton extends StatelessWidget {
  const MatchCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // User avatar skeleton
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            // User info skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Status indicator skeleton
            Column(
              children: [
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCardSkeleton extends StatelessWidget {
  const RestaurantCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
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

class LoadingListSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget Function() itemBuilder;

  const LoadingListSkeleton({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }
}