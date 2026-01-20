import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL Laravel Anda
  static String baseUrl = 'http://127.0.0.1:8000/api'; 

  // Simpan Token
  static Future<void> saveToken(String token) async {
    try {
      debugPrint('Attempting to save token: ${token.substring(0, 5)}...');
      final prefs = await SharedPreferences.getInstance();
      bool success = await prefs.setString('auth_token', token);
      debugPrint('Token save status: $success');
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  // Ambil Token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      debugPrint('Retrieved token from storage: ${token != null ? token.substring(0, 5) + "..." : "NULL"}');
      return token;
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  // Logout - Clear semua data user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    await prefs.remove('user_id');
    await prefs.remove('user_photo');
    debugPrint('All user data cleared (Logged out)');
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('Logging in as: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      debugPrint('Login Status Code: ${response.statusCode}');
      debugPrint('Login Response Body: ${response.body}');

      final decoded = json.decode(response.body);
      if (response.statusCode == 200) {
        debugPrint('Login Decoded Keys: ${decoded is Map ? decoded.keys.toList() : "Not a Map"}');
        
        // Cari token di berbagai kemungkinan key
        String? token;
        if (decoded is Map) {
          token = decoded['token'] ?? decoded['access_token'];
          if (token == null && decoded['data'] is Map) {
            token = decoded['data']['token'] ?? decoded['data']['access_token'];
            debugPrint('Found token in [data] object');
          }
        }
        
        if (token != null) {
          debugPrint('TOKEN DETECTED: ${token.substring(0, 5)}...');
          await saveToken(token);
          
          // Save user data from response
          Map<String, dynamic> userData = {};
          if (decoded['user'] is Map) {
            userData = Map<String, dynamic>.from(decoded['user']);
          } else if (decoded['data'] is Map && decoded['data']['user'] is Map) {
            userData = Map<String, dynamic>.from(decoded['data']['user']);
          } else if (decoded is Map) {
            // Try to extract user fields directly
            userData = {
              'name': decoded['name'] ?? decoded['user_name'] ?? '',
              'email': decoded['email'] ?? decoded['user_email'] ?? '',
              'phone': decoded['phone'] ?? decoded['phone_number'] ?? '',
              'id': decoded['id'] ?? decoded['user_id'] ?? '',
            };
          }
          if (userData.isNotEmpty) {
            await saveUserData(userData);
          }
          
          return {'success': true, 'data': decoded};
        } else {
          debugPrint('CRITICAL: Login success but NO TOKEN KEY found. Keys: ${decoded.keys}');
          return {'success': false, 'message': 'Token tidak ditemukan dalam respons server'};
        }
      } else {
        return {'success': false, 'message': decoded['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Simpan Data User saat Login
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', userData['name'] ?? '');
      await prefs.setString('user_email', userData['email'] ?? '');
      await prefs.setString('user_phone', userData['phone'] ?? userData['phone_number'] ?? '');
      await prefs.setString('user_id', (userData['id'] ?? '').toString());
      await prefs.setString('user_photo', userData['photo'] ?? userData['avatar'] ?? '');
      debugPrint('User data saved: ${userData['name']}');
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Ambil Profile User dari Local Storage
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'name': prefs.getString('user_name') ?? 'User',
        'email': prefs.getString('user_email') ?? '-',
        'phone': prefs.getString('user_phone') ?? '-',
        'id': prefs.getString('user_id') ?? '',
        'photo': prefs.getString('user_photo') ?? '',
      };
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return {'name': 'User', 'email': '-', 'phone': '-'};
    }
  }

  // Ambil Profile dari API (jika ada endpoint)
  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      debugPrint('FetchProfile Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        Map<String, dynamic> userData = {};
        
        if (decoded is Map) {
          if (decoded.containsKey('data') && decoded['data'] is Map) {
            userData = Map<String, dynamic>.from(decoded['data']);
          } else if (decoded.containsKey('user') && decoded['user'] is Map) {
            userData = Map<String, dynamic>.from(decoded['user']);
          } else {
            userData = Map<String, dynamic>.from(decoded);
          }
        }
        
        // Save to local storage
        await saveUserData(userData);
        return userData;
      }
    } catch (e) {
      debugPrint('Error fetching profile from API: $e');
    }
    // Fallback to local storage
    return await getProfile();
  }

  // Ambil Semua Kategori
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      debugPrint('GetCategories Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        if (decoded is List) {
          list = List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map && decoded.containsKey('data')) {
          list = List<Map<String, dynamic>>.from(decoded['data']);
        }
        return list;
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
    return [];
  }

  // Simpan Outlet Baru
  static Future<Map<String, dynamic>> createOutlet(Map<String, dynamic> data) async {
    try {
      String? token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/outlets'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      final decoded = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': decoded};
      } else {
        return {'success': false, 'message': decoded['message'] ?? 'Gagal menyimpan outlet'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Ambil Semua Outlet (Untuk Database)
  static Future<List<Map<String, dynamic>>> getOutlets() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/outlets'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      debugPrint('GetOutlets Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        if (decoded is List) list = List<Map<String, dynamic>>.from(decoded);
        if (decoded is Map && decoded.containsKey('data')) {
          list = List<Map<String, dynamic>>.from(decoded['data']);
        }
        
        if (list.isNotEmpty) {
          debugPrint('Database Outlet Keys: ${list.first.keys.toList()}');
          debugPrint('Database Outlet Data: ${list.first}');
        }
        return list;
      }
    } catch (e) {
      debugPrint('Error fetching outlets: $e');
    }
    return [];
  }

  // Ambil Outlet Saya (Untuk Beranda)
  static Future<List<Map<String, dynamic>>> getMyOutlets() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/my-outlets'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      debugPrint('GetMyOutlets Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        if (decoded is List) list = List<Map<String, dynamic>>.from(decoded);
        if (decoded is Map && decoded.containsKey('data')) {
          list = List<Map<String, dynamic>>.from(decoded['data']);
        }
        
        if (list.isNotEmpty) {
          debugPrint('Sample Outlet Keys: ${list.first.keys.toList()}');
          debugPrint('Sample Outlet Data: ${list.first}');
        }
        return list;
      }
    } catch (e) {
      debugPrint('Error fetching my-outlets: $e');
    }
    return [];
  }

  // Tambah Outlet ke Beranda (My Outlets)
  static Future<bool> addToMyOutlets(dynamic outletId) async {
    try {
      String? token = await getToken();
      debugPrint('Adding outlet $outletId to my-outlets...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/my-outlets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'outlet_id': outletId}),
      );

      debugPrint('AddToMyOutlets Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding to my outlets: $e');
      return false;
    }
  }

  // Hapus Outlet dari Beranda
  static Future<bool> deleteMyOutlet(dynamic outletId) async {
    try {
      String? token = await getToken();
      debugPrint('Deleting outlet $outletId from my-outlets...');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/my-outlets/$outletId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('DeleteMyOutlet Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting my outlet: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getRegions() async {
    try {
      String? token = await getToken();
      debugPrint('Fetching Provinsis from: $baseUrl/regions');
      final response = await http.get(
        Uri.parse('$baseUrl/regions'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map && decoded.containsKey('data')) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching regions: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getRegencies(dynamic provinceId) async {
    try {
      String? token = await getToken();
      debugPrint('Fetching Regencies for province: $provinceId');
      final response = await http.get(
        Uri.parse('$baseUrl/regencies/$provinceId'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map && decoded.containsKey('data')) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching regencies: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getDistricts(dynamic regencyId) async {
    try {
      String? token = await getToken();
      debugPrint('Fetching Districts for regency: $regencyId');
      final response = await http.get(
        Uri.parse('$baseUrl/districts/$regencyId'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map && decoded.containsKey('data')) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
    return [];
  }

  // Ambil Riwayat Kunjungan
  static Future<List<Map<String, dynamic>>> getAttendanceHistory() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/history'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      debugPrint('GetHistory Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<Map<String, dynamic>> list = [];
        // Handle various response structures
        if (decoded is List) {
          list = List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
             list = List<Map<String, dynamic>>.from(decoded['data']);
          } else if (decoded.containsKey('data') && decoded['data'] is Map && decoded['data'].containsKey('data')) {
             list = List<Map<String, dynamic>>.from(decoded['data']['data']);
          }
        }

        if (list.isNotEmpty) {
          debugPrint('History Sample: ${list.first}');
        }
        return list;
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
    return [];
  }

  // Check In ke Outlet
  static Future<Map<String, dynamic>> checkIn({
    required int outletId,
    String? imagePath,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String? token = await getToken();
      debugPrint('Checking in to outlet: $outletId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/checkin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'outlet_id': outletId,
          if (imagePath != null) 'image': imagePath,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      debugPrint('CheckIn Status: ${response.statusCode}');
      debugPrint('CheckIn Response: ${response.body}');
      
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': decoded};
      } else {
        return {'success': false, 'message': decoded['message'] ?? 'Check-in gagal'};
      }
    } catch (e) {
      debugPrint('Error check-in: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Check Out dari Outlet
  static Future<Map<String, dynamic>> checkOut({
    required int attendanceId,
    String? imagePath,
    double? latitude,
    double? longitude,
    DateTime? checkOutTime,
    String? duration,
  }) async {
    try {
      String? token = await getToken();
      final now = checkOutTime ?? DateTime.now();
      debugPrint('Checking out from attendance: $attendanceId at ${now.toIso8601String()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'attendance_id': attendanceId,
          'check_out_time': now.toIso8601String(),
          if (duration != null) 'duration': duration,
          if (imagePath != null) 'image': imagePath,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      debugPrint('CheckOut Status: ${response.statusCode}');
      debugPrint('CheckOut Response: ${response.body}');
      
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': decoded};
      } else {
        return {'success': false, 'message': decoded['message'] ?? 'Check-out gagal'};
      }
    } catch (e) {
      debugPrint('Error check-out: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
