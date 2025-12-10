import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'diseño.dart';
import 'componentes.dart';

class ChatClub extends StatefulWidget {
  final String clubId;
  final String clubNombre;

  const ChatClub({
    super.key,
    required this.clubId,
    required this.clubNombre,
  });

  @override
  State<ChatClub> createState() => _ChatClubState();
}

class _ChatClubState extends State<ChatClub> {
  final TextEditingController _controladorMensaje = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controladorMensaje.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    if (_controladorMensaje.text.trim().isEmpty) return;

    final usuario = _auth.currentUser;
    if (usuario == null) return;

    try {
      await _firestore.collection('clubs').doc(widget.clubId).collection('mensajes').add({
        'texto': _controladorMensaje.text.trim(),
        'usuarioId': usuario.uid,
        'usuarioNombre': usuario.displayName ?? 'Usuario',
        'timestamp': FieldValue.serverTimestamp(),
        'leidoPor': [usuario.uid],
      });

      _controladorMensaje.clear();
      _scrollAlFinal();
    } catch (e) {
      print('Error enviando mensaje: $e');
    }
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _construirMensaje(DocumentSnapshot mensaje) {
    final datos = mensaje.data() as Map<String, dynamic>;
    final esMio = datos['usuarioId'] == _auth.currentUser?.uid;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!esMio)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColores.primario.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  datos['usuarioNombre'].toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColores.primario,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!esMio)
                  Text(
                    datos['usuarioNombre'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: esMio ? AppColores.primario : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    datos['texto'],
                    style: TextStyle(
                      fontSize: 14,
                      color: esMio ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (datos['timestamp'] != null)
                  Text(
                    _formatearFecha(datos['timestamp'].toDate()),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          if (esMio) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays > 0) {
      return '${diferencia.inDays}d';
    } else if (diferencia.inHours > 0) {
      return '${diferencia.inHours}h';
    } else if (diferencia.inMinutes > 0) {
      return '${diferencia.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clubNombre),
        backgroundColor: AppColores.primario,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('clubs')
                  .doc(widget.clubId)
                  .collection('mensajes')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error cargando mensajes'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const IndicadorCarga(mensaje: 'Cargando mensajes...');
                }

                final mensajes = snapshot.data?.docs ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    return _construirMensaje(mensajes[index]);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColores.fondo,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controladorMensaje,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _enviarMensaje(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _enviarMensaje,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColores.primario,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
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
}