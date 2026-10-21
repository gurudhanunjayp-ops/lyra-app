import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared design system for the infertility app.
/// Modern medical palette — teal/cyan accents on a clean light surface,
/// rounded cards and pill buttons.

class AppColors {
  static const primary = Color(0xFF0D9488); // teal-600
  static const primaryDark = Color(0xFF0F766E); // teal-700
  static const accent = Color(0xFF2DD4BF); // teal-400
  static const accentBlue = Color(0xFF38BDF8); // sky-400
  static const bgTop = Color(0xFFFFFFFF);
  static const bgBottom = Color(0xFFE9F7F4);
  static const surface = Color(0xFFF1FAF8);
  static const ink = Color(0xFF1E293B); // slate-800
  static const muted = Color(0xFF64748B); // slate-500
  static const card = Colors.white;
}

const LinearGradient kBrandGradient = LinearGradient(
  colors: [AppColors.primary, AppColors.accent],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kBgGradient = LinearGradient(
  colors: [AppColors.bgTop, AppColors.bgBottom],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgBottom,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14.5),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC9E8E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.muted,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: AppColors.primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

/// Background decoration motifs — painted vector shapes, no assets needed.
enum BgDecor { soft, waves, crosses, ekg, dots, hearts }

/// Clean medical-style page background (white fading into soft teal)
/// with subtle painted vector decoration.
class AppBackground extends StatelessWidget {
  final Widget child;
  final BgDecor decor;
  const AppBackground(
      {super.key, required this.child, this.decor = BgDecor.soft});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kBgGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _BgDecorPainter(decor)),
          ),
          child,
        ],
      ),
    );
  }
}

class _BgDecorPainter extends CustomPainter {
  final BgDecor decor;
  _BgDecorPainter(this.decor);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft colour blobs — shared by all variants.
    _blob(canvas, Offset(w * 0.88, -h * 0.04), w * 0.45,
        AppColors.primary.withValues(alpha: 0.07));
    _blob(canvas, Offset(-w * 0.10, h * 0.62), w * 0.5,
        AppColors.accent.withValues(alpha: 0.07));
    _blob(canvas, Offset(w * 0.92, h * 0.92), w * 0.38,
        AppColors.primary.withValues(alpha: 0.05));

    switch (decor) {
      case BgDecor.soft:
        _crosses(canvas, size, alpha: 0.05);
        break;
      case BgDecor.waves:
        _waves(canvas, size);
        break;
      case BgDecor.crosses:
        _crosses(canvas, size, alpha: 0.08);
        break;
      case BgDecor.ekg:
        _ekg(canvas, size);
        break;
      case BgDecor.dots:
        _dots(canvas, size);
        break;
      case BgDecor.hearts:
        _hearts(canvas, size);
        break;
    }
  }

  void _blob(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(c, r, Paint()..color = color);
  }

  void _cross(Canvas canvas, Offset o, double s, Paint p) {
    final t = s * 0.32;
    final r = Radius.circular(s * 0.09);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: o, width: s, height: t), r),
        p);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: o, width: t, height: s), r),
        p);
  }

  void _crosses(Canvas canvas, Size size, {required double alpha}) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    _cross(canvas, Offset(w * 0.10, h * 0.14), 34, paint);
    _cross(canvas, Offset(w * 0.78, h * 0.30), 22, paint);
    _cross(canvas, Offset(w * 0.30, h * 0.55), 26, paint);
    _cross(canvas, Offset(w * 0.86, h * 0.68), 30, paint);
    _cross(canvas, Offset(w * 0.15, h * 0.86), 20, paint);
    _cross(canvas, Offset(w * 0.55, h * 0.92), 24, paint);
  }

  void _dots(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.10);
    const gap = 26.0;
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 5; j++) {
        canvas.drawCircle(
            Offset(size.width * 0.62 + i * gap, size.height * 0.10 + j * gap),
            2.4,
            paint);
      }
    }
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 5; j++) {
        canvas.drawCircle(
            Offset(size.width * 0.05 + i * gap, size.height * 0.78 + j * gap),
            2.4,
            paint);
      }
    }
  }

  void _waves(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Path wave(double baseY, double amp, Color color) {
      final p = Path()..moveTo(0, baseY);
      const steps = 24;
      for (var i = 0; i < steps; i++) {
        final x1 = w * i / steps;
        final x2 = w * (i + 1) / steps;
        final midX = (x1 + x2) / 2;
        final up = i.isEven ? -amp : amp;
        p.quadraticBezierTo(midX, baseY + up, x2, baseY);
      }
      p.lineTo(w, h);
      p.lineTo(0, h);
      p.close();
      canvas.drawPath(p, Paint()..color = color);
      return p;
    }

    wave(h * 0.86, 22, AppColors.accent.withValues(alpha: 0.14));
    wave(h * 0.90, 26, AppColors.primary.withValues(alpha: 0.10));
    wave(h * 0.94, 20, AppColors.primaryDark.withValues(alpha: 0.08));
  }

  void _ekg(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final y = h * 0.22;
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final p = Path()
      ..moveTo(0, y)
      ..lineTo(w * 0.22, y)
      ..lineTo(w * 0.27, y - 16)
      ..lineTo(w * 0.32, y + 12)
      ..lineTo(w * 0.37, y)
      ..lineTo(w * 0.52, y)
      ..lineTo(w * 0.57, y - 34)
      ..lineTo(w * 0.62, y + 22)
      ..lineTo(w * 0.66, y)
      ..lineTo(w, y);
    canvas.drawPath(p, paint);

    final y2 = h * 0.82;
    final p2 = Path()
      ..moveTo(0, y2)
      ..lineTo(w * 0.30, y2)
      ..lineTo(w * 0.35, y2 - 26)
      ..lineTo(w * 0.40, y2 + 16)
      ..lineTo(w * 0.44, y2)
      ..lineTo(w, y2);
    canvas.drawPath(
        p2,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  Path _heart(Offset c, double s) {
    final p = Path();
    p.moveTo(c.dx, c.dy + s * 0.35);
    p.cubicTo(c.dx - s * 1.1, c.dy - s * 0.45, c.dx - s * 0.55,
        c.dy - s * 1.05, c.dx, c.dy - s * 0.45);
    p.cubicTo(c.dx + s * 0.55, c.dy - s * 1.05, c.dx + s * 1.1,
        c.dy - s * 0.45, c.dx, c.dy + s * 0.35);
    p.close();
    return p;
  }

  void _hearts(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.08);
    final stroke = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(_heart(Offset(w * 0.16, h * 0.16), 26), fill);
    canvas.drawPath(_heart(Offset(w * 0.16, h * 0.16), 26), stroke);
    canvas.drawPath(_heart(Offset(w * 0.84, h * 0.42), 18), fill);
    canvas.drawPath(_heart(Offset(w * 0.30, h * 0.70), 22), stroke);
    canvas.drawPath(_heart(Offset(w * 0.72, h * 0.86), 28), fill);
    canvas.drawPath(_heart(Offset(w * 0.72, h * 0.86), 28), stroke);
  }

  @override
  bool shouldRepaint(_BgDecorPainter oldDelegate) =>
      oldDelegate.decor != decor;
}

/// Fade + slide-up entrance animation. Wrap any widget to animate it in
/// once when it first mounts.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.offsetY = 24,
  });

  @override
  Widget build(BuildContext context) {
    final total = duration + delay;
    final start =
        total.inMilliseconds == 0 ? 0.0 : delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start.clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, offsetY * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Gradient pill button used across the app.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      offsetY: 16,
      child: _PressableScale(
        onTap: onPressed,
        child: Container(
          width: width,
          height: 56,
          decoration: BoxDecoration(
            gradient: kBrandGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onPressed,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scales a child down slightly while pressed — used by buttons/cards.
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableScale({required this.child, this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Label + rounded filled text field.
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final IconData? icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.hint,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Icon inside a soft tinted rounded square.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? color;

  const IconBadge({
    super.key,
    required this.icon,
    this.size = 62,
    this.iconSize = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color ?? AppColors.primary, size: iconSize),
    );
  }
}

/// Icon inside a gradient circle — logo / hero mark. Gently scales in.
class GradientIconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const GradientIconBadge({
    super.key,
    required this.icon,
    this.size = 96,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: scale.clamp(0.0, 1.0),
          child: child,
        ),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: kBrandGradient,
          borderRadius: BorderRadius.circular(size * 0.3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

/// Consistent inner-page scaffold: gradient background + modern app bar.
class PageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final BgDecor decor;

  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.drawer,
    this.decor = BgDecor.soft,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        title: Text(title),
        leading: leading,
        actions: actions,
      ),
      body: AppBackground(decor: decor, child: SafeArea(child: body)),
    );
  }
}

/// White rounded container grouping a form/section.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final String? title;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: title == null
            ? child
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
      ),
    );
  }
}

/// Tappable list-row card: icon badge + title/subtitle + chevron.
class ListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.chevron_right_rounded,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FadeSlideIn(
        offsetY: 18,
        child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                IconBadge(icon: icon, size: 46, iconSize: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.muted),
                          ),
                        ),
                    ],
                  ),
                ),
                trailing ??
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Labeled dropdown matching AppTextField styling.
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final IconData? icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;

  const AppDropdown({
    super.key,
    required this.label,
    this.icon,
    required this.items,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          isExpanded: true,
          initialValue: value,
          decoration:
              InputDecoration(prefixIcon: icon != null ? Icon(icon) : null),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Yes/No chip selector row.
class YesNoField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  const YesNoField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
        _YesNoChip(
          label: 'Yes',
          selected: value == 'yes',
          onTap: () => onChanged('yes'),
        ),
        const SizedBox(width: 10),
        _YesNoChip(
          label: 'No',
          selected: value == 'no',
          onTap: () => onChanged('no'),
        ),
      ],
    );
  }
}

class _YesNoChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _YesNoChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? kBrandGradient : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFC9E8E2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

/// Tappable white card with an icon for dashboard grids.
class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      offsetY: 18,
      child: _PressableScale(
        onTap: onTap,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 3,
          shadowColor: AppColors.primary.withValues(alpha: 0.18),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconBadge(icon: icon),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
