import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class ApexLimelightDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const ApexLimelightDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class ApexLimelightNavigationBar extends StatelessWidget {
  const ApexLimelightNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.compactNavigation = false,
    this.height = 56.0,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<ApexLimelightDestination> destinations;
  final bool compactNavigation;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return const SizedBox.shrink();

    final primaryColor = context.colors.cyan;
    final count = destinations.length;

    return SizedBox(
      height: height,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: height,
                constraints: const BoxConstraints(maxWidth: 310),
                decoration: BoxDecoration(
                  color: context.colors.navChip.withValues(
                    alpha: 0.8,
                  ), // Semi-transparent navbar background
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / count;
                    final highlightWidth = itemWidth - 4;
                    final innerHeight = constraints.maxHeight - 8;

                    return Stack(
                      children: [
                        // Liquid sliding highlight
                        _LiquidHighlight(
                          selectedIndex: selectedIndex,
                          itemCount: count,
                          itemWidth: itemWidth,
                          highlightWidth: highlightWidth,
                          innerHeight: innerHeight,
                          color: primaryColor.withValues(alpha: 0.14),
                        ),
                        // Icon buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(count, (index) {
                            final isSelected = index == selectedIndex;
                            final item = destinations[index];

                            return Expanded(
                              child: GestureDetector(
                                key: Key('nav_item_$index'),
                                onTap: () => onDestinationSelected(index),
                                behavior: HitTestBehavior.opaque,
                                child: Center(
                                  child: Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    size: isSelected ? 24 : 22,
                                    color: isSelected
                                        ? primaryColor
                                        : context.colors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Liquid water-drop highlight that stretches as it slides between tabs.
/// The leading edge moves first while the trailing edge "peels away" with delay.
class _LiquidHighlight extends StatefulWidget {
  const _LiquidHighlight({
    required this.selectedIndex,
    required this.itemCount,
    required this.itemWidth,
    required this.highlightWidth,
    required this.innerHeight,
    required this.color,
  });

  final int selectedIndex;
  final int itemCount;
  final double itemWidth;
  final double highlightWidth;
  final double innerHeight;
  final Color color;

  @override
  State<_LiquidHighlight> createState() => _LiquidHighlightState();
}

class _LiquidHighlightState extends State<_LiquidHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _previousIndex;

  // Left and right edge positions
  late double _startLeft;
  late double _startRight;
  late double _endLeft;
  late double _endRight;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _computeEdges(widget.selectedIndex, widget.selectedIndex);
    _controller.value = 1.0; // Start fully settled
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _LiquidHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _computeEdges(_previousIndex, widget.selectedIndex);
      _controller.forward(from: 0.0);
    }
  }

  void _computeEdges(int fromIndex, int toIndex) {
    _startLeft = (widget.itemWidth * fromIndex) + 2;
    _startRight = _startLeft + widget.highlightWidth;
    _endLeft = (widget.itemWidth * toIndex) + 2;
    _endRight = _endLeft + widget.highlightWidth;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final movingRight = _endLeft >= _startLeft;

        double left;
        double right;

        if (movingRight) {
          // Right edge leads (fast), left edge follows (delayed peel-off)
          final leadT = Curves.easeOutCubic.transform(
            (t * 1.3).clamp(0.0, 1.0),
          );
          final trailT = Curves.easeOutCubic.transform(
            ((t - 0.2) * 1.25).clamp(0.0, 1.0),
          );
          right = _startRight + (_endRight - _startRight) * leadT;
          left = _startLeft + (_endLeft - _startLeft) * trailT;
        } else {
          // Left edge leads (fast), right edge follows (delayed peel-off)
          final leadT = Curves.easeOutCubic.transform(
            (t * 1.3).clamp(0.0, 1.0),
          );
          final trailT = Curves.easeOutCubic.transform(
            ((t - 0.2) * 1.25).clamp(0.0, 1.0),
          );
          left = _startLeft + (_endLeft - _startLeft) * leadT;
          right = _startRight + (_endRight - _startRight) * trailT;
        }

        return Positioned(
          left: left,
          top: 4,
          width: (right - left).clamp(
            widget.highlightWidth * 0.8,
            double.infinity,
          ),
          height: widget.innerHeight,
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        );
      },
    );
  }
}
