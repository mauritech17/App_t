import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/stores_screen.dart';

void main() {
  runApp(const ProviderScope(child: TalabiyahApp()));
}

class TalabiyahApp extends StatelessWidget {
  const TalabiyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talabiyah Extract PoC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StoresScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}