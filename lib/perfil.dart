import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'diseño.dart';
import 'componentes.dart';
import '../servicio/servicio_firestore.dart';
import '../modelos/datos_usuario.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  int _seccionSeleccionada = 0;
  DatosUsuario? _datosUsuario;
  bool _estaCargando = true;
  final ServicioFirestore _servicioFirestore = ServicioFirestore();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Imagen seleccionada para subir
  File? _imagenSeleccionada;
  bool _subiendoImagen = false;

  // Referencia a FirebaseStorage
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      if (mounted) setState(() => _estaCargando = false);
      return;
    }

    try {
      final datos = await _servicioFirestore.obtenerDatosUsuario(usuario.uid);
      if (mounted) {
        setState(() {
          _datosUsuario = datos;
          _estaCargando = false;
        });
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galería'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Cámara'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null && mounted) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<String?> _subirImagenAFirebase(File imagen) async {
    try {
      setState(() => _subiendoImagen = true);

      final usuario = _auth.currentUser;
      if (usuario == null) {
        print('Usuario no autenticado');
        return null;
      }

      // Generar nombre único para el archivo
      final nombreArchivo =
          '${usuario.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Crear referencia al archivo en Firebase Storage
      final Reference ref = _storage.ref().child('imagenes_perfil/$nombreArchivo');
      
      // Subir el archivo
      final UploadTask uploadTask = ref.putFile(
        imagen,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'subidoPor': usuario.email ?? usuario.uid,
            'fechaSubida': DateTime.now().toString(),
          },
        ),
      );

      // Monitorear progreso de subida
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes * 100;
        print('Progreso de subida: $progress%');
      });

      // Esperar a que se complete la subida
      final TaskSnapshot snapshot = await uploadTask;
      
      // Obtener la URL de descarga
      final String url = await snapshot.ref.getDownloadURL();
      
      print('Imagen subida exitosamente. URL: $url');
      return url;
      
    } catch (e) {
      print('Error subiendo imagen: $e');
      
      // Manejar errores específicos
      if (e is FirebaseException) {
        print('Código de error: ${e.code}');
        print('Mensaje: ${e.message}');
      }
      
      return null;
    } finally {
      if (mounted) {
        setState(() => _subiendoImagen = false);
      }
    }
  }

  void _mostrarDialogoEditarPerfil() {
    final nombreCtrl = TextEditingController(text: _datosUsuario?.nombre ?? '');
    final biografiaCtrl = TextEditingController(text: _datosUsuario?.biografia ?? '');

    // Imagen temporal para vista previa en el diálogo
    File? imagenTemp = _imagenSeleccionada;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Editar Perfil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColores.primario.withOpacity(0.1),
                            backgroundImage: imagenTemp != null
                                ? FileImage(imagenTemp!)
                                : (_datosUsuario?.urlImagenPerfil != null &&
                                        _datosUsuario!.urlImagenPerfil!.isNotEmpty
                                    ? NetworkImage(_datosUsuario!.urlImagenPerfil!)
                                    : null) as ImageProvider?,
                            child: imagenTemp == null &&
                                    (_datosUsuario?.urlImagenPerfil == null ||
                                        _datosUsuario!.urlImagenPerfil!.isEmpty)
                                ? const Icon(Icons.person, size: 50, color: AppColores.primario)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                await _seleccionarImagen();
                                if (_imagenSeleccionada != null) {
                                  setStateDialog(() {
                                    imagenTemp = _imagenSeleccionada;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColores.primario,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: biografiaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Biografía',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _imagenSeleccionada = null);
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _subiendoImagen
                      ? null
                      : () async {
                          String? nuevaUrl = _datosUsuario?.urlImagenPerfil;

                          // Subir nueva imagen si se seleccionó una
                          if (imagenTemp != null) {
                            nuevaUrl = await _subirImagenAFirebase(imagenTemp!);
                            if (nuevaUrl == null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al subir la imagen'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          }

                          try {
                            // Preparar datos a actualizar
                            final Map<String, dynamic> datosActualizados = {
                              'nombre': nombreCtrl.text.trim(),
                              'biografia': biografiaCtrl.text.trim(),
                              'ultimaActualizacion': DateTime.now().toIso8601String(),
                            };

                            // Agregar URL de imagen si hay una nueva
                            if (nuevaUrl != null) {
                              datosActualizados['urlImagenPerfil'] = nuevaUrl;
                            }

                            // Actualizar en Firestore
                            await _servicioFirestore.actualizarDatosUsuario(
                              _auth.currentUser!.uid,
                              datosActualizados,
                            );

                            // Recargar datos
                            await _cargarDatosUsuario();
                            
                            if (mounted) {
                              setState(() => _imagenSeleccionada = null);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil actualizado correctamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            print('Error al actualizar perfil: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al actualizar: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.primario,
                  ),
                  child: _subiendoImagen
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Resto del código se mantiene igual...
  Future<void> _cerrarSesion() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Widget _construirEncabezadoPerfil() {
    if (_estaCargando) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: EstilosApp.tarjeta,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.tarjeta,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mi Perfil', style: EstilosApp.tituloMedio),
              ElevatedButton(
                onPressed: _mostrarDialogoEditarPerfil,
                style: EstilosApp.botonPrimario,
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 6),
                    Text('Editar perfil'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColores.primario.withOpacity(0.1),
                backgroundImage: _datosUsuario?.urlImagenPerfil != null &&
                        _datosUsuario!.urlImagenPerfil!.isNotEmpty
                    ? NetworkImage(_datosUsuario!.urlImagenPerfil!)
                    : null,
                child: _datosUsuario?.urlImagenPerfil == null ||
                        _datosUsuario!.urlImagenPerfil!.isEmpty
                    ? const Icon(Icons.person, size: 40, color: AppColores.primario)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _datosUsuario?.nombre ?? 'Usuario',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(_datosUsuario?.correo ?? '', style: EstilosApp.cuerpoMedio),
                    const SizedBox(height: 8),
                    Text(
                      '${_datosUsuario?.estadisticas['librosLeidos'] ?? 0} libros leídos',
                      style: TextStyle(color: AppColores.secundario),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirSelectorSeccion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EstilosApp.tarjeta,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: DatosApp.seccionesPerfil.asMap().entries.map((entry) {
            final index = entry.key;
            final seccion = entry.value;
            return Padding(
              padding: EdgeInsets.only(right: index < DatosApp.seccionesPerfil.length - 1 ? 8 : 0),
              child: BotonSeccion(
                texto: seccion['texto'] as String,
                estaSeleccionado: _seccionSeleccionada == index,
                icono: seccion['icono'] as IconData,
                alPresionar: () => setState(() => _seccionSeleccionada = index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirContenidoSeccion() {
    // Puedes ir añadiendo aquí tus secciones completas una a una
    // Por ahora, un placeholder simple
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.tarjeta,
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.construction, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Sección en desarrollo', style: EstilosApp.tituloMedio),
            Text('Pronto tendrás aquí toda tu información', style: EstilosApp.cuerpoMedio),
          ],
        ),
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
        actions: const [BotonesBarraApp(rutaActual: '/perfil')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _construirEncabezadoPerfil(),
            const SizedBox(height: 20),
            _construirSelectorSeccion(),
            const SizedBox(height: 20),
            _construirContenidoSeccion(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cerrarSesion,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}