import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_service.dart';
import 'package:image_picker/image_picker.dart';
import 'services/api_service.dart';

class AddOutletScreen extends StatefulWidget {
  const AddOutletScreen({super.key});

  @override
  State<AddOutletScreen> createState() => _AddOutletScreenState();
}

class _AddOutletScreenState extends State<AddOutletScreen> {
  XFile? _image;
  final _picker = ImagePicker();
  
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _kodePosController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  
  bool _isSaving = false;
  
  // Categories from API
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  bool _isLoadingCategories = false;

  // API Data
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _regencies = [];
  List<Map<String, dynamic>> _districts = [];
  
  bool _isLoadingProvinces = false;
  bool _isLoadingRegencies = false;
  bool _isLoadingDistricts = false;

  Map<String, dynamic>? _selectedProvince;
  Map<String, dynamic>? _selectedRegency;
  Map<String, dynamic>? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _loadCategories();
  }

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingProvinces = true);
    final data = await ApiService.getRegions();
    setState(() {
      _provinces = data;
      _isLoadingProvinces = false;
    });
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    final data = await ApiService.getCategories();
    setState(() {
      _categories = data;
      _isLoadingCategories = false;
    });
  }

  Future<void> _loadRegencies(dynamic provinceId) async {
    setState(() {
      _isLoadingRegencies = true;
      _regencies = [];
      _selectedRegency = null;
      _districts = [];
      _selectedDistrict = null;
    });
    final data = await ApiService.getRegencies(provinceId);
    setState(() {
      _regencies = data;
      _isLoadingRegencies = false;
    });
  }

  Future<void> _loadDistricts(dynamic regencyId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
    });
    final data = await ApiService.getDistricts(regencyId);
    setState(() {
      _districts = data;
      _isLoadingDistricts = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _kelurahanController.dispose();
    _kodePosController.dispose();
    _teleponController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_kodeController.text.isEmpty || _namaController.text.isEmpty || _selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi data wajib (Kode, Nama, Provinsi)')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final outletData = {
      'code': _kodeController.text,
      'name': _namaController.text,
      'category_id': _selectedCategory?['id'],
      'province': _selectedProvince?['name'],
      'city': _selectedRegency?['name'],
      'districts': _selectedDistrict?['name'],
      'village': _kelurahanController.text,
      'phone': _teleponController.text,
      'postal_code': _kodePosController.text,
      'notes': _catatanController.text,
    };

    final result = await ApiService.createOutlet(outletData);

    if (mounted) {
      setState(() => _isSaving = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outlet berhasil disimpan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kembali dan beritahu kalau ada data baru
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Upload Area
                  _buildImageUpload(),
                  
                  const SizedBox(height: 24),
                  
                  // Form Fields
                  _buildLabel('Kode Outlet'),
                  _buildTextField(_kodeController, 'Contoh: KPOO1'),
                  
                  const SizedBox(height: 16),
                  
                  _buildLabel('Nama outlet'),
                  _buildTextField(_namaController, 'Nama Outlet-Nama Jalan'),
                  
                  const SizedBox(height: 16),

                  _buildLabel(LanguageService.t(context, 'phone')),
                  _buildTextField(_teleponController, 'Contoh: 08123456789', keyboardType: TextInputType.phone),
                  
                  const SizedBox(height: 16),
                  
                  _buildLabel('Kategori'),
                  _buildApiDropdown(
                    _selectedCategory, 
                    'Pilih Kategori', 
                    _categories, 
                    _isLoadingCategories,
                    (val) {
                      setState(() => _selectedCategory = val);
                    }
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildLabel('Provinsi'),
                  _buildApiDropdown(
                    _selectedProvince, 
                    'Pilih Provinsi', 
                    _provinces, 
                    _isLoadingProvinces,
                    (val) {
                      setState(() => _selectedProvince = val);
                      if (val != null) _loadRegencies(val['id']);
                    }
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildLabel('Kabupaten/Kota'),
                  _buildApiDropdown(
                    _selectedRegency, 
                    'Pilih Kabupaten/Kota', 
                    _regencies, 
                    _isLoadingRegencies,
                    (val) {
                      setState(() => _selectedRegency = val);
                      if (val != null) _loadDistricts(val['id']);
                    }
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildLabel('Kecamatan'),
                  _buildApiDropdown(
                    _selectedDistrict, 
                    'Pilih Kecamatan', 
                    _districts, 
                    _isLoadingDistricts,
                    (val) {
                      setState(() => _selectedDistrict = val);
                    }
                  ),
                  
                  const SizedBox(height: 16),
                  
                  
                  // Catatan / Alamat Detail
                  _buildLabel('Catatan'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _catatanController,
                      maxLines: 4,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan di sini...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4361EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              LanguageService.t(context, 'save'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            LanguageService.t(context, 'add_outlet'),
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

  Widget _buildImageUpload() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _image == null
              ? const Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.black54)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb 
                      ? Image.network(_image!.path, fit: BoxFit.cover) 
                      : Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildApiDropdown(
    Map<String, dynamic>? value, 
    String hint, 
    List<Map<String, dynamic>> items, 
    bool isLoading,
    Function(Map<String, dynamic>?) onChanged
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          isExpanded: true,
          value: value,
          hint: isLoading 
            ? Row(
                children: [
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Text('Memuat...', style: GoogleFonts.poppins(fontSize: 14)),
                ],
              )
            : Text(hint, style: GoogleFonts.poppins(fontSize: 14)),
          items: items.map((Map<String, dynamic> item) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: item,
              child: Text(item['name'] ?? 'No Name', style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
          onChanged: isLoading ? null : onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdown(String? value, String hint, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: 14)),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
