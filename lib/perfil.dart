import 'package:flutter/material.dart';
import 'diseño.dart';
import 'componentes.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  int _seccionSeleccionada = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      appBar: AppBar(
        title: const Text('BookWorm', style: EstilosApp.tituloGrande),
        backgroundColor: AppColores.primario,
        automaticallyImplyLeading: false,
        actions: const [BotonesBarraApp(rutaActual: '/perfil')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _construirEncabezadoPerfil(),
            const SizedBox(height: 20),
            _construirSelectorSeccion(),
            const SizedBox(height: 20),
            _construirContenidoSeccion(),
          ],
        ),
      ),
    );
  }

  Widget _construirEncabezadoPerfil() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.decoracionTarjeta,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mi Perfil', style: EstilosApp.tituloMedio),
              ElevatedButton(
                onPressed: () {},
                style: EstilosApp.botonPrimario,
                child: const Row(children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 6),
                  Text('Editar perfil', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColores.primario.withOpacity(0.1),
                  border: Border.all(color: AppColores.primario, width: 2),
                ),
                child: const Icon(Icons.person, size: 40, color: AppColores.primario),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre del usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('email@ejemplo.com', style: EstilosApp.cuerpoMedio),
                    SizedBox(height: 8),
                    Text(
                      'Lector activo', 
                      style: TextStyle(fontSize: 12, color: AppColores.secundario, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirSelectorSeccion() {
    final secciones = [
      {'texto': 'Información', 'icono': Icons.person_outline},
      {'texto': 'Mi Progreso', 'icono': Icons.trending_up},
      {'texto': 'Estadísticas', 'icono': Icons.analytics},
      {'texto': 'Configuración', 'icono': Icons.settings},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EstilosApp.decoracionTarjeta,
      child: Row(children: [
        for (int i = 0; i < secciones.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: BotonSeccion(
            texto: secciones[i]['texto'] as String,
            estaSeleccionado: _seccionSeleccionada == i,
            icono: secciones[i]['icono'] as IconData,
            alPresionar: () => setState(() => _seccionSeleccionada = i),
          )),
        ],
      ]),
    );
  }

  Widget _construirContenidoSeccion() {
    final secciones = [
      _construirSeccionInformacion(),
      _construirSeccionProgreso(),
      _construirSeccionEstadisticas(),
      _construirSeccionConfiguracion(),
    ];
    return secciones[_seccionSeleccionada];
  }

  Widget _construirSeccionInformacion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.decoracionTarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información Personal', style: EstilosApp.tituloMedio),
          const SizedBox(height: 20),
          
          _construirTarjetaInfo(
            'Datos Personales',
            [
              _construirElementoInfo('Nombre completo', ''),
              _construirElementoInfo('Email', ''),
              _construirElementoInfo('Fecha de registro', ''),
            ],
            Icons.person,
          ),
          const SizedBox(height: 20),
          
          _construirTarjetaInfo(
            'Biografía',
            [
              const Text(
                'Completa tu biografía para que otros lectores te conozcan mejor.',
                style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              ),
            ],
            Icons.description,
          ),
          const SizedBox(height: 20),
          
          _construirTarjetaInfo(
            'Preferencias de Lectura',
            [
              _construirElementoPreferencia('Géneros favoritos', ''),
              _construirElementoPreferencia('Formato preferido', ''),
              _construirElementoPreferencia('Idiomas', ''),
              _construirElementoPreferencia('Metas de lectura', ''),
            ],
            Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaInfo(String titulo, List<Widget> contenido, IconData icono) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColores.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 20, color: AppColores.primario),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...contenido,
        ],
      ),
    );
  }

  Widget _construirElementoInfo(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              etiqueta,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor.isEmpty ? 'No especificado' : valor,
              style: TextStyle(
                fontSize: 14,
                color: valor.isEmpty ? Colors.grey : Colors.black87,
                fontStyle: valor.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirElementoPreferencia(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              etiqueta,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor.isEmpty ? 'No especificado' : valor,
              style: TextStyle(
                fontSize: 14,
                color: valor.isEmpty ? Colors.grey : Colors.black87,
                fontStyle: valor.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionProgreso() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.decoracionTarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mi Progreso de Lectura', style: EstilosApp.tituloMedio),
              ElevatedButton(
                onPressed: () {},
                style: EstilosApp.botonPrimario,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 6),
                    Text('Añadir libros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColores.primario.withOpacity(0.8), AppColores.secundario],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _construirElementoEstadistica('0', 'Libros leídos'),
                _construirElementoEstadistica('0', 'Páginas'),
                _construirElementoEstadistica('0', 'Días racha'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          _construirTarjetaProgreso(
            'Leyendo actualmente',
            'No hay libros en progreso',
            '0% completado',
            Icons.bookmark,
          ),
          const SizedBox(height: 16),
          
          _construirTarjetaProgreso(
            'Próximas lecturas',
            '0 libros en lista de espera',
            'Ver lista completa',
            Icons.queue,
          ),
          const SizedBox(height: 16),
          
          _construirTarjetaProgreso(
            'Completados este año',
            '0 libros terminados',
            'Ver historial',
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _construirElementoEstadistica(String valor, String etiqueta) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _construirTarjetaProgreso(String titulo, String subtitulo, String estado, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColores.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColores.primario.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 20, color: AppColores.primario),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColores.secundario.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              estado,
              style: TextStyle(fontSize: 12, color: AppColores.secundario, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionEstadisticas() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.decoracionTarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas de Lectura', style: EstilosApp.tituloMedio),
          const SizedBox(height: 20),
          
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColores.fondo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Gráfico de progreso mensual', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text('Los datos se mostrarán aquí', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(child: _construirTarjetaEstadistica('Géneros más leídos', 'No hay datos', Icons.category)),
              const SizedBox(width: 12),
              Expanded(child: _construirTarjetaEstadistica('Tiempo promedio', 'No hay datos', Icons.timer)),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _construirTarjetaEstadistica('Libros por mes', 'No hay datos', Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _construirTarjetaEstadistica('Páginas por día', 'No hay datos', Icons.menu_book)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaEstadistica(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColores.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 24, color: AppColores.primario),
          const SizedBox(height: 8),
          Text(titulo, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _construirSeccionConfiguracion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: EstilosApp.decoracionTarjeta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configuración', style: EstilosApp.tituloMedio),
          const SizedBox(height: 20),
          
          _construirElementoConfiguracion('Notificaciones', 'Gestiona las notificaciones de la app', Icons.notifications, true),
          _construirElementoConfiguracion('Privacidad', 'Controla tu información personal', Icons.privacy_tip, false),
          _construirElementoConfiguracion('Idioma', 'Español', Icons.language, false),
          _construirElementoConfiguracion('Tema', 'Claro', Icons.palette, false),
          _construirElementoConfiguracion('Sincronización', 'Última sincronización: hoy', Icons.sync, false),
          _construirElementoConfiguracion('Ayuda y soporte', 'Centro de ayuda y contacto', Icons.help, false),
          const SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cerrar sesión'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Eliminar cuenta'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirElementoConfiguracion(String titulo, String subtitulo, IconData icono, bool tieneSwitch) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColores.primario.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 20, color: AppColores.primario),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitulo, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          if (tieneSwitch)
            Switch(
              value: true,
              onChanged: (valor) {},
              activeColor: AppColores.primario,
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}