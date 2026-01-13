import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'diseño.dart';
import 'componentes.dart';
import 'API/modelos.dart';
import 'API/open_library.dart';
import 'API/gutendex_service.dart';
import 'API/google_books_service.dart';
import 'API/librivox_service.dart';
import 'API/internet_archive_service.dart';

class DetallesLibro extends StatefulWidget {
  final Libro libro;

  const DetallesLibro({super.key, required this.libro});

  @override
  State<DetallesLibro> createState() => _DetallesLibroState();
}

class _DetallesLibroState extends State<DetallesLibro> {
  late Libro _libroDetallado;
  bool _cargandoDetalles = false;
  bool _libroGuardado = false;
  bool _libroFavorito = false;
  final OpenLibraryService _openLibrary = OpenLibraryService();
  final GutendexService _gutendexService = GutendexService();
  final GoogleBooksService _googleBooksService = GoogleBooksService(apiKey: 'AIzaSyDGyQmEOJsYJfoOMYbr5DIns3adtE13jFM');
  final LibriVoxService _libriVoxService = LibriVoxService();
  final InternetArchiveService _internetArchiveService = InternetArchiveService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _libroDetallado = widget.libro;
    _verificarSiLibroEstaGuardado();
    _cargarDetallesCompletos();
  }

  Future<void> _verificarSiLibroEstaGuardado() async {
    try {
      final usuario = _auth.currentUser;
      if (usuario == null) return;

      final doc = await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('libros_guardados')
          .doc(widget.libro.id)
          .get();

      if (mounted && doc.exists) {
        setState(() {
          _libroGuardado = true;
          _libroFavorito = doc.data()?['favorito'] ?? false;
        });
      }
    } catch (e) {
      print('Error verificando libro guardado: $e');
    }
  }

  Future<void> _cargarDetallesCompletos() async {
    setState(() => _cargandoDetalles = true);
    try {
      Libro? detalles;
      if (widget.libro.id.startsWith('guten_')) {
        detalles = await _gutendexService.obtenerDetalles(widget.libro.id);
        
        // Enriquecer con Google Books si es Gutenberg para obtener mejores metadatos
        if (detalles != null) {
          try {
            final query = '${detalles.titulo} ${detalles.autores.isNotEmpty ? detalles.autores.first : ""}';
            final busquedaExtra = await _googleBooksService.buscarLibros(query, limite: 1);
            
            if (busquedaExtra.isNotEmpty) {
              final googleLibro = busquedaExtra.first;
              // Solo actualizar si la descripción es significativamente más larga o si faltan datos
              bool mejorDescripcion = (googleLibro.descripcion?.length ?? 0) > (detalles.descripcion?.length ?? 0);
              
              detalles = detalles.copyWith(
                descripcion: mejorDescripcion ? googleLibro.descripcion : detalles.descripcion,
                urlMiniatura: detalles.urlMiniatura ?? googleLibro.urlMiniatura,
                fechaPublicacion: detalles.fechaPublicacion ?? googleLibro.fechaPublicacion,
                numeroPaginas: detalles.numeroPaginas ?? googleLibro.numeroPaginas,
                categorias: detalles.categorias.isEmpty ? googleLibro.categorias : detalles.categorias,
                calificacionPromedio: googleLibro.calificacionPromedio,
                numeroCalificaciones: googleLibro.numeroCalificaciones,
                urlVistaPrevia: googleLibro.urlLectura,
              );
            }
          } catch (e) {
            print('Error enriqueciendo con Google Books: $e');
          }
        }
      } else if (widget.libro.id.startsWith('google_')) {
        detalles = await _googleBooksService.obtenerDetalles(widget.libro.id);
      } else if (widget.libro.id.startsWith('librivox_')) {
        detalles = widget.libro; // Ya viene completo
      } else if (widget.libro.id.startsWith('ia_')) {
        detalles = widget.libro; // Ya viene completo
      } else {
        detalles = await _openLibrary.obtenerDetalles(widget.libro.id);
      }
      
      if (detalles != null && mounted) {
        setState(() {
          // Fusionar con los datos que ya tenemos para no perder nada
          _libroDetallado = _libroDetallado.copyWith(
            titulo: detalles!.titulo,
            autores: detalles!.autores.isNotEmpty ? detalles!.autores : _libroDetallado.autores,
            descripcion: detalles!.descripcion ?? _libroDetallado.descripcion,
            urlMiniatura: detalles!.urlMiniatura ?? _libroDetallado.urlMiniatura,
            fechaPublicacion: detalles!.fechaPublicacion ?? _libroDetallado.fechaPublicacion,
            numeroPaginas: detalles!.numeroPaginas ?? _libroDetallado.numeroPaginas,
            categorias: detalles!.categorias.isNotEmpty ? detalles!.categorias : _libroDetallado.categorias,
            calificacionPromedio: detalles!.calificacionPromedio ?? _libroDetallado.calificacionPromedio,
            numeroCalificaciones: detalles!.numeroCalificaciones ?? _libroDetallado.numeroCalificaciones,
            urlLectura: detalles!.urlLectura ?? _libroDetallado.urlLectura,
            urlVistaPrevia: detalles!.urlVistaPrevia ?? _libroDetallado.urlVistaPrevia,
            esAudiolibro: detalles!.esAudiolibro || _libroDetallado.esAudiolibro,
          );
        });
      }
    } catch (e) {
      print('Error cargando detalles: $e');
    } finally {
      if (mounted) {
        setState(() => _cargandoDetalles = false);
      }
    }
  }

  Future<void> _guardarLibro({bool favorito = false}) async {
    try {
      final usuario = _auth.currentUser;
      if (usuario == null) {
        _mostrarError('Debes iniciar sesión para guardar libros');
        return;
      }

      // Usar toMap() para consistencia y añadir campos necesarios
      final datosLibro = _libroDetallado.toMap();
      datosLibro['fechaGuardado'] = FieldValue.serverTimestamp();
      datosLibro['estado'] = 'guardado';
      datosLibro['libroId'] = _libroDetallado.id; // Para retrocompatibilidad si se usa este campo
      datosLibro['favorito'] = favorito;

      await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('libros_guardados')
          .doc(_libroDetallado.id)
          .set(datosLibro);

      setState(() {
        _libroGuardado = true;
        if (favorito) _libroFavorito = true;
      });

      _mostrarExito(favorito 
          ? '"${_libroDetallado.titulo}" añadido a favoritos' 
          : '"${_libroDetallado.titulo}" guardado en tu biblioteca');
    } catch (e) {
      _mostrarError('Error al guardar libro: $e');
    }
  }

  Future<void> _marcarComoFavorito() async {
    if (_libroFavorito) return;
    await _guardarLibro(favorito: true);
  }

  Future<void> _iniciarProgresoLectura() async {
    try {
      final usuario = _auth.currentUser;
      if (usuario == null) {
        _mostrarError('Debes iniciar sesión para iniciar progreso');
        return;
      }

      final progresoId = _firestore.collection('progreso_lectura').doc().id;
      
      await _firestore
          .collection('progreso_lectura')
          .doc(progresoId)
          .set({
            'id': progresoId,
            'usuarioId': usuario.uid,
            'libroId': _libroDetallado.id,
            'tituloLibro': _libroDetallado.titulo,
            'autoresLibro': _libroDetallado.autores,
            'miniaturaLibro': _libroDetallado.urlMiniatura,
            'estado': 'leyendo',
            'paginaActual': 0,
            'paginasTotales': _libroDetallado.numeroPaginas ?? 0,
            'fechaInicio': FieldValue.serverTimestamp(),
            'calificacion': 0.0,
          });

      // Actualizar el libro guardado si existe
      if (_libroGuardado) {
        await _firestore
            .collection('usuarios')
            .doc(usuario.uid)
            .collection('libros_guardados')
            .doc(_libroDetallado.id)
            .update({'estado': 'leyendo'});
      }

      _mostrarExito('Progreso iniciado para "${_libroDetallado.titulo}"');
    } catch (e) {
      _mostrarError('Error al iniciar progreso: $e');
    }
  }

  Future<void> _abrirUrlLectura() async {
    if (_libroDetallado.urlLectura == null) return;
    
    final url = Uri.parse(_libroDetallado.urlLectura!);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _mostrarError('No se pudo abrir el enlace de lectura');
      }
    } catch (e) {
      _mostrarError('Error al abrir el libro: $e');
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

  Widget _construirItemInfo({required IconData icono, required String texto}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icono, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _compartirLibro() {
    final texto = '¡Mira este libro en BookWorm!\n\n'
        '${_libroDetallado.titulo}\n'
        '${_libroDetallado.autores.isNotEmpty ? "Por: " + _libroDetallado.autores.join(", ") : ""}\n'
        '${_libroDetallado.urlLectura ?? ""}';
    
    Clipboard.setData(ClipboardData(text: texto));
    _mostrarExito('Enlace copiado al portapapeles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _libroDetallado.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColores.primario,
        actions: [
          IconButton(
            icon: Icon(
              _libroFavorito ? Icons.favorite : Icons.favorite_border,
              color: _libroFavorito ? Colors.red : null,
            ),
            onPressed: _marcarComoFavorito,
            tooltip: 'Favorito',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartirLibro,
            tooltip: 'Compartir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del libro
            Center(
              child: Container(
                width: 200,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _libroDetallado.urlMiniatura != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _libroDetallado.urlMiniatura!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.book,
                              size: 60,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.book,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            if (_libroDetallado.esAudiolibro)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColores.secundario,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.headset, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Audiolibro',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // Título y autores
            Text(
              _libroDetallado.titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            if (_libroDetallado.autores.isNotEmpty)
              Text(
                'Por ${_libroDetallado.autores.join(', ')}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 16),

            // Calificación
            if (_libroDetallado.calificacionPromedio != null)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${_libroDetallado.calificacionPromedio!.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${_libroDetallado.numeroCalificaciones ?? 0} calificaciones)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Información adicional
            if (_libroDetallado.fechaPublicacion != null)
              _construirItemInfo(
                icono: Icons.calendar_today,
                texto: 'Publicado: ${_libroDetallado.fechaPublicacion}',
              ),

            if (_libroDetallado.numeroPaginas != null)
              _construirItemInfo(
                icono: Icons.article,
                texto: '${_libroDetallado.numeroPaginas} páginas',
              ),

            if (_libroDetallado.categorias.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _libroDetallado.categorias.map((cat) => Chip(
                    label: Text(cat, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColores.secundario.withOpacity(0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 8),

            // Descripción
            if (_libroDetallado.descripcion != null && _libroDetallado.descripcion!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColores.primario,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _libroDetallado.descripcion!,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),

            // Botón de Lectura (Gutendex o LibriVox)
            if (_libroDetallado.urlLectura != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _abrirUrlLectura,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.secundario,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_libroDetallado.esAudiolibro ? Icons.headset : Icons.open_in_browser),
                      const SizedBox(width: 8),
                      Text(
                        _libroDetallado.esAudiolibro ? 'Escuchar (LibriVox)' : 'Leer Online (Gratis)', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _libroGuardado ? null : _guardarLibro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _libroGuardado ? Colors.grey : AppColores.primario,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_libroGuardado ? Icons.check : Icons.bookmark_add),
                        const SizedBox(width: 8),
                        Text(_libroGuardado ? 'Ya guardado' : 'Guardar Libro'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _iniciarProgresoLectura,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColores.primario),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_libroDetallado.esAudiolibro ? Icons.play_circle_fill : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(_libroDetallado.esAudiolibro ? 'Comenzar a Escuchar' : 'Comenzar a Leer'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_cargandoDetalles)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}