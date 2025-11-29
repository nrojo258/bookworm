import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/datos_usuario.dart';
import '../modelos/progreso_lectura.dart';

class ServicioFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> crearUsuario(DatosUsuario datosUsuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(datosUsuario.uid)
          .set(datosUsuario.toMap());
      print('✅ Usuario creado en Firestore: ${datosUsuario.uid}');
    } catch (e) {
      print('❌ Error al crear usuario: $e');
      throw Exception('Error al crear usuario: $e');
    }
  }

  Future<DatosUsuario?> obtenerDatosUsuario(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        print('✅ Usuario obtenido de Firestore: ${doc.data()}');
        return DatosUsuario.fromMap(doc.data()!);
      }
      print('⚠️ Usuario no encontrado en Firestore');
      return null;
    } catch (e) {
      print('❌ Error al obtener usuario: $e');
      throw Exception('Error al obtener usuario: $e');
    }
  }

  Future<void> actualizarEstadisticasUsuario(String uid, Map<String, dynamic> nuevasEstadisticas) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update({'estadisticas': nuevasEstadisticas});
      print('✅ Estadísticas actualizadas');
    } catch (e) {
      print('❌ Error al actualizar stats: $e');
      throw Exception('Error al actualizar stats: $e');
    }
  }

  Future<void> guardarProgresoLectura(ProgresoLectura progreso) async {
    try {
      await _firestore
          .collection('progreso_lectura')
          .doc(progreso.id)
          .set(progreso.toMap());
      print('✅ Progreso guardado: ${progreso.tituloLibro}');
    } catch (e) {
      print('❌ Error al guardar progreso: $e');
      throw Exception('Error al guardar progreso: $e');
    }
  }

  Stream<List<ProgresoLectura>> obtenerProgresoLecturaUsuario(String usuarioId) {
    return _firestore
        .collection('progreso_lectura')
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fechaInicio', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProgresoLectura.fromMap(doc.data()))
            .toList());
  }

  Future<List<ProgresoLectura>> obtenerLibrosCompletados(String usuarioId) async {
    try {
      final snapshot = await _firestore
          .collection('progreso_lectura')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('estado', isEqualTo: 'completado')
          .get();
      
      return snapshot.docs
          .map((doc) => ProgresoLectura.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener libros completados: $e');
      throw Exception('Error al obtener libros completados: $e');
    }
  }

  Future<void> actualizarEstadoLectura({
    required String progresoId,
    required String estado,
    int? paginaActual,
    DateTime? fechaCompletado,
  }) async {
    try {
      final datosActualizacion = <String, dynamic>{'estado': estado};
      
      if (paginaActual != null) {
        datosActualizacion['paginaActual'] = paginaActual;
      }
      
      if (fechaCompletado != null) {
        datosActualizacion['fechaCompletado'] = Timestamp.fromDate(fechaCompletado);
      }

      await _firestore
          .collection('progreso_lectura')
          .doc(progresoId)
          .update(datosActualizacion);
      print('✅ Estado de lectura actualizado: $estado');
    } catch (e) {
      print('❌ Error al actualizar estado: $e');
      throw Exception('Error al actualizar estado: $e');
    }
  }

  Future<ProgresoLectura?> obtenerProgresoLibro(String usuarioId, String libroId) async {
    try {
      final snapshot = await _firestore
          .collection('progreso_lectura')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('libroId', isEqualTo: libroId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ProgresoLectura.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('❌ Error al verificar progreso: $e');
      return null;
    }
  }

  Future<List<ProgresoLectura>> obtenerLibrosEnProgreso(String usuarioId) async {
    try {
      final snapshot = await _firestore
          .collection('progreso_lectura')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('estado', isEqualTo: 'leyendo')
          .get();

      return snapshot.docs
          .map((doc) => ProgresoLectura.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener libros en progreso: $e');
      return [];
    }
  }
}