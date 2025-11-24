import 'package:flutter/material.dart';
import 'diseño.dart';
import 'componentes.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  int _selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BookWorm', style: AppStyles.titleLarge),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        actions: const [AppBarButtons(currentRoute: '/perfil')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildSectionSelector(),
            const SizedBox(height: 20),
            _buildSectionContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mi Perfil', style: AppStyles.titleMedium),
              ElevatedButton(
                onPressed: () {},
                style: AppStyles.primaryButton,
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
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre del usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('email@ejemplo.com', style: AppStyles.bodyMedium),
                    SizedBox(height: 8),
                    Text(
                      'Lector activo', 
                      style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500)
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

  Widget _buildSectionSelector() {
    final sections = [
      {'text': 'Información', 'icon': Icons.person_outline},
      {'text': 'Mi Progreso', 'icon': Icons.trending_up},
      {'text': 'Estadísticas', 'icon': Icons.analytics},
      {'text': 'Configuración', 'icon': Icons.settings},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Row(children: [
        for (int i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: SectionButton(
            text: sections[i]['text'] as String,
            isSelected: _selectedSection == i,
            icon: sections[i]['icon'] as IconData,
            onPressed: () => setState(() => _selectedSection = i),
          )),
        ],
      ]),
    );
  }

  Widget _buildSectionContent() {
    final sections = [
      _buildInformacionSection(),
      _buildProgresoSection(),
      _buildEstadisticasSection(),
      _buildConfiguracionSection(),
    ];
    return sections[_selectedSection];
  }

  Widget _buildInformacionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información Personal', style: AppStyles.titleMedium),
          const SizedBox(height: 20),
          
          _buildInfoCard(
            'Datos Personales',
            [
              _buildInfoItem('Nombre completo', ''),
              _buildInfoItem('Email', ''),
              _buildInfoItem('Fecha de registro', ''),
              _buildInfoItem('Ubicación', ''),
            ],
            Icons.person,
          ),
          const SizedBox(height: 20),
          
          _buildInfoCard(
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
          
          _buildInfoCard(
            'Preferencias de Lectura',
            [
              _buildPreferenceItem('Géneros favoritos', ''),
              _buildPreferenceItem('Formato preferido', ''),
              _buildPreferenceItem('Idiomas', ''),
              _buildPreferenceItem('Metas de lectura', ''),
            ],
            Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...content,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey : Colors.black87,
                fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey : Colors.black87,
                fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgresoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mi Progreso de Lectura', style: AppStyles.titleMedium),
              ElevatedButton(
                onPressed: () {},
                style: AppStyles.primaryButton,
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
                colors: [AppColors.primary.withOpacity(0.8), AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('0', 'Libros leídos'),
                _buildStatItem('0', 'Páginas'),
                _buildStatItem('0', 'Días racha'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildProgressCard(
            'Leyendo actualmente',
            'No hay libros en progreso',
            '0% completado',
            Icons.bookmark,
          ),
          const SizedBox(height: 16),
          
          _buildProgressCard(
            'Próximas lecturas',
            '0 libros en lista de espera',
            'Ver lista completa',
            Icons.queue,
          ),
          const SizedBox(height: 16),
          
          _buildProgressCard(
            'Completados este año',
            '0 libros terminados',
            'Ver historial',
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildProgressCard(String title, String subtitle, String status, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas de Lectura', style: AppStyles.titleMedium),
          const SizedBox(height: 20),
          
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
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
              Expanded(child: _buildStatCard('Géneros más leídos', 'No hay datos', Icons.category)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Tiempo promedio', 'No hay datos', Icons.timer)),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildStatCard('Libros por mes', 'No hay datos', Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Páginas por día', 'No hay datos', Icons.menu_book)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildConfiguracionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configuración', style: AppStyles.titleMedium),
          const SizedBox(height: 20),
          
          _buildSettingItem('Notificaciones', 'Gestiona las notificaciones de la app', Icons.notifications, true),
          _buildSettingItem('Privacidad', 'Controla tu información personal', Icons.privacy_tip, false),
          _buildSettingItem('Idioma', 'Español', Icons.language, false),
          _buildSettingItem('Tema', 'Claro', Icons.palette, false),
          _buildSettingItem('Sincronización', 'Última sincronización: hoy', Icons.sync, false),
          _buildSettingItem('Ayuda y soporte', 'Centro de ayuda y contacto', Icons.help, false),
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

  Widget _buildSettingItem(String title, String subtitle, IconData icon, bool hasSwitch) {
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
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          if (hasSwitch)
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}