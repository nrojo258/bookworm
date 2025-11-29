import 'package:flutter/material.dart';
import 'diseño.dart';
import 'componentes.dart';
import 'modelos.dart';
import 'open_library.dart';

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
    if (_controladorBusqueda.text.isEmpty) {
      _mostrarError('Por favor ingresa un término de búsqueda');
      return;
    }
    
    setState(() {
      _estaCargando = true;
      _haBuscado = true;
    });

    try {
      List<Libro> resultados;
      
      print('Buscando');
      print('Término: ${_controladorBusqueda.text}');
      print('Género: $_generoSeleccionado');
      
      resultados = await _servicioOpenLibrary.buscarLibros(
        consulta: _controladorBusqueda.text,
        genero: _generoSeleccionado == 'Todos los géneros' ? null : _generoSeleccionado,
        limite: 20,
      );
      
      print('Resultados encontrados: ${resultados.length}');
      
      setState(() {
        _resultadosBusqueda = resultados;
      });
    } catch (e) {
      print('Error en búsqueda: $e');
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

  Widget _ElementoLibro(Libro libro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: libro.urlMiniatura != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      libro.urlMiniatura!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progresoCarga) {
                        if (progresoCarga == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progresoCarga.expectedTotalBytes != null
                                ? progresoCarga.cumulativeBytesLoaded / progresoCarga.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.book, size: 40, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.book, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  libro.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                if (libro.autores.isNotEmpty)
                  Text(
                    'Por ${libro.autores.join(', ')}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                if (libro.fechaPublicacion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Publicado: ${libro.fechaPublicacion}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
                
                if (libro.calificacionPromedio != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${libro.calificacionPromedio!.toStringAsFixed(1)} (${libro.numeroCalificaciones ?? 0})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
                
                if (libro.descripcion != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    libro.descripcion!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _SeccionResultados() {
    if (_estaCargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColores.primario)),
            SizedBox(height: 16),
            Text('Buscando libros...', style: EstilosApp.cuerpoMedio),
          ],
        ),
      );
    }

    if (!_haBuscado) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Busca tu próximo libro favorito', 
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Ingresa un título, autor o género', 
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColores.primario.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._resultadosBusqueda.map(_ElementoLibro).toList(),
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
              decoration: EstilosApp.decoracionTarjeta,
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
                    textoHint: 'Ej: Harry Potter, Stephen King, Ciencia Ficción...',
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
              decoration: EstilosApp.decoracionTarjeta,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados de búsqueda',
                    style: EstilosApp.tituloMedio,
                  ),
                  const SizedBox(height: 16),
                  _SeccionResultados(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}