import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/clima_model.dart';

class ClimaService {
  static const _apiKey = '1f9555a78a5793ae9b2aa51078ff6390';

  Future<ClimaModel> getClimaColombia(String ciudad) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?q=$ciudad,CO&appid=$_apiKey&units=metric&lang=es');
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        return ClimaModel.fromJson(jsonDecode(res.body));
      }
      throw 'Error al obtener el clima (${res.statusCode})';
    } on Exception {
      throw 'Sin conexión a internet. Verifica tu red.';
    }
  }
}