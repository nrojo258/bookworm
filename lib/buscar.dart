import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diseño.dart';
import 'componentes.dart';
import 'API/modelos.dart';
import 'API/open_library.dart';
import 'API/gutendex_service.dart';
import 'API/librivox_service.dart';
import 'API/google_books_service.dart';
import 'API/internet_archive_service.dart';

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  final OpenLibraryService _servicioOpenLibrary = OpenLibraryService();
  final GutendexService _servicioGutendex = GutendexService();
  final LibriVoxService _servicioLibriVox = LibriVoxService();
  final GoogleBooksService _servicioGoogleBooks = GoogleBooksService(apiKey: 'AIzaSyBr-6JMgXDq5Ov_wV3hxykLnVujEn2YK6Y');
  final InternetArchiveService _servicioInternetArchive = InternetArchiveService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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

  Future<void> _guardarLibro(Libro libro, {bool favorito = false}) async {
    try {
      final usuario = _auth.currentUser;
      if (usuario == null) {
        _mostrarError('Debes iniciar sesión para guardar libros');
        return;
      }

      final datosLibro = libro.toMap();
      datosLibro['fechaGuardado'] = FieldValue.serverTimestamp();
      datosLibro['estado'] = 'guardado';
      datosLibro['libroId'] = libro.id;
      datosLibro['favorito'] = favorito;

      await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('libros_guardados')
          .doc(libro.id)
          .set(datosLibro);

      _mostrarExito(favorito 
          ? '"${libro.titulo}" añadido a tus favoritos' 
          : '"${libro.titulo}" guardado en tu biblioteca');
    } catch (e) {
      _mostrarError('Error al guardar libro: $e');
    }
  }

  Future<void> _realizarBusqueda() async {
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
      String consultaBusqueda = _controladorBusqueda.text;
      if (consultaBusqueda.isEmpty && 
          (_generoSeleccionado == null || _generoSeleccionado == 'Todos los géneros') &&
          (_formatoSeleccionado == null || _formatoSeleccionado == 'Todos los formatos')) {
        consultaBusqueda = 'fiction';
      }
      
      List<Future<List<Libro>>> busquedas = [];
      
      if (_formatoSeleccionado == 'Todos los formatos' || _formatoSeleccionado == 'Libros') {
        busquedas.add(_servicioOpenLibrary.buscarLibros(
          consultaBusqueda,
          genero: _generoSeleccionado == 'Todos los géneros' ? null : _generoSeleccionado,
          limite: 15,
        ));
        busquedas.add(_servicioGutendex.buscarLibros(
          consultaBusqueda,
          genero: _generoSeleccionado == 'Todos los géneros' ? null : _generoSeleccionado,
        ));
        busquedas.add(_servicioGoogleBooks.buscarLibros(
          consultaBusqueda,
          genero: _generoSeleccionado == 'Todos los géneros' ? null : _generoSeleccionado,
        ));
        busquedas.add(_servicioInternetArchive.buscarLibros(
          consultaBusqueda,
          genero: _generoSeleccionado == 'Todos los géneros' ? null : _generoSeleccionado,
        ));
      }
      
      if (_formatoSeleccionado == 'Todos los formatos' || _formatoSeleccionado == 'Audiolibros') {
        busquedas.add(_servicioLibriVox.buscarLibros(
          consultaBusqueda,
          genero: _generoSeleccionado == 'Todos los géneros' ? null : _generoSeleccionado,
        ));
      }

      final listasResultados = await Future.wait(busquedas);
      List<Libro> resultados = [];
      
      int maxLen = listasResultados.map((l) => l.length).fold(0, (prev, element) => element > prev ? element : prev);
      for (int i = 0; i < maxLen; i++) {
        for (var lista in listasResultados) {
          if (i < lista.length) {
            resultados.add(lista[i]);
          }
        }
      }
      
      if (_formatoSeleccionado != null && _formatoSeleccionado != 'Todos los formatos') {
        if (_formatoSeleccionado == 'Audiolibros') {
          resultados = resultados.where((libro) => libro.esAudiolibro).toList();
        } else if (_formatoSeleccionado == 'Libros') {
          resultados = resultados.where((libro) => !libro.esAudiolibro).toList();
        }
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

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColores.secundario,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarDetallesLibro(Libro libro) {
    Navigator.pushNamed(
      context,
      '/detalles_libro',
      arguments: libro,
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
          ],
        ),
        const SizedBox(height: 16),
        ..._resultadosBusqueda.map((libro) => _construirTarjetaLibro(libro)),
      ],
    );
  }

  Widget _construirTarjetaLibro(Libro libro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: EstilosApp.tarjetaPlana,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _mostrarDetallesLibro(libro),
                child: Stack(
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
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.book, size: 40, color: Colors.grey);
                                },
                              ),
                            )
                          : const Icon(Icons.book, size: 40, color: Colors.grey),
                    ),
                    if (libro.esAudiolibro)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColores.secundario,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.headset,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _mostrarDetallesLibro(libro),
                      child: Text(
                        libro.titulo,
                        style: EstilosApp.tituloPequeno,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (libro.autores.isNotEmpty)
                      Text(
                        'Por ${libro.autores.join(', ')}',
                        style: EstilosApp.cuerpoMedio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (libro.fechaPublicacion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Publicado: ${libro.fechaPublicacion}',
                        style: EstilosApp.cuerpoPequeno,
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
                            style: EstilosApp.cuerpoPequeno,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: AppColores.primario),
                    onPressed: () => _guardarLibro(libro, favorito: true),
                    tooltip: 'Añadir a favoritos',
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add, color: AppColores.primario),
                    onPressed: () => _guardarLibro(libro),
                    tooltip: 'Guardar libro',
                  ),
                ],
              ),
            ],
          ),
          if (libro.descripcion != null) ...[
            const SizedBox(height: 12),
            Text(
              libro.descripcion!,
              style: EstilosApp.cuerpoPequeno,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _mostrarDetallesLibro(libro),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.primario,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ver Detalles Completos'),
                ),
              ),
            ],
          ),
        ],
      ),
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
                  const Text('Encuentra tu próximo libro', style: EstilosApp.tituloMedio),
                  const SizedBox(height: 8),
                  const Text('Busca entre miles de libros y audiolibros', style: EstilosApp.cuerpoMedio),
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
                  const Text('Resultados de búsqueda', style: EstilosApp.tituloMedio),
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
