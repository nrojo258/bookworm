import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'diseño.dart';
import 'componentes.dart';

class GraficosEstadisticas extends StatefulWidget {
  final Map<String, dynamic> datosEstadisticas;

  const GraficosEstadisticas({
    super.key,
    required this.datosEstadisticas,
  });

  @override
  State<GraficosEstadisticas> createState() => _GraficosEstadisticasState();
}

class _GraficosEstadisticasState extends State<GraficosEstadisticas> {
  int _graficoSeleccionado = 0;

  List<BarChartGroupData> _construirDatosBarrasLibros() {
    final datosMensuales = {
      'Ene': 4,
      'Feb': 6,
      'Mar': 8,
      'Abr': 5,
      'May': 7,
      'Jun': 9,
    };

    return datosMensuales.entries.map((entry) {
      final index = datosMensuales.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: AppColores.primario,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> _construirDatosTortaGeneros() {
    final datosGeneros = {
      'Ficción': 30,
      'Ciencia Ficción': 25,
      'Fantasía': 20,
      'No Ficción': 15,
      'Romance': 10,
    };

    final colores = [
      AppColores.primario,
      AppColores.secundario,
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
    ];

    double total = datosGeneros.values.reduce((a, b) => a + b).toDouble();
    double startAngle = 0;

    return datosGeneros.entries.map((entry) {
      final porcentaje = (entry.value / total) * 100;
      final section = PieChartSectionData(
        color: colores[datosGeneros.keys.toList().indexOf(entry.key) % colores.length],
        value: porcentaje,
        title: '${porcentaje.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      startAngle += porcentaje * 3.6;
      return section;
    }).toList();
  }

  Widget _construirGraficoBarras() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: EstilosApp.tarjetaPlana,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 12,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColores.primario,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} libros',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      meses[value.toInt()],
                      style: EstilosApp.cuerpoPequeno,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: EstilosApp.cuerpoPequeno,
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _construirDatosBarrasLibros(),
        ),
      ),
    );
  }

  Widget _construirGraficoTorta() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: EstilosApp.tarjetaPlana,
      child: PieChart(
        PieChartData(
          sections: _construirDatosTortaGeneros(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          startDegreeOffset: 270,
        ),
      ),
    );
  }

  Widget _construirGraficoLineas() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: EstilosApp.tarjetaPlana,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(enabled: true),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 30,
          minY: 0,
          maxY: 120,
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 40),
                const FlSpot(5, 60),
                const FlSpot(10, 80),
                const FlSpot(15, 70),
                const FlSpot(20, 90),
                const FlSpot(25, 100),
                const FlSpot(30, 110),
              ],
              isCurved: true,
              color: AppColores.primario,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirGraficoActual() {
    switch (_graficoSeleccionado) {
      case 0:
        return _construirGraficoBarras();
      case 1:
        return _construirGraficoTorta();
      case 2:
        return _construirGraficoLineas();
      default:
        return _construirGraficoBarras();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Detalladas'),
        backgroundColor: AppColores.primario,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: EstilosApp.tarjeta,
              child: Row(
                children: [
                  Expanded(
                    child: BotonSeccion(
                      texto: 'Libros/Mes',
                      estaSeleccionado: _graficoSeleccionado == 0,
                      icono: Icons.bar_chart,
                      alPresionar: () => setState(() => _graficoSeleccionado = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BotonSeccion(
                      texto: 'Géneros',
                      estaSeleccionado: _graficoSeleccionado == 1,
                      icono: Icons.pie_chart,
                      alPresionar: () => setState(() => _graficoSeleccionado = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BotonSeccion(
                      texto: 'Progreso',
                      estaSeleccionado: _graficoSeleccionado == 2,
                      icono: Icons.trending_up,
                      alPresionar: () => setState(() => _graficoSeleccionado = 2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _construirGraficoActual(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: EstilosApp.tarjeta,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen Estadístico',
                    style: EstilosApp.tituloMedio,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _construirEstadisticaResumen('Libros leídos', '${widget.datosEstadisticas['librosLeidos'] ?? 0}'),
                      _construirEstadisticaResumen('Páginas totales', '${widget.datosEstadisticas['paginasTotales'] ?? 0}'),
                      _construirEstadisticaResumen('Días racha', '${widget.datosEstadisticas['rachaActual'] ?? 0}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirEstadisticaResumen(String titulo, String valor) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColores.primario,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: EstilosApp.cuerpoPequeno,
        ),
      ],
    );
  }
}
