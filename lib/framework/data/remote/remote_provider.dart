import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteProvider {
  final String baseUrl;

  const RemoteProvider({this.baseUrl = 'http://localhost:8000/api'});

  Future<List<Map<String, dynamic>>> getAll(String endpoint) async {
    final res = await http.get(Uri.parse('$baseUrl/$endpoint/'));
    _assertOk(res, endpoint, {200});
    return (json.decode(res.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getById(String endpoint, String id) async {
    final res = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));
    if (res.statusCode == 404) return null;
    _assertOk(res, '$endpoint/$id', {200});
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create(
      String endpoint, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$endpoint/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    _assertOk(res, endpoint, {200, 201});
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
      String endpoint, String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    _assertOk(res, '$endpoint/$id', {200});
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<void> delete(String endpoint, String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));
    _assertOk(res, '$endpoint/$id', {200, 204});
  }

  void _assertOk(http.Response res, String context, Set<int> expected) {
    if (!expected.contains(res.statusCode)) {
      throw RemoteException(res.statusCode, context, res.body);
    }
  }
}

class RemoteException implements Exception {
  final int statusCode;
  final String context;
  final String body;

  const RemoteException(this.statusCode, this.context, this.body);

  @override
  String toString() => 'RemoteException($statusCode) [$context]: $body';
}
