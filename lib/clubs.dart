import 'package:flutter/material.dart';
import 'diseño.dart';
import 'componentes.dart';

class Clubs extends StatefulWidget {
  const Clubs({super.key});

  @override
  State<Clubs> createState() => _ClubsState();
}

class _ClubsState extends State<Clubs> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  int _seccionSeleccionada = 0;
  String? _generoSeleccionado;

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  void _mostrarCrearClub() {
    final controladorNombre = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear Nuevo Club', style: EstilosApp.tituloMedio),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Completa la información del club', style: EstilosApp.cuerpoMedio),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controladorNombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del club', 
                    prefixIcon: Icon(Icons.group, color: AppColores.primario)
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Género del club', 
                  style: EstilosApp.cuerpoGrande
                ),
                const SizedBox(height: 10),
                FiltroDesplegable(
                  valor: _generoSeleccionado,
                  items: DatosApp.generos,
                  hint: 'Selecciona un género',
                  alCambiar: (valor) => setState(() => _generoSeleccionado = valor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: controladorNombre.text.isEmpty || _generoSeleccionado == null ? null : () {
                _crearClub(controladorNombre.text, _generoSeleccionado!);
                Navigator.pop(context);
              },
              style: EstilosApp.botonPrimario,
              child: const Text('Crear Club'),
            ),
          ],
        ),
      ),
    );
  }

  void _crearClub(String nombre, String genero) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Club "$nombre" creado exitosamente'),
        backgroundColor: AppColores.secundario,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _generoSeleccionado = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        title: const Text('BookWorm', style: EstilosApp.tituloGrande),
        backgroundColor: AppColores.primario,
        automaticallyImplyLeading: false,
        actions: const [BotonesBarraApp(rutaActual: '/clubs')],
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Clubs de lectura', style: EstilosApp.tituloMedio),
                      ElevatedButton(
                        onPressed: _mostrarCrearClub,
                        style: EstilosApp.botonPrimario,
                        child: const Row(children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 4),
                          Text('Crear club', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descubre y únete a clubs con intereses similares', 
                    style: EstilosApp.cuerpoMedio
                  ),
                  const SizedBox(height: 20),
                  BarraBusquedaPersonalizada(
                    controlador: _controladorBusqueda,
                    textoHint: 'Buscar clubs...',
                    alBuscar: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: EstilosApp.decoracionTarjeta,
              child: Row(children: [
                Expanded(child: BotonSeccion(
                  texto: 'Descubrir clubs',
                  estaSeleccionado: _seccionSeleccionada == 0,
                  icono: Icons.explore,
                  alPresionar: () => setState(() => _seccionSeleccionada = 0),
                )),
                const SizedBox(width: 12),
                Expanded(child: BotonSeccion(
                  texto: 'Mis clubs',
                  estaSeleccionado: _seccionSeleccionada == 1,
                  icono: Icons.group,
                  alPresionar: () => setState(() => _seccionSeleccionada = 1),
                )),
              ]),
            ),
            const SizedBox(height: 20),

            _seccionSeleccionada == 0 ? _construirDescubrirClubs() : _construirMisClubs(),
          ],
        ),
      ),
    );
  }

  Widget _construirDescubrirClubs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.decoracionTarjeta,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clubs recomendados', style: EstilosApp.tituloMedio),
          SizedBox(height: 16),
          Text('Explora clubs basados en tus intereses', style: EstilosApp.cuerpoMedio),
          SizedBox(height: 20),
          EstadoVacio(
            icono: Icons.group,
            titulo: 'No se encontraron clubs',
            descripcion: 'Intenta con otros términos de búsqueda',
          ),
        ],
      ),
    );
  }

  Widget _construirMisClubs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.decoracionTarjeta,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mis clubs activos', style: EstilosApp.tituloMedio),
          SizedBox(height: 16),
          Text('Gestiona tus clubs de lectura actuales', style: EstilosApp.cuerpoMedio),
          SizedBox(height: 20),
          EstadoVacio(
            icono: Icons.group_add,
            titulo: 'No tienes clubs activos',
            descripcion: 'Únete a un club o crea uno nuevo',
          ),
        ],
      ),
    );
  }
}