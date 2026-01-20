import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'add_outlet_screen.dart';
import 'riwayat_screen.dart';
import 'database_screen.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'language_screen.dart';
import 'timezone_screen.dart';
import 'language_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

// Konfigurasi utama aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService(),
      builder: (context, child) {
        return MaterialApp(
          title: 'TreckingRec',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4361EE)),
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          debugShowCheckedModeBanner: false,
          locale: LanguageService().currentLocale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id'),
            Locale('en'),
            Locale('ar'),
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/add-outlet': (context) => const AddOutletScreen(),
            '/riwayat': (context) => const RiwayatScreen(),
            '/database': (context) => const DatabaseScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/language': (context) => const LanguageScreen(),
            '/timezone': (context) => const TimezoneScreen(),
          },
        );
      },
    );
  }
}
