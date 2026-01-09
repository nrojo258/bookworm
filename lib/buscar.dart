import 'package:flutter/material.dart';
import 'diseño.dart';
import 'componentes.dart';
import '../API/modelos.dart';
import '../API/open_library.dart';

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  final OpenLibrary _servicioOpenLibrary = OpenLibrary();
  
  String? _formatoSeleccionado = 'Todos los formatos';
  String? _generoSeleccionado = 'Todos los géneros';
  
  List<Libro> _resultadosBusqueda = [];
  bool _estaCargando = false;
  bool _haBuscado = false;

  @override
  void initState() {
    super.initState();
    _generoSeleccionado = DatosApp.generos.isNotEmpty ? DatosApp.generos.first : null;
    _formatoSeleccionado = 'Todos los formatos';
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  Future<void> _realizarBusqueda() async {
    // Permitir búsqueda sin texto si hay filtros seleccionados
    bool tieneFiltros = (_generoSeleccionado != null && _generoSeleccionado != 'Todos los géneros') || 
                       (_formatoSeleccionado != null && _formatoSeleccionado != 'Todos los formatos');
    
    if (_controladorBusqueda.text.isEmpty && !tieneFiltros) {
      _mostrarError('Por favor ingresa un término de búsqueda o selecciona un filtro');
      return;
    }
    
    setState(() {
      _estaCargando = true;
      _haBuscado = true;
    });

    try {
      List<Libro> resultados;
      String consultaBusqueda = _controladorBusqueda.text;
      
      // Si no hay texto pero hay género, usar el género como consulta
      if (consultaBusqueda.isEmpty && _generoSeleccionado != null && _generoSeleccionado != 'Todos los géneros') {
        consultaBusqueda = _generoSeleccionado!;
      }
      
      // Si no hay texto ni género específico, hacer una búsqueda general
      if (consultaBusqueda.isEmpty) {
        consultaBusqueda = 'fiction'; // Búsqueda general por defecto
      }
      
      resultados = await _servicioOpenLibrary.buscarLibros(
        consulta: consultaBusqueda,
        genero: _generoSeleccionado == 'Todos los géneros' ? null : _generoSeleccionado,
        limite: 20,
      );
      
      // Filtrar por formato si es necesario
      if (_formatoSeleccionado != null && _formatoSeleccionado != 'Todos los formatos') {
        if (_formatoSeleccionado == 'Audiolibros') {
          // Por ahora, mostrar mensaje de que no hay audiolibros disponibles
          _mostrarError('Los audiolibros estarán disponibles próximamente');
          resultados = [];
        }
        // Si es "Libros", mostrar todos los resultados (son libros físicos)
      }
      
      setState(() {
        _resultadosBusqueda = resultados;
      });
    } catch (e) {
      _mostrarError('Error al buscar: $e');
      setState(() {
        _resultadosBusqueda = [];
      });
    } finally {
      setState(() {
        _estaCargando = false;
      });
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _seccionResultados() {
    if (_estaCargando) {
      return const IndicadorCarga(mensaje: 'Buscando libros...');
    }

    if (!_haBuscado) {
      return const EstadoVacio(
        icono: Icons.search,
        titulo: 'Busca tu próximo libro favorito',
        descripcion: 'Ingresa un título, autor, o selecciona un género/formato',
      );
    }

    if (_resultadosBusqueda.isEmpty) {
      return const EstadoVacio(
        icono: Icons.search_off,
        titulo: 'No se encontraron libros',
        descripcion: 'Intenta con otros términos de búsqueda',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_resultadosBusqueda.length} resultados encontrados',
              style: EstilosApp.cuerpoMedio,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color.fromRGBO(74, 111, 165, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._resultadosBusqueda.map((libro) => TarjetaLibro(libro: libro)),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        title: const Text('BookWorm', style: EstilosApp.tituloGrande),
        backgroundColor: AppColores.primario,
        automaticallyImplyLeading: false,
        actions: const [BotonesBarraApp(rutaActual: '/search')],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: EstilosApp.tarjeta,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Encuentra tu próximo libro',
                    style: EstilosApp.tituloMedio,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Busca entre miles de libros y audiolibros',
                    style: EstilosApp.cuerpoMedio,
                  ),
                  const SizedBox(height: 20),
                  
                  BarraBusquedaPersonalizada(
                    controlador: _controladorBusqueda,
                    textoHint: 'Ej: Harry Potter, Stephen King, o deja vacío para buscar por filtros',
                    alBuscar: _realizarBusqueda,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: FiltroDesplegable(
                          valor: _formatoSeleccionado,
                          items: const ['Todos los formatos', 'Libros', 'Audiolibros'],
                          hint: 'Formato',
                          alCambiar: (valor) {
                            if (valor != null) {
                              setState(() {
                                _formatoSeleccionado = valor;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FiltroDesplegable(
                          valor: _generoSeleccionado,
                          items: DatosApp.generos,
                          hint: 'Género',
                          alCambiar: (valor) {
                            if (valor != null) {
                              setState(() {
                                _generoSeleccionado = valor;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: EstilosApp.tarjeta,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados de búsqueda',
                    style: EstilosApp.tituloMedio,
                  ),
                  const SizedBox(height: 16),
                  _seccionResultados(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
