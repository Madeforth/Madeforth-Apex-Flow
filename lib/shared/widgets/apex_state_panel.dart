import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:flutter/material.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class ApexStatePanel extends StatelessWidget {
  const ApexStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.elevated,
                  border: Border.all(color: context.colors.border),
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                ),
                child: Icon(icon, size: 16, color: context.colors.cyan),
              ),
              const SizedBox(width: ApexSpacing.x1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (loading) ...[
            const SizedBox(height: ApexSpacing.x2),
            LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  child: ColoredBox(
                    color: context.colors.rail,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: constraints.maxWidth * 0.62,
                        height: 5,
                        child: ColoredBox(color: context.colors.cyan),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: ApexSpacing.x2),
            action!,
          ],
        ],
      ),
    );
  }
}
