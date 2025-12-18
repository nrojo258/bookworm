import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'diseño.dart';
import '../servicio/servicio_firestore.dart'; 
import '../modelos/datos_usuario.dart'; 

class Autenticacion extends StatefulWidget {
  const Autenticacion({super.key});

  @override
  State<Autenticacion> createState() => _EstadoPantallaAuth();
}

class _EstadoPantallaAuth extends State<Autenticacion> {
  final _controladorEmail = TextEditingController();
  final _controladorPassword = TextEditingController();
  final _controladorConfirmarPassword = TextEditingController();
  final _controladorNombre = TextEditingController();
  
  bool _esLogin = true;
  bool _passwordOculta = true;
  bool _confirmarPasswordOculta = true;
  bool _estaCargando = false;
  
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  
  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorPassword.dispose();
    _controladorConfirmarPassword.dispose();
    _controladorNombre.dispose();
    super.dispose();
  }

  void _alternarModoAuth() {
    setState(() {
      _esLogin = !_esLogin;
      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  Future<void> _enviarFormulario() async {
    if (!_validarFormulario()) return;
    setState(() => _estaCargando = true);

    try {
      _esLogin ? await _iniciarSesionUsuario() : await _registrarUsuario();
    } on FirebaseAuthException catch (e) {
      _manejarErrorFirebase(e);
    } catch (e) {
      _mostrarSnackBar('Error inesperado: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  bool _validarFormulario() {
    if (_controladorEmail.text.isEmpty || _controladorPassword.text.isEmpty) {
      _mostrarSnackBar('Completa todos los campos', Colors.red);
      return false;
    }
    if (!_esLogin) {
      if (_controladorNombre.text.isEmpty) {
        _mostrarSnackBar('Ingresa tu nombre', Colors.red);
        return false;
      }
      if (_controladorPassword.text != _controladorConfirmarPassword.text) {
        _mostrarSnackBar('Las contraseñas no coinciden', Colors.red);
        return false;
      }
    }
    if (_controladorPassword.text.length < 6) {
      _mostrarSnackBar('La contraseña debe tener al menos 6 caracteres', Colors.red);
      return false;
    }
    return true;
  }

  Future<void> _iniciarSesionUsuario() async {
    final credencialUsuario = await _auth.signInWithEmailAndPassword(
      email: _controladorEmail.text.trim(),
      password: _controladorPassword.text,
    );
    if (credencialUsuario.user != null) {
      _mostrarSnackBar('¡Bienvenido de vuelta!', Colors.green);
      _navegarAInicio();
    }
  }

  Future<void> _registrarUsuario() async {
    final credencialUsuario = await _auth.createUserWithEmailAndPassword(
      email: _controladorEmail.text.trim(),
      password: _controladorPassword.text,
    );

    if (credencialUsuario.user != null) {
      final datosUsuario = DatosUsuario(
        uid: credencialUsuario.user!.uid,
        nombre: _controladorNombre.text.trim(),
        correo: _controladorEmail.text.trim(),
        fechaCreacion: DateTime.now(),
        preferencias: {
          'generos': [],
          'formatos': ['fisico', 'audio'],
          'notificaciones': true,
        },

        estadisticas: {
          'librosLeidos': 0,
          'tiempoLectura': 0, 
          'rachaActual': 0, 
          'paginasTotales': 0,
        },
        
        generosFavoritos: [],
      );

      try {
        final servicioFirestore = ServicioFirestore();
        await servicioFirestore.crearUsuario(datosUsuario);
        _mostrarSnackBar('¡Cuenta creada exitosamente!', Colors.green);
        _navegarAInicio();
      } catch (e) {
        _mostrarSnackBar('Error al guardar datos: $e', Colors.red);
      }
    }
  } 

  Future<void> _iniciarSesionConGoogle() async {
    setState(() => _estaCargando = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el sign in
        setState(() => _estaCargando = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Verificar si es un usuario nuevo
        final servicioFirestore = ServicioFirestore();
        final datosUsuarioExistente = await servicioFirestore.obtenerDatosUsuario(user.uid);
        
        if (datosUsuarioExistente == null) {
          // Usuario nuevo, crear documento
          final datosUsuario = DatosUsuario(
            uid: user.uid,
            nombre: user.displayName ?? 'Usuario',
            correo: user.email ?? '',
            fechaCreacion: DateTime.now(),
            preferencias: {
              'generos': [],
              'formatos': ['fisico', 'audio'],
              'notificaciones': true,
            },
            estadisticas: {
              'librosLeidos': 0,
              'tiempoLectura': 0, 
              'rachaActual': 0, 
              'paginasTotales': 0,
            },
            generosFavoritos: [],
          );
          await servicioFirestore.crearUsuario(datosUsuario);
        }

        _mostrarSnackBar('¡Bienvenido!', Colors.green);
        _navegarAInicio();
      }
    } on FirebaseAuthException catch (e) {
      _manejarErrorFirebase(e);
    } catch (e) {
      _mostrarSnackBar('Error al iniciar sesión con Google: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  void _manejarErrorFirebase(FirebaseAuthException e) {
    final mensajesError = {
      'user-not-found': 'No existe una cuenta con este email',
      'wrong-password': 'Contraseña incorrecta',
      'email-already-in-use': 'Ya existe una cuenta con este email',
      'weak-password': 'La contraseña es demasiado débil',
      'invalid-email': 'El formato del email no es válido',
      'network-request-failed': 'Error de conexión',
      'too-many-requests': 'Demasiados intentos. Intenta más tarde',
    };
    
    _mostrarSnackBar(mensajesError[e.code] ?? 'Error: ${e.message}', Colors.red);
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: color == Colors.green ? 2 : 3),
      ),
    );
  }

  void _navegarAInicio() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  Widget _construirCampoTexto(TextEditingController controlador, String etiqueta, IconData icono, 
  {bool textoOculto = false, VoidCallback? alAlternarVisibilidad}) {
    return TextFormField(
      controller: controlador,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono, color: AppColores.primario),
        suffixIcon: alAlternarVisibilidad != null ? IconButton(
          icon: Icon(textoOculto ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: alAlternarVisibilidad,
        ) : null,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColores.primario)),
      ),
      obscureText: textoOculto,
      enabled: !_estaCargando,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColores.primario, AppColores.secundario],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColores.primario,
                        child: Icon(Icons.menu_book_rounded, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(_esLogin ? 'Iniciar Sesión' : 'Crear Cuenta', style: EstilosApp.tituloMedio),
                      const SizedBox(height: 10),
                      Text(
                        _esLogin ? 'Bienvenido de vuelta' : 'Únete a nuestra comunidad',
                        style: EstilosApp.cuerpoMedio,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      
                      if (!_esLogin) ...[
                        _construirCampoTexto(_controladorNombre, 'Nombre', Icons.person),
                        const SizedBox(height: 15),
                      ],
                      
                      _construirCampoTexto(_controladorEmail, 'Correo electrónico', Icons.email),
                      const SizedBox(height: 15),
                      
                      _construirCampoTexto(_controladorPassword, 'Contraseña', Icons.lock,
                        textoOculto: _passwordOculta,
                        alAlternarVisibilidad: _estaCargando ? null : () => setState(() => _passwordOculta = !_passwordOculta),
                      ),
                      const SizedBox(height: 15),
                      
                      if (!_esLogin) ...[
                        _construirCampoTexto(_controladorConfirmarPassword, 'Confirmar contraseña', Icons.lock_outline,
                          textoOculto: _confirmarPasswordOculta,
                          alAlternarVisibilidad: _estaCargando ? null : () => setState(() => _confirmarPasswordOculta = !_confirmarPasswordOculta),
                        ),
                        const SizedBox(height: 15),
                      ],
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _estaCargando
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColores.primario)))
                            : ElevatedButton(
                                onPressed: _enviarFormulario,
                                style: EstilosApp.botonPrimario,
                                child: Text(_esLogin ? 'Iniciar Sesión' : 'Crear Cuenta', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                      ),
                      if (!_estaCargando) ..._construirPieAuth(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _construirPieAuth() {
    return [
      const SizedBox(height: 20),
      const Row(children: [
        Expanded(child: Divider(color: Colors.grey)),
        Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('O', style: TextStyle(color: Colors.grey))),
        Expanded(child: Divider(color: Colors.grey)),
      ]),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_esLogin ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?', style: EstilosApp.cuerpoMedio),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: _estaCargando ? null : _alternarModoAuth,
            child: Text(
              _esLogin ? 'Regístrate' : 'Inicia Sesión',
              style: const TextStyle(color: AppColores.primario, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: _estaCargando ? null : _iniciarSesionConGoogle,
          icon: const Icon(Icons.g_mobiledata, color: Colors.red), // Icono aproximado para Google
          label: const Text('Continuar con Google'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ];
  }
}