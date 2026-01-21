import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class RouletteWheel extends StatefulWidget {
  final List<String> items;
  final bool isSpinning;
  final int? winnerIndex;
  final VoidCallback? onAnimationEnd;

  const RouletteWheel({
    super.key,
    required this.items,
    this.isSpinning = false,
    this.winnerIndex,
    this.onAnimationEnd,
  });

  @override
  State<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends State<RouletteWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _currentAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
  }

  @override
  void didUpdateWidget(RouletteWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _spin();
    }
  }

  void _spin() {
    if (widget.items.isEmpty) return;

    // Calculate target angle based on winner index
    // The pointer is usually at top (3*pi/2) or right (0). Let's assume pointer is at Top.
    // Angle per item = 2*pi / count.
    
    // We want to land such that the winner index slice is at -pi/2 (top).
    // But we are rotating the Wheel.
    
    final count = widget.items.length;
    final sliceAngle = 2 * pi / count;
    final winnerIndex = widget.winnerIndex ?? 0;
    
    // Random extra rotations (e.g. 5 to 10 full spins)
    final extraSpins = 5 + Random().nextInt(5);
    
    // Calculate the angle to align the winner slice to top
    // Slice 0 starts at 0 (Right). Slice i starts at i * sliceAngle.
    // Center of Slice i is at i*sliceAngle + sliceAngle/2.
    // To bring Center of Slice i to Top (-pi/2 or 3pi/2):
    // TargetRotation = - (CenterAngle_i) + TopPosition
    // Actually easier: We want final rotation + CenterAngle_i = TopPosition modulo 2pi.
    
    // Let's keep it simple.
    // If we rotate CLOCKWISE.
    // Final Angle of wheel = Target.
    
    // Let's randomize the final stopping point within the slice for realism?
    // For now, center of slice.
    
    final itemCenterAngle = (winnerIndex * sliceAngle) + (sliceAngle / 2);
    // We want (itemCenterAngle + rotation) % 2pi = 3*pi/2 (270 deg, Top)
    // So rotation = 3*pi/2 - itemCenterAngle.
    
    double targetAngleBase = (3 * pi / 2) - itemCenterAngle;
    
    // Add full spins
    double targetAngle = targetAngleBase + (2 * pi * extraSpins);
    
    // We need to animate from _currentAngle to targetAngle.
    // Ensure we always spin forward.
    if (targetAngle < _currentAngle) {
        // Add enough 2pi to make it forward
        final diff = _currentAngle - targetAngle;
        final turnsNeeded = (diff / (2 * pi)).ceil();
        targetAngle += (turnsNeeded + extraSpins) * 2 * pi;
    }

    _controller.duration = const Duration(seconds: 4); // Fixed duration for now
    
    final startAngle = _currentAngle;
    
    final curve = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
    
    Animation<double> animation = Tween<double>(begin: startAngle, end: targetAngle).animate(curve);
    
    animation.addListener(() {
      setState(() {
        _currentAngle = animation.value;
      });
    });
    
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
         _currentAngle = _currentAngle % (2 * pi); // Normalize after spin
         widget.onAnimationEnd?.call();
      }
    });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text(
          'Add items to spin!',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // The Wheel
        Transform.rotate(
          angle: _currentAngle,
          child: CustomPaint(
            size: const Size(380, 380),
            painter: _WheelPainter(items: widget.items),
          ),
        ),
        // The Pointer (Triangle at top)
        Container(
          margin: const EdgeInsets.only(top: 0), // Overlap slightly
          child: CustomPaint(
            size: const Size(20, 30),
            painter: _PointerPainter(),
          ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> items;
  _WheelPainter({required this.items});

  final List<Color> colors = [
    AppColors.neonCyan,
    AppColors.neonPurple,
    AppColors.neonGreen,
    AppColors.neonPink,
    const Color(0xFFFFD740), // Amber
    const Color(0xFFFF6E40), // Deep Orange
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final count = items.length;
    final sweepAngle = 2 * pi / count;
    
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < count; i++) {
      paint.color = colors[i % colors.length];
      
      // Draw Slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle,
        sweepAngle,
        true,
        paint,
      );
      
      // Draw Text
      // Calculate position at middle of slice, slightly inwards
      final angle = (i * sweepAngle) + (sweepAngle / 2);
      final dist = radius * 0.7;
      final x = center.dx + dist * cos(angle);
      final y = center.dy + dist * sin(angle);
      
      final itemText = items[i];
      // Truncate if too long (simple logic)
      final text = itemText.length > 12 ? '${itemText.substring(0, 10)}...' : itemText;

      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.bg, // Contrast against bright neon
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
      
      // Rotate canvas for text? Or just place it.
      // Rotation makes it readable from center outwards.
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi); // Align text radiating out? Or +pi to read inwards?
      // Let's align radiating OUT from center.
      // angle points from center to text pos.
      // + pi makes text 'bottom' point to center.
      // 0 rotation would be horizontal.
      
      // Actually standard is to read like clock numbers? No, usually radial.
      // Let's try simple centering first.
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
    
    // Draw Border
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, borderPaint);
    
    // Draw Center Hub
    paint.color = AppColors.panel;
    canvas.drawCircle(center, radius * 0.1, paint);
    canvas.drawCircle(center, radius * 0.1, borderPaint);
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => oldDelegate.items != items;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.text
      ..style = PaintingStyle.fill;
      
      // Upside down triangle at top center
      final path = Path();
      path.moveTo(size.width / 2, size.height); // Tip down
      path.lineTo(size.width, 0); // Top Right
      path.lineTo(0, 0); // Top Left
      path.close();
      
      canvas.drawPath(path, paint);
      
       final borderPaint = Paint()
      ..color = AppColors.bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
