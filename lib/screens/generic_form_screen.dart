import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../framework/core/form_controller.dart';
import '../framework/ui/framework_form.dart';
import '../framework/data/api_provider.dart';
import '../framework/data/base_repository.dart';

class GenericFormScreen extends StatefulWidget {
  final String title;
  final String endpoint;
  final String entityId;
  final List<Map<String, dynamic>> schema;
  final Map<String, dynamic>? extraData;

  const GenericFormScreen({
    super.key,
    required this.title,
    required this.endpoint,
    required this.entityId,
    required this.schema,
    this.extraData,
  });

  @override
  State<GenericFormScreen> createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends State<GenericFormScreen> {
  late final FormController _formController;
  late final BaseRepository _repository;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get isNew => widget.entityId == 'new';

  @override
  void initState() {
    super.initState();
    _formController = FormController();
    _repository = AppFramework().getRepository(widget.endpoint);
    if (!isNew) _loadEntity();
  }

  Future<void> _loadEntity() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.findById(widget.entityId);
      if (data != null) {
        data.forEach((key, value) => _formController.updateField(key, value));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al cargar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEntity() async {
    setState(() => _isSaving = true);
    try {
      final dataToSave = Map<String, dynamic>.from(_formController.data);

      if (widget.extraData != null) {
        widget.extraData!.forEach((key, value) {
          if (key.contains('.')) {
            final parts = key.split('.');
            dataToSave[parts[0]] ??= {};
            dataToSave[parts[0]][parts[1]] = value;
          } else {
            dataToSave[key] = value;
          }
        });
      }

      if (!isNew) dataToSave['id'] = widget.entityId;

      await _repository.save(dataToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isNew ? 'Creado exitosamente' : 'Actualizado exitosamente'),
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteEntity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Eliminar este registro permanentemente?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await _repository.delete(widget.entityId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Eliminado exitosamente')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Nuevo ${widget.title}' : 'Editar ${widget.title}'),
        actions: [
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _deleteEntity,
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FrameworkForm(
                    schema: widget.schema,
                    controller: _formController,
                    entityId: widget.entityId,
                  ),
                ),
              ),
            ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _isSaving ? null : _saveEntity,
              icon: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
            ),
    );
  }
}
