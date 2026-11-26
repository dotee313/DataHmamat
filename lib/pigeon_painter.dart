import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'genetics/genetics.dart';

/// رسم حمامة جانبية تتغير ألوانها وأجنحتها وريشها حسب الشكل الظاهري المتوقع.
/// يُرسم بالكامل داخل التطبيق بلا صور ولا إنترنت.
class PigeonPainter extends CustomPainter {
  const PigeonPainter({required this.phenotype, this.beakScore = 0});

  final Phenotype phenotype;

  /// طول المنقار المتوقع (٠ متوسط، موجب أطول، سالب أقصر).
  final double beakScore;

  static const Color _ink = Color(0xFF3A3050);

  Color get _body {
    final p = phenotype;
    Color base;
    if (p.recessiveRed) {
      base = const Color(0xFFC1432E);
    } else if (p.baseColor.startsWith('Ash')) {
      base = const Color(0xFFB4553B);
    } else if (p.baseColor.startsWith('Brown')) {
      base = const Color(0xFF7A5436);
    } else {
      base = const Color(0xFF6F7F98);
    }
    if (p.spread && !p.recessiveRed) {
      base = Color.lerp(base, const Color(0xFF1F1F27), 0.75)!;
    }
    if (p.dilute) base = Color.lerp(base, const Color(0xFFD9D4C7), 0.5)!;
    if (p.milky) base = Color.lerp(base, Colors.white, 0.28)!;
    if (p.ice) base = Color.lerp(base, Colors.white, 0.38)!;
    return base;
  }

  Color get _beak {
    switch (phenotype.beakColor) {
      case 'pinkish-horn':
        return const Color(0xFFD9A28F);
      case 'light horn':
        return const Color(0xFFC9B79C);
      case 'dark horn':
        return const Color(0xFF5C4A3E);
      default:
        return const Color(0xFF2A2A2E);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 200, size.height / 150);
    canvas.save();
    canvas.translate(
      (size.width - 200 * scale) / 2,
      (size.height - 150 * scale) / 2,
    );
    canvas.scale(scale);
    _draw(canvas);
    canvas.restore();
  }

  void _draw(Canvas canvas) {
    final p = phenotype;
    final body = _body;
    final dark = Color.lerp(body, Colors.black, 0.55)!;
    final wingColor = Color.lerp(body, Colors.white, p.spread ? 0.0 : 0.12)!;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..color = _ink.withValues(alpha: 0.55);
    Paint fill(Color c) => Paint()..color = c;

    // ظل الأرض.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(98, 143), width: 112, height: 8),
      fill(Colors.black.withValues(alpha: 0.12)),
    );

    // الرجلان.
    final leg = Paint()
      ..color = const Color(0xFFB84A55)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final x in <double>[86, 106]) {
      canvas.drawLine(Offset(x, 112), Offset(x - 2, 134), leg);
      canvas.drawLine(Offset(x - 2, 134), Offset(x - 13, 139), leg);
      canvas.drawLine(Offset(x - 2, 134), Offset(x + 9, 139), leg);
    }
    if (p.featherStructure.contains('foot-feathered')) {
      final puff = Color.lerp(body, Colors.white, 0.25)!;
      for (final x in <double>[84, 104]) {
        final r = Rect.fromCenter(
          center: Offset(x, 126),
          width: 15,
          height: 24,
        );
        canvas.drawOval(r, fill(puff));
        canvas.drawOval(r, stroke);
      }
    }

    // الذيل.
    final tail = Path()
      ..moveTo(46, 74)
      ..lineTo(6, 104)
      ..lineTo(20, 114)
      ..lineTo(56, 98)
      ..close();
    canvas.drawPath(tail, fill(Color.lerp(body, Colors.black, 0.18)!));
    canvas.drawPath(tail, stroke);

    // الجسم والعنق والرأس.
    final bodyRect = Rect.fromCenter(
      center: const Offset(98, 82),
      width: 132,
      height: 72,
    );
    final neckRect = Rect.fromCenter(
      center: const Offset(140, 62),
      width: 42,
      height: 52,
    );
    final headRect = Rect.fromCircle(center: const Offset(154, 46), radius: 17);
    final bodyPath = Path()
      ..addOval(bodyRect)
      ..addOval(neckRect)
      ..addOval(headRect);
    canvas.drawPath(bodyPath, fill(body));

    // لمعة العنق.
    final sheenRect = Rect.fromCenter(
      center: const Offset(146, 68),
      width: 28,
      height: 22,
    );
    final sheenColors = p.recessiveRed
        ? const <Color>[Color(0xFFE0A040), Color(0xFFE08A40)]
        : const <Color>[Color(0xFF7BB07F), Color(0xFF9A6BB5)];
    final sheenAlpha = (p.dilute || p.ice || p.milky) ? 0.25 : 0.5;
    canvas.drawOval(
      sheenRect,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            sheenColors[0].withValues(alpha: sheenAlpha),
            sheenColors[1].withValues(alpha: sheenAlpha),
          ],
        ).createShader(sheenRect),
    );

    // البقع (أبرق / مبرقش / لوزي) داخل حدود الجسم.
    canvas.save();
    canvas.clipPath(bodyPath);
    if (p.pied) {
      final white = fill(Colors.white);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(96, 106), width: 78, height: 36),
        white,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(160, 40), width: 16, height: 14),
        white,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(62, 84), width: 40, height: 26),
        white,
      );
    }
    if (p.grizzle) {
      final rnd = math.Random(7);
      final dot = fill(Colors.white.withValues(alpha: 0.85));
      for (var i = 0; i < 46; i++) {
        canvas.drawCircle(
          Offset(34 + rnd.nextDouble() * 130, 46 + rnd.nextDouble() * 72),
          1.3 + rnd.nextDouble() * 1.4,
          dot,
        );
      }
    }
    if (p.almond) {
      final rnd = math.Random(11);
      final gold = fill(const Color(0xFFC59A3B).withValues(alpha: 0.9));
      final brown = fill(const Color(0xFF3B2B1E).withValues(alpha: 0.8));
      for (var i = 0; i < 34; i++) {
        canvas.drawCircle(
          Offset(34 + rnd.nextDouble() * 130, 46 + rnd.nextDouble() * 72),
          1.4 + rnd.nextDouble() * 1.6,
          i.isEven ? gold : brown,
        );
      }
    }
    canvas.restore();

    // ريش مجعّد على الصدر.
    if (p.featherStructure.contains('frilled')) {
      final curl = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(body, Colors.white, 0.45)!;
      for (var i = 0; i < 8; i++) {
        final cx = 122 + (i % 3) * 13.0;
        final cy = 76 + (i ~/ 3) * 12.0;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: 6),
          math.pi * 0.1,
          math.pi * 1.25,
          false,
          curl,
        );
      }
    }

    // الجناح ونقشه.
    final wing = Path()
      ..moveTo(120, 66)
      ..cubicTo(104, 54, 54, 62, 22, 100)
      ..cubicTo(56, 108, 104, 100, 120, 66)
      ..close();
    final tPattern = !p.recessiveRed && !p.spread && p.pattern == 'T-pattern';
    canvas.drawPath(
      wing,
      fill(tPattern ? Color.lerp(wingColor, Colors.black, 0.45)! : wingColor),
    );
    if (!p.recessiveRed && !p.spread) {
      canvas.save();
      canvas.clipPath(wing);
      if (p.pattern.startsWith('Bar (')) {
        final bar = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = dark;
        canvas.drawPath(
          Path()
            ..moveTo(94, 54)
            ..quadraticBezierTo(86, 82, 72, 110),
          bar,
        );
        canvas.drawPath(
          Path()
            ..moveTo(70, 54)
            ..quadraticBezierTo(62, 80, 48, 108),
          bar,
        );
      } else if (p.pattern == 'Check') {
        final spot = fill(dark);
        for (var x = 36.0; x < 118; x += 12) {
          for (var y = 64.0; y < 104; y += 10) {
            final shift = ((y - 64) ~/ 10).isEven ? 0.0 : 6.0;
            canvas.drawCircle(Offset(x + shift, y), 3.4, spot);
          }
        }
      } else if (tPattern) {
        final spot = fill(Color.lerp(wingColor, Colors.white, 0.25)!);
        for (var x = 40.0; x < 116; x += 18) {
          for (var y = 68.0; y < 102; y += 14) {
            canvas.drawCircle(Offset(x, y), 2.2, spot);
          }
        }
      }
      canvas.restore();
    }
    canvas.drawPath(wing, stroke);
    canvas.drawPath(bodyPath, stroke);

    // فتيلا الرأس.
    if (p.featherStructure.contains('crested')) {
      final crest = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(body, Colors.black, 0.2)!;
      canvas.drawPath(
        Path()
          ..moveTo(148, 33)
          ..quadraticBezierTo(140, 24, 138, 14),
        crest,
      );
      canvas.drawPath(
        Path()
          ..moveTo(154, 30)
          ..quadraticBezierTo(153, 20, 156, 10),
        crest,
      );
      canvas.drawPath(
        Path()
          ..moveTo(160, 33)
          ..quadraticBezierTo(166, 24, 172, 17),
        crest,
      );
    }

    // المنقار والعين.
    final length = (18 + beakScore * 4).clamp(10.0, 30.0).toDouble();
    final beak = Path()
      ..moveTo(168, 42)
      ..lineTo(168 + length, 48)
      ..lineTo(168, 54)
      ..close();
    canvas.drawPath(beak, fill(_beak));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(170, 44), width: 8, height: 6),
      fill(Colors.white.withValues(alpha: 0.9)),
    );
    if (p.eyeColor.startsWith('pearl')) {
      canvas.drawCircle(const Offset(158, 42), 5.4, fill(const Color(0xFFF2EBD0)));
      canvas.drawCircle(const Offset(158, 42), 5.4, stroke);
      canvas.drawCircle(const Offset(158.6, 42), 2.4, fill(Colors.black));
    } else {
      canvas.drawCircle(const Offset(158, 42), 5, fill(const Color(0xFF1B1B1B)));
      canvas.drawCircle(const Offset(159.6, 40.4), 1.2, fill(Colors.white));
    }
  }

  @override
  bool shouldRepaint(covariant PigeonPainter old) =>
      old.phenotype != phenotype || old.beakScore != beakScore;
}

class PigeonView extends StatelessWidget {
  const PigeonView({super.key, required this.phenotype, this.beakScore = 0});

  final Phenotype phenotype;
  final double beakScore;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 200 / 150,
      child: CustomPaint(
        painter: PigeonPainter(phenotype: phenotype, beakScore: beakScore),
      ),
    );
  }
}
