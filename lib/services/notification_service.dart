import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _key = 'local_notifications';
  
  // Tambah notifikasi baru
  static Future<void> addNotification({
    required String type,
    required String title,
    required String message,
    String? outletName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_key) ?? [];
      
      final notif = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type, // 'check_in' atau 'check_out'
        'title': title,
        'message': message,
        'outlet_name': outletName,
        'time': DateTime.now().toIso8601String(),
        'read': false,
      };
      
      existing.insert(0, jsonEncode(notif)); // Tambah di awal (terbaru)
      
      // Batasi maksimal 50 notifikasi
      if (existing.length > 50) {
        existing.removeRange(50, existing.length);
      }
      
      await prefs.setStringList(_key, existing);
      debugPrint('Notification added: $title');
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }
  
  // Ambil semua notifikasi
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_key) ?? [];
      return data.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }
  
  // Hitung notifikasi belum dibaca
  static Future<int> getUnreadCount() async {
    final notifs = await getNotifications();
    return notifs.where((n) => n['read'] != true).length;
  }
  
  // Tandai semua sebagai sudah dibaca
  static Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_key) ?? [];
      
      final updated = data.map((e) {
        final notif = Map<String, dynamic>.from(jsonDecode(e));
        notif['read'] = true;
        return jsonEncode(notif);
      }).toList();
      
      await prefs.setStringList(_key, updated);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }
  
  // Hapus semua notifikasi
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }
  
  // Helper: Tambah notifikasi check-in
  static Future<void> addCheckInNotification(String outletName, DateTime time) async {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await addNotification(
      type: 'check_in',
      title: 'Check-in Berhasil ✅',
      message: 'Anda check-in di $outletName pada $timeStr WIB',
      outletName: outletName,
    );
  }
  
  // Helper: Tambah notifikasi check-out
  static Future<void> addCheckOutNotification(String outletName, DateTime time, String duration) async {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await addNotification(
      type: 'check_out',
      title: 'Check-out Berhasil 🏁',
      message: 'Anda check-out dari $outletName pada $timeStr WIB (Durasi: $duration)',
      outletName: outletName,
    );
  }
}
