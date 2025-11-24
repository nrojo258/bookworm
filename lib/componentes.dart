import 'package:flutter/material.dart';
import 'diseño.dart';

class AppBarButtons extends StatelessWidget {
  final String currentRoute;

  const AppBarButtons({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final routes = {
      'Buscar': '/search',
      'Clubs': '/clubs', 
      'Perfil': '/perfil',
    };

    return Row(children: [
      ...routes.entries.map((e) => _buildAppBarButton(context, e.key, e.value)),
      const SizedBox(width: 16),
    ]);
  }

  Widget _buildAppBarButton(BuildContext context, String text, String route) {
    final isActive = currentRoute == route;
    return TextButton(
      onPressed: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.white : Colors.white70,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// Los demás componentes permanecen igual...
class SectionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onPressed;

  const SectionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearch;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: onSearch,
            style: AppStyles.primaryButton,
            child: const Text('Buscar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class DropdownFilter extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const DropdownFilter({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          items: items.map((value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}