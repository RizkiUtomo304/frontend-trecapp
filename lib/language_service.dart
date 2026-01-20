import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale _currentLocale = const Locale('id');
  Locale get currentLocale => _currentLocale;

  void setLanguage(String language) {
    switch (language) {
      case 'English':
        _currentLocale = const Locale('en');
        break;
      case 'Arab':
        _currentLocale = const Locale('ar');
        break;
      default:
        _currentLocale = const Locale('id');
    }
    notifyListeners();
  }

  static String t(BuildContext context, String key) {
    final locale = _instance.currentLocale.languageCode;
    return _translations[locale]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    'id': {
      'home': 'Beranda',
      'history': 'Riwayat',
      'profile': 'Profil',
      'welcome': 'Selamat Datang',
      'search': 'Cari',
      'add_outlet': 'Tambah Outlet',
      'outlet_new': 'Outlet Baru',
      'database': 'Database',
      'edit_profile': 'Edit Profil',
      'settings': 'Pengaturan',
      'about': 'Tentang',
      'help': 'Bantuan',
      'logout': 'Log out',
      'save': 'Simpan',
      'name': 'Nama Lengkap',
      'phone': 'Nomor Telepon',
      'email': 'Email',
      'password': 'Kata Sandi',
      'new_password': 'Masukkan kata sandi Baru',
      'select_language': 'Pilih Bahasa',
      'select_timezone': 'Zona waktu',
      'general': 'Umum',
      'identity': 'Identitas',
      'information': 'Informasi',
      'update_password': 'Perbarui Kata Sandi',
      'change_photo': 'Ubah Foto Profil',
      'visited': 'Baru Dikunjungi',
      'detail': 'Detail',
      'search_hint': 'Ketik untuk mencari',
      'add': 'Tambahkan',
      'cancel': 'Batalkan',
      'outlet_code': 'Kode Outlet',
      'outlet_name': 'Nama Outlet',
      'category': 'Kategori',
      'province': 'Provinsi',
      'regency': 'Kabupaten/Kota',
      'district': 'Kecamatan',
      'village': 'Kelurahan/Desa',
      'postal_code': 'Kode Pos',
      'notes': 'Catatan',
      'check_in': 'Check In',
      'check_out': 'Check Out',
      'date': 'Tanggal',
      'duration': 'Durasi',
      'checkout_confirm_title': 'Check Out',
      'checkout_confirm_msg': 'Apakah Anda yakin ingin melakukan checkout sekarang?',
      'back': 'kembali',
      'checkout_required': 'Silakan checkout terlebih dahulu',
    },
    'en': {
      'home': 'Home',
      'history': 'History',
      'profile': 'Profile',
      'welcome': 'Welcome',
      'search': 'Search',
      'add_outlet': 'Add Outlet',
      'outlet_new': 'New Outlet',
      'database': 'Database',
      'edit_profile': 'Edit Profile',
      'settings': 'Settings',
      'about': 'About',
      'help': 'Help',
      'logout': 'Log out',
      'save': 'Save',
      'name': 'Full Name',
      'phone': 'Phone Number',
      'email': 'Email',
      'password': 'Password',
      'new_password': 'Enter new password',
      'select_language': 'Select Language',
      'select_timezone': 'Timezone',
      'general': 'General',
      'identity': 'Identity',
      'information': 'Information',
      'update_password': 'Update Password',
      'change_photo': 'Change Profile Photo',
      'visited': 'Recently Visited',
      'detail': 'Detail',
      'search_hint': 'Type to search',
      'add': 'Add',
      'cancel': 'Cancel',
      'outlet_code': 'Outlet Code',
      'outlet_name': 'Outlet Name',
      'category': 'Category',
      'province': 'Province',
      'regency': 'Regency/City',
      'district': 'District',
      'village': 'Village',
      'postal_code': 'Postal Code',
      'notes': 'Notes',
      'check_in': 'Check In',
      'check_out': 'Check Out',
      'date': 'Date',
      'duration': 'Duration',
      'checkout_confirm_title': 'Check Out',
      'checkout_confirm_msg': 'Are you sure you want to check out now?',
      'back': 'back',
      'checkout_required': 'Please checkout first',
    },
    'ar': {
      'home': 'الرئيسية',
      'history': 'السجل',
      'profile': 'الملف الشخصي',
      'welcome': 'أهلاً بك',
      'search': 'بحث',
      'add_outlet': 'إضافة منفذ',
      'outlet_new': 'منفذ جديد',
      'database': 'قاعدة البيانات',
      'edit_profile': 'تعديل الملف الشخصي',
      'settings': 'الإعدادات',
      'about': 'حول',
      'help': 'مساعدة',
      'logout': 'تسجيل الخروج',
      'save': 'حفظ',
      'name': 'الاسم الكامل',
      'phone': 'رقم الهاتف',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'new_password': 'أدخل كلمة مرور جديدة',
      'select_language': 'اختر اللغة',
      'select_timezone': 'المنطقة الزمنية',
      'general': 'عام',
      'identity': 'الهوية',
      'information': 'معلومات',
      'update_password': 'تحديث كلمة المرور',
      'change_photo': 'تغيير صورة الملف الشخصي',
      'visited': 'تمت زيارته مؤخراً',
      'detail': 'Detail',
      'search_hint': 'اكتب للبحث',
      'add': 'إضافة',
      'cancel': 'إلغاء',
      'outlet_code': 'رمز المنفذ',
      'outlet_name': 'اسم المنفذ',
      'category': 'الفئة',
      'province': 'المقاطعة',
      'regency': 'المنطقة/المدينة',
      'district': 'المنطقة',
      'village': 'القرية',
      'postal_code': 'الرمز البريدي',
      'notes': 'ملاحظات',
      'check_in': 'تسجيل الدخول',
      'check_out': 'تسجيل الخروج',
      'date': 'التاريخ',
      'duration': 'المدة',
      'checkout_confirm_title': 'تسجيل الخروج',
      'checkout_confirm_msg': 'هل أنت متأكد أنك تريد تسجيل الخروج الآن؟',
      'back': 'عودة',
      'checkout_required': 'يرجى تسجيل الخروج أولاً',
    }
  };
}
