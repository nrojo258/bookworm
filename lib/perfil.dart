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
    );
  }
}