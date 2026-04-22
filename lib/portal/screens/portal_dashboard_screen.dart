import 'package:flutter/material.dart';
import '../../sigma_theme.dart';
import '../widgets/portal_shell.dart';
import '../widgets/portal_widgets.dart';

class PortalDashboardScreen extends StatelessWidget {
  const PortalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;

    final content = isDesktop
        ? _DesktopDashboard()
        : _MobileDashboard();

    return PortalShell(
      currentRoute: '/portal',
      child: content,
    );
  }
}

// ── Datos de ejemplo ──────────────────────────────────────────────────────────
final _weeklyAttendance = [0.88, 0.93, 0.88, 0.78, 0.92, 0.92, 0.95];
final _weekLabels = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'];

final _subjects = [
  ('Matemáticas', 'Σ', 18.0, SigmaColors.blue),
  ('Español',     'A', 17.0, SigmaColors.teal),
  ('Ciencias',    '~', 19.0, SigmaColors.green),
];

final _messages = [
  ('Prof. Rodríguez', 'Evaluación próxima semana', 'Hoy 9:30', true, SigmaColors.blue),
  ('Coordinación',    'Reunión de representantes', 'Ayer 14:00', true, SigmaColors.teal),
];

// ── Mobile ────────────────────────────────────────────────────────────────────
class _MobileDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PortalMobileAppBar(),
      backgroundColor: SigmaColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            _StudentHeroCard(),
            const SizedBox(height: 16),
            // Stat cards
            _StatRow(compact: true),
            const SizedBox(height: 20),
            // Asistencia semanal
            _SectionTitle('Asistencia semanal'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SigmaColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: WeeklyBarChart(values: _weeklyAttendance, labels: _weekLabels),
            ),
            const SizedBox(height: 20),
            // Últimas notas
            _SectionTitle('Últimas notas'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SigmaColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: Column(
                children: _subjects.map((s) => SubjectRow(
                  name: s.$1, initial: s.$2, score: s.$3, maxScore: 20, color: s.$4,
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Desktop ───────────────────────────────────────────────────────────────────
class _DesktopDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigmaColors.surface,
      appBar: const PortalTopBar(title: 'Dashboard', subtitle: 'Abril 2026'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buenos días, Carlos Martínez 🌅',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Aquí el resumen de Ana para hoy',
                style: TextStyle(fontSize: 14, color: SigmaColors.textSub)),
            const SizedBox(height: 22),
            _StatRow(compact: false),
            const SizedBox(height: 24),
            // Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SigmaColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Asistencia — Últimas 7 semanas'),
                  const SizedBox(height: 12),
                  WeeklyBarChart(values: _weeklyAttendance, labels: _weekLabels),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Bottom 2-col
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SigmaColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Calificaciones recientes'),
                        const SizedBox(height: 12),
                        ..._subjects.map((s) => SubjectRow(
                          name: s.$1, initial: s.$2, score: s.$3, maxScore: 20, color: s.$4,
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SigmaColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Comunicados'),
                        const SizedBox(height: 12),
                        ..._messages.map((m) => MessageItem(
                          sender: m.$1, preview: m.$2, time: m.$3,
                          unread: m.$4, avatarColor: m.$5,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _StudentHeroCard extends StatelessWidget {
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

class _StatRow extends StatelessWidget {
  final bool compact;
  const _StatRow({required this.compact});

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(label: 'Promedio', value: '18.2/20', sub: 'Todas las materias', borderColor: SigmaColors.blue),
      StatCard(label: 'Alertas', value: '2', sub: 'Pendientes', borderColor: SigmaColors.red),
      StatCard(label: 'Mensajes', value: '3', sub: 'Sin leer', borderColor: SigmaColors.teal),
    ];

    if (!compact) {
      // Desktop: 4 cards con asistencia incluida
      return Row(
        children: [
          Expanded(child: StatCard(label: 'Asistencia', value: '96%', sub: 'Este mes', borderColor: SigmaColors.teal)),
          const SizedBox(width: 12),
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
          const SizedBox(width: 12),
          Expanded(child: cards[2]),
        ],
      );
    }

    return Row(
      children: cards.expand((c) => [Expanded(child: c), const SizedBox(width: 10)]).toList()..removeLast(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SigmaColors.textPrimary));
  }
}
