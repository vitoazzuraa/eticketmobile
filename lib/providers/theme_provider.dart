import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State global untuk tema, dipakai di main.dart dan setting_screen.dart
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);