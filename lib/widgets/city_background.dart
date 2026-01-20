import 'package:flutter/material.dart';
import 'dart:math';

class CityBackground extends StatelessWidget {
  const CityBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white, // Very light top
            Color(0xFFE3E8FC), // Light Blue tint
            Color(0xFFB4C0FA), // Softer Blue
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: CityScapePainter(),
      ),
    );
  }
}

class CityScapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final primaryColor = const Color(0xFF4361EE);

    // --- Back Layer Buildings (Very Subtle) ---
    paint.color = primaryColor.withOpacity(0.05); // Very transparent
    _drawSkyline(canvas, size, paint, offset: 0, heightFactor: 0.25, density: 10);

    // --- Middle Layer Buildings (Subtle) ---
    paint.color = primaryColor.withOpacity(0.1); 
    _drawSkyline(canvas, size, paint, offset: 150, heightFactor: 0.2, density: 8);

    // --- Front Layer Buildings (More visible but still transparent) ---
    paint.color = primaryColor.withOpacity(0.2);
    
    // Draw Monas and Pancoran
    _drawLandmarks(canvas, size, paint);
    
    // Fill rest
    _drawSkyline(canvas, size, paint, offset: 50, heightFactor: 0.15, density: 5, skipRanges: [
      RangeValues(size.width * 0.15, size.width * 0.35), // Monas Area
      RangeValues(size.width * 0.65, size.width * 0.85), // Pancoran Area
    ]);

    // --- Ground ---
    paint.color = primaryColor.withOpacity(0.25);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12),
      paint,
    );
  }

  void _drawLandmarks(Canvas canvas, Size size, Paint paint) {
    double groundY = size.height * 0.88;

    // --- Draw MONAS (Left Side) - Detailed ---
    double monasX = size.width * 0.25;
    double scale = size.height * 0.00035; // Slightly larger scale

    Path monas = Path();
    
    // 1. Base Platform (Pelataran Bawah)
    monas.addRect(Rect.fromCenter(center: Offset(monasX, groundY - 10), width: 140 * scale, height: 20));
    
    // 2. Cawan (The Cup/Goblet) - Angled walls
    Path cawan = Path();
    cawan.moveTo(monasX - 45 * scale, groundY - 20); // Bottom Left
    cawan.lineTo(monasX + 45 * scale, groundY - 20); // Bottom Right
    cawan.lineTo(monasX + 55 * scale, groundY - 50 * scale); // Top Right (Angled out)
    cawan.lineTo(monasX + 50 * scale, groundY - 65 * scale); // Top Edge Right
    cawan.lineTo(monasX - 50 * scale, groundY - 65 * scale); // Top Edge Left
    cawan.lineTo(monasX - 55 * scale, groundY - 50 * scale); // Top Left (Angled out)
    cawan.close();
    monas.addPath(cawan, Offset.zero);

    // 3. Obelisk (Tower)
    // Tapering tower
    Path tower = Path();
    tower.moveTo(monasX - 12 * scale, groundY - 65 * scale);
    tower.lineTo(monasX + 12 * scale, groundY - 65 * scale);
    tower.lineTo(monasX + 8 * scale, groundY - 260 * scale); // Tapers at top
    tower.lineTo(monasX - 8 * scale, groundY - 260 * scale);
    tower.close();
    monas.addPath(tower, Offset.zero);

    // 4. Lidah Api (The Flame)
    Path flame = Path();
    flame.moveTo(monasX, groundY - 260 * scale); // Base of flame
    // Left curve
    flame.cubicTo(
      monasX - 15 * scale, groundY - 270 * scale, 
      monasX - 15 * scale, groundY - 290 * scale, 
      monasX, groundY - 300 * scale // Tip
    ); 
    // Right curve
    flame.cubicTo(
      monasX + 15 * scale, groundY - 290 * scale, 
      monasX + 15 * scale, groundY - 270 * scale, 
      monasX, groundY - 260 * scale
    );
    flame.close();
    monas.addPath(flame, Offset.zero);

    canvas.drawPath(monas, paint);


    // --- Draw PATUNG PANCORAN (Right Side) ---
    double pancoranX = size.width * 0.75;
    double pancoranScale = size.height * 0.0003;
    
    // Pillar (Curve)
    Path pillar = Path();
    pillar.moveTo(pancoranX, groundY);
    pillar.quadraticBezierTo(pancoranX + 15, groundY - 80 * pancoranScale, pancoranX + 30, groundY - 160 * pancoranScale);
    pillar.lineTo(pancoranX + 45, groundY - 160 * pancoranScale); // Platform width
    pillar.quadraticBezierTo(pancoranX + 25, groundY - 80 * pancoranScale, pancoranX + 40, groundY);
    pillar.close();
    canvas.drawPath(pillar, paint);

    // Statue
    canvas.drawCircle(Offset(pancoranX + 38, groundY - 165 * pancoranScale), 6, paint); 
    canvas.drawLine(
      Offset(pancoranX + 38, groundY - 165 * pancoranScale), 
      Offset(pancoranX + 70, groundY - 175 * pancoranScale), 
      paint..strokeWidth = 3
    );
    paint.style = PaintingStyle.fill;
  }

  void _drawSkyline(Canvas canvas, Size size, Paint paint, {
    required double offset,
    required double heightFactor,
    required int density,
    List<RangeValues> skipRanges = const [],
  }) {
    final random = Random(offset.toInt()); 
    final path = Path();
    
    double currentX = 0;
    double groundY = size.height * 0.88;
    path.moveTo(0, size.height);

    while (currentX < size.width) {
      double width = 30 + random.nextDouble() * 50; 
      
      // Check if we should skip this area (for landmarks)
      bool skip = false;
      for (var range in skipRanges) {
        if (currentX + width > range.start && currentX < range.end) {
          skip = true;
          currentX = range.end; // Jump past the range
          break;
        }
      }
      if (skip) continue;

      double height = 50 + random.nextDouble() * (size.height * heightFactor); 
      bool hasPointedRoof = random.nextBool();

      if (currentX + width > size.width) width = size.width - currentX;
      
      path.lineTo(currentX, groundY - height); // Up left
      
      if (hasPointedRoof) {
        path.lineTo(currentX + width / 2, groundY - height - 20); // Peak
        path.lineTo(currentX + width, groundY - height); // Down right
      } else {
        path.lineTo(currentX + width, groundY - height); // Across top
      }
      
      path.lineTo(currentX + width, groundY); // Down right
      
      currentX += width;
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
