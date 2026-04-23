import 'package:flutter/material.dart';
import '../../sigma_theme.dart';
import '../widgets/portal_shell.dart';
import '../widgets/portal_widgets.dart';

const _subjects = [
  ('Matemáticas', 'Σ', 18.0, SigmaColors.blue),
  ('Español',     'A', 17.0, SigmaColors.teal),
  ('Ciencias',    '~', 19.0, SigmaColors.green),
  ('Historia',    'H', 16.0, SigmaColors.amber),
  ('Ed. Física',  '☉', 20.0, SigmaColors.red),
  ('Inglés',      'En', 18.0, SigmaColors.purple),
];

class PortalCalificacionesScreen extends StatelessWidget {
  const PortalCalificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    final content = isDesktop ? _DesktopCalificaciones() : _MobileCalificaciones();
    return PortalShell(currentRoute: '/portal/calificaciones', child: content);
  }
}

class _MobileCalificaciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calificaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
          const SizedBox(height: 14),
          // Summary hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SigmaColors.navy, Color(0xFF1A4080)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('Promedio general', style: TextStyle(color: Color(0xFF8BBCE0), fontSize: 12)),
                SizedBox(height: 4),
                Text('18.2', style: TextStyle(color: SigmaColors.snowWhite, fontSize: 40, fontWeight: FontWeight.w900)),
                Text('/20 · 1er Trimestre', style: TextStyle(color: Color(0xFF8BBCE0), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Subject list
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
    );
  }
}

class _DesktopCalificaciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calificaciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: StatCard(label: 'Promedio general', value: '18.0/20', sub: '1er Trimestre', borderColor: SigmaColors.blue)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'Materias aprobadas', value: '6 de 6', borderColor: SigmaColors.teal)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'Mejor materia', value: '20/20', sub: 'Ed. Física', borderColor: SigmaColors.red)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Desglose por materia',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: SigmaColors.textPrimary)),
          const SizedBox(height: 14),
          Container(
            //constraints: const BoxConstraints(maxWidth: 640),
            padding: const EdgeInsets.all(20),
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
        ],
      ),
    );
  }
}
