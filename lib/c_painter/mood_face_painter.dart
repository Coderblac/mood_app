import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mood_app/models/mood_entry.dart';


class MoodFacePainter extends CustomPainter {
  final MoodType mood;
  final double animationValue; // 0.0 to 1.0 for pulse/bounce animation
  final bool isSmall; // compact mode for timeline

  MoodFacePainter({
    required this.mood,
    this.animationValue = 1.0,
    this.isSmall = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r =
        (size.width < size.height ? size.width : size.height) / 2 * 0.9;

    // opulse scale applied to whole face
    final double scale = 0.85 + 0.15 * animationValue;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);
    canvas.translate(-cx, -cy);

    _drawFace(canvas, cx, cy, r);

    canvas.restore();
  }

  void _drawFace(Canvas canvas, double cx, double cy, double r) {
    final Color faceColor = MoodData.colors[mood]!;
    final Color darkColor = _darken(faceColor, 0.25);

    // Face circle 
    final Paint bgPaint = Paint()
      ..color = faceColor.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final Paint rimPaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07;
    canvas.drawCircle(Offset(cx, cy), r, rimPaint);

    // Dispatch to mood specific drawing
    switch (mood) {

      case MoodType.happy:
        _drawHappy(canvas, cx, cy, r, faceColor, darkColor);
        break;
      case MoodType.neutral:
        _drawNeutral(canvas, cx, cy, r, faceColor, darkColor);
        break;
      case MoodType.sad:
        _drawSad(canvas, cx, cy, r, faceColor, darkColor);
        break;
  
    }
  }


  // happy simple smile open eyes slight brow lift

  void _drawHappy(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color faceColor,
    Color darkColor,
  ) {
    final Paint strokePaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.065;

    // Eyes simple circles filled
    final Paint eyePaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.1), r * 0.1, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.28, cy - r * 0.1), r * 0.1, eyePaint);

    // Eye shine
    final Paint shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx - r * 0.25, cy - r * 0.13),
      r * 0.035,
      shinePaint,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.31, cy - r * 0.13),
      r * 0.035,
      shinePaint,
    );

    // elaxed brows lifted slightly
    _drawEyebrow(
      canvas,
      cx - r * 0.28,
      cy - r * 0.28,
      r * 0.22,
      strokePaint,
      arch: -0.05,
      strokeWidth: r * 0.06,
    );
    _drawEyebrow(
      canvas,
      cx + r * 0.28,
      cy - r * 0.28,
      r * 0.22,
      strokePaint,
      arch: -0.05,
      strokeWidth: r * 0.06,
    );

    // Smile arc
    final Rect smileRect = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.05),
      width: r * 0.76,
      height: r * 0.52,
    );
    final Path smilePath = Path()
      ..addArc(smileRect, math.pi * 0.1, math.pi * 0.8);
    canvas.drawPath(smilePath, strokePaint);
  }


  // NEUTRAL flat line mouth normal eyes level brows

  void _drawNeutral(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color faceColor,
    Color darkColor,
  ) {
    final Paint strokePaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.065;

    // Eyes
    final Paint eyePaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.1), r * 0.09, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.28, cy - r * 0.1), r * 0.09, eyePaint);

    // Level flat brows
    _drawEyebrow(
      canvas,
      cx - r * 0.28,
      cy - r * 0.27,
      r * 0.22,
      strokePaint,
      arch: 0.0,
      strokeWidth: r * 0.06,
    );
    _drawEyebrow(
      canvas,
      cx + r * 0.28,
      cy - r * 0.27,
      r * 0.22,
      strokePaint,
      arch: 0.0,
      strokeWidth: r * 0.06,
    );

    // Flat/slightly wavy mouth
    final Path mouthPath = Path();
    mouthPath.moveTo(cx - r * 0.3, cy + r * 0.25);
    mouthPath.cubicTo(
      cx - r * 0.1,
      cy + r * 0.22,
      cx + r * 0.1,
      cy + r * 0.28,
      cx + r * 0.3,
      cy + r * 0.25,
    );
    canvas.drawPath(mouthPath, strokePaint);
  }

  // SAD downturned mouth arc, droopy eyes, angled brows (inner up)

  void _drawSad(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color faceColor,
    Color darkColor,
  ) {
    final Paint strokePaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.065;

    // Droopy eyes half lidded (ellipse + arc)
    final Paint eyePaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.08), r * 0.09, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.28, cy - r * 0.08), r * 0.09, eyePaint);

    // Half lid lines
    final Paint lidPaint = Paint()
      ..color = darkColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - r * 0.37, cy - r * 0.1),
      Offset(cx - r * 0.19, cy - r * 0.1),
      lidPaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.19, cy - r * 0.1),
      Offset(cx + r * 0.37, cy - r * 0.1),
      lidPaint,
    );

    // Sad brows inner corners raised worried angle)
    _drawAngledBrow(
      canvas,
      cx - r * 0.28,
      cy - r * 0.28,
      r * 0.22,
      strokePaint,
      leftSide: true,
      strokeWidth: r * 0.06,
    );
    _drawAngledBrow(
      canvas,
      cx + r * 0.28,
      cy - r * 0.28,
      r * 0.22,
      strokePaint,
      leftSide: false,
      strokeWidth: r * 0.06,
    );

    // downward frown arc
    final Rect frownRect = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.55),
      width: r * 0.7,
      height: r * 0.52,
    );
    final Path frownPath = Path()
      ..addArc(frownRect, math.pi * 1.1, math.pi * 0.8);
    canvas.drawPath(frownPath, strokePaint);

    // Tear drop
    _drawTear(canvas, cx + r * 0.32, cy + r * 0.05, r * 0.07, darkColor);
  }



  /* Reusable primitives */


  void _drawEyebrow(
    Canvas canvas,
    double cx,
    double cy,
    double width,
    Paint paint, {
    double arch = 0.0,
    double strokeWidth = 4.0,
  }) {
    final Paint bPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final Path path = Path();
    path.moveTo(cx - width / 2, cy);
    path.quadraticBezierTo(cx, cy + arch * width, cx + width / 2, cy);
    canvas.drawPath(path, bPaint);
  }

  void _drawAngledBrow(
    Canvas canvas,
    double cx,
    double cy,
    double width,
    Paint paint, {
    required bool leftSide,
    double strokeWidth = 4.0,
  }) {
    final Paint bPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    // Inner corner raised, outer corner lower
    final double innerY = cy - width * 0.18;
    final double outerY = cy + width * 0.04;
    canvas.drawLine(
      Offset(leftSide ? cx - width / 2 : cx + width / 2, outerY),
      Offset(leftSide ? cx + width / 2 : cx - width / 2, innerY),
      bPaint,
    );
  }

  void _drawTear(Canvas canvas, double cx, double cy, double r, Color color) {
    final Paint tearPaint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.85)
      ..style = PaintingStyle.fill;
    final Path tearPath = Path();
    tearPath.moveTo(cx, cy - r * 1.4);
    tearPath.cubicTo(cx + r, cy - r * 0.3, cx + r, cy + r * 0.5, cx, cy + r);
    tearPath.cubicTo(
      cx - r,
      cy + r * 0.5,
      cx - r,
      cy - r * 0.3,
      cx,
      cy - r * 1.4,
    );
    canvas.drawPath(tearPath, tearPaint);
  }

  Color _darken(Color color, double amount) {
    final HSLColor hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(MoodFacePainter oldDelegate) =>
      oldDelegate.mood != mood || oldDelegate.animationValue != animationValue;
}
