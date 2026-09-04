import 'dart:math';
import 'package:flutter/material.dart';

// Asli ghadi jaisi dial: beech mein ek pin (center dot), do hands
// (chhota = hours, lamba = minutes). User jis hand ke pass drag kare,
// wahi hand ghoomegi. Total time = hours*60 + minutes.
class CircularDurationPicker extends StatefulWidget {
  final int totalMinutes; // abhi set kiya hua total time
  final bool enabled; // false = drag disabled (jab session chal raha ho)
  final ValueChanged<int> onMinutesSelected; // naya total minutes wapas bhejta hai
  final String centerLabel;

  const CircularDurationPicker({
    super.key,
    required this.totalMinutes,
    required this.enabled,
    required this.onMinutesSelected,
    required this.centerLabel,
  });

  @override
  State<CircularDurationPicker> createState() =>
      _CircularDurationPickerState();
}

enum _DraggingHand { none, hour, minute }

class _CircularDurationPickerState extends State<CircularDurationPicker> {
_DraggingHand _dragging = _DraggingHand.none;

int get _hours => widget.totalMinutes ~/ 60;
int get _minutes => widget.totalMinutes % 60;

void _handlePanStart(Offset localPosition, Size size) {
if (!widget.enabled) return;

final center = Offset(size.width / 2, size.height / 2);
final radius = min(size.width, size.height) / 2 - 30;

final hourHandLen = radius * 0.5;
final minuteHandLen = radius * 0.85;

final hourAngle = _angleForHour(_hours % 12);
final minuteAngle = _angleForMinute(_minutes);

final hourHandTip = center + Offset(cos(hourAngle), sin(hourAngle)) * hourHandLen;
final minuteHandTip =
center + Offset(cos(minuteAngle), sin(minuteAngle)) * minuteHandLen;

final distToHour = (localPosition - hourHandTip).distance;
final distToMinute = (localPosition - minuteHandTip).distance;

// Jis hand ki tip ke zyada pass tap/drag hua, wahi hand pakdo
if (distToHour < distToMinute) {
setState(() => _dragging = _DraggingHand.hour);
} else {
setState(() => _dragging = _DraggingHand.minute);
}
_handlePanUpdate(localPosition, size);
}

void _handlePanUpdate(Offset localPosition, Size size) {
if (!widget.enabled || _dragging == _DraggingHand.none) return;

final center = Offset(size.width / 2, size.height / 2);
final dx = localPosition.dx - center.dx;
final dy = localPosition.dy - center.dy;

double angle = atan2(dy, dx) + pi / 2;
if (angle < 0) angle += 2 * pi;
final fraction = angle / (2 * pi);

if (_dragging == _DraggingHand.hour) {
// Poora chakkar = 12 hours
int newHour = (fraction * 12).round() % 12;
final newTotal = newHour * 60 + _minutes;
widget.onMinutesSelected(newTotal == 0 ? 1 : newTotal);
} else if (_dragging == _DraggingHand.minute) {
// Poora chakkar = 60 minutes
int newMinute = (fraction * 60).round() % 60;
final newTotal = _hours * 60 + newMinute;
widget.onMinutesSelected(newTotal == 0 ? 1 : newTotal);
}
}

void _handlePanEnd() {
setState(() => _dragging = _DraggingHand.none);
}

double _angleForHour(int hour) => -pi / 2 + (2 * pi / 12) * hour;
double _angleForMinute(int minute) => -pi / 2 + (2 * pi / 60) * minute;

@override
Widget build(BuildContext context) {
return LayoutBuilder(
builder: (context, constraints) {
final size = Size(
constraints.maxWidth.isFinite ? constraints.maxWidth : 260,
constraints.maxHeight.isFinite ? constraints.maxHeight : 260,
);

return GestureDetector(
onPanStart: (details) => _handlePanStart(details.localPosition, size),
onPanUpdate: (details) => _handlePanUpdate(details.localPosition, size),
onPanEnd: (_) => _handlePanEnd(),
child: CustomPaint(
size: size,
painter: _ClockPainter(
hours: _hours % 12,
minutes: _minutes,
enabled: widget.enabled,
),
/*
    child: Center(
      child: Text(
        widget.centerLabel,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
            ),
    ),
  ),

     */
/*
  child: CustomPaint(
size: size,
  painter: _ClockPainter(
    hours: _hours % 12,
    minutes: _minutes,
    enabled: widget.enabled,
  ),
  child: Center(
    child: Text(
      widget.centerLabel,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
  ),


 */
),


);
},
);
}
}

class _ClockPainter extends CustomPainter {
final int hours;
final int minutes;
final bool enabled;

_ClockPainter({
required this.hours,
required this.minutes,
required this.enabled,
});

@override
void paint(Canvas canvas, Size size) {
final center = Offset(size.width / 2, size.height / 2);
final radius = min(size.width, size.height) / 2 - 30;

// Clock face (safed circle + border)
final facePaint = Paint()..color = Colors.white;
final borderPaint = Paint()
..color = Colors.grey.shade300
..style = PaintingStyle.stroke
..strokeWidth = 2;
canvas.drawCircle(center, radius + 20, facePaint);
canvas.drawCircle(center, radius + 20, borderPaint);

// 1 se 12 tak numbers
for (int i = 1; i <= 12; i++) {
final angle = -pi / 2 + (2 * pi / 12) * i;
final pos = center + Offset(cos(angle), sin(angle)) * (radius + 2);

final textPainter = TextPainter(
text: TextSpan(
text: '$i',
style: TextStyle(
color: Colors.grey.shade700,
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
textDirection: TextDirection.ltr,
)..layout();

textPainter.paint(
canvas,
pos - Offset(textPainter.width / 2, textPainter.height / 2),
);
}

// Small tick marks (minute ke liye 60 chhoti lines)
for (int i = 0; i < 60; i++) {
final angle = -pi / 2 + (2 * pi / 60) * i;
final isHourTick = i % 5 == 0;
final outer = center + Offset(cos(angle), sin(angle)) * (radius + 16);
final inner = center +
Offset(cos(angle), sin(angle)) * (radius + (isHourTick ? 10 : 13));
canvas.drawLine(
inner,
outer,
Paint()
..color = Colors.grey.shade400
..strokeWidth = isHourTick ? 2 : 1,
);
}

final handColor = enabled ? Colors.blue : Colors.blue.withOpacity(0.5);

// ---- Hour hand (chhoti, mota) ----
final hourAngle = -pi / 2 + (2 * pi / 12) * hours + (2 * pi / 12) * (minutes / 60);
final hourHandLen = radius * 0.5;
final hourTip = center + Offset(cos(hourAngle), sin(hourAngle)) * hourHandLen;
canvas.drawLine(
center,
hourTip,
Paint()
..color = handColor
..strokeWidth = 6
..strokeCap = StrokeCap.round,
);

// ---- Minute hand (lambi, patli) ----
final minuteAngle = -pi / 2 + (2 * pi / 60) * minutes;
final minuteHandLen = radius * 0.85;
final minuteTip = center + Offset(cos(minuteAngle), sin(minuteAngle)) * minuteHandLen;
canvas.drawLine(
center,
minuteTip,
Paint()
..color = handColor
..strokeWidth = 4
..strokeCap = StrokeCap.round,
);

// ---- Hands ke sirf pe pin (handle) dikhana, drag karne mein aasani ke liye ----
canvas.drawCircle(hourTip, 9, Paint()..color = Colors.white);
canvas.drawCircle(
hourTip,
9,
Paint()
..color = handColor
..style = PaintingStyle.stroke
..strokeWidth = 3,
);
  canvas.drawCircle(minuteTip, 9, Paint()..color = Colors.white);
  canvas.drawCircle(
    minuteTip,
    9,
    Paint()
      ..color = handColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );

  // ---- Center pin (beech ka gol dot, jahan dono hands milti hain) ----
  canvas.drawCircle(center, 7, Paint()..color = handColor);
  canvas.drawCircle(center, 7, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
}

@override
bool shouldRepaint(covariant _ClockPainter oldDelegate) {
  return oldDelegate.hours != hours ||
      oldDelegate.minutes != minutes ||
      oldDelegate.enabled != enabled;
}
}
