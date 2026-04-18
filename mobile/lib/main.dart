import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/tag_viewer_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C81), // Dark blue
          primary: const Color(0xFF0F4C81),
          secondary: Colors.teal,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F4C81),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const TagViewerPage(),
    );
  }
}
