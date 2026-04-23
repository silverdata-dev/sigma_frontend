
// ── Shared widgets ────────────────────────────────────────────────────────────
import 'package:flutter/cupertino.dart';

import '../../../sigma_theme.dart';
import '../portal_widgets.dart';

class StudentHeroCard extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SigmaColors.navy, Color(0xFF1A4080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          LetterAvatar(letter: 'A', color: SigmaColors.teal, size: 46),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ana Martínez', style: TextStyle(color: SigmaColors.snowWhite, fontWeight: FontWeight.w800, fontSize: 16)),
                Text('3er Grado · Sección A', style: TextStyle(color: Color(0xFF8BBCE0), fontSize: 12)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('96%', style: TextStyle(color: SigmaColors.teal, fontWeight: FontWeight.w900, fontSize: 22)),
              Text('Asistencia', style: TextStyle(color: Color(0xFF8BBCE0), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}