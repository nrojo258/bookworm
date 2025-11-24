import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diseño.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;
    setState(() => _isLoading = true);

    try {
      _isLogin ? await _loginUser() : await _registerUser();
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _showSnackBar('Error inesperado: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Completa todos los campos', Colors.red);
      return false;
    }
    if (!_isLogin) {
      if (_nameController.text.isEmpty) {
        _showSnackBar('Ingresa tu nombre', Colors.red);
        return false;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showSnackBar('Las contraseñas no coinciden', Colors.red);
        return false;
      }
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('La contraseña debe tener al menos 6 caracteres', Colors.red);
      return false;
    }
    return true;
  }

  Future<void> _loginUser() async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (userCredential.user != null) {
      _showSnackBar('¡Bienvenido de vuelta!', Colors.green);
      _navigateToHome();
    }
  }

  Future<void> _registerUser() async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'preferences': {'genres': [], 'formats': []},
        'stats': {'booksRead': 0, 'readingTime': 0, 'currentStreak': 0}
      });
      _showSnackBar('¡Cuenta creada!', Colors.green);
      _navigateToHome();
    }
  }

  void _handleFirebaseError(FirebaseAuthException e) {
    final errorMessages = {
      'user-not-found': 'No existe una cuenta con este email',
      'wrong-password': 'Contraseña incorrecta',
      'email-already-in-use': 'Ya existe una cuenta con este email',
      'weak-password': 'La contraseña es demasiado débil',
      'invalid-email': 'El formato del email no es válido',
      'network-request-failed': 'Error de conexión',
      'too-many-requests': 'Demasiados intentos. Intenta más tarde',
    };
    
    _showSnackBar(errorMessages[e.code] ?? 'Error: ${e.message}', Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: color == Colors.green ? 2 : 3),
      ),
    );
  }

  void _navigateToHome() {Navigator.pushReplacementNamed(context, '/home');}

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, 
                        {bool obscureText = false, VoidCallback? onToggleVisibility}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: onToggleVisibility != null ? IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggleVisibility,
        ) : null,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
      ),
      obscureText: obscureText,
      enabled: !_isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
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
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.menu_book_rounded, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(_isLogin ? 'Iniciar Sesión' : 'Crear Cuenta', style: AppStyles.titleMedium),
                      const SizedBox(height: 10),
                      Text(
                        _isLogin ? 'Bienvenido de vuelta' : 'Únete a nuestra comunidad',
                        style: AppStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      
                      if (!_isLogin) ...[
                        _buildTextField(_nameController, 'Nombre', Icons.person),
                        const SizedBox(height: 15),
                      ],
                      
                      _buildTextField(_emailController, 'Correo electrónico', Icons.email),
                      const SizedBox(height: 15),
                      
                      _buildTextField(_passwordController, 'Contraseña', Icons.lock,
                        obscureText: _obscurePassword,
                        onToggleVisibility: _isLoading ? null : () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 15),
                      
                      if (!_isLogin) ...[
                        _buildTextField(_confirmPasswordController, 'Confirmar contraseña', Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: _isLoading ? null : () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        const SizedBox(height: 15),
                      ],
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
                            : ElevatedButton(
                                onPressed: _submitForm,
                                style: AppStyles.primaryButton,
                                child: Text(_isLogin ? 'Iniciar Sesión' : 'Crear Cuenta', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                      ),
                      if (!_isLoading) ..._buildAuthFooter(),
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

  List<Widget> _buildAuthFooter() {
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
          Text(_isLogin ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?', style: AppStyles.bodyMedium),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: _isLoading ? null : _toggleAuthMode,
            child: Text(
              _isLogin ? 'Regístrate' : 'Inicia Sesión',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ];
  }
}