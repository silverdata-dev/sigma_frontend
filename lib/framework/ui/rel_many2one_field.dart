import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/form_controller.dart';
import 'field_wrappers.dart';

const kRelBaseUrl = 'http://localhost:8000/api';

// ── Shared helpers ────────────────────────────────────────────────────────────

/// Filtra un registro por un mapa de condiciones con soporte de dot-notation.
bool relMatchesFilter(Map<String, dynamic> rec, Map<String, String>? filter) {
  if (filter == null) return true;
  for (final e in filter.entries) {
    dynamic v = rec;
    for (final part in e.key.split('.')) {
      v = (v is Map) ? v[part] : null;
    }
    if (v?.toString() != e.value) return false;
  }
  return true;
}

/// Genera la etiqueta de display para un registro usando los campos indicados.
String relDisplayName(Map<String, dynamic> rec, List<String> fields) =>
    fields.map((f) => rec[f]?.toString() ?? '').where((s) => s.isNotEmpty).join(' · ');

/// Construye un formulario simple con solo campos de tipo 'text'.
Widget buildRelSimpleForm(List<Map<String, dynamic>> schema, FormController ctrl) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: schema
        .where((f) => (f['type'] as String?) != 'one2many_relational')
        .map((f) => FrameworkTextField(
              fieldKey: f['key'] as String,
              controller: ctrl,
              label: f['label'] as String?,
            ))
        .toList(),
  );
}

// ── Diálogo de Crear / Editar ─────────────────────────────────────────────────

Future<Map<String, dynamic>?> showRelFormDialog(
  BuildContext context, {
  required String endpoint,
  String? entityId,
  required List<Map<String, dynamic>> schema,
  Map<String, dynamic>? extraData,
}) {
  return showDialog<Map<String, dynamic>?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _RelFormDialog(
      endpoint: endpoint,
      entityId: entityId,
      schema: schema,
      extraData: extraData,
    ),
  );
}

class _RelFormDialog extends StatefulWidget {
  final String endpoint;
  final String? entityId;
  final List<Map<String, dynamic>> schema;
  final Map<String, dynamic>? extraData;

  const _RelFormDialog({
    required this.endpoint,
    this.entityId,
    required this.schema,
    this.extraData,
  });

  @override
  State<_RelFormDialog> createState() => _RelFormDialogState();
}

class _RelFormDialogState extends State<_RelFormDialog> {
  late final FormController _ctrl = FormController();
  bool _loading = false;
  bool _saving = false;

  bool get _isNew =>
      widget.entityId == null || widget.entityId!.isEmpty;

  @override
  void initState() {
    super.initState();
    if (!_isNew) _loadRecord();
  }

  Future<void> _loadRecord() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(
          Uri.parse('$kRelBaseUrl/${widget.endpoint}/${widget.entityId}'));
      if (res.statusCode == 200 && mounted) {
        (json.decode(res.body) as Map<String, dynamic>)
            .forEach(_ctrl.updateField);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final data = Map<String, dynamic>.from(_ctrl.data);
      // Aplicar extraData con soporte de dot-notation
      widget.extraData?.forEach((k, v) {
        if (k.contains('.')) {
          final parts = k.split('.');
          data[parts[0]] ??= <String, dynamic>{};
          (data[parts[0]] as Map)[parts[1]] = v;
        } else {
          data[k] = v;
        }
      });

      final http.Response res;
      if (_isNew) {
        res = await http.post(
          Uri.parse('$kRelBaseUrl/${widget.endpoint}/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
      } else {
        res = await http.put(
          Uri.parse('$kRelBaseUrl/${widget.endpoint}/${widget.entityId}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
      }

      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.of(context).pop(json.decode(res.body));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${res.statusCode}: ${res.body}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isNew ? 'Crear registro' : 'Editar registro'),
      content: _loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: SizedBox(
                width: 440,
                child: buildRelSimpleForm(widget.schema, _ctrl),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving || _loading ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isNew ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}

// ── Diálogo de Búsqueda / Selección ──────────────────────────────────────────

Future<Map<String, dynamic>?> showRelSearchDialog(
  BuildContext context, {
  required String endpoint,
  Map<String, String>? filter,
  required List<String> displayFields,
  List<Map<String, dynamic>>? createSchema,
  Map<String, dynamic>? createExtraData,
}) {
  return showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (_) => _RelSearchDialog(
      endpoint: endpoint,
      filter: filter,
      displayFields: displayFields,
      createSchema: createSchema,
      createExtraData: createExtraData,
    ),
  );
}

class _RelSearchDialog extends StatefulWidget {
  final String endpoint;
  final Map<String, String>? filter;
  final List<String> displayFields;
  final List<Map<String, dynamic>>? createSchema;
  final Map<String, dynamic>? createExtraData;

  const _RelSearchDialog({
    required this.endpoint,
    this.filter,
    required this.displayFields,
    this.createSchema,
    this.createExtraData,
  });

  @override
  State<_RelSearchDialog> createState() => _RelSearchDialogState();
}

class _RelSearchDialogState extends State<_RelSearchDialog> {
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _search.addListener(_applySearch);
  }

  Future<void> _loadRecords() async {
    try {
      final res =
          await http.get(Uri.parse('$kRelBaseUrl/${widget.endpoint}/'));
      if (res.statusCode == 200 && mounted) {
        final list =
            (json.decode(res.body) as List).cast<Map<String, dynamic>>();
        setState(() {
          _all = list
              .where((r) => relMatchesFilter(r, widget.filter))
              .toList();
          _filtered = List.from(_all);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applySearch() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _all.where((r) => widget.displayFields.any(
            (f) => (r[f]?.toString().toLowerCase() ?? '').contains(q),
          )).toList();
    });
  }

  Future<void> _createNew() async {
    if (widget.createSchema == null) return;
    final result = await showRelFormDialog(
      context,
      endpoint: widget.endpoint,
      schema: widget.createSchema!,
      extraData: widget.createExtraData,
    );
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar'),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar...',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Sin resultados',
                            style: TextStyle(
                                color: Theme.of(context).hintColor),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final rec = _filtered[i];
                            return ListTile(
                              dense: true,
                              title: Text(
                                  relDisplayName(rec, widget.displayFields)),
                              onTap: () => Navigator.of(context).pop(rec),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        if (widget.createSchema != null)
          FilledButton.icon(
            onPressed: _createNew,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Crear nuevo'),
          ),
      ],
    );
  }
}

// ── FrameworkRelMany2One ──────────────────────────────────────────────────────

/// Campo Many2One con búsqueda, creación y edición inline al estilo Odoo.
class FrameworkRelMany2One extends FormFieldWrapper {
  final String relatedEndpoint;
  final Map<String, String>? relatedFilter;
  final List<String> displayFields;
  final List<Map<String, dynamic>> relatedSchema;
  final Map<String, dynamic>? createExtraData;

  const FrameworkRelMany2One({
    super.key,
    required super.fieldKey,
    required super.controller,
    super.label,
    required this.relatedEndpoint,
    this.relatedFilter,
    this.displayFields = const ['name'],
    this.relatedSchema = const [],
    this.createExtraData,
  });

  @override
  State<FrameworkRelMany2One> createState() => _FrameworkRelMany2OneState();
}

class _FrameworkRelMany2OneState
    extends FormFieldWrapperState<FrameworkRelMany2One> {
  Map<String, dynamic>? _selectedRecord;
  String? _loadedId;

  @override
  void initState() {
    super.initState();
    _checkAndLoad();
  }

  @override
  void onDependencyChanged(String key) {
    if (key == widget.fieldKey) _checkAndLoad();
  }

  void _checkAndLoad() {
    final id = currentValue?.toString();
    if (id != null && id.isNotEmpty && id != _loadedId) {
      _loadedId = id;
      _loadRecord(id);
    } else if ((id == null || id.isEmpty) && _loadedId != null) {
      setState(() {
        _selectedRecord = null;
        _loadedId = null;
      });
    }
  }

  Future<void> _loadRecord(String id) async {
    try {
      final res = await http.get(
          Uri.parse('$kRelBaseUrl/${widget.relatedEndpoint}/$id'));
      if (res.statusCode == 200 && mounted) {
        setState(() => _selectedRecord =
            json.decode(res.body) as Map<String, dynamic>);
      }
    } catch (_) {}
  }

  Future<void> _openSearch() async {
    final result = await showRelSearchDialog(
      context,
      endpoint: widget.relatedEndpoint,
      filter: widget.relatedFilter,
      displayFields: widget.displayFields,
      createSchema:
          widget.relatedSchema.isNotEmpty ? widget.relatedSchema : null,
      createExtraData: widget.createExtraData,
    );
    if (result != null && mounted) {
      final id = result['id']?.toString() ?? '';
      setState(() {
        _selectedRecord = result;
        _loadedId = id;
      });
      widget.controller.updateField(widget.fieldKey, id);
    }
  }

  Future<void> _openEdit() async {
    if (_selectedRecord == null) return;
    final updated = await showRelFormDialog(
      context,
      endpoint: widget.relatedEndpoint,
      entityId: _selectedRecord!['id']?.toString(),
      schema: widget.relatedSchema,
      extraData: widget.createExtraData,
    );
    if (updated != null && mounted) {
      setState(() => _selectedRecord = updated);
    }
  }

  void _clear() {
    setState(() {
      _selectedRecord = null;
      _loadedId = null;
    });
    widget.controller.updateField(widget.fieldKey, null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = _selectedRecord != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label ?? widget.fieldKey,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _openSearch,
                child: Text(
                  hasValue
                      ? relDisplayName(_selectedRecord!, widget.displayFields)
                      : 'Seleccionar...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasValue ? null : theme.hintColor,
                  ),
                ),
              ),
            ),
            if (hasValue) ...[
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                tooltip: 'Abrir / Editar',
                visualDensity: VisualDensity.compact,
                onPressed: _openEdit,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Quitar',
                visualDensity: VisualDensity.compact,
                onPressed: _clear,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.search, size: 18),
                tooltip: 'Buscar',
                visualDensity: VisualDensity.compact,
                onPressed: _openSearch,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
          ],
        ),
      ),
    );
  }
}
