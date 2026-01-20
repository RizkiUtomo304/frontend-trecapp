import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_service.dart';
import 'app_theme.dart';

class TimezoneScreen extends StatefulWidget {
  const TimezoneScreen({super.key});

  @override
  State<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<TimezoneScreen> {
  String _selectedTimezone = 'WITA';

  final List<Map<String, String>> _timezones = [
    {'name': 'WIB', 'full': 'Waktu Indonesia Barat', 'offset': 'UTC+7'},
    {'name': 'WITA', 'full': 'Waktu Indonesia Tengah', 'offset': 'UTC+8'},
    {'name': 'WIT', 'full': 'Waktu Indonesia Timur', 'offset': 'UTC+9'},
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
                    const Icon(Icons.access_time_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      LanguageService.t(context, 'select_timezone') ?? 'Zona Waktu',
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

          // Timezone List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: _timezones.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tz = entry.value;
                  return Column(
                    children: [
                      _buildTimezoneItem(tz),
                      if (index < _timezones.length - 1)
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

  Widget _buildTimezoneItem(Map<String, String> timezone) {
    bool isSelected = _selectedTimezone == timezone['name'];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedTimezone = timezone['name']!;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Clock icon with color
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected 
                    ? AppTheme.primaryElectric.withOpacity(0.1)
                    : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: isSelected ? AppTheme.primaryElectric : AppTheme.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Timezone info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          timezone['name']!,
                          style: AppTheme.bodyLarge.copyWith(
                            color: isSelected ? AppTheme.primaryElectric : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? AppTheme.primaryElectric.withOpacity(0.1)
                              : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            timezone['offset']!,
                            style: AppTheme.labelText.copyWith(
                              color: isSelected ? AppTheme.primaryElectric : AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timezone['full']!,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Radio button
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                )
              else
                Container(
                  width: 24,
                  height: 24,
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
