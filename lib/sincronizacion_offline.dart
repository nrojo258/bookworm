import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'diseño.dart';
import 'componentes.dart';
import '../modelos/datos_usuario.dart';
import '../modelos/progreso_lectura.dart';

class SincronizacionOffline {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();
  late Box _cajaLocal;

  Future<void> inicializar() async {
    _cajaLocal = await Hive.openBox('datos_offline');
    await _verificarConexionYSincronizar();
  }

  Future<bool> tieneConexion() async {
    final resultado = await _connectivity.checkConnectivity();
    return resultado != ConnectivityResult.none;
  }

  Future<void> guardarLocalmente<T>(String clave, T datos) async {
    await _cajaLocal.put(clave, datos);
  }

  Future<T?> obtenerLocalmente<T>(String clave) async {
    return _cajaLocal.get(clave);
  }

  Future<void> guardarProgresoOffline(ProgresoLectura progreso) async {
    final tieneInternet = await tieneConexion();
    
    if (tieneInternet) {
      await _firestore
          .collection('progreso_lectura')
          .doc(progreso.id)
          .set(progreso.toMap());
    } 
    
    else {
      final progresosPendientes = await obtenerLocalmente<List<Map<String, dynamic>>>('progresos_pendientes') ?? [];
      progresosPendientes.add(progreso.toMap());
      await guardarLocalmente('progresos_pendientes', progresosPendientes);
      
      final misProgresos = await obtenerLocalmente<List<Map<String, dynamic>>>('mis_progresos') ?? [];
      misProgresos.add(progreso.toMap());
      await guardarLocalmente('mis_progresos', misProgresos);
    }
  }

  Future<void> guardarMensajeOffline(Map<String, dynamic> mensaje) async {
    final tieneInternet = await tieneConexion();
    
    if (tieneInternet) {
      await _firestore
          .collection('clubs')
          .doc(mensaje['clubId'])
          .collection('mensajes')
          .add(mensaje);
    } 
    
    else {
      final mensajesPendientes = await obtenerLocalmente<List<Map<String, dynamic>>>('mensajes_pendientes') ?? [];
      mensajesPendientes.add(mensaje);
      await guardarLocalmente('mensajes_pendientes', mensajesPendientes);
    }
  }

  Future<void> sincronizarDatosPendientes() async {
    final tieneInternet = await tieneConexion();
    if (!tieneInternet) return;

    final progresosPendientes = await obtenerLocalmente<List<Map<String, dynamic>>>('progresos_pendientes');
    if (progresosPendientes != null && progresosPendientes.isNotEmpty) {
      for (final progresoData in progresosPendientes) {
        try {
          final progreso = ProgresoLectura.fromMap(progresoData);
          await _firestore
              .collection('progreso_lectura')
              .doc(progreso.id)
              .set(progreso.toMap());
        } 
        
        catch (e) {
          print('Error sincronizando progreso: $e');
        }
      }
      await guardarLocalmente('progresos_pendientes', []);
    }

    final mensajesPendientes = await obtenerLocalmente<List<Map<String, dynamic>>>('mensajes_pendientes');
    if (mensajesPendientes != null && mensajesPendientes.isNotEmpty) {
      for (final mensaje in mensajesPendientes) {
        try {
          await _firestore
              .collection('clubs')
              .doc(mensaje['clubId'])
              .collection('mensajes')
              .add(mensaje);
        } 
        
        catch (e) {
          print('Error sincronizando mensaje: $e');
        }
      }
      await guardarLocalmente('mensajes_pendientes', []);
    }
  }

  Future<List<ProgresoLectura>> obtenerProgresosOffline() async {
    final tieneInternet = await tieneConexion();
    
    if (tieneInternet) {
      final usuario = _auth.currentUser;
      if (usuario == null) return [];
      
      final snapshot = await _firestore
          .collection('progreso_lectura')
          .where('usuarioId', isEqualTo: usuario.uid)
          .get();
      
      final progresos = snapshot.docs.map((doc) => ProgresoLectura.fromMap(doc.data())).toList();
      await guardarLocalmente(
        'mis_progresos',
        progresos.map((p) => p.toMap()).toList()
      );
      
      return progresos;
    } 
    
    else {
      final progresosData = await obtenerLocalmente<List<Map<String, dynamic>>>('mis_progresos');
      if (progresosData == null) return [];
      
      return progresosData.map((data) => ProgresoLectura.fromMap(data)).toList();
    }
  }

  Future<List<Map<String, dynamic>>> obtenerMensajesOffline(String clubId) async {
    final tieneInternet = await tieneConexion();
    
    if (tieneInternet) {
      final snapshot = await _firestore
          .collection('clubs')
          .doc(clubId)
          .collection('mensajes')
          .orderBy('timestamp')
          .get();
      
      final mensajes = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      await guardarLocalmente('mensajes_$clubId', mensajes);
      
      return mensajes;
    } 
    
    else {
      final mensajes = await obtenerLocalmente<List<Map<String, dynamic>>>('mensajes_$clubId');
      return mensajes ?? [];
    }
  }

  Future<void> _verificarConexionYSincronizar() async {
    _connectivity.onConnectivityChanged.listen((resultado) async {
      if (resultado != ConnectivityResult.none) {
        await sincronizarDatosPendientes();
      }
    });
  }
}

class PantallaSincronizacion extends StatefulWidget {
  const PantallaSincronizacion({super.key});

  @override
  State<PantallaSincronizacion> createState() => _PantallaSincronizacionState();
}

class _PantallaSincronizacionState extends State<PantallaSincronizacion> {
  final SincronizacionOffline _sincronizacion = SincronizacionOffline();
  bool _estaSincronizando = false;
  bool _tieneConexion = true;

  @override
  void initState() {
    super.initState();
    _verificarEstadoConexion();
    _sincronizacion.inicializar();
  }

  Future<void> _verificarEstadoConexion() async {
    final tieneConexion = await _sincronizacion.tieneConexion();
    setState(() {
      _tieneConexion = tieneConexion;
    });
  }

  Future<void> _sincronizarManual() async {
    setState(() => _estaSincronizando = true);
    try {
      await _sincronizacion.sincronizarDatosPendientes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Datos sincronizados exitosamente'),
          backgroundColor: AppColores.secundario,
        ),
      );
    } 
    
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sincronizando: $e'),
          backgroundColor: AppColores.rojo,
        ),
      );
    } finally {
      setState(() => _estaSincronizando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización'),
        backgroundColor: AppColores.primario,
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
                  Row(
                    children: [
                      Icon(
                        _tieneConexion ? Icons.wifi : Icons.wifi_off,
                        color: _tieneConexion ? AppColores.secundario : AppColores.rojo,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tieneConexion ? 'Conectado' : 'Sin conexión',
                              style: EstilosApp.tituloPequeno,
                            ),
                            Text(
                              _tieneConexion 
                                ? 'Los cambios se guardan automáticamente'
                                : 'Los cambios se guardarán cuando reconectes',
                              style: EstilosApp.cuerpoMedio,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _tieneConexion && !_estaSincronizando ? _sincronizarManual : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: _tieneConexion ? AppColores.primario : Colors.grey,
                    ),
                    child: _estaSincronizando
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(width: 12),
                              Text('Sincronizando...'),
                            ],
                          )
                        : const Text('Sincronizar ahora'),
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
                    'Modo Offline',
                    style: EstilosApp.tituloMedio,
                  ),
                  const SizedBox(height: 16),
                  const ElementoConfiguracion(
                    titulo: 'Guardado automático',
                    subtitulo: 'Guarda cambios localmente sin conexión',
                    icono: Icons.save,
                    tieneSwitch: true,
                    valorSwitch: true,
                  ),
                  const ElementoConfiguracion(
                    titulo: 'Sincronización en segundo plano',
                    subtitulo: 'Sincroniza automáticamente al reconectar',
                    icono: Icons.sync,
                    tieneSwitch: true,
                    valorSwitch: true,
                  ),
                  const ElementoConfiguracion(
                    titulo: 'Limpiar caché',
                    subtitulo: 'Liberar espacio de almacenamiento',
                    icono: Icons.cleaning_services,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}