import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Dimmed mask and corner brackets aligned to the viewfinder rect.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key, required this.viewfinderRect});

  final Rect viewfinderRect;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScannerOverlayPainter(viewfinderRect: viewfinderRect),
      size: Size.infinite,
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  ScannerOverlayPainter({required this.viewfinderRect});

  final Rect viewfinderRect;

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.62)
      ..style = PaintingStyle.fill;

    final hole = RRect.fromRectAndRadius(
      viewfinderRect,
      const Radius.circular(12),
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(hole),
      ),
      dimPaint,
    );

    final cornerPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLen = 28.0;
    final r = viewfinderRect;

    void corner(Offset start, Offset corner, Offset end) {
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(end.dx, end.dy),
        cornerPaint,
      );
    }

    corner(
      Offset(r.left, r.top + cornerLen),
      r.topLeft,
      Offset(r.left + cornerLen, r.top),
    );
    corner(
      Offset(r.right - cornerLen, r.top),
      r.topRight,
      Offset(r.right, r.top + cornerLen),
    );
    corner(
      Offset(r.left, r.bottom - cornerLen),
      r.bottomLeft,
      Offset(r.left + cornerLen, r.bottom),
    );
    corner(
      Offset(r.right - cornerLen, r.bottom),
      r.bottomRight,
      Offset(r.right, r.bottom - cornerLen),
    );

    // Subtle grid inside frame (document alignment).
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    final thirdW = r.width / 3;
    final thirdH = r.height / 3;
    for (var i = 1; i <= 2; i++) {
      canvas.drawLine(
        Offset(r.left + thirdW * i, r.top),
        Offset(r.left + thirdW * i, r.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(r.left, r.top + thirdH * i),
        Offset(r.right, r.top + thirdH * i),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.viewfinderRect != viewfinderRect;
  }
}
