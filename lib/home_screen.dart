import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'profile_screen.dart';
import 'riwayat_screen.dart';
import 'database_screen.dart';
import 'language_service.dart';
import 'package:image_picker/image_picker.dart';
import 'check_in_screen.dart';
import 'notification_screen.dart';
import 'services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  late AnimationController _fabAnimController;
  late AnimationController _headerAnimController;
  late Animation<double> _fabScaleAnimation;

  List<Map<String, dynamic>> outlets = [];
  
  // Weekly status: Map dari hari minggu (1=Senin, 7=Minggu) ke status (true=hadir)
  Map<int, bool> _weeklyStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchMyOutlets();
    _fetchWeeklyAttendance();
    
    _fabAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut),
    );
    
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimController.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyOutlets() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMyOutlets();
    if (mounted) {
      setState(() {
        outlets = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeeklyAttendance() async {
    try {
      final history = await ApiService.getAttendanceHistory();
      
      // Hitung awal dan akhir minggu ini (Senin - Minggu)
      final now = DateTime.now();
      final weekday = now.weekday;
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      
      Map<int, bool> status = {};
      
      for (var record in history) {
        String? dateStr = record['check_in_time'] ?? record['created_at'] ?? record['date'];
        if (dateStr != null) {
          try {
            DateTime checkInDate = DateTime.parse(dateStr);
            if (checkInDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
                checkInDate.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
              status[checkInDate.weekday] = true;
            }
          } catch (e) {
            debugPrint('Error parsing date: $dateStr');
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _weeklyStatus = status;
        });
      }
      debugPrint('Weekly Status: $_weeklyStatus');
    } catch (e) {
      debugPrint('Error fetching weekly attendance: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  List<Map<String, dynamic>> get _filteredOutlets {
    if (_searchQuery.isEmpty) return outlets;
    return outlets.where((outlet) {
      final name = (outlet['name'] ?? '').toString().toLowerCase();
      final address = (outlet['address'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || 
             address.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Curved Gradient Background
          ClipPath(
            clipper: _SmoothCurveClipper(),
            child: Container(
              width: double.infinity,
              height: 320,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF3B82F6),
                    Color(0xFF60A5FA),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Floating bubbles for organic feel
                  Positioned(
                    top: -40,
                    right: -30,
                    child: _buildFloatingBubble(180, 0.08),
                  ),
                  Positioned(
                    top: 60,
                    left: -50,
                    child: _buildFloatingBubble(120, 0.05),
                  ),
                  Positioned(
                    top: 140,
                    right: 40,
                    child: _buildFloatingBubble(60, 0.06),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          _selectedIndex == 0
              ? _buildHomeContent()
              : _selectedIndex == 1 
                  ? const RiwayatScreen()
                  : const ProfileScreen(),
                  
          // FAB Overlay
          if (_isFabExpanded && _selectedIndex == 0)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
        ],
      ),
      
      floatingActionButton: _selectedIndex == 0 ? _buildModernFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }
  
  Widget _buildFloatingBubble(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildHeaderContent(),
        Expanded(
          child: ClipRect(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildDashboardCard(),
                  const SizedBox(height: 20),
                  _buildCircularStats(),
                  const SizedBox(height: 24),
                  _buildOutletSection(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderContent() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TrackingRec',
                      style: GoogleFonts.dancingScript(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Smart Outlet Management',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildHeaderIconButton(
                      Icons.notifications_none_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildHeaderIconButton(
                      Icons.person_outline_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Search Bar - More rounded & soft with prominent shadow
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50), // Pill shape!
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: -3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade800),
                      decoration: InputDecoration(
                        hintText: 'Cari outlet...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Cari',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Add padding at bottom so scroll content goes behind
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle, // Circle instead of rounded square!
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildDashboardCard() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final dayDate = DateFormat('d').format(now);
    final monthYear = DateFormat('MMMM yyyy').format(now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28), // More rounded
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Date display - Soft rounded square
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(22), // Softer corners
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    dayDate,
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      monthYear,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Calendar icon - circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF3B82F6),
                  size: 22,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 22),
          
          // Soft divider
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade200,
                  Colors.grey.shade200,
                  Colors.transparent,
                ],
                stops: const [0, 0.1, 0.9, 1],
              ),
            ),
          ),
          
          const SizedBox(height: 18),
          
          Text(
            'Status Minggu Ini',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),
          
          // Weekly Status - organic circles (Senin-Sabtu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayStatus('S', 1), // Senin (weekday 1)
              _buildDayStatus('S', 2), // Selasa (weekday 2)
              _buildDayStatus('R', 3), // Rabu (weekday 3)
              _buildDayStatus('K', 4), // Kamis (weekday 4)
              _buildDayStatus('J', 5), // Jumat (weekday 5)
              _buildDayStatus('S', 6), // Sabtu (weekday 6)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayStatus(String day, int weekday) {
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    
    // Cek apakah hadir pada hari tersebut
    final isPresent = _weeklyStatus[weekday] == true;
    // Hari sudah lewat tapi tidak hadir = absent
    final isAbsent = weekday < todayWeekday && !isPresent;
    // Hari ini
    final isToday = weekday == todayWeekday;
    
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.grey.shade200;
    Widget? icon;

    if (isPresent) {
      bgColor = const Color(0xFF10B981);
      borderColor = const Color(0xFF10B981);
      icon = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
    } else if (isAbsent) {
      bgColor = const Color(0xFFF43F5E);
      borderColor = const Color(0xFFF43F5E);
      icon = const Icon(Icons.close_rounded, color: Colors.white, size: 16);
    } else if (isToday) {
      // Hari ini tapi belum check-in - highlight dengan border biru
      borderColor = const Color(0xFF3B82F6);
    }

    return Column(
      children: [
        Text(
          day, 
          style: GoogleFonts.poppins(
            fontSize: 11, 
            color: isToday ? const Color(0xFF3B82F6) : Colors.grey.shade500,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: isToday && !isPresent ? 3 : 2),
            boxShadow: isPresent || isAbsent ? [
              BoxShadow(
                color: bgColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ] : null,
          ),
          child: icon,
        ),
      ],
    );
  }

  Widget _buildCircularStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('${outlets.length}', 'Total\nOutlet', const Color(0xFF3B82F6)),
          _buildStatDivider(),
          _buildStatItem('0', 'Check\nIn', const Color(0xFF10B981)),
          _buildStatDivider(),
          _buildStatItem('10', 'Target\nHarian', const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label, 
          style: GoogleFonts.poppins(
            fontSize: 11, 
            color: Colors.grey.shade500,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade100,
    );
  }

  Widget _buildOutletSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Outlet', 
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredOutlets.length} outlet',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF3B82F6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildOutletList(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildOutletList() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: CircularProgressIndicator(
            color: const Color(0xFF3B82F6),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_filteredOutlets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store_mall_directory_rounded,
                  size: 42,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum ada outlet',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tambahkan outlet untuk memulai',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredOutlets.length,
      itemBuilder: (context, index) {
        return _buildOutletCard(_filteredOutlets[index]);
      },
    );
  }

  Widget _buildOutletCard(Map<String, dynamic> outlet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Outlet Image - More rounded
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=200',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (outlet['code'] ?? outlet['id'] ?? '').toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        outlet['name'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              outlet['address'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Menu button - Circle
                PopupMenuButton<String>(
                  icon: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade500, size: 20),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (String result) {
                    if (result == 'check_in') {
                      _handleCheckIn(outlet);
                    } else if (result == 'delete') {
                      _showDeleteConfirmation(outlet);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'check_in',
                      child: Row(
                        children: [
                          const Icon(Icons.login_rounded, color: Color(0xFF3B82F6), size: 20),
                          const SizedBox(width: 12),
                          Text(LanguageService.t(context, 'check_in') ?? 'Check In', 
                            style: GoogleFonts.poppins(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E), size: 20),
                          const SizedBox(width: 12),
                          Text(LanguageService.t(context, 'delete') ?? 'Hapus', 
                            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFFF43F5E))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          _buildFabOption(
            label: LanguageService.t(context, 'outlet_new') ?? 'Outlet Baru',
            icon: Icons.add_business_rounded,
            onTap: () {
              _toggleFab();
              Navigator.pushNamed(context, '/add-outlet');
            },
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            label: LanguageService.t(context, 'database') ?? 'Database',
            icon: Icons.folder_outlined,
            onTap: () {
              _toggleFab();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DatabaseScreen()),
              );
            },
          ),
          const SizedBox(height: 14),
        ],
        
        // Main FAB - Pill or Circle based on state
        GestureDetector(
          onTap: _toggleFab,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            width: _isFabExpanded ? 58 : 130,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(_isFabExpanded ? 29 : 29),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isFabExpanded
                    ? const Icon(Icons.close_rounded, color: Colors.white, size: 26, key: ValueKey('close'))
                    : Row(
                        key: const ValueKey('add'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            'Tambah',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 20),
            const SizedBox(width: 10),
            Text(
              label, 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.history_rounded, Icons.history_rounded, 'Riwayat'),
              _buildNavItem(2, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade400,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> outlet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          LanguageService.t(context, 'delete_outlet_title') ?? 'Hapus Outlet',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          LanguageService.t(context, 'delete_outlet_confirm') ?? 'Apakah Anda yakin ingin menghapus outlet ini?',
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LanguageService.t(context, 'cancel') ?? 'Batal',
              style: GoogleFonts.poppins(color: Colors.grey.shade500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOutlet(outlet);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              LanguageService.t(context, 'delete') ?? 'Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOutlet(Map<String, dynamic> outlet) async {
    setState(() => _isLoading = true);
    final success = await ApiService.deleteMyOutlet(outlet['id']);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService.t(context, 'delete_success') ?? 'Outlet berhasil dihapus'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            margin: const EdgeInsets.all(16),
          ),
        );
        _fetchMyOutlets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService.t(context, 'delete_failed') ?? 'Gagal menghapus outlet'),
            backgroundColor: const Color(0xFFF43F5E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _handleCheckIn(Map<String, dynamic> outlet) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckInScreen(
            outlet: outlet,
            imagePath: image.path,
          ),
        ),
      );
    }
  }
}

// Smooth curve clipper for organic header
class _SmoothCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    
    // More organic curve
    path.quadraticBezierTo(
      size.width * 0.25, size.height - 20,
      size.width * 0.5, size.height - 40,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 60,
      size.width, size.height - 30,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
