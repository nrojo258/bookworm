import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  
  // Para manejo de imagen de perfil
  File? _imagenSeleccionada;
  bool _subiendoImagen = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final usuario = _auth.currentUser;
    if (usuario != null) {
      try {
        final datosUsuario = await _servicioFirestore.obtenerDatosUsuario(usuario.uid);
        setState(() {
          _datosUsuario = datosUsuario;
          _estaCargando = false;
        });
      } catch (e) {
        print('Error cargando datos: $e');
        setState(() {
          _estaCargando = false;
        });
      }
    } else {
      setState(() {
        _estaCargando = false;
      });
    }
  }

  void _mostrarDialogoEditarPerfil() {
    final TextEditingController controladorNombre = TextEditingController(text: _datosUsuario?.nombre ?? '');
    final TextEditingController controladorCorreo = TextEditingController(text: _datosUsuario?.correo ?? '');
    final TextEditingController controladorBiografia = TextEditingController(text: _datosUsuario?.biografia ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Editar Perfil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vista previa de imagen
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColores.primario.withOpacity(0.1),
                              border: Border.all(color: AppColores.primario, width: 2),
                            ),
                            child: _imagenSeleccionada != null
                              ? ClipOval(
                                  child: Image.file(
                                    _imagenSeleccionada!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _datosUsuario?.urlImagenPerfil != null && _datosUsuario!.urlImagenPerfil!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _datosUsuario!.urlImagenPerfil!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColores.primario,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.person, size: 50, color: AppColores.primario),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColores.primario,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                onPressed: _seleccionarImagen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controladorNombre,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controladorCorreo,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controladorBiografia,
                      decoration: const InputDecoration(labelText: 'Biografía'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _subiendoImagen ? null : () async {
                    String? urlImagen = _datosUsuario?.urlImagenPerfil;
                    
                    // Subir nueva imagen si fue seleccionada
                    if (_imagenSeleccionada != null) {
                      urlImagen = await _subirImagenAFirebase(_imagenSeleccionada!);
                      if (urlImagen == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al subir la imagen')),
                        );
                        return;
                      }
                    }
                    
                    final nuevosDatos = {
                      'nombre': controladorNombre.text.trim(),
                      'correo': controladorCorreo.text.trim(),
                      'biografia': controladorBiografia.text.trim(),
                      'urlImagenPerfil': urlImagen,
                    };
                    
                    try {
                      await _servicioFirestore.actualizarDatosUsuario(_auth.currentUser!.uid, nuevosDatos);
                      await _cargarDatosUsuario(); // Recargar datos
                      setState(() {
                        _imagenSeleccionada = null; // Limpiar imagen seleccionada
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil actualizado correctamente')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar perfil: $e')),
                      );
                    }
                  },
                  child: _subiendoImagen 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
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

  void _cambiarNotificaciones(bool valor) async {
    try {
      await _servicioFirestore.actualizarDatosUsuario(_auth.currentUser!.uid, {
        'preferencias': {
          ...?_datosUsuario?.preferencias,
          'notificaciones': valor,
        }
      });
      await _cargarDatosUsuario();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notificaciones ${valor ? 'activadas' : 'desactivadas'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cambiar notificaciones')),
      );
    }
  }

  void _mostrarDialogoPrivacidad() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configuración de Privacidad'),
          content: const Text('Aquí puedes configurar tu privacidad. Esta funcionalidad estará disponible próximamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoIdioma() {
    String idiomaSeleccionado = 'es'; // Por defecto español

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Seleccionar Idioma'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Español'),
                    value: 'es',
                    groupValue: idiomaSeleccionado,
                    onChanged: (value) {
                      setStateDialog(() => idiomaSeleccionado = value!);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'en',
                    groupValue: idiomaSeleccionado,
                    onChanged: (value) {
                      setStateDialog(() => idiomaSeleccionado = value!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Aquí iría la lógica para cambiar el idioma
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Idioma cambiado a ${idiomaSeleccionado == 'es' ? 'Español' : 'English'}')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoTema() {
    String temaSeleccionado = 'claro'; // Por defecto claro

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Seleccionar Tema'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Claro'),
                    value: 'claro',
                    groupValue: temaSeleccionado,
                    onChanged: (value) {
                      setStateDialog(() => temaSeleccionado = value!);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Oscuro'),
                    value: 'oscuro',
                    groupValue: temaSeleccionado,
                    onChanged: (value) {
                      setStateDialog(() => temaSeleccionado = value!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Aquí iría la lógica para cambiar el tema
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tema cambiado a ${temaSeleccionado == 'claro' ? 'Claro' : 'Oscuro'}')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sincronizarDatos() async {
    // Simular sincronización
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronizando datos...')),
    );
    
    // Aquí iría la lógica real de sincronización
    await Future.delayed(const Duration(seconds: 2));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos sincronizados correctamente')),
    );
  }

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ayuda y Soporte'),
          content: const Text('Para obtener ayuda, contacta con nuestro soporte técnico o visita nuestro centro de ayuda en línea.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cerrarSesion() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: const Text('¿De dónde quieres seleccionar la imagen?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
                if (imagen != null) {
                  setState(() {
                    _imagenSeleccionada = File(imagen.path);
                  });
                }
              },
              child: const Text('Galería'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final XFile? imagen = await picker.pickImage(source: ImageSource.camera);
                if (imagen != null) {
                  setState(() {
                    _imagenSeleccionada = File(imagen.path);
                  });
                }
              },
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _subirImagenAFirebase(File imagen) async {
    try {
      setState(() => _subiendoImagen = true);
      
      final String nombreArchivo = '${_auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance.ref().child('imagenes_perfil/$nombreArchivo');
      
      final UploadTask uploadTask = ref.putFile(imagen);
      final TaskSnapshot snapshot = await uploadTask;
      final String urlDescarga = await snapshot.ref.getDownloadURL();
      
      setState(() => _subiendoImagen = false);
      return urlDescarga;
    } catch (e) {
      setState(() => _subiendoImagen = false);
      print('Error al subir imagen: $e');
      return null;
    }
  }
  
  Widget _construirEncabezadoPerfil() {
    if (_estaCargando) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: EstilosApp.tarjeta,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
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
                child: const Row(children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 6),
                  Text('Editar perfil', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColores.primario.withOpacity(0.1),
                  border: Border.all(color: AppColores.primario, width: 2),
                ),
                child: _datosUsuario?.urlImagenPerfil != null && _datosUsuario!.urlImagenPerfil!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _datosUsuario!.urlImagenPerfil!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColores.primario,
                        ),
                      ),
                    )
                  : const Icon(Icons.person, size: 40, color: AppColores.primario),
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
                    Text(
                      _datosUsuario?.correo ?? 'email@ejemplo.com',
                      style: EstilosApp.cuerpoMedio,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_datosUsuario?.estadisticas['librosLeidos'] ?? 0} libros leídos', 
                      style: TextStyle(
                        fontSize: 12, 
                        color: AppColores.secundario, 
                        fontWeight: FontWeight.w500
                      ),
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
      child: Row(children: [
        for (int i = 0; i < DatosApp.seccionesPerfil.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: BotonSeccion(
            texto: DatosApp.seccionesPerfil[i]['texto'] as String,
            estaSeleccionado: _seccionSeleccionada == i,
            icono: DatosApp.seccionesPerfil[i]['icono'] as IconData,
            alPresionar: () => setState(() => _seccionSeleccionada = i),
          )),
        ],
      ]),
    );
  }

  Widget _construirContenidoSeccion() {
    final secciones = [
      _construirSeccionInformacion(),
      _construirSeccionProgreso(),
      _construirSeccionEstadisticas(),
      _construirSeccionPreferencias(),
      _construirSeccionConfiguracion(),
    ];
    return secciones[_seccionSeleccionada];
  }

  Widget _construirSeccionInformacion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.tarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información Personal', style: EstilosApp.tituloMedio),
          const SizedBox(height: 20),
          
          _construirTarjetaInfo(
            'Datos Personales',
            [
              _construirElementoInfo('Nombre completo', _datosUsuario?.nombre ?? 'No especificado'),
              _construirElementoInfo('Email', _datosUsuario?.correo ?? 'No especificado'),
              _construirElementoInfo('Fecha de registro', _datosUsuario?.fechaCreacion.toString().substring(0, 10) ?? 'No especificado'),
            ],
            Icons.person,
          ),
          const SizedBox(height: 20),
          
          _construirTarjetaInfo(
            'Biografía',
            [
              Text(
                _datosUsuario?.biografia.isNotEmpty == true ? _datosUsuario!.biografia : 'Completa tu biografía para que otros lectores te conozcan mejor.',
                style: EstilosApp.cuerpoMedio,
              ),
            ],
            Icons.description,
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaInfo(String titulo, List<Widget> contenido, IconData icono) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: EstilosApp.tarjetaPlana,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 20, color: AppColores.primario),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: EstilosApp.cuerpoGrande,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...contenido,
        ],
      )
    );
  }

  Widget _construirElementoInfo(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              etiqueta,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor.isEmpty ? 'No especificado' : valor,
              style: TextStyle(
                fontSize: 14,
                color: valor.isEmpty ? Colors.grey : Colors.black87,
                fontStyle: valor.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionProgreso() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.tarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mi Progreso de Lectura', style: EstilosApp.tituloMedio),
              ElevatedButton(
                onPressed: () {},
                style: EstilosApp.botonPrimario,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 6),
                    Text('Añadir libros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: EstilosApp.decoracionGradiente,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _construirElementoEstadistica(
                  '${_datosUsuario?.estadisticas['librosLeidos'] ?? 0}', 
                  'Libros leídos'
                ),
                _construirElementoEstadistica(
                  '${_datosUsuario?.estadisticas['paginasTotales'] ?? 0}', 
                  'Páginas'
                ),
                _construirElementoEstadistica(
                  '${_datosUsuario?.estadisticas['rachaActual'] ?? 0}', 
                  'Días racha'
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          _construirTarjetaProgreso(
            'Leyendo actualmente',
            'No hay libros en progreso',
            '0% completado',
            Icons.bookmark,
          ),
          const SizedBox(height: 16),
          
          _construirTarjetaProgreso(
            'Próximas lecturas',
            '0 libros en lista de espera',
            'Ver lista completa',
            Icons.queue,
          ),
          const SizedBox(height: 16),
          
          _construirTarjetaProgreso(
            'Completados este año',
            '0 libros terminados',
            'Ver historial',
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _construirElementoEstadistica(String valor, String etiqueta) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _construirTarjetaProgreso(String titulo, String subtitulo, String estado, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EstilosApp.tarjetaPlana,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColores.primario.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 20, color: AppColores.primario),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: EstilosApp.cuerpoGrande,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: EstilosApp.cuerpoMedio,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColores.secundario.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              estado,
              style: TextStyle(fontSize: 12, color: AppColores.secundario, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionEstadisticas() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.tarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas de Lectura', style: EstilosApp.tituloMedio),
          const SizedBox(height: 20),
          
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: EstilosApp.tarjetaPlana,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Gráfico de progreso mensual', style: EstilosApp.cuerpoMedio),
                  Text('Los datos se mostrarán aquí', style: EstilosApp.cuerpoPequeno),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(child: _construirTarjetaEstadistica('Géneros más leídos', 'No hay datos', Icons.category)),
              const SizedBox(width: 12),
              Expanded(child: _construirTarjetaEstadistica('Tiempo promedio', 'No hay datos', Icons.timer)),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _construirTarjetaEstadistica('Libros por mes', 'No hay datos', Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _construirTarjetaEstadistica('Páginas por día', 'No hay datos', Icons.menu_book)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaEstadistica(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EstilosApp.tarjetaPlana,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 24, color: AppColores.primario),
          const SizedBox(height: 8),
          Text(titulo, style: EstilosApp.cuerpoMedio),
          const SizedBox(height: 4),
          Text(valor, style: EstilosApp.tituloPequeno),
        ],
      ),
    );
  }

  Widget _construirSeccionPreferencias() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.tarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferencias de Lectura', style: EstilosApp.tituloMedio),
          const SizedBox(height: 20),
          
          // Formatos preferidos
          _construirTarjetaInfo(
            'Formatos Preferidos',
            [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _construirChipFormato('Físico', Icons.book, _datosUsuario?.preferencias['formatos']?.contains('fisico') ?? false),
                  _construirChipFormato('Digital', Icons.tablet, _datosUsuario?.preferencias['formatos']?.contains('digital') ?? false),
                  _construirChipFormato('Audiolibro', Icons.headphones, _datosUsuario?.preferencias['formatos']?.contains('audio') ?? false),
                ],
              ),
            ],
            Icons.format_list_bulleted,
          ),
          const SizedBox(height: 20),
          
          // Géneros favoritos
          _construirTarjetaInfo(
            'Géneros Favoritos',
            [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _construirChipGenero('Ficción', _datosUsuario?.generosFavoritos?.contains('ficcion') ?? false),
                  _construirChipGenero('No Ficción', _datosUsuario?.generosFavoritos?.contains('no_ficcion') ?? false),
                  _construirChipGenero('Ciencia Ficción', _datosUsuario?.generosFavoritos?.contains('ciencia_ficcion') ?? false),
                  _construirChipGenero('Fantasía', _datosUsuario?.generosFavoritos?.contains('fantasia') ?? false),
                  _construirChipGenero('Romance', _datosUsuario?.generosFavoritos?.contains('romance') ?? false),
                  _construirChipGenero('Misterio', _datosUsuario?.generosFavoritos?.contains('misterio') ?? false),
                  _construirChipGenero('Biografía', _datosUsuario?.generosFavoritos?.contains('biografia') ?? false),
                  _construirChipGenero('Historia', _datosUsuario?.generosFavoritos?.contains('historia') ?? false),
                ],
              ),
            ],
            Icons.category,
          ),
          const SizedBox(height: 20),
          
          // Objetivos de lectura
          _construirTarjetaInfo(
            'Objetivos de Lectura',
            [
              ElementoConfiguracion(
                titulo: 'Libros por mes',
                subtitulo: 'Establece tu meta mensual',
                icono: Icons.flag,
                alPresionar: _mostrarDialogoObjetivos,
              ),
              ElementoConfiguracion(
                titulo: 'Recordatorios diarios',
                subtitulo: 'Recuérdame leer todos los días',
                icono: Icons.schedule,
                tieneSwitch: true,
                valorSwitch: _datosUsuario?.preferencias['recordatorios'] ?? false,
                alCambiarSwitch: _cambiarRecordatorios,
              ),
            ],
            Icons.track_changes,
          ),
          const SizedBox(height: 20),
          
          // Horarios de lectura
          _construirTarjetaInfo(
            'Horarios Preferidos',
            [
              ElementoConfiguracion(
                titulo: 'Horario de lectura',
                subtitulo: 'Establece tus horarios favoritos',
                icono: Icons.access_time,
                alPresionar: _mostrarDialogoHorarios,
              ),
            ],
            Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget _construirChipFormato(String formato, IconData icono, bool seleccionado) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16),
          const SizedBox(width: 4),
          Text(formato),
        ],
      ),
      selected: seleccionado,
      onSelected: (bool value) => _cambiarFormatoPreferido(formato.toLowerCase(), value),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColores.primario.withOpacity(0.2),
      checkmarkColor: AppColores.primario,
    );
  }

  Widget _construirChipGenero(String genero, bool seleccionado) {
    return FilterChip(
      label: Text(genero),
      selected: seleccionado,
      onSelected: (bool value) => _cambiarGeneroFavorito(genero.toLowerCase().replaceAll(' ', '_'), value),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColores.primario.withOpacity(0.2),
      checkmarkColor: AppColores.primario,
    );
  }

  void _cambiarFormatoPreferido(String formato, bool agregar) async {
    try {
      List<String> formatosActuales = List<String>.from(_datosUsuario?.preferencias['formatos'] ?? []);
      
      if (agregar) {
        if (!formatosActuales.contains(formato)) {
          formatosActuales.add(formato);
        }
      } else {
        formatosActuales.remove(formato);
      }
      
      await _servicioFirestore.actualizarDatosUsuario(_auth.currentUser!.uid, {
        'preferencias': {
          ...?_datosUsuario?.preferencias,
          'formatos': formatosActuales,
        }
      });
      
      await _cargarDatosUsuario();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar formatos preferidos')),
      );
    }
  }

  void _cambiarGeneroFavorito(String genero, bool agregar) async {
    try {
      List<String> generosActuales = List<String>.from(_datosUsuario?.generosFavoritos ?? []);
      
      if (agregar) {
        if (!generosActuales.contains(genero)) {
          generosActuales.add(genero);
        }
      } else {
        generosActuales.remove(genero);
      }
      
      await _servicioFirestore.actualizarDatosUsuario(_auth.currentUser!.uid, {
        'generosFavoritos': generosActuales,
      });
      
      await _cargarDatosUsuario();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar géneros favoritos')),
      );
    }
  }

  void _cambiarRecordatorios(bool valor) async {
    try {
      await _servicioFirestore.actualizarDatosUsuario(_auth.currentUser!.uid, {
        'preferencias': {
          ...?_datosUsuario?.preferencias,
          'recordatorios': valor,
        }
      });
      await _cargarDatosUsuario();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recordatorios ${valor ? 'activados' : 'desactivados'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cambiar recordatorios')),
      );
    }
  }

  void _mostrarDialogoObjetivos() {
    int librosPorMes = _datosUsuario?.preferencias['libros_por_mes'] ?? 1;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Establecer Objetivos'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¿Cuántos libros quieres leer por mes?'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (librosPorMes > 1) {
                            librosPorMes--;
                            setStateDialog(() {});
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          librosPorMes.toString(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (librosPorMes < 50) {
                            librosPorMes++;
                            setStateDialog(() {});
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _servicioFirestore.actualizarDatosUsuario(_auth.currentUser!.uid, {
                        'preferencias': {
                          ...?_datosUsuario?.preferencias,
                          'libros_por_mes': librosPorMes,
                        }
                      });
                      await _cargarDatosUsuario();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Objetivo establecido: $librosPorMes libros por mes')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al guardar objetivo')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoHorarios() {
    TimeOfDay horaInicio = _datosUsuario?.preferencias['hora_inicio'] != null 
      ? TimeOfDay(
          hour: _datosUsuario!.preferencias['hora_inicio']['hora'] ?? 9,
          minute: _datosUsuario!.preferencias['hora_inicio']['minuto'] ?? 0,
        )
      : const TimeOfDay(hour: 9, minute: 0);
    
    TimeOfDay horaFin = _datosUsuario?.preferencias['hora_fin'] != null
      ? TimeOfDay(
          hour: _datosUsuario!.preferencias['hora_fin']['hora'] ?? 22,
          minute: _datosUsuario!.preferencias['hora_fin']['minuto'] ?? 0,
        )
      : const TimeOfDay(hour: 22, minute: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Horarios de Lectura'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Hora de inicio'),
                    subtitle: Text(horaInicio.format(context)),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: horaInicio,
                      );
                      if (picked != null) {
                        horaInicio = picked;
                        setStateDialog(() {});
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Hora de fin'),
                    subtitle: Text(horaFin.format(context)),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: horaFin,
                      );
                      if (picked != null) {
                        horaFin = picked;
                        setStateDialog(() {});
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _servicioFirestore.actualizarDatosUsuario(_auth.currentUser!.uid, {
                        'preferencias': {
                          ...?_datosUsuario?.preferencias,
                          'hora_inicio': {'hora': horaInicio.hour, 'minuto': horaInicio.minute},
                          'hora_fin': {'hora': horaFin.hour, 'minuto': horaFin.minute},
                        }
                      });
                      await _cargarDatosUsuario();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Horarios guardados correctamente')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al guardar horarios')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _construirSeccionConfiguracion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.tarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configuración', style: EstilosApp.tituloMedio),
          const SizedBox(height: 20),
          
          ElementoConfiguracion(
            titulo: 'Notificaciones',
            subtitulo: 'Gestiona las notificaciones de la app',
            icono: Icons.notifications,
            tieneSwitch: true,
            valorSwitch: _datosUsuario?.preferencias['notificaciones'] ?? true,
            alCambiarSwitch: _cambiarNotificaciones,
          ),
          ElementoConfiguracion(
            titulo: 'Privacidad',
            subtitulo: 'Controla tu información personal',
            icono: Icons.privacy_tip,
            alPresionar: _mostrarDialogoPrivacidad,
          ),
          ElementoConfiguracion(
            titulo: 'Idioma',
            subtitulo: 'Español',
            icono: Icons.language,
            alPresionar: _mostrarDialogoIdioma,
          ),
          ElementoConfiguracion(
            titulo: 'Tema',
            subtitulo: 'Claro',
            icono: Icons.palette,
            alPresionar: _mostrarDialogoTema,
          ),
          ElementoConfiguracion(
            titulo: 'Sincronización',
            subtitulo: 'Última sincronización: hoy',
            icono: Icons.sync,
            alPresionar: _sincronizarDatos,
          ),
          ElementoConfiguracion(
            titulo: 'Ayuda y soporte',
            subtitulo: 'Centro de ayuda y contacto',
            icono: Icons.help,
            alPresionar: _mostrarAyuda,
          ),
          const SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _cerrarSesion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cerrar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
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
          ],
        ),
      ),
    );
  }
}