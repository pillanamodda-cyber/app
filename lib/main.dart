import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OSGLiveApp());
}

class OSGLiveApp extends StatelessWidget {
  const OSGLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: MaterialApp(
        title: 'OSG LIVE Esports',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0E1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF5722),
            secondary: Color(0xFFFF9800),
            surface: Color(0xFF131B2E),
            error: Color(0xFFE53935),
          ),
          textTheme: GoogleFonts.rajdhaniTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
