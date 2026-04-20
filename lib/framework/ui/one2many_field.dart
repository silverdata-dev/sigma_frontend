import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'rel_many2one_field.dart';

/// Campo One2Many: lista de Subjects relacionados con el sujeto actual.
/// Soporta agregar (buscando o creando), editar y eliminar registros vinculados.
class FrameworkRelOne2Many extends StatefulWidget {
  /// ID de la entidad padre (si es 'new' o null, muestra aviso hasta guardar).
  final String? entityId;
  final String? label;

  // Endpoint del vínculo (ej: 'subject-relaciones')
  final String linkEndpoint;

  // Campo FK que apunta al padre (ej: 'sujeto_a_id')
  final String linkForeignKey;

  // Campo FK que apunta al relacionado (ej: 'sujeto_b_id')
  final String linkRelatedKey;

  // Valor fijo para el campo 'tipo' al crear el vínculo (ej: 'representante')
  final String? linkTipo;

  // Endpoint del Subject relacionado (ej: 'subjects')
  final String relatedEndpoint;

  // Campos a mostrar en la lista (del response del linkEndpoint)
  final List<String> linkDisplayFields;

  // Campos a mostrar en el diálogo de búsqueda (del relatedEndpoint)
  final List<String> relatedDisplayFields;

  // Filtro adicional para el diálogo de búsqueda
  final Map<String, String>? relatedFilter;

  // Schema del formulario inline del Subject relacionado
  final List<Map<String, dynamic>> relatedSchema;

  // Extra data que se aplica al crear un Subject nuevo (ej: {'metadata_json.rol': 'Representante'})
  final Map<String, dynamic>? createExtraData;

  const FrameworkRelOne2Many({
    super.key,
    this.entityId,
    this.label,
    required this.linkEndpoint,
    required this.linkForeignKey,
    required this.linkRelatedKey,
    this.linkTipo,
    required this.relatedEndpoint,
    this.linkDisplayFields = const ['name'],
    this.relatedDisplayFields = const ['name'],
    this.relatedFilter,
    this.relatedSchema = const [],
    this.createExtraData,
  });

  @override
  State<FrameworkRelOne2Many> createState() => _FrameworkRelOne2ManyState();
}

class _FrameworkRelOne2ManyState extends State<FrameworkRelOne2Many> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = false;

  bool get _isNew =>
      widget.entityId == null ||
      widget.entityId!.isEmpty ||
      widget.entityId == 'new';

  @override
  void initState() {
    super.initState();
    if (!_isNew) _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _loading = true);
    try {
      final params = <String, String>{
        widget.linkForeignKey: widget.entityId!,
        if (widget.linkTipo != null) 'tipo': widget.linkTipo!,
      };
      final uri = Uri.parse('$kRelBaseUrl/${widget.linkEndpoint}/')
          .replace(queryParameters: params);
      final res = await http.get(uri);
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _records = (json.decode(res.body) as List)
              .cast<Map<String, dynamic>>();
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addRecord() async {
    // Muestra diálogo de búsqueda: seleccionar existente o crear nuevo
    final selected = await showRelSearchDialog(
      context,
      endpoint: widget.relatedEndpoint,
      filter: widget.relatedFilter,
      displayFields: widget.relatedDisplayFields,
      createSchema:
          widget.relatedSchema.isNotEmpty ? widget.relatedSchema : null,
      createExtraData: widget.createExtraData,
    );
    if (selected == null || !mounted) return;

    final relatedId = selected['id']?.toString();
    if (relatedId == null) return;

    // Crea el vínculo
    final body = <String, dynamic>{
      widget.linkForeignKey: widget.entityId,
      widget.linkRelatedKey: relatedId,
      if (widget.linkTipo != null) 'tipo': widget.linkTipo,
    };
    try {
      final res = await http.post(
        Uri.parse('$kRelBaseUrl/${widget.linkEndpoint}/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        await _loadRecords();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al vincular: ${res.body}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _editRecord(Map<String, dynamic> linkRecord) async {
    final relatedId = linkRecord[widget.linkRelatedKey]?.toString();
    if (relatedId == null) return;
    await showRelFormDialog(
      context,
      endpoint: widget.relatedEndpoint,
      entityId: relatedId,
      schema: widget.relatedSchema,
      extraData: widget.createExtraData,
    );
    await _loadRecords();
  }

  Future<void> _deleteRecord(Map<String, dynamic> linkRecord) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Quitar este vínculo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quitar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final linkId = linkRecord['id']?.toString();
    if (linkId == null) return;

    try {
      final res = await http
          .delete(Uri.parse('$kRelBaseUrl/${widget.linkEndpoint}/$linkId'));
      if (res.statusCode == 200 && mounted) {
        await _loadRecords();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                widget.label!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _isNew
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Guarda primero para gestionar registros vinculados.',
                      style: TextStyle(
                          color: theme.hintColor,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                : Column(
                    children: [
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_records.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Sin registros vinculados.',
                            style: TextStyle(color: theme.hintColor),
                          ),
                        )
                      else
                        ..._records.map(
                          (rec) => _LinkTile(
                            record: rec,
                            displayFields: widget.linkDisplayFields,
                            onEdit: () => _editRecord(rec),
                            onDelete: () => _deleteRecord(rec),
                          ),
                        ),
                      const Divider(height: 1),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: TextButton.icon(
                            onPressed: _addRecord,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agregar'),
                            style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final Map<String, dynamic> record;
  final List<String> displayFields;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LinkTile({
    required this.record,
    required this.displayFields,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final display = relDisplayName(record, displayFields);
    return ListTile(
      dense: true,
      title: Text(display.isEmpty ? '(sin datos)' : display),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Quitar vínculo',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
