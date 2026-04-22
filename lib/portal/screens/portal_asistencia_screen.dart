import 'package:flutter/material.dart';
import '../../sigma_theme.dart';
import '../widgets/portal_shell.dart';
import '../widgets/portal_widgets.dart';

class PortalAsistenciaScreen extends StatelessWidget {
  const PortalAsistenciaScreen({super.key});

  static const _present = {1, 2, 3, 7, 8, 9, 10, 13, 14, 15, 16, 17, 20, 22, 23, 24, 28, 29};
  static const _absent = {6};

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    final content = isDesktop ? _DesktopAsistencia() : _MobileAsistencia();
    return PortalShell(currentRoute: '/portal/asistencia', child: content);
  }
}

class _MobileAsistencia extends StatelessWidget {
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
            const Text('Asistencia — Abril 2026',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
            const SizedBox(height: 16),
            _StatRow(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SigmaColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: AttendanceCalendar(
                year: 2026, month: 4,
                presentDays: PortalAsistenciaScreen._present,
                absentDays: PortalAsistenciaScreen._absent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopAsistencia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigmaColors.surface,
      appBar: const PortalTopBar(title: 'Asistencia', subtitle: 'Abril 2026'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Abril 2026',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
            const SizedBox(height: 18),
            _StatRow(),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SigmaColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: AttendanceCalendar(
                year: 2026, month: 4,
                presentDays: PortalAsistenciaScreen._present,
                absentDays: PortalAsistenciaScreen._absent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: StatCard(label: 'Días presentes', value: '14', sub: 'Este mes', borderColor: SigmaColors.blue)),
        const SizedBox(width: 10),
        Expanded(child: StatCard(label: 'Días ausentes', value: '1', sub: 'Justificado', borderColor: SigmaColors.red)),
        const SizedBox(width: 10),
        Expanded(child: StatCard(label: '% Asistencia', value: '96%', sub: 'Acumulado', borderColor: SigmaColors.teal)),
      ],
    );
  }
}
