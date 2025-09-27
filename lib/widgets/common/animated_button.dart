import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderSide? borderSide;
  final Duration animationDuration;
  final double scaleOnTap;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.borderSide,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleOnTap = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnTap,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                border: widget.borderSide != null
                    ? Border.fromBorderSide(widget.borderSide!)
                    : null,
                boxShadow: widget.elevation != null
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: widget.elevation!,
                          offset: Offset(0, widget.elevation! / 2),
                        ),
                      ]
                    : null,
              ),
              padding: widget.padding ?? const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.foregroundColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Specialized animated buttons for common use cases

class AnimatedElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AnimatedElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.black87,
      foregroundColor: foregroundColor ?? Colors.white,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      elevation: 2,
      child: child,
    );
  }
}

class AnimatedOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AnimatedOutlinedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? Colors.black87,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      borderSide: BorderSide(
        color: borderColor ?? Colors.grey.shade300,
        width: 1,
      ),
      child: child,
    );
  }
}

class AnimatedTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;

  const AnimatedTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.foregroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? Colors.black87,
      borderRadius: BorderRadius.circular(8),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: child,
    );
  }
}

class AnimatedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      padding: padding ?? const EdgeInsets.all(12),
      child: Icon(
        icon,
        size: size ?? 24,
        color: iconColor ?? Colors.grey.shade600,
      ),
    );
  }
}

// Floating Action Button with animation
class AnimatedFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const AnimatedFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(16),
      elevation: elevation ?? 6,
      scaleOnTap: 0.92,
      child: child,
    );
  }
}