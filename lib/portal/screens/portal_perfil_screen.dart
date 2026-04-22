import 'package:flutter/material.dart';
import '../../sigma_theme.dart';
import '../widgets/portal_shell.dart';
import '../widgets/portal_widgets.dart';

class PortalPerfilScreen extends StatelessWidget {
  const PortalPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    final content = isDesktop ? _DesktopPerfil() : _MobilePerfil();
    return PortalShell(currentRoute: '/portal/perfil', child: content);
  }
}

class _StudentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          LetterAvatar(letter: 'A', color: SigmaColors.teal, size: 54),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ana Martínez', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
                Text('3er Grado · Sección A', style: TextStyle(fontSize: 12, color: SigmaColors.textSub)),
                Text('U.E. San Ignacio', style: TextStyle(fontSize: 12, color: SigmaColors.textSub)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('96%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: SigmaColors.blue)),
              Text('Asistencia', style: TextStyle(fontSize: 10, color: SigmaColors.textSub)),
              SizedBox(height: 4),
              Text('18.2', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: SigmaColors.teal)),
              Text('Promedio', style: TextStyle(fontSize: 10, color: SigmaColors.textSub)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RepresentanteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Nombre',       'Carlos Martínez'),
      ('Institución',  'U.E. San Ignacio'),
      ('Año escolar',  '2025–2026'),
      ('Correo',       'c.martinez@email.com'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Representante',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SigmaColors.textPrimary)),
          const SizedBox(height: 12),
          ...rows.map((r) => _InfoRow(label: r.$1, value: r.$2)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: SigmaColors.textSub)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SigmaColors.textPrimary),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _MobilePerfil extends StatelessWidget {
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
            const Text('Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SigmaColors.textPrimary)),
            const SizedBox(height: 14),
            _StudentCard(),
            const SizedBox(height: 16),
            _RepresentanteCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DesktopPerfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigmaColors.surface,
      appBar: const PortalTopBar(title: 'Perfil', subtitle: 'Abril 2026'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StudentCard(),
              const SizedBox(height: 20),
              _RepresentanteCard(),
            ],
          ),
        ),
      ),
    );
  }
}
