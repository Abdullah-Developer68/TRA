import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CouncilApp(),
    ),
  );
}

class CouncilApp extends StatefulWidget {
  const CouncilApp({super.key});

  @override
  State<CouncilApp> createState() => _CouncilAppState();
}

class _CouncilAppState extends State<CouncilApp> {
  bool _isAuthenticated = true; // Set to true by default or toggle via AuthScreen

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Agent Council',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isAuthenticated
          ? const HomeScreen()
          : AuthScreen(
              onAuthenticated: () {
                setState(() => _isAuthenticated = true);
              },
            ),
    );
  }
}
