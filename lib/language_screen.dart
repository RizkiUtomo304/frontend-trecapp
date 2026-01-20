import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_service.dart';
import 'app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'Indonesia';

  @override
  void initState() {
    super.initState();
    final locale = LanguageService().currentLocale.languageCode;
    if (locale == 'en') {
      _selectedLanguage = 'English';
    } else if (locale == 'ar') {
      _selectedLanguage = 'Arab';
    } else {
      _selectedLanguage = 'Indonesia';
    }
  }

  final List<Map<String, dynamic>> _languages = [
    {'name': 'Indonesia', 'code': 'id', 'flag': '🇮🇩'},
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Arab', 'code': 'ar', 'flag': '🇸🇦'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: Column(
        children: [
          // Gradient Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E3A8A),
                  Color(0xFF3B82F6),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 24, 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.language_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      LanguageService.t(context, 'select_language') ?? 'Pilih Bahasa',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Language List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: _languages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final lang = entry.value;
                  return Column(
                    children: [
                      _buildLanguageItem(lang),
                      if (index < _languages.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(height: 1, color: AppTheme.border),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, dynamic> language) {
    bool isSelected = _selectedLanguage == language['name'];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedLanguage = language['name'];
            LanguageService().setLanguage(language['name']);
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Flag
              Text(
                language['flag'],
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 16),
              
              // Language name
              Expanded(
                child: Text(
                  language['name'],
                  style: AppTheme.bodyLarge.copyWith(
                    color: isSelected ? AppTheme.primaryElectric : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              
              // Check mark
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.glowShadow(AppTheme.primaryElectric),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                )
              else
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
