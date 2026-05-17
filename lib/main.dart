import 'package:flutter/material.dart';
import 'data/datasources/remote/clima_service.dart';
import 'models/clima_model.dart';

void main() => runApp(const DomiciliosApp());

class DomiciliosApp extends StatelessWidget {
  const DomiciliosApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DomiciliosApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      home: const PantallaRepartidor(),
    );
  }
}

class PantallaRepartidor extends StatefulWidget {
  const PantallaRepartidor({super.key});
  @override
  State<PantallaRepartidor> createState() => _PantallaRepartidorState();
}

class _PantallaRepartidorState extends State<PantallaRepartidor> {
  final _service = ClimaService();
  ClimaModel? _clima;
  String? _error;
  bool _cargando = false;

  Future<void> _cargarClima() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final clima = await _service.getClimaColombia('Cali');
      setState(() { _clima = clima; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _cargando = false; });
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarClima();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DomiciliosApp — Repartidor'),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clima actual', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            if (_cargando)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.wifi_off, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                ]),
              )
            else if (_clima != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.cloud, color: Color(0xFF06B6D4), size: 48),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_clima!.ciudad,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${_clima!.temperatura.toStringAsFixed(1)} °C  ·  ${_clima!.descripcion}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    Text('Humedad: ${_clima!.humedad}%',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                ]),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarClima,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar clima'),
            ),
          ],
        ),
      ),
    );
  }
}