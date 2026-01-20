class LocationData {
  static const List<String> provinsiList = [
    'Aceh', 'Sumatera Utara', 'Sumatera Barat', 'Riau', 'Kepulauan Riau',
    'Jambi', 'Sumatera Selatan', 'Bangka Belitung', 'Bengkulu', 'Lampung',
    'DKI Jakarta', 'Jawa Barat', 'Jawa Tengah', 'DI Yogyakarta', 'Jawa Timur',
    'Banten', 'Bali', 'Nusa Tenggara Barat', 'Nusa Tenggara Timur',
    'Kalimantan Barat', 'Kalimantan Tengah', 'Kalimantan Selatan', 'Kalimantan Timur', 'Kalimantan Utara',
    'Sulawesi Utara', 'Gorontalo', 'Sulawesi Tengah', 'Sulawesi Barat', 'Sulawesi Selatan', 'Sulawesi Tenggara',
    'Maluku', 'Maluku Utara', 'Papua', 'Papua Barat', 'Papua Tengah', 'Papua Pegunungan', 'Papua Selatan', 'Papua Barat Daya'
  ];

  static const Map<String, List<String>> kabupatenData = {
    'Banten': ['Kab. Tangerang', 'Kab. Serang', 'Kab. Lebak', 'Kab. Pandeglang', 'Kota Tangerang', 'Kota Serang', 'Kota Cilegon', 'Kota Tangerang Selatan'],
    'Jawa Barat': ['Kab. Bekasi', 'Kota Bekasi', 'Kab. Bogor', 'Kota Bogor', 'Kota Bandung', 'Kab. Bandung', 'Kab. Bandung Barat', 'Kota Cimahi', 'Kab. Sukabumi', 'Kota Sukabumi', 'Kab. Cianjur', 'Kab. Karawang', 'Kab. Purwakarta', 'Kab. Subang', 'Kab. Cirebon', 'Kota Cirebon', 'Kab. Indramayu', 'Kab. Majalengka', 'Kab. Kuningan', 'Kab. Sumedang', 'Kab. Garut', 'Kab. Tasikmalaya', 'Kota Tasikmalaya', 'Kab. Ciamis', 'Kota Banjar', 'Kab. Pangandaran'],
    'DKI Jakarta': ['Jakarta Pusat', 'Jakarta Selatan', 'Jakarta Timur', 'Jakarta Barat', 'Jakarta Utara', 'Kepulauan Seribu'],
    'Jawa Tengah': ['Kota Semarang', 'Kota Surakarta', 'Kab. Magelang', 'Kota Magelang', 'Kab. Banyumas', 'Kab. Cilacap', 'Kab. Brebes', 'Kab. Tegal', 'Kota Tegal', 'Kab. Pemalang', 'Kab. Pekalongan', 'Kota Pekalongan', 'Kab. Batang', 'Kab. Kendal', 'Kab. Kudus', 'Kab. Jepara', 'Kab. Demak', 'Kab. Pati', 'Kab. Rembang', 'Kab. Blora', 'Kab. Grobogan', 'Kab. Sragen', 'Kab. Karanganyar', 'Kab. Wonogiri', 'Kab. Sukoharjo', 'Kab. Boyolali', 'Kab. Klaten', 'Kab. Kebumen', 'Kab. Purworejo', 'Kab. Wonosobo', 'Kab. Temanggung', 'Kab. Banjarnegara', 'Kab. Purbalingga', 'Kota Salatiga'],
    'Jawa Timur': ['Kota Surabaya', 'Kota Malang', 'Kota Batu', 'Kab. Sidoarjo', 'Kab. Gresik', 'Kab. Mojokerto', 'Kota Mojokerto', 'Kab. Jombang', 'Kab. Lamongan', 'Kab. Tuban', 'Kab. Bojonegoro', 'Kab. Madiun', 'Kota Madiun', 'Kab. Ngawi', 'Kab. Magetan', 'Kab. Ponorogo', 'Kab. Pacitan', 'Kab. Kediri', 'Kota Kediri', 'Kab. Nganjuk', 'Kab. Blitar', 'Kota Blitar', 'Kab. Tulungagung', 'Kab. Trenggalek', 'Kab. Malang', 'Kab. Pasuruan', 'Kota Pasuruan', 'Kab. Probolinggo', 'Kota Probolinggo', 'Kab. Lumajang', 'Kab. Bondowoso', 'Kab. Situbondo', 'Kab. Jember', 'Kab. Banyuwangi', 'Kab. Bangkalan', 'Kab. Sampang', 'Kab. Pamekasan', 'Kab. Sumenep'],
    'DI Yogyakarta': ['Kota Yogyakarta', 'Kab. Sleman', 'Kab. Bantul', 'Kab. Kulon Progo', 'Kab. Gunungkidul'],
    'Bali': ['Kota Denpasar', 'Kab. Badung', 'Kab. Gianyar', 'Kab. Tabanan', 'Kab. Buleleng', 'Kab. Karangasem', 'Kab. Bangli', 'Kab. Klungkung', 'Kab. Jembrana'],
    'Bengkulu': ['Kota Bengkulu', 'Kab. Bengkulu Tengah', 'Kab. Bengkulu Utara', 'Kab. Bengkulu Selatan', 'Kab. Rejang Lebong', 'Kab. Lebong', 'Kab. Kaur', 'Kab. Seluma', 'Kab. Mukomuko', 'Kab. Kepahiang'],
    'Lampung': ['Kota Bandar Lampung', 'Kota Metro', 'Kab. Lampung Selatan', 'Kab. Lampung Tengah', 'Kab. Lampung Utara', 'Kab. Lampung Barat', 'Kab. Lampung Timur', 'Kab. Tanggamus', 'Kab. Pesawaran', 'Kab. Pringsewu', 'Kab. Mesuji', 'Kab. Tulang Bawang', 'Kab. Tulang Bawang Barat', 'Kab. Way Kanan', 'Kab. Pesisir Barat'],
    'Sumatera Utara': ['Kota Medan', 'Kota Binjai', 'Kota Tebing Tinggi', 'Kota Pematangsiantar', 'Kota Tanjungbalai', 'Kota Sibolga', 'Kota Padangsidimpuan', 'Kota Gunungsitoli', 'Kab. Deli Serdang', 'Kab. Langkat', 'Kab. Karo', 'Kab. Simalungun', 'Kab. Asahan', 'Kab. Serdang Bedagai', 'Kab. Batu Bara', 'Kab. Labuhanbatu', 'Kab. Labuhanbatu Utara', 'Kab. Labuhanbatu Selatan', 'Kab. Tapanuli Utara', 'Kab. Tapanuli Tengah', 'Kab. Tapanuli Selatan', 'Kab. Toba', 'Kab. Samosir', 'Kab. Humbang Hasundutan', 'Kab. Pakpak Bharat', 'Kab. Dairi', 'Kab. Mandailing Natal', 'Kab. Padang Lawas', 'Kab. Padang Lawas Utara', 'Kab. Nias', 'Kab. Nias Utara', 'Kab. Nias Selatan', 'Kab. Nias Barat'],
    'Riau': ['Kota Pekanbaru', 'Kota Dumai', 'Kab. Kampar', 'Kab. Pelalawan', 'Kab. Siak', 'Kab. Kuantan Singingi', 'Kab. Bengkalis', 'Kab. Rokan Hulu', 'Kab. Rokan Hilir', 'Kab. Indragiri Hulu', 'Kab. Indragiri Hilir', 'Kab. Kepulauan Meranti'],
    'Kepulauan Riau': ['Kota Batam', 'Kota Tanjungpinang', 'Kab. Bintan', 'Kab. Karimun', 'Kab. Natuna', 'Kab. Kepulauan Anambas', 'Kab. Lingga'],
    'Sumatera Barat': ['Kota Padang', 'Kota Bukittinggi', 'Kota Payakumbuh', 'Kota Solok', 'Kota Pariaman', 'Kota Padang Panjang', 'Kota Sawahlunto', 'Kab. Padang Pariaman', 'Kab. Agam', 'Kab. Solok', 'Kab. Solok Selatan', 'Kab. Pasaman', 'Kab. Pasaman Barat', 'Kab. Lima Puluh Kota', 'Kab. Tanah Datar', 'Kab. Pesisir Selatan', 'Kab. Dharmasraya', 'Kab. Kepulauan Mentawai'],
    'Sumatera Selatan': ['Kota Palembang', 'Kota Prabumulih', 'Kota Lubuklinggau', 'Kota Pagar Alam', 'Kab. Ogan Ilir', 'Kab. Ogan Komering Ilir', 'Kab. Ogan Komering Ulu', 'Kab. Ogan Komering Ulu Timur', 'Kab. Ogan Komering Ulu Selatan', 'Kab. Muara Enim', 'Kab. Lahat', 'Kab. Empat Lawang', 'Kab. Musi Rawas', 'Kab. Musi Rawas Utara', 'Kab. Musi Banyuasin', 'Kab. Banyuasin', 'Kab. Penukal Abab Lematang Ilir'],
  };

  static const Map<String, List<String>> kecamatanData = {
    // Jawa Barat
    'Kab. Bekasi': ['Cibarusah', 'Cikarang', 'Tambun', 'Setu'],
    'Kota Bekasi': ['Bekasi Barat', 'Bekasi Timur', 'Bekasi Utara', 'Bekasi Selatan'],
    // DKI Jakarta
    'Jakarta Selatan': ['Kebayoran Baru', 'Kebayoran Lama', 'Cilandak', 'Tebet'],
    // Bengkulu
    'Kota Bengkulu': ['Gading Cempaka', 'Muara Bangka Hulu', 'Ratu Agung', 'Selebar', 'Singaran Pati', 'Sungai Serut', 'Teluk Segara', 'Kampung Melayu', 'Bengkulu City'],
    'Kab. Bengkulu Utara': ['Arga Makmur', 'Enggano', 'Kerkap', 'Putri Hijau'],
  };

  static const Map<String, List<String>> kelurahanData = {
    // Jawa Barat
    'Cibarusah': ['Ridogalih', 'Sirnajati', 'Cibarusah Kota'],
    // DKI Jakarta
    'Kebayoran Baru': ['Selong', 'Gunung', 'Kramat Pela', 'Gandaria Utara'],
    // Bengkulu
    'Gading Cempaka': ['Jalan Gedang', 'Lingkar Barat', 'Padang Harapan', 'Sido Mulyo'],
    'Arga Makmur': ['Gunung Alam', 'Karang Anyar', 'Purwosari'],
  };

  static List<String> getKabupatenList(String? provinsi) {
    if (provinsi == null) return [];
    return kabupatenData[provinsi] ?? ['Kab. A di $provinsi', 'Kab. B di $provinsi', 'Kota C di $provinsi'];
  }

  static List<String> getKecamatanList(String? kabupaten) {
    if (kabupaten == null) return [];
    return kecamatanData[kabupaten] ?? ['Kecamatan 1', 'Kecamatan 2', 'Kecamatan 3'];
  }

  static List<String> getKelurahanList(String? kecamatan) {
    if (kecamatan == null) return [];
    return kelurahanData[kecamatan] ?? ['Kelurahan A', 'Kelurahan B', 'Desa C'];
  }
}
