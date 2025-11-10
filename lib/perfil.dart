import 'package:flutter/material.dart';

const Color _kBlockColor = Color(0xFFE0E0E0);
const TextStyle _kLinkStyle = TextStyle(fontSize: 18, color: Colors.black54);
const TextStyle _kHeaderStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54);
const double _kSpacing = 20.0; 

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BookWorm',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.popAndPushNamed(context, '/search'), child: const Text('Buscar', style: _kLinkStyle)),
          TextButton(onPressed: () => Navigator.popAndPushNamed(context, '/clubs'), child: const Text('Clubs', style: _kLinkStyle)),
          TextButton(onPressed: () {}, child: const Text('Perfil', style: TextStyle(fontSize: 18, color: Colors.black))), 
          const SizedBox(width: _kSpacing),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_kSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Mi Perfil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kBlockColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: (){},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Editar perfil',
                      style: TextStyle(fontSize: 16, color: Colors.black54)
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _kSpacing),
          
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/informacion'),
                  child: const Text('Información', style: _kLinkStyle),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/miProgreso'),
                  child: const Text('Mi Progreso', style: _kLinkStyle),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/estadisticas'),
                  child: const Text('Estadísticas', style: _kLinkStyle),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/configuracion'),
                  child: const Text('Configuración', style: _kLinkStyle),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}