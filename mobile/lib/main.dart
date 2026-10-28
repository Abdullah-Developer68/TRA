import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
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
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = ApiService.currentUser != null;
  }

  void _onAuthenticated(UserAccount user) {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _onLogout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRA — Multi-Agent Consensus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isAuthenticated
          ? HomeScreen(onLogout: _onLogout)
          : AuthScreen(onAuthenticated: _onAuthenticated),
    );
  }
}
