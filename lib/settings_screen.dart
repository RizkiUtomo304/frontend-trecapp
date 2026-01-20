import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_screen.dart';
import 'timezone_screen.dart';
import 'language_service.dart';
import 'app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                    Text(
                      LanguageService.t(context, 'settings') ?? 'Pengaturan',
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

          // Settings Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    context: context,
                    icon: Icons.language_rounded,
                    iconColor: AppTheme.primaryElectric,
                    title: LanguageService.t(context, 'select_language') ?? 'Pilih Bahasa',
                    subtitle: 'Indonesia',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LanguageScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    context: context,
                    icon: Icons.access_time_rounded,
                    iconColor: AppTheme.primaryViolet,
                    title: LanguageService.t(context, 'select_timezone') ?? 'Zona Waktu',
                    subtitle: 'Asia/Jakarta (WIB)',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TimezoneScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    context: context,
                    icon: Icons.notifications_outlined,
                    iconColor: AppTheme.warning,
                    title: 'Notifikasi',
                    subtitle: 'Aktif',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    context: context,
                    icon: Icons.dark_mode_outlined,
                    iconColor: AppTheme.textSecondary,
                    title: 'Mode Gelap',
                    subtitle: 'Nonaktif',
                    onTap: () {},
                    showArrow: false,
                    trailing: Switch.adaptive(
                      value: false,
                      onChanged: (val) {},
                      activeColor: AppTheme.primaryElectric,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // App Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.accentCyan,
                    title: 'Versi Aplikasi',
                    subtitle: '1.0.0',
                    onTap: () {},
                    showArrow: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTheme.bodySmall),
                  ],
                ),
              ),
              trailing ?? (showArrow 
                ? Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 24)
                : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppTheme.border),
    );
  }
}
