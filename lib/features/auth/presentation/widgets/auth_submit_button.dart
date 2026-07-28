import 'package:flutter/material.dart';
import 'package:stay_alive/core/widgets/app_button.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(text: label, onPressed: onPressed, isLoading: isLoading);
  }
}
