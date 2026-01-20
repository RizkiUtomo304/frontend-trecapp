import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme - Modern Design System for TrackingRec
class AppTheme {
  // ============ COLOR PALETTE ============
  
  // Primary Gradients
  static const Color primaryDark = Color(0xFF0F172A);    // Slate 900
  static const Color primaryBlue = Color(0xFF1E3A8A);    // Blue 800
  static const Color primaryElectric = Color(0xFF3B82F6); // Blue 500
  static const Color primaryViolet = Color(0xFF7C3AED);   // Violet 600
  static const Color primaryIndigo = Color(0xFF4F46E5);   // Indigo 600
  
  // Accent Colors
  static const Color accentCyan = Color(0xFF06B6D4);     // Cyan 500
  static const Color accentPink = Color(0xFFEC4899);     // Pink 500
  static const Color accentOrange = Color(0xFFF97316);   // Orange 500
  
  // Status Colors
  static const Color success = Color(0xFF10B981);        // Emerald 500
  static const Color warning = Color(0xFFF59E0B);        // Amber 500
  static const Color error = Color(0xFFEF4444);          // Red 500
  static const Color info = Color(0xFF3B82F6);           // Blue 500
  
  // Neutral Colors
  static const Color surfaceLight = Color(0xFFF8FAFC);   // Slate 50
  static const Color surfaceCard = Color(0xFFFFFFFF);    // White
  static const Color textPrimary = Color(0xFF0F172A);    // Slate 900
  static const Color textSecondary = Color(0xFF64748B);  // Slate 500
  static const Color textMuted = Color(0xFF94A3B8);      // Slate 400
  static const Color border = Color(0xFFE2E8F0);         // Slate 200
  
  // ============ GRADIENTS ============
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A8A),  // Blue 800
      Color(0xFF3B82F6),  // Blue 500
      Color(0xFF7C3AED),  // Violet 600
    ],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),  // Slate 900
      Color(0xFF1E3A8A),  // Blue 800
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E40AF),  // Blue 700
      Color(0xFF4F46E5),  // Indigo 600
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED),  // Violet 600
      Color(0xFFEC4899),  // Pink 500
    ],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF059669),  // Emerald 600
      Color(0xFF10B981),  // Emerald 500
    ],
  );
  
  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDC2626),  // Red 600
      Color(0xFFF87171),  // Red 400
    ],
  );
  
  // ============ SHADOWS ============
  
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];
  
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  // Neumorphism shadows
  static List<BoxShadow> neumorphismLight = [
    const BoxShadow(
      color: Colors.white,
      blurRadius: 15,
      offset: Offset(-5, -5),
    ),
    BoxShadow(
      color: Colors.grey.shade300,
      blurRadius: 15,
      offset: const Offset(5, 5),
    ),
  ];
  
  // ============ DECORATIONS ============
  
  static BoxDecoration glassCard({
    double opacity = 0.1,
    double blur = 10,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    );
  }
  
  static BoxDecoration gradientCard({
    Gradient? gradient,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      gradient: gradient ?? cardGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: mediumShadow,
    );
  }
  
  static BoxDecoration whiteCard({
    double borderRadius = 20,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: hasShadow ? softShadow : null,
      border: Border.all(color: border.withOpacity(0.5)),
    );
  }
  
  // ============ TEXT STYLES ============
  
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headingMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );
  
  static TextStyle get headingSmall => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
  
  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textMuted,
  );
  
  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static TextStyle get labelText => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textMuted,
    letterSpacing: 0.5,
  );
  
  // Brand title style
  static TextStyle get brandTitle => GoogleFonts.dancingScript(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // ============ INPUT DECORATION ============
  
  static InputDecoration modernInput({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium.copyWith(color: textMuted),
      prefixIcon: prefixIcon != null 
        ? Icon(prefixIcon, color: textMuted, size: 22)
        : null,
      suffix: suffix,
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryElectric, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 1),
      ),
    );
  }
  
  // ============ BUTTON STYLES ============
  
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryElectric,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: buttonText,
  );
  
  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: surfaceLight,
    foregroundColor: primaryElectric,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    side: const BorderSide(color: primaryElectric, width: 1.5),
    textStyle: buttonText.copyWith(color: primaryElectric),
  );
  
  static ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: error,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: buttonText,
  );
}

/// Animated Gradient Container Widget
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
  });
  
  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final List<Color> colors1 = [
    const Color(0xFF0F172A),
    const Color(0xFF1E3A8A),
    const Color(0xFF3B82F6),
  ];
  
  final List<Color> colors2 = [
    const Color(0xFF1E3A8A),
    const Color(0xFF4F46E5),
    const Color(0xFF7C3AED),
  ];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(colors1[0], colors2[0], _controller.value)!,
                Color.lerp(colors1[1], colors2[1], _controller.value)!,
                Color.lerp(colors1[2], colors2[2], _controller.value)!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Glass Card Widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double opacity;
  
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.opacity = 0.15,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Gradient Button Widget
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;
  
  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient = AppTheme.primaryGradient,
    this.height = 56,
    this.borderRadius = 16,
    this.isLoading = false,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null ? gradient : null,
        color: onPressed == null ? AppTheme.textMuted : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: onPressed != null ? AppTheme.glowShadow(AppTheme.primaryElectric) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(text, style: AppTheme.buttonText),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
