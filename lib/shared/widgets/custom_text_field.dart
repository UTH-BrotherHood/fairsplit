import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    required this.controller,
    this.validator,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
