import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/screen/upload.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.urbanistTextTheme(Theme.of(context).textTheme),
        primaryColor: const Color(0xFF2A5D97),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: const Color(0xFF8391A1),
          secondary: const Color(0xFFE8ECF4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 22),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
        ),
        appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
      ),
      initialRoute: '/upload',
      routes: {
        // '/': (context) => Home(),
        // '/login': (context) => Login(),
        // '/register': (context) => Register(),
        // '/mock': (context) => Mock()
        '/upload': (context) => Upload(),
      },
    );
  }
}
