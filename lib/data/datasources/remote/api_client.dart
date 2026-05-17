import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const _base = 'https://api.domiciliosapp.co/v1';
  static const _timeout = Duration(seconds: 30);

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String endpoint, {String? token}) async {
    final res = await http
        .get(Uri.parse('$_base$endpoint'), headers: _headers(token))
        .timeout(_timeout);
    return _procesar(res);
  }

  Future<dynamic> post(String endpoint,
      {required Map<String, dynamic> body, String? token}) async {
    final res = await http
        .post(Uri.parse('$_base$endpoint'),
            headers: _headers(token), body: jsonEncode(body))
        .timeout(_timeout);
    return _procesar(res);
  }

  Future<dynamic> patch(String endpoint,
      {required Map<String, dynamic> body, String? token}) async {
    final res = await http
        .patch(Uri.parse('$_base$endpoint'),
            headers: _headers(token), body: jsonEncode(body))
        .timeout(_timeout);
    return _procesar(res);
  }

  dynamic _procesar(http.Response res) {
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    if (res.statusCode == 401) throw 'Sesión expirada. Vuelve a iniciar sesión.';
    if (res.statusCode == 403) throw 'Sin permisos para esta acción.';
    if (res.statusCode == 404) throw 'Recurso no encontrado.';
    throw data['message'] ?? 'Error del servidor: ${res.statusCode}';
  }
}