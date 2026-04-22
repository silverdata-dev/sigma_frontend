import 'package:flutter/material.dart';
import '../../sigma_theme.dart';

// ── StatCard ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color borderColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigmaColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: borderColor, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: SigmaColors.textSub, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
          if (sub != null)
            Text(sub!, style: const TextStyle(fontSize: 11, color: SigmaColors.textSub)),
        ],
      ),
    );
  }
}

// ── LetterAvatar ─────────────────────────────────────────────────────────────
class LetterAvatar extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;

  const LetterAvatar({super.key, required this.letter, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

// ── SubjectRow ───────────────────────────────────────────────────────────────
class SubjectRow extends StatelessWidget {
  final String name;
  final String initial;
  final double score;
  final double maxScore;
  final Color color;

  const SubjectRow({
    super.key,
    required this.name,
    required this.initial,
    required this.score,
    required this.maxScore,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          LetterAvatar(letter: initial, color: color, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / maxScore,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${score.toStringAsFixed(0)}/${maxScore.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SigmaColors.textSub),
          ),
        ],
      ),
    );
  }
}

// ── WeeklyBarChart ───────────────────────────────────────────────────────────
class WeeklyBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;

  const WeeklyBarChart({super.key, required this.values, required this.labels, this.color = SigmaColors.teal});

  @override
  Widget build(BuildContext context) {
    final maxVal = values.fold(0.0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final ratio = maxVal > 0 ? values[i] / maxVal : 0.0;
          final isLast = i == values.length - 1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(values[i] * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 9, color: SigmaColors.textSub),
                  ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: 70 * ratio,
                    decoration: BoxDecoration(
                      color: isLast ? color : color.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i], style: const TextStyle(fontSize: 9, color: SigmaColors.textSub)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── AttendanceCalendar ───────────────────────────────────────────────────────
class AttendanceCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Set<int> presentDays;
  final Set<int> absentDays;

  const AttendanceCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.presentDays,
    required this.absentDays,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // 0=Mon…6=Sun → shift to Sun=0
    int startWeekday = firstDay.weekday % 7;

    const headers = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];
    final cells = <Widget>[];

    for (final h in headers) {
      cells.add(Center(
        child: Text(h, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SigmaColors.textSub)),
      ));
    }

    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final dow = DateTime(year, month, d).weekday % 7;
      final isWeekend = dow == 0 || dow == 6;
      final isPresent = presentDays.contains(d);
      final isAbsent = absentDays.contains(d);

      Color? bg;
      Color textColor = SigmaColors.textPrimary;

      if (isAbsent) {
        bg = SigmaColors.red.withValues(alpha: 0.18);
        textColor = SigmaColors.red;
      } else if (isPresent) {
        bg = SigmaColors.teal.withValues(alpha: 0.2);
        textColor = SigmaColors.teal;
      } else if (isWeekend) {
        textColor = SigmaColors.textSub;
      }

      cells.add(
        Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$d',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: cells,
    );
  }
}

// ── MessageItem ──────────────────────────────────────────────────────────────
class MessageItem extends StatelessWidget {
  final String sender;
  final String preview;
  final String time;
  final bool unread;
  final Color avatarColor;

  const MessageItem({
    super.key,
    required this.sender,
    required this.preview,
    required this.time,
    this.unread = false,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          LetterAvatar(letter: sender[0], color: avatarColor, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(preview, style: const TextStyle(fontSize: 12, color: SigmaColors.textSub)),
                if (unread) ...[
                  const SizedBox(height: 4),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: SigmaColors.teal, shape: BoxShape.circle)),
                ],
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: SigmaColors.textSub)),
        ],
      ),
    );
  }
}

// ── SigmaLogo (SVG widget usando flutter_svg) ─────────────────────────────────
class SigmaLogo extends StatelessWidget {
  final double size;
  const SigmaLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    // Renderiza el SVG directamente como widget
    try {
      // ignore: avoid_dynamic_calls
      return _SvgLogo(size: size);
    } catch (_) {
      return _FallbackLogo(size: size);
    }
  }
}

class _SvgLogo extends StatelessWidget {
  final double size;
  const _SvgLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.24,
      child: CustomPaint(painter: _SigmaIconPainter()),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  final double size;
  const _FallbackLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: SigmaColors.navy, borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text('Σ', style: TextStyle(color: Colors.white, fontSize: size * 0.5, fontWeight: FontWeight.w900)),
    );
  }
}

// CustomPainter que reproduce el ícono SVG de Sigma
class _SigmaIconPainter extends CustomPainter {
  static const _colors = [
    SigmaColors.blue, SigmaColors.teal, SigmaColors.amber,
    SigmaColors.red, SigmaColors.purple, SigmaColors.green,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 124;

    Offset p(double x, double y) => Offset(x * scaleX, y * scaleY);

    // Nodos periféricos (posiciones del SVG original)
    final nodes = [
      p(50, 10), p(76, 25), p(76, 55),
      p(50, 70), p(24, 55), p(24, 25),
    ];
    final center = p(50, 40);

    // Líneas desde centro a nodos
    for (int i = 0; i < nodes.length; i++) {
      final paint = Paint()
        ..color = _colors[i].withValues(alpha: 0.45)
        ..strokeWidth = 1.5 * scaleX
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, nodes[i], paint);
    }

    // Nodos periféricos: halo + círculo de color
    for (int i = 0; i < nodes.length; i++) {
      final r = 5.0 * scaleX;
      canvas.drawCircle(nodes[i], r * 1.8, Paint()..color = _colors[i].withValues(alpha: 0.12));
      canvas.drawCircle(nodes[i], r, Paint()..color = _colors[i]);
      canvas.drawCircle(
        Offset(nodes[i].dx - r * 0.28, nodes[i].dy - r * 0.28),
        r * 0.32,
        Paint()..color = Colors.white.withValues(alpha: 0.45),
      );
    }

    // Nodo central
    final cr = 11.5 * scaleX;
    canvas.drawCircle(center, cr * 1.17, Paint()..color = SigmaColors.navy.withValues(alpha: 0.08));
    canvas.drawCircle(center, cr, Paint()..color = SigmaColors.navy);
    canvas.drawCircle(
      Offset(center.dx - cr * 0.35, center.dy - cr * 0.35),
      cr * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );

    // Sigma (Σ) en el centro
    final tp = TextPainter(
      text: TextSpan(
        text: 'Σ',
        style: TextStyle(
          color: SigmaColors.snowWhite,
          fontSize: 13 * scaleX,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2 + scaleY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
