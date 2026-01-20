import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_service.dart';
import 'services/api_service.dart';

import 'dart:async';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'services/notification_service.dart';

class CheckInScreen extends StatefulWidget {
  final Map<String, dynamic> outlet;
  final String imagePath;

  const CheckInScreen({super.key, required this.outlet, required this.imagePath});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  late DateTime _checkInTime;
  DateTime? _checkOutTime; // null sampai user benar checkout
  late Timer _timer;
  DateTime _now = DateTime.now();
  
  int? _attendanceId; // ID attendance dari response check-in
  bool _isLoading = false;
  bool _isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    _checkInTime = DateTime.now();
    _startTimer();
    _performCheckIn(); // Panggil API check-in
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }
  
  Future<void> _performCheckIn() async {
    setState(() => _isLoading = true);
    
    final outletId = widget.outlet['id'];
    if (outletId == null) {
      debugPrint('Error: outlet_id is null');
      setState(() => _isLoading = false);
      return;
    }
    
    final result = await ApiService.checkIn(
      outletId: outletId is int ? outletId : int.parse(outletId.toString()),
      imagePath: widget.imagePath,
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _isCheckedIn = true;
          // Ambil attendance_id dari berbagai kemungkinan struktur response
          final data = result['data'];
          debugPrint('=== CHECK-IN RESPONSE DATA ===');
          debugPrint('Data type: ${data.runtimeType}');
          debugPrint('Data content: $data');
          
          if (data is Map) {
            // Coba berbagai kemungkinan key
            _attendanceId = data['id'] 
                ?? data['attendance_id'] 
                ?? data['attendance']?['id']
                ?? data['data']?['id']
                ?? data['data']?['attendance_id'];
            
            // Debug semua key yang tersedia
            debugPrint('Available keys: ${data.keys.toList()}');
          }
          debugPrint('Extracted attendance_id: $_attendanceId');
          
          // Tambah notifikasi realtime
          NotificationService.addCheckInNotification(
            widget.outlet['name'] ?? 'Outlet',
            _checkInTime,
          );
        } else {
          // Tampilkan error dan kembali ke halaman sebelumnya
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Check-in gagal'),
              backgroundColor: Colors.red,
            ),
          );
          // Kembali ke halaman sebelumnya jika check-in gagal
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)} Jam $twoDigitMinutes Menit $twoDigitSeconds Detik";
  }
  @override
  Widget build(BuildContext context) {
    // Block back button jika sudah check-in tapi belum checkout
    return PopScope(
      canPop: _checkOutTime != null, // Hanya bisa pop jika sudah checkout
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isCheckedIn && _checkOutTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LanguageService.t(context, 'checkout_required') ?? 'Silakan checkout terlebih dahulu'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Captured Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb 
                      ? Image.network(
                          widget.imagePath,
                          height: 150,
                          width: 250,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(widget.imagePath),
                          height: 150,
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Outlet Info
                  Text(
                    widget.outlet['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.outlet['address'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  // Form Fields
                  _buildLabel(context, 'date'),
                  _buildReadOnlyField(DateFormat('dd-MM-yyyy').format(_checkInTime)),
                  
                  const SizedBox(height: 16),
                  _buildLabel(context, 'check_in'),
                  _buildReadOnlyField('${DateFormat('HH.mm').format(_checkInTime)} WIB'),
                  
                  const SizedBox(height: 16),
                  _buildLabel(context, 'check_out'),
                  _buildReadOnlyField(_checkOutTime != null 
                      ? '${DateFormat('HH.mm').format(_checkOutTime!)} WIB' 
                      : '-'),
                  
                  const SizedBox(height: 16),
                  _buildLabel(context, 'duration'),
                  _buildReadOnlyField(_checkOutTime != null 
                      ? _formatDuration(_checkOutTime!.difference(_checkInTime))
                      : '-'),
                  
                  const SizedBox(height: 40),
                  
                  // Check Out Button atau History
                  if (_checkOutTime != null)
                    _buildCheckoutHistory()
                  else
                    _buildCheckOutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilkan history/ringkasan setelah checkout
  Widget _buildCheckoutHistory() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
              const SizedBox(width: 8),
              Text(
                'Checkout Berhasil!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHistoryRow('Outlet', widget.outlet['name'] ?? '-'),
          _buildHistoryRow('Check-in', '${DateFormat('HH:mm').format(_checkInTime)} WIB'),
          _buildHistoryRow('Check-out', '${DateFormat('HH:mm').format(_checkOutTime!)} WIB'),
          _buildHistoryRow('Durasi', _formatDuration(_checkOutTime!.difference(_checkInTime))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate ke halaman Home dengan menghapus semua route sebelumnya
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4D6FFF), Color(0xFF63A1FF)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Judul tanpa icon back
              Text(
                LanguageService.t(context, 'check_in'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Status indicator
              if (_isCheckedIn && _checkOutTime == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Aktif',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String key) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          LanguageService.t(context, key),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCheckOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _showCheckOutConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF63A1FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          LanguageService.t(context, 'check_out'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCheckOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF63A1FF),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageService.t(context, 'checkout_confirm_title'),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LanguageService.t(context, 'checkout_confirm_msg'),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE3A3A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(LanguageService.t(context, 'back')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close dialog
                        
                        // Panggil API checkout jika ada attendance_id
                        if (_attendanceId != null) {
                          setState(() => _isLoading = true);
                          
                          final checkoutTime = DateTime.now();
                          final duration = checkoutTime.difference(_checkInTime);
                          final durationStr = '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
                          
                          final result = await ApiService.checkOut(
                            attendanceId: _attendanceId!,
                            checkOutTime: checkoutTime,
                            duration: durationStr,
                          );
                          
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                              if (result['success'] == true) {
                                _checkOutTime = checkoutTime;
                                
                                // Tambah notifikasi realtime
                                final durationDisplay = '${duration.inHours}j ${duration.inMinutes % 60}m';
                                NotificationService.addCheckOutNotification(
                                  widget.outlet['name'] ?? 'Outlet',
                                  checkoutTime,
                                  durationDisplay,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'] ?? 'Check-out gagal')),
                                );
                              }
                            });
                          }
                        } else {
                          // Jika tidak ada attendance_id, set checkout time saja
                          setState(() {
                            _checkOutTime = DateTime.now();
                          });
                        }
                        
                        // Tidak auto-kembali, biarkan user lihat history dulu
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DEE70),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(LanguageService.t(context, 'check_out')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
