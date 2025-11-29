import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'autenticación.dart';
import 'buscar.dart';
import 'clubs.dart';
import 'perfil.dart';
import 'diseño.dart';
import 'componentes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppBookWorm());
}

class AppBookWorm extends StatelessWidget {
  const AppBookWorm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookWorm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColores.primario,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColores.primario),
        scaffoldBackgroundColor: AppColores.fondo,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColores.primario, 
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(style: EstilosApp.botonPrimario),
      ),
      routes: {
        '/': (context) => const Autenticacion(),
        '/home': (context) => const PaginaInicio(),
        '/search': (context) => const Buscar(),
        '/clubs': (context) => const Clubs(),
        '/perfil': (context) => const Perfil(),
      },
      initialRoute: '/',
    );
  }
}

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text('BookWorm', style: EstilosApp.tituloGrande),
        ),
        actions: const [BotonesBarraApp(rutaActual: '/home')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColores.primario, AppColores.secundario],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bienvenido de vuelta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Continúa tu aventura literaria',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _construirBoton(
                              'Buscar libros', 
                              Icons.search, 
                              () => Navigator.pushNamed(context, '/search')
                            ),
                            const SizedBox(width: 12),
                            _construirBoton(
                              'Ver progreso', 
                              Icons.trending_up, 
                              () => Navigator.pushNamed(context, '/perfil')
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: EstilosApp.decoracionTarjeta,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acceso rápido',
                    style: EstilosApp.tituloMedio,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      final List<Map<String, dynamic>> accionesRapidas = [
                        {'icono': Icons.menu_book, 'etiqueta': 'Libros leídos'},
                        {'icono': Icons.flag, 'etiqueta': 'Meta semanal'},
                        {'icono': Icons.access_time, 'etiqueta': 'Tiempo leído'},
                        {'icono': Icons.local_fire_department, 'etiqueta': 'Días de racha'},
                      ];
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColores.fondo,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              accionesRapidas[index]['icono'],
                              size: 32,
                              color: AppColores.primario,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              accionesRapidas[index]['etiqueta'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: EstilosApp.decoracionTarjeta,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Mis lecturas actuales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: Text(
                              'No tienes lecturas en progreso',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: EstilosApp.decoracionTarjeta,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Actividad reciente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: Text(
                              'No hay actividad reciente',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirBoton(String texto, IconData icono, VoidCallback alPresionar) {
    return ElevatedButton(
      onPressed: alPresionar,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}