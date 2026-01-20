import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_service.dart';
import 'services/api_service.dart';

class OutletDetailScreen extends StatelessWidget {
  final Map<String, dynamic> outlet;

  const OutletDetailScreen({super.key, required this.outlet});

  // Helper untuk mendapat nilai dari berbagai kemungkinan key
  String? _getValue(List<String> keys) {
    for (var key in keys) {
      final value = outlet[key];
      if (value != null && value.toString().isNotEmpty && value != '-') {
        return value.toString();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Debug info
    debugPrint('DETAIL SCREEN DATA: ${outlet.keys.toList()}');
    debugPrint('FULL OUTLET DATA: $outlet');
    
    // Ambil nilai dengan berbagai kemungkinan key
    final name = _getValue(['name', 'outlet_name']) ?? 'Unknown';
    final code = _getValue(['code', 'outlet_code', 'kode']);
    final phone = _getValue(['phone', 'phone_number', 'telepon', 'no_telp']);
    final category = _getValue(['category', 'category_name', 'kategori']);
    final province = _getValue(['province', 'provinsi', 'prov']);
    final regency = _getValue(['city', 'regency', 'kabupaten', 'kabupaten_kota', 'kota']);
    final district = _getValue(['districts', 'district', 'kecamatan']);
    final village = _getValue(['village', 'kelurahan', 'desa', 'ward', 'sub_district']);
    final postalCode = _getValue(['postal_code', 'kode_pos', 'zip_code']);
    final notes = _getValue(['notes', 'catatan', 'note', 'address', 'alamat']);
    
    // Buat alamat lengkap
    final addressParts = [village, district, regency, province].where((s) => s != null && s.isNotEmpty).toList();
    final fullAddress = addressParts.isNotEmpty ? addressParts.join(', ') : null;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: Icon(Icons.store, size: 60, color: Colors.grey[400]),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Details - tampilkan semua yang ada datanya
                        _buildDetailItem(context, 'outlet_code', code),
                        _buildDetailItem(context, 'phone', phone),
                        _buildDetailItem(context, 'category', category),
                        
                        const Divider(height: 24),
                        
                        // Lokasi section
                        Text(
                          'Lokasi',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        _buildDetailItem(context, 'province', province),
                        _buildDetailItem(context, 'regency', regency),
                        _buildDetailItem(context, 'district', district),
                        _buildDetailItem(context, 'village', village),
                        _buildDetailItem(context, 'postal_code', postalCode),
                        
                        // Alamat Lengkap
                        if (fullAddress != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fullAddress,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const Divider(height: 32),
                        
                        Text(
                          LanguageService.t(context, 'notes'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notes ?? '-', 
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Fixed Bottom Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Menambahkan outlet...'), duration: Duration(seconds: 1)),
                            );

                            final success = await ApiService.addToMyOutlets(outlet['id']);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${outlet['name']} berhasil ditambahkan ke Beranda!'),
                                  backgroundColor: const Color(0xFF4361EE),
                                ),
                              );
                              // Kembali ke Home dan hapus semua route lain di atasnya
                              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal menambahkan outlet. Coba lagi.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF63A1FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            LanguageService.t(context, 'add'),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5F5),
                            foregroundColor: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            LanguageService.t(context, 'cancel'),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String labelKey, String? value) {
    if (value == null || value.isEmpty || value == '-') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              LanguageService.t(context, labelKey),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
