import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A pill-shaped button that plays a 3D card-flip (rotateX) transition
/// between two states, swapping its background color, icon, and label
/// together. Adapted from a Framer Motion "flip button" reference design,
/// reimplemented natively with [Transform]/[Matrix4] (no extra package).
class FlipStateButton extends StatefulWidget {
  const FlipStateButton({
    super.key,
    required this.isActive,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
    this.activeIcon,
    this.inactiveIcon,
    this.height = 56,
    this.textColor = Colors.white,
  });

  final bool isActive;
  final String activeLabel;
  final String inactiveLabel;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final double height;
  final Color textColor;

  @override
  State<FlipStateButton> createState() => _FlipStateButtonState();
}

class _FlipStateButtonState extends State<FlipStateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flip;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: widget.isActive ? 1 : 0,
    );
    _flip = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant FlipStateButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      widget.isActive ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _flip,
          builder: (context, _) {
            // Classic two-phase card flip: 0 -> 90deg rotates the front
            // face away (still showing old content), 90 -> 180deg brings
            // the "back" in. Content is swapped at the halfway point and
            // counter-rotated so it never appears mirrored.
            final angle = _flip.value * math.pi;
            final showBack = _flip.value >= 0.5;
            final color = showBack ? widget.activeColor : widget.inactiveColor;
            final label = showBack ? widget.activeLabel : widget.inactiveLabel;
            final icon = showBack ? widget.activeIcon : widget.inactiveIcon;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(angle),
              child: Container(
                width: double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
                alignment: Alignment.center,
                child: Transform(
                  alignment: Alignment.center,
                  transform: showBack
                      ? (Matrix4.identity()..rotateX(math.pi))
                      : Matrix4.identity(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, color: widget.textColor, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
