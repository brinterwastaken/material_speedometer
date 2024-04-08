import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpeedDial extends StatefulWidget {
  final ColorScheme colorScheme;
  final int maxSpeed;
  final int newSpeed;
  final int oldSpeed;
  final bool active;
  final int diameter;
  final String unit;
  final AnimationController controller;

  const SpeedDial(
      {super.key,
      required this.colorScheme,
      required this.maxSpeed,
      required this.newSpeed,
      required this.oldSpeed,
      required this.controller,
      required this.active,
      required this.diameter,
      required this.unit});

  @override
  State<SpeedDial> createState() => _SpeedDialState();
}

class _SpeedDialState extends State<SpeedDial>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CustomPaint(
          painter: DialPainter(
              widget.active
                  ? widget.colorScheme.primary
                  : widget.colorScheme.primary.withOpacity(0.5),
              widget.active
                  ? widget.colorScheme.surfaceVariant
                  : widget.colorScheme.surfaceVariant.withOpacity(0.5),
              widget.active
                  ? widget.colorScheme.onSurface
                  : widget.colorScheme.onSurface.withOpacity(0.5),
              widget.maxSpeed,
              widget.controller.value * 100,
          widget.active),
          size: Size.fromWidth(widget.diameter.toDouble()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${widget.newSpeed}',
              style: widget.active
                  ? Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: widget.colorScheme.primary)
                  : Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: widget.colorScheme.primary.withOpacity(0.5)),
            ),
            const SizedBox(width: 5),
            Text(
              widget.unit,
              style: widget.active
                  ? Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: widget.colorScheme.onSurface)
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: widget.colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        )
      ],
    );
  }
}

class DialPainter extends CustomPainter {
  final Color highlightColor;
  final Color slotColor;
  final Color textColor;
  final double percent;
  final int maxSpeed;
  final bool isActive;
  DialPainter(this.highlightColor, this.slotColor, this.textColor, this.maxSpeed, this.percent, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {

    Rect drawingRect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2);

    final Paint highlightPaint = Paint();
    highlightPaint.color = highlightColor;
    highlightPaint.style = PaintingStyle.stroke;
    highlightPaint.strokeCap = StrokeCap.round;
    highlightPaint.strokeWidth = 15;

    final Paint slotPaint = Paint();
    slotPaint.color = slotColor;
    slotPaint.style = PaintingStyle.stroke;
    slotPaint.strokeCap = StrokeCap.round;
    slotPaint.strokeWidth = 20;

    final Paint dotPaint = Paint();
    dotPaint.color = highlightColor;
    dotPaint.style = PaintingStyle.fill;

    canvas.drawArc(drawingRect, 135 * math.pi / 180, 270 * math.pi / 180, false,
        slotPaint);

    canvas.drawArc(drawingRect, 135 * math.pi / 180,
        percent / 100 * 270 * math.pi / 180, false, highlightPaint);

    final double centerX = (size.width + 30) / 2;
    final double centerY = (size.height + 30) / 2;
    final int dotCount = 11;
    final double radiantStep = 1.5 * math.pi/(dotCount -1);
    final outerRad = size.width / 2 - 20;
    final textRad = size.width / 2 - 40;

    for (int i = 0; i < dotCount; i++) {
      canvas.drawCircle(
        Offset(centerX + math.cos(math.pi * 3/4 + i * radiantStep) * outerRad - 15,
            centerY + math.sin(math.pi * 3/4 + i * radiantStep) * outerRad - 15),
        3,
        dotPaint,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(i * maxSpeed/(dotCount -1)).round()}',
          style: TextStyle(
            color: textColor,
          )
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(canvas, Offset(centerX + math.cos(math.pi * 3/4 + i * radiantStep) * textRad - 15 - textPainter.width/2,
          centerY + math.sin(math.pi * 3/4 + i * radiantStep) * textRad - 15 - textPainter.height/2),);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
