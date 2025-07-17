import 'package:flutter/material.dart';

//Reusable colors
// Define colors from your Login & Signup screens
final Color primaryColor = const Color(
  0xFF4A90E2,
); // Primary color matching the login/signup screens.
final Color backgroundColor = const Color(
  0xFFF5F7FA,
); // Background color matching the login/signup screens.
final Color bottomNavSelectedColor = const Color(
  0xFF4A90E2,
); // Color for the selected bottom navigation item.
final Color bottomNavUnselectedColor =
    Colors.grey; // Color for the unselected bottom navigation items.

final Color fillerColor = const Color.fromARGB(255, 191, 197, 205);

/// Reusable App Button
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.teal,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
      label: Text(text),
    );
  }
}

/// Reusable App TextField
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const AppTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    );
  }
}

/// Reusable Clinic List Tile
class ClinicTile extends StatelessWidget {
  final Map<String, dynamic> clinic;
  final VoidCallback onTap;

  const ClinicTile({Key? key, required this.clinic, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.teal),
        title: Text(clinic['name'] ?? ''),
        subtitle: Text(
          "${clinic['address'] ?? ''} • ${clinic['distance'] ?? '–'}",
        ),
        onTap: onTap,
      ),
    );
  }
}
