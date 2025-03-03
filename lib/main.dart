import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/screens/home.dart';
import 'package:my_app/screens/login.dart';
import 'package:my_app/screens/register.dart';
import 'package:my_app/screens/file_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoVault',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/',
      routes: _buildRoutes(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.urbanistTextTheme(),
      primaryColor: const Color(0xFF2A5D97),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        surface: Colors.white,
        primary: const Color(0xFF8391A1),
        secondary: const Color(0xFFE8ECF4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 22),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/': (context) => const Home(),
      '/login': (context) => const Login(),
      '/register': (context) => const Register(),
      '/filelist': (context) => const FileList(),
    };
  }
}
