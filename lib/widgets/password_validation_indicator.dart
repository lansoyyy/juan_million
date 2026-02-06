import 'package:flutter/material.dart';

class PasswordValidationIndicator extends StatelessWidget {
  final String password;
  final bool showIndicators;

  const PasswordValidationIndicator({
    super.key,
    required this.password,
    this.showIndicators = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showIndicators || password.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool hasMinLength = password.length >= 8;
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasNumber = password.contains(RegExp(r'[0-9]'));
    final bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\[\]\\/\-+=;]'));

    final bool isValid = hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecialChar;

    return Container(
      margin: const EdgeInsets.only(top: 8, left: 20, right: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isValid ? 'Password is valid' : 'Password requirements not met',
                style: TextStyle(
                  color: isValid ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('At least 8 characters', hasMinLength),
          _buildRequirementItem('One uppercase letter (A-Z)', hasUppercase),
          _buildRequirementItem('One lowercase letter (a-z)', hasLowercase),
          _buildRequirementItem('One number (0-9)', hasNumber),
          _buildRequirementItem('One special character (!@#...)', hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check : Icons.close,
            color: isMet ? Colors.green : Colors.red,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
