import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/login_provider.dart';
import 'Screens/HomePage.dart';
import 'Screens/login_screen.dart';
import 'Screens/homepage.dart' hide HomePage;

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MPCPL Login',
      routes: {
        '/login': (context) => const LoginScreen(),
         '/home': (context) => const HomePage(userData: {},),
      },
      home: const LoginScreen(),
    );
  }
}


