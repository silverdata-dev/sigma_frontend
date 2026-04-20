import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../framework/data/api_provider.dart';

class GenericListScreen extends StatefulWidget {
  final String title;
  final String endpoint;
  final String routePrefix;
  final List<String> displayFields; // Campos que se mostrarán en la tarjeta
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
  late RemoteDataProvider _provider;
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _provider = AppFramework().getProvider(widget.endpoint);
    _loadData();
    _provider.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _data = _filterData(data);
        });
      }
    });
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    if (widget.filterKey == null || widget.filterValue == null) return data;
    return data.where((item) {
      // Especial para metadata_json -> rol (Sujetos)
      if (widget.filterKey!.startsWith('metadata_json.')) {
        final key = widget.filterKey!.split('.')[1];
        final meta = item['metadata_json'] ?? {};
        return meta[key] == widget.filterValue;
      }
      return item[widget.filterKey] == widget.filterValue;
    }).toList();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _provider.getAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? const Center(child: Text('No hay registros encontrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    final item = _data[index];
                    
                    // Extraer título principal (el primer display field)
                    final titleField = widget.displayFields.isNotEmpty ? item[widget.displayFields[0]]?.toString() ?? 'Sin Nombre' : 'Ítem';
                    
                    // Subtítulo con los demás campos
                    final subParts = widget.displayFields.skip(1).map((f) => item[f]?.toString() ?? '').where((s) => s.isNotEmpty).join(' • ');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        title: Text(titleField, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: subParts.isNotEmpty ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(subParts),
                        ) : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navegar al formulario de edición con el ID
                          context.push('${widget.routePrefix}/${item['id']}');
                        },
                      ),
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
