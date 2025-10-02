import 'package:flutter/material.dart';

class MatchesToggleWidget extends StatefulWidget {
  final bool isActiveMode;
  final Function(bool) onModeChanged;

  const MatchesToggleWidget({
    super.key,
    required this.isActiveMode,
    required this.onModeChanged,
  });

  @override
  State<MatchesToggleWidget> createState() => _MatchesToggleWidgetState();
}

class _MatchesToggleWidgetState extends State<MatchesToggleWidget>
    with TickerProviderStateMixin {

  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Set initial state
    if (!widget.isActiveMode) {
      _slideController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MatchesToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActiveMode != widget.isActiveMode) {
      if (widget.isActiveMode) {
        _slideController.reverse();
      } else {
        _slideController.forward();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTap(bool isActiveMode) {
    if (widget.isActiveMode == isActiveMode) return;

    // Trigger scale animation for feedback
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    widget.onModeChanged(isActiveMode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: Listenable.merge([_slideController, _scaleController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    // Background slider
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _slideAnimation.value < 0.5
                                          ? Colors.black87
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: _slideAnimation.value < 0.5
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _slideAnimation.value >= 0.5
                                          ? Colors.grey.shade600
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: _slideAnimation.value >= 0.5
                                          ? [
                                              BoxShadow(
                                                color: Colors.grey.withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Labels
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTap(true),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              height: double.infinity,
                              alignment: Alignment.center,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isActiveMode
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.chat_bubble_outline,
                                        key: ValueKey(widget.isActiveMode),
                                        size: 18,
                                        color: widget.isActiveMode
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Active Sessions'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTap(false),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              height: double.infinity,
                              alignment: Alignment.center,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: !widget.isActiveMode
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.notifications_none,
                                        key: ValueKey(!widget.isActiveMode),
                                        size: 18,
                                        color: !widget.isActiveMode
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Pending Requests'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Compact toggle for smaller spaces
class CompactMatchesToggle extends StatelessWidget {
  final bool isActiveMode;
  final Function(bool) onModeChanged;
  final int activeCount;
  final int pendingCount;

  const CompactMatchesToggle({
    super.key,
    required this.isActiveMode,
    required this.onModeChanged,
    this.activeCount = 0,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              icon: Icons.chat_bubble_outline,
              label: 'Active',
              count: activeCount,
              isSelected: isActiveMode,
              onTap: () => onModeChanged(true),
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.notifications_none,
              label: 'Pending',
              count: pendingCount,
              isSelected: !isActiveMode,
              onTap: () => onModeChanged(false),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}