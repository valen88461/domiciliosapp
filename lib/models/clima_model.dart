
class ClimaModel {
  final String ciudad;
  final double temperatura;
  final String descripcion;
  final int humedad;

  ClimaModel({
    required this.ciudad,
    required this.temperatura,
    required this.descripcion,
    required this.humedad,
  });

  factory ClimaModel.fromJson(Map<String, dynamic> json) {
    return ClimaModel(
      ciudad: json['name'],
      temperatura: (json['main']['temp'] as num).toDouble(),
      descripcion: json['weather'][0]['description'],
      humedad: json['main']['humidity'],
    );
  }
}