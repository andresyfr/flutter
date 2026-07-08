import 'package:flutter/material.dart';
import 'router/app_router.dart';

void main() {
  runApp(const PokeFlutterApp());
}

class PokeFlutterApp extends StatelessWidget {
  const PokeFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PokéFlutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
