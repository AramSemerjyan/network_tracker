import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double minHeight;
  final double minWidth;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.minHeight = 40,
    this.minWidth = 64,
  });

  factory GradientButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    required IconData icon,
    required Widget label,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
    double minHeight = 40,
    double minWidth = 64,
  }) {
    return GradientButton(
      key: key,
      onPressed: onPressed,
      padding: padding,
      borderRadius: borderRadius,
      minHeight: minHeight,
      minWidth: minWidth,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          label,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final enabled = onPressed != null;

    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF667EEA),
        Color(0xFF764BA2),
      ],
    );

    final backgroundColor = enabled
        ? (isDark ? null : scheme.primaryContainer)
        : scheme.surfaceContainerHighest;

    final foregroundColor = enabled
        ? (isDark ? Colors.white : scheme.onPrimaryContainer)
        : scheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, minWidth: minWidth),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: isDark && enabled ? gradient : null,
            borderRadius: borderRadius,
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            child: Padding(
              padding: padding,
              child: Align(
                alignment: Alignment.center,
                child: DefaultTextStyle.merge(
                  style: theme.textTheme.labelLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                  child: IconTheme.merge(
                    data: IconThemeData(color: foregroundColor),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
