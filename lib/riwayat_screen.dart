import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_service.dart';
import 'app_theme.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'package:intl/intl.dart';
import 'outlet_detail_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;

  bool _isLoading = true;
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadHistory();
    _searchController.addListener(_filterHistory);
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    // Fetch history dan outlets secara bersamaan
    final historyFuture = ApiService.getAttendanceHistory();
    final outletsFuture = ApiService.getOutlets();
    
    final results = await Future.wait([historyFuture, outletsFuture]);
    final historyData = results[0] as List<Map<String, dynamic>>;
    final outletsData = results[1] as List<Map<String, dynamic>>;
    
    // Buat map outlet_id -> outlet data untuk lookup cepat
    final outletMap = <int, Map<String, dynamic>>{};
    for (var outlet in outletsData) {
      final id = outlet['id'];
      if (id != null) {
        outletMap[id is int ? id : int.tryParse(id.toString()) ?? 0] = outlet;
      }
    }
    
    // Gabungkan outlet info ke history items
    final enrichedHistory = historyData.map((item) {
      final outletId = item['outlet_id'];
      if (outletId != null && item['outlet'] == null) {
        final id = outletId is int ? outletId : int.tryParse(outletId.toString()) ?? 0;
        final outletData = outletMap[id];
        if (outletData != null) {
          return {
            ...item,
            'outlet': outletData,
            'outlet_name': outletData['name'],
            'address': outletData['address'],
          };
        }
      }
      return item;
    }).toList();
    
    // Debug
    if (enrichedHistory.isNotEmpty) {
      debugPrint('=== ENRICHED HISTORY ===');
      debugPrint('First item: ${enrichedHistory.first}');
    }
    
    setState(() {
      _history = enrichedHistory;
      _filteredHistory = enrichedHistory;
      _isLoading = false;
    });
    _animController.forward();
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistory = _history.where((item) {
        final outlet = item['outlet'] is Map ? item['outlet'] : null;
        final name = (outlet?['name'] ?? item['outlet_name'] ?? item['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _performCheckout(dynamic attendanceId, String? checkInTime) async {
    // Hitung durasi
    String durationStr = '00:00:00';
    if (checkInTime != null) {
      try {
        final checkIn = DateTime.parse(checkInTime);
        final now = DateTime.now();
        final duration = now.difference(checkIn);
        durationStr = '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
      } catch (e) {
        debugPrint('Error parsing check-in time: $e');
      }
    }

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryElectric),
      ),
    );

    final result = await ApiService.checkOut(
      attendanceId: attendanceId is int ? attendanceId : int.parse(attendanceId.toString()),
      checkOutTime: DateTime.now(),
      duration: durationStr,
    );

    // Tutup loading
    if (mounted) Navigator.pop(context);

    if (result['success'] == true) {
      // Ambil nama outlet dari history
      final item = _history.firstWhere(
        (h) => h['id'] == attendanceId,
        orElse: () => {},
      );
      final outlet = item['outlet'] is Map ? item['outlet'] : null;
      final outletName = outlet?['name'] ?? item['outlet_name'] ?? 'Outlet';
      
      // Tambah notifikasi realtime
      NotificationService.addCheckOutNotification(
        outletName,
        DateTime.now(),
        durationStr,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh data
      _loadHistory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Checkout gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: Column(
        children: [
          // Gradient Header
          _buildHeader(),
          
          // Search Bar
          _buildSearchBar(),
          
          // History List
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryElectric,
              onRefresh: _loadHistory,
              child: _buildHistoryList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.t(context, 'history') ?? 'Riwayat',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat semua kunjungan Anda',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade800),
              decoration: InputDecoration(
                hintText: LanguageService.t(context, 'search_hint') ?? 'Cari riwayat...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _filterHistory();
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryElectric),
      );
    }

    if (_filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryElectric.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 50,
                color: AppTheme.primaryElectric,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak ada riwayat',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Riwayat kunjungan Anda akan muncul di sini',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _filteredHistory.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animValue = Curves.easeOut.transform(
              ((_animController.value - delay) / (1 - delay)).clamp(0.0, 1.0),
            );
            return Transform.translate(
              offset: Offset(0, 20 * (1 - animValue)),
              child: Opacity(
                opacity: animValue,
                child: child,
              ),
            );
          },
          child: _buildHistoryCard(_filteredHistory[index], index),
        );
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    // Handle nested outlet object from API
    final outlet = item['outlet'] is Map ? item['outlet'] : null;
    final outletName = outlet?['name'] ?? item['outlet_name'] ?? item['name'] ?? 'Unknown Outlet';
    final address = outlet?['address'] ?? item['address'] ?? '-';
    final checkInTime = item['check_in_time'] ?? item['check_in'] ?? item['created_at'];
    final checkOutTime = item['check_out_time'] ?? item['check_out'];
    final isActive = checkOutTime == null; // Belum checkout
    final attendanceId = item['id'];
    
    String timeString = '';
    String dateString = '';
    if (checkInTime != null) {
      try {
        final dt = DateTime.parse(checkInTime);
        timeString = DateFormat('HH:mm').format(dt);
        dateString = DateFormat('dd MMM yyyy').format(dt);
      } catch (e) {
        timeString = checkInTime.toString();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetailBottomSheet(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Timeline indicator
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryElectric,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryElectric.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryElectric,
                            AppTheme.primaryElectric.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AppTheme.cardGradient,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=200',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
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
                        outletName,
                        style: AppTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: AppTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? Colors.orange.withOpacity(0.1) 
                                  : AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isActive ? Icons.timer : Icons.check_circle, 
                                  size: 10, 
                                  color: isActive ? Colors.orange : AppTheme.success,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isActive ? 'Aktif' : 'Selesai',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: isActive ? Colors.orange : AppTheme.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isActive && attendanceId != null)
                            GestureDetector(
                              onTap: () => _performCheckout(attendanceId, checkInTime),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryElectric,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Out',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeString,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryElectric,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateString,
                      style: AppTheme.labelText,
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMuted,
                      size: 20,
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

  void _showDetailBottomSheet(Map<String, dynamic> item) {
    // Handle nested outlet object from API
    final outlet = item['outlet'] is Map ? item['outlet'] : null;
    final outletName = outlet?['name'] ?? item['outlet_name'] ?? item['name'] ?? 'Unknown Outlet';
    final address = outlet?['address'] ?? item['address'] ?? '-';
    final checkInTime = item['check_in_time'] ?? item['check_in'] ?? item['created_at'];
    final checkOutTime = item['check_out_time'] ?? item['check_out'];
    final outletId = outlet?['id'] ?? item['outlet_id'] ?? item['id'];
    
    String checkInStr = '-';
    String checkOutStr = '-';
    String dateStr = '-';
    String durationStr = '-';
    
    if (checkInTime != null) {
      try {
        final dtIn = DateTime.parse(checkInTime);
        checkInStr = DateFormat('HH:mm').format(dtIn);
        dateStr = DateFormat('EEEE, dd MMM yyyy', 'id').format(dtIn);
        
        if (checkOutTime != null) {
          final dtOut = DateTime.parse(checkOutTime);
          checkOutStr = DateFormat('HH:mm').format(dtOut);
          final duration = dtOut.difference(dtIn);
          final hours = duration.inHours;
          final minutes = duration.inMinutes.remainder(60);
          durationStr = '${hours}j ${minutes}m';
        }
      } catch (e) {
        checkInStr = checkInTime.toString();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Detail Kunjungan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            // Outlet info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outletName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Date
            _buildDetailRow(Icons.calendar_today_rounded, 'Tanggal', dateStr),
            const SizedBox(height: 12),
            
            // Time info
            Row(
              children: [
                Expanded(
                  child: _buildTimeCard('Check-in', checkInStr, AppTheme.success),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeCard('Check-out', checkOutStr, AppTheme.primaryElectric),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Duration
            _buildDetailRow(Icons.timer_outlined, 'Durasi', durationStr),
            const SizedBox(height: 24),
            
            // Button ke detail outlet
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  if (outletId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OutletDetailScreen(
                          outlet: {
                            'id': outletId,
                            'name': outletName,
                            'address': address,
                            ...item,
                          },
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryElectric,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lihat Detail Outlet',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textMuted),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard(String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
