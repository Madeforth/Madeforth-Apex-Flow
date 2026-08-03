import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:flutter/material.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class ApexPanel extends StatelessWidget {
  const ApexPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(
          color: context.colors.border.withValues(alpha: 0.82),
        ),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0611110F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
