import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:orange_ui/model/avatar/live_avatar_model.dart';

/// Highly efficient 2.5D Canvas Painter for real-time avatar animation
class AvatarCanvasPainter extends CustomPainter {
  final AvatarPose pose;
  final LiveAvatarModel avatar;
  final bool isGlowing;

  AvatarCanvasPainter({
    required this.pose,
    required this.avatar,
    this.isGlowing = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.38;

    canvas.save();

    // 1. Apply upper body & breathing kinematics
    final double bodyOffsetY = math.sin(pose.breathingPhase) * 6.0;
    final double bodySwayX = pose.bodySway * 18.0;
    canvas.translate(bodySwayX, bodyOffsetY);

    // Draw stylized shoulders / torso
    _drawTorso(canvas, center, baseRadius);

    // 2. Apply head matrix transform (Yaw, Pitch, Roll)
    final headCenter = Offset(center.dx, center.dy - baseRadius * 0.25);
    canvas.translate(headCenter.dx, headCenter.dy);
    canvas.rotate(pose.roll * 0.4); // Roll tilt

    final headSkewX = pose.yaw * 0.25;
    final headSkewY = pose.pitch * 0.25;
    final matrix = Matrix4.identity()
      ..setEntry(0, 1, headSkewX)
      ..setEntry(1, 0, headSkewY);
    canvas.transform(matrix.storage);

    // Draw head base, ears, hair, face
    _drawHead(canvas, Offset.zero, baseRadius);

    // Draw eyebrows
    _drawEyebrows(canvas, Offset.zero, baseRadius);

    // Draw eyes & blinking
    _drawEyes(canvas, Offset.zero, baseRadius);

    // Draw mouth & Viseme lip-sync
    _drawVisemeMouth(canvas, Offset.zero, baseRadius);

    canvas.restore();
  }

  void _drawTorso(Canvas canvas, Offset center, double radius) {
    final torsoPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E2235), Color(0xFF0F111D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(center.dx - radius * 1.4, center.dy, radius * 2.8, radius * 1.8));

    final path = Path()
      ..moveTo(center.dx - radius * 0.7, center.dy + radius * 0.3)
      ..cubicTo(center.dx - radius * 1.5, center.dy + radius * 0.8, center.dx - radius * 1.6, center.dy + radius * 1.8, center.dx - radius * 1.6, center.dy + radius * 1.8)
      ..lineTo(center.dx + radius * 1.6, center.dy + radius * 1.8)
      ..cubicTo(center.dx + radius * 1.6, center.dy + radius * 0.8, center.dx + radius * 1.5, center.dy + radius * 0.8, center.dx + radius * 0.7, center.dy + radius * 0.3)
      ..close();

    canvas.drawPath(path, torsoPaint);

    // Tech glow lines on collar
    if (isGlowing) {
      final glowPaint = Paint()
        ..color = const Color(0xFF00FFCC).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);

      canvas.drawPath(path, glowPaint);
    }
  }

  void _drawHead(Canvas canvas, Offset center, double radius) {
    final headRect = Rect.fromCircle(center: center, radius: radius);

    // Head base color
    final headPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF2C324D), Color(0xFF181B2B)],
        center: Alignment(-0.2, -0.3),
      ).createShader(headRect);

    canvas.drawCircle(center, radius, headPaint);

    // Cyber / fantasy ears
    _drawEars(canvas, center, radius);

    // Outer glow rim
    final rimPaint = Paint()
      ..color = const Color(0xFFFF7A00).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, rimPaint);
  }

  void _drawEars(Canvas canvas, Offset center, double radius) {
    final earPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7A00), Color(0xFF8B2500)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(center.dx - radius * 1.2, center.dy - radius * 1.5, radius * 2.4, radius));

    // Left Ear
    final leftEar = Path()
      ..moveTo(center.dx - radius * 0.7, center.dy - radius * 0.5)
      ..lineTo(center.dx - radius * 1.1 + (pose.yaw * 10), center.dy - radius * 1.3 + (pose.pitch * 8))
      ..lineTo(center.dx - radius * 0.2, center.dy - radius * 0.8)
      ..close();
    canvas.drawPath(leftEar, earPaint);

    // Right Ear
    final rightEar = Path()
      ..moveTo(center.dx + radius * 0.7, center.dy - radius * 0.5)
      ..lineTo(center.dx + radius * 1.1 + (pose.yaw * 10), center.dy - radius * 1.3 + (pose.pitch * 8))
      ..lineTo(center.dx + radius * 0.2, center.dy - radius * 0.8)
      ..close();
    canvas.drawPath(rightEar, earPaint);
  }

  void _drawEyebrows(Canvas canvas, Offset center, double radius) {
    final browPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final browLift = pose.eyebrowRaise * 14.0;
    final eyeDist = radius * 0.42;
    final browY = center.dy - radius * 0.35 - browLift;

    // Left eyebrow
    canvas.drawLine(
      Offset(center.dx - eyeDist - 22, browY + (pose.eyebrowRaise < 0 ? 4 : 0)),
      Offset(center.dx - eyeDist + 18, browY - (pose.eyebrowRaise < 0 ? 3 : 0)),
      browPaint,
    );

    // Right eyebrow
    canvas.drawLine(
      Offset(center.dx + eyeDist - 18, browY - (pose.eyebrowRaise < 0 ? 3 : 0)),
      Offset(center.dx + eyeDist + 22, browY + (pose.eyebrowRaise < 0 ? 4 : 0)),
      browPaint,
    );
  }

  void _drawEyes(Canvas canvas, Offset center, double radius) {
    final eyeDist = radius * 0.42;
    final eyeY = center.dy - radius * 0.12;
    final eyeRadius = radius * 0.22;

    _renderSingleEye(canvas, Offset(center.dx - eyeDist, eyeY), eyeRadius, pose.leftEyeBlink);
    _renderSingleEye(canvas, Offset(center.dx + eyeDist, eyeY), eyeRadius, pose.rightEyeBlink);
  }

  void _renderSingleEye(Canvas canvas, Offset eyeCenter, double eyeRadius, double blinkFactor) {
    canvas.save();
    canvas.clipRect(Rect.fromCenter(center: eyeCenter, width: eyeRadius * 2.4, height: eyeRadius * 2.2));

    // Eye background
    final scleraPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawOval(
      Rect.fromCenter(
        center: eyeCenter,
        width: eyeRadius * 1.8,
        height: eyeRadius * 1.9 * (1.0 - blinkFactor * 0.95),
      ),
      scleraPaint,
    );

    if (blinkFactor < 0.85) {
      // Iris & pupil with gaze tracking
      final gazeOffset = Offset(pose.eyeGazeX * 12.0, pose.eyeGazeY * 10.0);
      final irisCenter = eyeCenter + gazeOffset;

      final irisPaint = Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0052D4)],
        ).createShader(Rect.fromCircle(center: irisCenter, radius: eyeRadius * 0.65));

      canvas.drawCircle(irisCenter, eyeRadius * 0.65, irisPaint);

      // Pupil
      final pupilPaint = Paint()..color = const Color(0xFF050714);
      canvas.drawCircle(irisCenter, eyeRadius * 0.32, pupilPaint);

      // Specular highlight
      final highlightPaint = Paint()..color = Colors.white.withOpacity(0.85);
      canvas.drawCircle(irisCenter + const Offset(-4, -5), eyeRadius * 0.18, highlightPaint);
    } else {
      // Closed eye line
      final closedLinePaint = Paint()
        ..color = const Color(0xFF050714)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(eyeCenter.dx - eyeRadius * 0.8, eyeCenter.dy),
        Offset(eyeCenter.dx + eyeRadius * 0.8, eyeCenter.dy),
        closedLinePaint,
      );
    }

    canvas.restore();
  }

  void _drawVisemeMouth(Canvas canvas, Offset center, double radius) {
    final mouthCenter = Offset(center.dx, center.dy + radius * 0.42);
    final mouthOpen = pose.mouthOpen;
    final mouthWide = pose.mouthWide;

    final mouthPaint = Paint()
      ..color = const Color(0xFF881024)
      ..style = PaintingStyle.fill;

    final lipOutlinePaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final baseWidth = radius * 0.45 * (1.0 + mouthWide * 0.35);
    final openHeight = radius * 0.42 * mouthOpen;

    if (mouthOpen < 0.08) {
      // Closed resting mouth with smile curve
      final mouthPath = Path()
        ..moveTo(mouthCenter.dx - baseWidth / 2, mouthCenter.dy)
        ..quadraticBezierTo(
          mouthCenter.dx,
          mouthCenter.dy + (mouthWide > 0 ? 10.0 : 2.0),
          mouthCenter.dx + baseWidth / 2,
          mouthCenter.dy,
        );
      canvas.drawPath(mouthPath, lipOutlinePaint);
    } else {
      // Active Viseme Open Mouth
      final mouthRect = Rect.fromCenter(
        center: mouthCenter,
        width: baseWidth,
        height: math.max(6.0, openHeight),
      );

      // Mouth cavity
      canvas.drawRRect(RRect.fromRectAndRadius(mouthRect, const Radius.circular(16)), mouthPaint);

      // Teeth highlight
      if (pose.viseme == VisemeType.ee || pose.viseme == VisemeType.aa) {
        final teethPaint = Paint()..color = Colors.white.withOpacity(0.9);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(mouthRect.left + 6, mouthRect.top, mouthRect.width - 12, math.min(8.0, openHeight * 0.35)),
            const Radius.circular(4),
          ),
          teethPaint,
        );
      }

      // Outer lip stroke
      canvas.drawRRect(RRect.fromRectAndRadius(mouthRect, const Radius.circular(16)), lipOutlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant AvatarCanvasPainter oldDelegate) {
    return true; // Continuously animate at 60 FPS
  }
}

