import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../framework/data/api_provider.dart';
import '../framework/data/base_repository.dart';

class GenericListScreen extends StatefulWidget {
  final String title;
  final String endpoint;
  final String routePrefix;
  final List<String> displayFields;
  final String? filterKey;
  final String? filterValue;

  const GenericListScreen({
    super.key,
    required this.title,
    required this.endpoint,
    required this.routePrefix,
    required this.displayFields,
    this.filterKey,
    this.filterValue,
  });

  @override
  State<GenericListScreen> createState() => _GenericListScreenState();
}

class _GenericListScreenState extends State<GenericListScreen> {
  late final BaseRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = AppFramework().getRepository(widget.endpoint);
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> data) {
    if (widget.filterKey == null || widget.filterValue == null) return data;
    return data.where((item) {
      if (widget.filterKey!.startsWith('metadata_json.')) {
        final key = widget.filterKey!.split('.')[1];
        final meta = item['metadata_json'] ?? {};
        return meta[key] == widget.filterValue;
      }
      return item[widget.filterKey] == widget.filterValue;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _repository.pull(),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = _filter(snapshot.data ?? []);
          if (data.isEmpty) {
            return const Center(child: Text('No hay registros encontrados.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final titleField = widget.displayFields.isNotEmpty
                  ? item[widget.displayFields[0]]?.toString() ?? 'Sin Nombre'
                  : 'Ítem';
              final subParts = widget.displayFields
                  .skip(1)
                  .map((f) => item[f]?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .join(' • ');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(titleField,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: subParts.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(subParts),
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push('${widget.routePrefix}/${item['id']}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${widget.routePrefix}/new'),
        icon: const Icon(Icons.add),
        label: const Text('Crear Nuevo'),
      ),
    );
  }
}
