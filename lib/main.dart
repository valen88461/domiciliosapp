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
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const PantallaRepartidor(),
    );
  }
}

class PantallaRepartidor extends StatefulWidget {
  const PantallaRepartidor({super.key});
  @override
  State<PantallaRepartidor> createState() => _PantallaRepartidorState();
}

class _PantallaRepartidorState extends State<PantallaRepartidor>
    with SingleTickerProviderStateMixin {
  final _service = ClimaService();
  ClimaModel? _clima;
  String? _error;
  bool _cargando = false;
  String _ciudad = 'Cali';
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _icono(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('lluvia') || d.contains('rain')) return '🌧️';
    if (d.contains('tormenta') || d.contains('storm')) return '⛈️';
    if (d.contains('nube') || d.contains('cloud')) return '☁️';
    if (d.contains('niebla') || d.contains('fog') || d.contains('mist')) return '🌫️';
    if (d.contains('nieve') || d.contains('snow')) return '❄️';
    return '☀️';
  }

  Map<String, dynamic> _estadoDomicilio(String desc, double temp) {
    final d = desc.toLowerCase();
    if (d.contains('tormenta') || d.contains('storm'))
      return {'texto': 'NO SALIR — Tormenta activa', 'color': const Color(0xFFEF4444), 'icon': Icons.dangerous};
    if (d.contains('lluvia') || d.contains('rain'))
      return {'texto': 'PRECAUCIÓN — Llevar impermeable', 'color': const Color(0xFFF97316), 'icon': Icons.warning_amber};
    if (temp >= 32)
      return {'texto': 'CALOR EXTREMO — Hidratarse bien', 'color': const Color(0xFFF97316), 'icon': Icons.thermostat};
    return {'texto': 'CONDICIONES ÓPTIMAS — ¡A domiciliar!', 'color': const Color(0xFF10B981), 'icon': Icons.check_circle};
  }

  // ── Data ─────────────────────────────────────────────────────────────────
  Future<void> _cargarClima() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final clima = await _service.getClimaColombia(_ciudad);
      setState(() => _clima = clima);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  // ── Selector de ciudad ───────────────────────────────────────────────────
  void _mostrarSelectorCiudad() {
    final ciudades = [
      'Bogotá', 'Medellín', 'Cali', 'Barranquilla',
      'Cartagena', 'Bucaramanga', 'Pereira', 'Manizales',
      'Cúcuta', 'Ibagué',
    ];
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF30363D),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Selecciona una ciudad',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Escribe otra ciudad...',
                  hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7C3AED)),
                  filled: true,
                  fillColor: const Color(0xFF21262D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF7C3AED)),
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        setState(() => _ciudad = controller.text.trim());
                        Navigator.pop(ctx);
                        _cargarClima();
                      }
                    },
                  ),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    setState(() => _ciudad = val.trim());
                    Navigator.pop(ctx);
                    _cargarClima();
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text('Ciudades principales',
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.2,
                physics: const NeverScrollableScrollPhysics(),
                children: ciudades.map((ciudad) {
                  final seleccionada = ciudad == _ciudad;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _ciudad = ciudad);
                      Navigator.pop(ctx);
                      _cargarClima();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: seleccionada
                            ? const Color(0xFF7C3AED).withOpacity(0.25)
                            : const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: seleccionada
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF30363D),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(ciudad,
                          style: TextStyle(
                            color: seleccionada
                                ? const Color(0xFFA78BFA)
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: seleccionada
                                ? FontWeight.bold
                                : FontWeight.normal,
                          )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _cargarClima();
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _cargando
                  ? _buildLoading()
                  : _error != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delivery_dining, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DomiciliosApp',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Panel del Repartidor',
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _cargarClima,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: const Icon(Icons.refresh, color: Color(0xFF7C3AED), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulse,
            child: const Text('🌤️', style: TextStyle(fontSize: 72)),
          ),
          const SizedBox(height: 24),
          const Text('Consultando el clima...',
              style: TextStyle(color: Color(0xFF8B949E), fontSize: 16)),
          const SizedBox(height: 16),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Color(0xFF21262D),
              color: Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📡', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            const Text('Sin conexión',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 14)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _cargarClima,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_clima == null) return const SizedBox();
    final estado = _estadoDomicilio(_clima!.descripcion, _clima!.temperatura);
    final icono = _icono(_clima!.descripcion);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ciudad ──
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF7C3AED), size: 18),
              const SizedBox(width: 6),
              Text(_clima!.ciudad,
                  style: const TextStyle(color: Color(0xFF8B949E), fontSize: 14)),
              const Spacer(),
              const Text('Actualizado ahora',
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),

          // ── Tarjeta principal ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1040), Color(0xFF161B22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF7C3AED), width: 1),
            ),
            child: Column(
              children: [
                Text(icono, style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 12),
                Text('${_clima!.temperatura.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 56, fontWeight: FontWeight.w200)),
                const SizedBox(height: 4),
                Text(_clima!.descripcion,
                    style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 18),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Stats ──
          Row(
            children: [
              _statCard('💧', 'Humedad', '${_clima!.humedad}%'),
              const SizedBox(width: 12),
              _statCard('🌡️', 'Sensación', '${(_clima!.temperatura - 2).toStringAsFixed(1)}°C'),
              const SizedBox(width: 12),
              _statCard('🌬️', 'Viento', 'Moderado'),
            ],
          ),
          const SizedBox(height: 16),

          // ── Estado domicilio ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (estado['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: (estado['color'] as Color).withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(estado['icon'] as IconData,
                    color: estado['color'] as Color, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estado para domicilios',
                          style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(estado['texto'] as String,
                          style: TextStyle(
                              color: estado['color'] as Color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Cambiar ciudad ──
          GestureDetector(
            onTap: _mostrarSelectorCiudad,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF7C3AED).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_location_alt,
                      color: Color(0xFF7C3AED), size: 22),
                  const SizedBox(width: 12),
                  const Text('Cambiar ciudad',
                      style: TextStyle(
                          color: Color(0xFFA78BFA),
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(_ciudad,
                      style: const TextStyle(
                          color: Color(0xFF8B949E), fontSize: 14)),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF8B949E), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── LogísticaTotal badge ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: const Row(
              children: [
                Icon(Icons.business, color: Color(0xFF8B949E), size: 18),
                SizedBox(width: 10),
                Text('LogísticaTotal — Cali',
                    style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
                Spacer(),
                Text('API: OpenWeatherMap',
                    style: TextStyle(color: Color(0xFF30363D), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String emoji, String label, String valor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(valor,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF8B949E), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}