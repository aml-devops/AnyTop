import 'package:flutter/material.dart';

class OperatorUiConfig {
  final Color iconColor;
  final IconData icon;

  const OperatorUiConfig({
    required this.iconColor,
    required this.icon,
  });

  static const _default = OperatorUiConfig(
    iconColor: Color(0xFF475569),
    icon: Icons.phone_android,
  );

  static const Map<String, OperatorUiConfig> _configs = {
    'MPT': OperatorUiConfig(
      iconColor: Color(0xFFDC2626),
      icon: Icons.phone_android,
    ),
    'Atom': OperatorUiConfig(
      iconColor: Color(0xFF16A34A),
      icon: Icons.phone_android,
    ),
    'U9': OperatorUiConfig(
      iconColor: Color(0xFF2563EB),
      icon: Icons.phone_android,
    ),
    'Mytel': OperatorUiConfig(
      iconColor: Color(0xFFDC2626),
      icon: Icons.phone_android,
    ),
    'All Operators': OperatorUiConfig(
      iconColor: Color(0xFF475569),
      icon: Icons.layers,
    ),
  };

  static OperatorUiConfig forOperator(String name) {
    final key = _configs.keys.firstWhere(
      (k) => k.toUpperCase() == name.toUpperCase(),
      orElse: () => '',
    );
    return key.isNotEmpty ? _configs[key]! : _default;
  }
}
