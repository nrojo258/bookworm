import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'buscar.dart'; 
import 'clubs.dart'; 
import 'perfil.dart';

const Color _kBlockColor = Color(0xFFE0E0E0);
const TextStyle _kLinkStyle = TextStyle(fontSize: 18, color: Colors.black54);
const TextStyle _kHeaderStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54);
const double _kSpacing = 20.0; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BookWormApp());
}

class BookWormApp extends StatelessWidget {
  const BookWormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookWorm',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color(0xFFF0F0F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      routes: {
        '/': (context) => const BookWormHomePage(),
        '/search': (context) => const Buscar(),
        '/clubs': (context) => const Clubs(), 
        '/perfil': (context) => const Perfil(), 
      },
      initialRoute: '/',
    );
  }
}

class BookWormHomePage extends StatelessWidget {
  const BookWormHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text(
          'BookWorm',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pushNamed(context, '/search'), child: const Text('Buscar', style: _kLinkStyle)),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/clubs'), child: const Text('Clubs', style: _kLinkStyle)), 
          TextButton(onPressed: () => Navigator.pushNamed(context, '/perfil'), child: const Text('Perfil', style: _kLinkStyle)), 
          const SizedBox(width: _kSpacing),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_kSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Container(
              height: 150, 
              color: _kBlockColor,
              margin: const EdgeInsets.only(bottom: _kSpacing),
              padding: const EdgeInsets.symmetric(horizontal: _kSpacing),
              alignment: Alignment.bottomLeft,
              child: Row(
                children: <Widget>[
                  InkWell( 
                    onTap: () => Navigator.pushNamed(context, '/search'),
                    child: const Text(
                      'Buscar libros', 
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 30),
                  InkWell( 
                    onTap: () => Navigator.pushNamed(context, '/progress'),
                    child: const Text(
                      'Ver progreso', 
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: _kSpacing,
                mainAxisSpacing: _kSpacing,
                childAspectRatio: 1.0,
              ),
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return const Card(
                  color: _kBlockColor,
                  elevation: 0,
                );
              },
            ),
            const SizedBox(height: _kSpacing),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 250,
                    color: _kBlockColor,
                    padding: const EdgeInsets.all(_kSpacing),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Mis lecturas actuales', style: _kHeaderStyle),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: _kSpacing),

                Expanded(
                  flex: 1,
                  child: Container(
                    height: 250,
                    color: _kBlockColor,
                    padding: const EdgeInsets.all(_kSpacing),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Actividad reciente', style: _kHeaderStyle),
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
}
