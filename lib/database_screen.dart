import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_service.dart';
import 'outlet_detail_screen.dart';
import 'services/api_service.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  // Data outlet asli dari database
  List<Map<String, dynamic>> outlets = [];
  List<Map<String, dynamic>> _filteredOutlets = [];

  @override
  void initState() {
    super.initState();
    _fetchOutlets();
    _searchController.addListener(_filterOutlets);
  }

  Future<void> _fetchOutlets() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getOutlets();
    if (mounted) {
      setState(() {
        outlets = data;
        _filteredOutlets = data;
        _isLoading = false;
      });
    }
  }

  void _filterOutlets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredOutlets = outlets;
      } else {
        _filteredOutlets = outlets.where((outlet) {
          final name = outlet['name']?.toString().toLowerCase() ?? '';
          final code = (outlet['code'] ?? outlet['id'])?.toString().toLowerCase() ?? '';
          final address = outlet['address']?.toString().toLowerCase() ?? '';
          return name.contains(query) || code.contains(query) || address.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Search Bar
          _buildSearchBar(),

          // Outlet List
          Expanded(
            child: _buildOutletList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 69,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF4361EE),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            LanguageService.t(context, 'database'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // 0.08 * 255 ≈ 20
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: LanguageService.t(context, 'search_hint'),
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          icon: Icon(
            Icons.search,
            color: Colors.grey[400],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildOutletList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredOutlets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada outlet ditemukan',
              style: GoogleFonts.poppins(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOutlets,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: _filteredOutlets.length,
        itemBuilder: (context, index) {
          final outlet = _filteredOutlets[index];
          return _buildOutletCard(outlet);
        },
      ),
    );
  }

  Widget _buildOutletCard(Map<String, dynamic> outlet) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // 0.08 * 255 ≈ 20
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Outlet Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: Image.network(
                'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=200',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.store,
                      size: 40,
                      color: Colors.grey[500],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Outlet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  outlet['code'] ?? outlet['id'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  outlet['name'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  outlet['address'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Detail Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OutletDetailScreen(outlet: outlet),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              LanguageService.t(context, 'detail'),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
