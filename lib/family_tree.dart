import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';
import 'theme.dart';

Color birdColor(Bird? bird) {
  if (bird == null) return AppTheme.muted;
  return bird.sex == 'أنثى' ? AppTheme.gold : AppTheme.purple;
}

/// دائرة طير: صورته إن وجدت وإلا أول حرف من اسمه، ولون الإطار حسب الجنس.
class BirdCircle extends StatelessWidget {
  const BirdCircle({
    super.key,
    required this.bird,
    required this.diameter,
    this.highlight = false,
    this.placeholderColor,
    this.onTap,
  });

  final Bird? bird;
  final double diameter;
  final bool highlight;
  final Color? placeholderColor;
  final VoidCallback? onTap;

  Widget _content(Color color) {
    final b = bird;
    if (b == null) {
      return Icon(Icons.help_outline_rounded,
          size: diameter * 0.42, color: color.withValues(alpha: 0.6));
    }
    if (b.photos.isNotEmpty) {
      final path = b.photos.last;
      try {
        if (File(path).existsSync()) {
          return ClipOval(
            child: Image.file(
              File(path),
              width: diameter,
              height: diameter,
              fit: BoxFit.cover,
              cacheWidth: (diameter * 3).round(),
              errorBuilder: (_, __, ___) => _initial(b, color),
            ),
          );
        }
      } catch (_) {}
    }
    return _initial(b, color);
  }

  Widget _initial(Bird b, Color color) {
    final text =
        b.name.isEmpty ? '?' : String.fromCharCode(b.name.runes.first);
    return Text(
      text,
      style: TextStyle(
        fontSize: diameter * 0.42,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = bird;
    final color =
        b == null ? (placeholderColor ?? AppTheme.muted) : birdColor(b);
    final surface = Theme.of(context).colorScheme.surface;
    final circle = Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.alphaBlend(
            color.withValues(alpha: b == null ? 0.05 : 0.14), surface),
        border: Border.all(
          color: color.withValues(alpha: b == null ? 0.35 : 1),
          width: highlight ? 4 : 2.5,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: _content(color),
    );
    final decorated = Stack(
      alignment: Alignment.bottomRight,
      children: [
        circle,
        if (b != null && !b.alive)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: diameter * 0.32,
              height: diameter * 0.32,
              decoration: const BoxDecoration(
                color: Color(0xFFD64545),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.heart_broken_outlined,
                size: diameter * 0.18,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
    if (onTap == null || b == null) return decorated;
    return GestureDetector(onTap: onTap, child: decorated);
  }
}

/// شجرة زوجين: دائرتان للأب والأم بينهما +، ويخرج خط من الأسفل
/// يتفرع بخطوط تنتهي بدوائر الأبناء.
class CoupleTree extends StatelessWidget {
  const CoupleTree({
    super.key,
    required this.father,
    required this.mother,
    required this.children,
    required this.onTap,
    this.highlightId,
  });

  final Bird? father;
  final Bird? mother;
  final List<Bird> children;
  final String? highlightId;
  final ValueChanged<Bird> onTap;

  static const double _slot = 92;
  static const double _parentD = 68;
  static const double _childD = 58;
  static const double _labelH = 48;
  static const double _parentOffset = 62;
  static const double _busY = 118;
  static const double _childTop = 150;

  Widget _label(BuildContext context, Bird? bird, Color fallback, bool hl) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: _slot - 6,
      height: _labelH,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bird?.name ?? S.notRegistered,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.15,
                fontWeight: bird == null ? FontWeight.w400 : FontWeight.w700,
                color: bird == null
                    ? AppTheme.muted
                    : (hl ? birdColor(bird) : ink),
              ),
            ),
            if (bird != null)
              Text(
                bird.alive ? S.alive : S.dead,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: bird.alive ? const Color(0xFF2E9E5B) : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _node(
    BuildContext context, {
    required Bird? bird,
    required double cx,
    required double top,
    required double d,
    Color? placeholder,
  }) {
    final hl = bird != null && bird.id == highlightId;
    return Positioned(
      left: cx - _slot / 2,
      top: top,
      width: _slot,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BirdCircle(
            bird: bird,
            diameter: d,
            highlight: hl,
            placeholderColor: placeholder,
            onTap: bird == null ? null : () => onTap(bird),
          ),
          _label(context, bird, placeholder ?? AppTheme.muted, hl),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = children.length;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = (dark ? Colors.white : AppTheme.purple)
        .withValues(alpha: dark ? 0.45 : 0.55);
    final height = (n == 0 ? _parentD + _labelH : _childTop + _childD + _labelH) + 6;

    return LayoutBuilder(
      builder: (context, constraints) {
        final avail =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
        final minW = 2 * _parentOffset + _slot;
        final contentW = math.max(avail, math.max(minW, n * _slot));
        final cx = contentW / 2;
        final parentY = _parentD / 2;
        final childXs = <double>[
          for (var i = 0; i < n; i++) cx + (i - (n - 1) / 2) * _slot,
        ];

        final tree = SizedBox(
          width: contentW,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TreePainter(
                    cx: cx,
                    parentY: parentY,
                    busY: _busY,
                    childTop: _childTop,
                    childXs: childXs,
                    color: lineColor,
                  ),
                ),
              ),
              _node(context,
                  bird: father,
                  cx: cx - _parentOffset,
                  top: 0,
                  d: _parentD,
                  placeholder: AppTheme.purple),
              _node(context,
                  bird: mother,
                  cx: cx + _parentOffset,
                  top: 0,
                  d: _parentD,
                  placeholder: AppTheme.gold),
              Positioned(
                left: cx - 15,
                top: parentY - 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: lineColor, width: 2.5),
                  ),
                  child: Icon(Icons.add_rounded, size: 20, color: lineColor),
                ),
              ),
              for (var i = 0; i < n; i++)
                _node(context,
                    bird: children[i],
                    cx: childXs[i],
                    top: _childTop,
                    d: _childD),
            ],
          ),
        );

        // اتجاه ثابت للرسم: الأب يسار والأم يمين مهما كانت لغة الواجهة.
        return Directionality(
          textDirection: TextDirection.ltr,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: tree,
          ),
        );
      },
    );
  }
}

class _TreePainter extends CustomPainter {
  _TreePainter({
    required this.cx,
    required this.parentY,
    required this.busY,
    required this.childTop,
    required this.childXs,
    required this.color,
  });

  final double cx;
  final double parentY;
  final double busY;
  final double childTop;
  final List<double> childXs;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (childXs.isEmpty) return;
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, parentY + 15), Offset(cx, busY), p);
    if (childXs.length > 1) {
      canvas.drawLine(Offset(childXs.first, busY), Offset(childXs.last, busY), p);
    }
    for (final x in childXs) {
      canvas.drawLine(Offset(x, busY), Offset(x, childTop), p);
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) =>
      old.cx != cx ||
      old.childXs.length != childXs.length ||
      old.color != color;
}

/// مؤشر دائري متحرك بدل الرقم المجرد.
class RingGauge extends StatelessWidget {
  const RingGauge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.caption,
    this.size = 96,
  });

  final String label;
  final double? value;
  final Color color;
  final String? caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    final v = (value ?? 0).clamp(0.0, 1.0).toDouble();
    final ink = Theme.of(context).colorScheme.onSurface;
    final track = AppTheme.muted.withValues(alpha: 0.2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: v),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) => SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(t, color, track),
              child: Center(
                child: Text(
                  value == null ? '—' : '${(value! * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: value == null ? AppTheme.muted : color,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ink),
        ),
        if (caption != null)
          Text(
            caption!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: color),
          ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.track);

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    if (value > 0) {
      final fg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, fg);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
