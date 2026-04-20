import 'dart:async';
import 'package:uuid/uuid.dart';
import '../core/framework_core.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Entidad genérica para envolver datos
class DynamicEntity implements FrameworkEntity {
  @override
  final String id;
  final Map<String, dynamic> data;

  DynamicEntity({required this.id, required this.data});

  @override
  Map<String, dynamic> toJson() => data;
}

// Proveedor Remoto Básico
class RemoteDataProvider implements DataProvider<DynamicEntity> {
  final String endpoint;
  final String baseUrl = "http://localhost:8000/api";
  final StreamController<List<Map<String, dynamic>>> _streamController = StreamController.broadcast();

  RemoteDataProvider(this.endpoint);

  @override
  Stream<List<Map<String, dynamic>>> get dataStream => _streamController.stream;

  @override
  Future<List<DynamicEntity>> getAll() async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      final list = l.map((e) => DynamicEntity(id: e['id'] ?? const Uuid().v4(), data: e)).toList();
      _streamController.add(list.map((e) => e.data).toList());
      return list;
    }
    throw Exception('Error loading $endpoint');
  }

  @override
  Future<DynamicEntity?> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DynamicEntity(id: data['id'], data: data);
    }
    return null;
  }

  @override
  Future<void> create(DynamicEntity entity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(entity.data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Create error: ${response.body}');
    }
    getAll(); // Update stream
  }

  @override
  Future<void> update(DynamicEntity entity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint/${entity.id}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(entity.data),
    );
    if (response.statusCode != 200) {
      throw Exception('Update error: ${response.body}');
    }
    getAll(); // Update stream
  }

  @override
  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Delete error: ${response.body}');
    }
    getAll(); // Update stream
  }
}

class AppFramework {
  static final AppFramework _instance = AppFramework._internal();
  factory AppFramework() => _instance;
  AppFramework._internal();

  final Map<String, RemoteDataProvider> _providers = {};

  RemoteDataProvider getProvider(String endpoint) {
    if (!_providers.containsKey(endpoint)) {
      _providers[endpoint] = RemoteDataProvider(endpoint);
    }
    return _providers[endpoint]!;
  }
}
