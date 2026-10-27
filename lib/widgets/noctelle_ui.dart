import 'package:flutter/material.dart';

abstract final class NoctelleColors {
  static const background = Color(0xFF0D1228);
  static const surface = Color(0xFF151A31);
  static const surfaceRaised = Color(0xFF1D2440);
  static const mint = Color(0xFF68FBC9);
  static const lavender = Color(0xFFC8BFFF);
  static const muted = Color(0xFF9CA6C4);
  static const outline = Color(0x243D496A);
}

class NoctellePage extends StatelessWidget {
  const NoctellePage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111832), NoctelleColors.background],
          stops: [0, 0.34],
        ),
      ),
      child: child,
    );
  }
}

class NoctellePanel extends StatelessWidget {
  const NoctellePanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = NoctelleColors.surface,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: NoctelleColors.outline),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class NoctellePageTitle extends StatelessWidget {
  const NoctellePageTitle({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: NoctelleColors.muted),
          ),
        ],
      ],
    );
  }
}
