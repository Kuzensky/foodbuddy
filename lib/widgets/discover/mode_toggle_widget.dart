import 'package:flutter/material.dart';

class ModeToggleWidget extends StatefulWidget {
  final bool isCreateMode;
  final Function(bool) onModeChanged;
  final String discoverLabel;
  final String createLabel;

  const ModeToggleWidget({
    super.key,
    required this.isCreateMode,
    required this.onModeChanged,
    this.discoverLabel = 'Find Sessions',
    this.createLabel = 'Your Sessions',
  });

  @override
  State<ModeToggleWidget> createState() => _ModeToggleWidgetState();
}

class _ModeToggleWidgetState extends State<ModeToggleWidget>
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
      duration: const Duration(milliseconds: 250),
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
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));


    // Set initial state
    if (widget.isCreateMode) {
      _slideController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModeToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCreateMode != widget.isCreateMode) {
      if (widget.isCreateMode) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTap(bool isCreateMode) {
    if (widget.isCreateMode == isCreateMode) return;

    // Trigger scale animation for feedback
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    widget.onModeChanged(isCreateMode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
                                      borderRadius: BorderRadius.circular(12),
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
                                          ? Colors.black87
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: _slideAnimation.value >= 0.5
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
                                  color: !widget.isCreateMode
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
                                        Icons.search,
                                        key: ValueKey(!widget.isCreateMode),
                                        size: 18,
                                        color: !widget.isCreateMode
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(widget.discoverLabel),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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
                                  color: widget.isCreateMode
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
                                        Icons.person,
                                        key: ValueKey(widget.isCreateMode),
                                        size: 18,
                                        color: widget.isCreateMode
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(widget.createLabel),
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

// Compact version for smaller spaces
class CompactModeToggle extends StatelessWidget {
  final bool isCreateMode;
  final Function(bool) onModeChanged;

  const CompactModeToggle({
    super.key,
    required this.isCreateMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            icon: Icons.search,
            label: 'Find',
            isSelected: !isCreateMode,
            onTap: () => onModeChanged(false),
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            icon: Icons.person,
            label: 'Yours',
            isSelected: isCreateMode,
            onTap: () => onModeChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Floating toggle overlay for map interface
class FloatingModeToggle extends StatelessWidget {
  final bool isCreateMode;
  final Function(bool) onModeChanged;
  final double? top;
  final double? left;
  final double? right;

  const FloatingModeToggle({
    super.key,
    required this.isCreateMode,
    required this.onModeChanged,
    this.top,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ?? MediaQuery.of(context).padding.top + kToolbarHeight + 16,
      left: left,
      right: right ?? 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CompactModeToggle(
          isCreateMode: isCreateMode,
          onModeChanged: onModeChanged,
        ),
      ),
    );
  }
}

// Animated indicator dots for visual feedback
class ToggleIndicator extends StatelessWidget {
  final bool isCreateMode;
  final Color activeColor;
  final Color inactiveColor;

  const ToggleIndicator({
    super.key,
    required this.isCreateMode,
    this.activeColor = Colors.black87,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: !isCreateMode ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCreateMode ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}