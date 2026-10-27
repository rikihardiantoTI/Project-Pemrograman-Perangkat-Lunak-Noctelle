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
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF141B38), NoctelleColors.background],
                stops: [0, 0.48],
              ),
            ),
          ),
        ),
        const Positioned(
          top: -110,
          right: -100,
          child: _GlowOrb(color: Color(0x226C63FF), size: 260),
        ),
        const Positioned(
          bottom: 60,
          left: -150,
          child: _GlowOrb(color: Color(0x1268FBC9), size: 240),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: size * 0.55)],
        ),
      ),
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
  const NoctellePageTitle({
    required this.title,
    this.subtitle,
    this.eyebrow = 'NOCTELLE • RUANG ISTIRAHAT',
    this.icon = Icons.nightlight_round,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String eyebrow;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: NoctelleColors.mint,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: NoctelleColors.muted, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: NoctelleColors.lavender.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: NoctelleColors.lavender.withValues(alpha: 0.14),
            ),
          ),
          child: Icon(icon, color: NoctelleColors.lavender, size: 23),
        ),
      ],
    );
  }
}

class NoctelleSectionLabel extends StatelessWidget {
  const NoctelleSectionLabel(this.title, {this.trailing, super.key});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: NoctelleColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: NoctelleColors.lavender,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
