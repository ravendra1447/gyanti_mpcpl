import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/login_provider.dart';
import 'Screens/HomePage.dart';
import 'Screens/login_screen.dart';
import 'Services/ForceUpdateService.dart';
import 'Widgets/ForceUpdateDialog.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCheckingUpdate = true;
  bool _updateRequired = false;
  String _playStoreUrl = '';

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateRequired = await ForceUpdateService.checkForUpdate();
      final playStoreUrl = await ForceUpdateService.getPlayStoreUrl();
      
      if (mounted) {
        setState(() {
          _updateRequired = updateRequired;
          _playStoreUrl = playStoreUrl;
          _isCheckingUpdate = false;
        });

        // Show update dialog if update is required
        if (_updateRequired) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUpdateDialog();
          });
        }
      }
    } catch (e) {
      print('Error in update check: $e');
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot dismiss by tapping outside
      builder: (context) => ForceUpdateDialog(playStoreUrl: _playStoreUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MPCPL Login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(userData: {}),
      },
      home: _isCheckingUpdate
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _updateRequired
              ? Scaffold(
                  body: Center(
                    child: ForceUpdateDialog(playStoreUrl: _playStoreUrl),
                  ),
                )
              : const LoginScreen(),
    );
  }
}


