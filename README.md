# BagiPorsi (`zerohunger`)

**BagiPorsi** adalah aplikasi mobile berbasis **Flutter (Material 3)** yang mendukung **SDG 2 – Zero Hunger**. Aplikasi ini mempertemukan toko, bakery, dan warung lokal yang memiliki makanan berlebih layak konsumsi dengan masyarakat di sekitarnya—baik secara **gratis** maupun dengan **harga hemat**—sehingga mengurangi sampah makanan (*food waste*) sekaligus memperluas akses pangan.

---

## Tim Pengembang (Kelompok T08 – Claude Code)

| Nama Anggota | NIM | Fokus Pengembangan |
| :--- | :--- | :--- |
| **Evan Adhyaksa Baskara** | 241110962 | Beranda, Kartu Makanan, Penerapan Material Design 3, Multi-child Layout Beranda |
| **Michael Christoffer Chu** | 241110679 | Peta & Pencarian Lokasi, Komponen Dasar Mobile UI, Layout Peta/Chat/Profil |
| **Zakky Pratama** | 241110371 | Alur Komunikasi & Chat Penjual, Single-child Layout Beranda, Responsive UI |
| **Filbert Matthew** | 241110460 | Struktur Navigasi Utama, Profil & Halaman Pendukung, Single-child Layout Pendukung, Adaptive UI & Aksesibilitas |

---

## Fitur Utama

### 1. Beranda (`ListingMakanan`)
- **Hero Ramah Lingkungan**: Menampilkan pesan *"Selamatkan porsi, jaga bumi kita."* dengan app bar adaptif yang berubah warna saat halaman digulir.
- **Pencarian & Filter Multi-Kriteria**: Pencarian nama makanan atau toko secara *real-time*, filter kategori horizontal (`Semua`, `Ayam`, `Nasi`, `Sarapan`, `Bakery`, dll.), filter preferensi (`Porsi gratis` / `Harga hemat`), serta pengurutan (`Rekomendasi`, `Terdekat`, `Stok terbanyak`).
- **Akses Cepat Aktivitas & Favorit**: Tombol di bilah atas untuk membuka **Restoran Favorit**, **Riwayat Pengambilan**, dan **Notifikasi Aktivitas** yang terhubung langsung dengan status klaim.

### 2. Peta Lokasi (`Peta`)
- **Eksplorasi Sekitar**: Visualisasi peta interaktif dengan penanda lokasi toko (*pin*) yang menampilkan harga atau label `GRATIS`.
- **Filter & Lembar Geser (*Draggable Sheet*)**: Pencarian lokasi/toko dan chip filter (`Semua`, `Terdekat`, `Gratis`, `Masih banyak`, `Buka malam`) yang langsung memperbarui pin peta dan kartu toko terpilih.

### 3. Alur Klaim & Sistem Poin Kebaikan (`DetailMakanan`, `KlaimSaya`, `ClaimStore`)
- **Klaim Porsi dengan Kuantitas**: Pengguna memilih jumlah porsi pada halaman detail makanan, lalu mendapatkan kode pengambilan unik beserta **QR Code** simulasi.
- **Penyelesaian Pesanan dari Awal hingga Akhir**:
  - Klaim aktif menampilkan batas waktu pengambilan, tombol **Kode & QR**, **Selesaikan pengambilan**, **Hubungi penjual**, **Petunjuk ambil**, dan **Batalkan klaim**.
  - Saat pengguna menekan **Selesaikan pengambilan** (baik dari kartu klaim maupun dari lembar QR), status pesanan berpindah ke **Riwayat (`Diambil`)**.
  - Setiap **1 porsi** makanan yang selesai diambil otomatis memberikan **+10 Poin Kebaikan**, menambah jumlah **Porsi Diselamatkan**, serta menghitung **Total Penghematan**.

### 4. Chat Penjual (`PilihRestoran` & `ChatPenjual`)
- **Katalog & Percakapan Terpisah per Toko**: Pengguna dapat memilih restoran dari katalog untuk memulai percakapan, mengirim pesan, atau menggunakan *chip* balasan cepat (*quick reply*).
- **Penyimpanan Draf & Status Selesai**: Draf pesan tersimpan otomatis per toko saat berpindah halaman, dan percakapan dapat ditandai **Selesai** atau **Diaktifkan kembali**.

### 5. Profil & Halaman Pendukung (`Profil`, `ProfilDetailPage`, `ProfilEditPage`, `TempatTersimpanPage`, `profil_pages.dart`)
- **Detail & Ubah Profil**:
  - Menekan tombol **Profil** membuka halaman detail profil (`ProfilDetailPage`) dengan statistik pengguna dan ilustrasi ulasan kuliner.
  - Tombol **Ubah profil** membuka form edit profil (`ProfilEditPage`) untuk mengubah **Nama lengkap**, **Nomor ponsel (`+62`)**, **Email**, dan **Jenis kelamin** melalui *bottom sheet* interaktif (*"Apa jenis kelaminmu?"*).
- **Tempat Tersimpan Multi-Lokasi (`TempatTersimpanPage`)**:
  - Mendukung penyimpanan banyak lokasi sekaligus: **Rumah**, **Tempat Kerja**, serta lokasi favorit tambahan melalui **Tambah baru** (misalnya `Kampus`, `Kos`, `Gym`).
  - Pengguna dapat memilih lokasi aktif maupun menghapus lokasi tersimpan.
- **Halaman Fitur Terdedikasi**:
  - **Poin Kamu (`PoinKamuPage`)**: Menampilkan total poin, **Tingkatan Level Kebaikan** (`Pemula Pangan`, `Penyelamat Porsi`, `Pahlawan Zero Hunger`), dan riwayat perolehan poin per klaim.
  - **Dampak Baikmu (`DampakBaikPage`)**: Menampilkan metrik porsi diselamatkan, estimasi penghematan rupiah, komitmen SDG 2 Zero Hunger, dan daftar makanan yang telah diselamatkan.
  - **Restoran Favorit (`RestoranFavoritPage`)**: Daftar toko yang ditandai favorit dari Beranda maupun Peta.
  - **Pusat Bantuan (`PusatBantuanPage`)** & **Tentang BagiPorsi (`TentangBagiPorsiPage`)**: Halaman FAQ interaktif dan informasi misi keberlanjutan aplikasi.

---

## Struktur Proyek

```text
lib/
├── main.dart                      # Entrypoint aplikasi & konfigurasi tema Material 3
├── data/
│   ├── chat_store.dart            # State management percakapan, draf, dan status chat per toko
│   ├── claim_store.dart           # State management klaim aktif, riwayat, poin, level, & penghematan
│   ├── food_catalog.dart          # Data katalog makanan dan toko
│   └── user_profile_store.dart    # State management profil pengguna, daftar lokasi tersimpan, & favorit
├── design/
│   └── bagi_porsi_theme.dart      # Palet warna BagiPorsi & tema Material 3
├── screens/
│   ├── main_navigation.dart       # Navigasi utama 5 tab (Beranda, Peta, Klaim, Chat, Profil)
│   ├── listing_makanan.dart       # Halaman Beranda, pencarian, kategori, dan kartu makanan
│   ├── detail_makanan.dart        # Halaman detail makanan & sheet konfirmasi klaim
│   ├── peta.dart                  # Halaman Peta interaktif & filter lokasi
│   ├── klaim_saya.dart            # Halaman Klaim Aktif, Riwayat, penyelesaian klaim, & QR Code
│   ├── pilih_restoran.dart        # Daftar percakapan & pemilihan toko untuk chat
│   ├── chat_penjual.dart          # Ruang percakapan dengan penjual & balasan cepat
│   ├── profil.dart                # Halaman utama Profil
│   ├── profil_edit.dart           # Halaman Detail Profil & Ubah Profil (nama, ponsel, email, gender)
│   ├── profil_pages.dart          # Halaman Poin Kamu, Dampak Baikmu, Pusat Bantuan, & Tentang BagiPorsi
│   ├── lokasi.dart                # Halaman Tempat Tersimpan (multi-lokasi: Rumah, Kerja, Tambah baru)
│   └── restoran_favorit.dart      # Halaman daftar Restoran Favorit
└── widgets/
    ├── app_search_bar.dart        # Komponen bilah pencarian konsisten
    ├── claim_scope.dart           # InheritedNotifier pengelola akses store lintas halaman
    ├── feature_widgets.dart       # Komponen kartu dan foto makanan bersama
    └── home_quick_actions.dart    # Widget komponen aksi ringkas
```

---

## Cara Menjalankan Aplikasi

1. Pastikan **Flutter SDK** (`^3.11.1`) telah terpasang:
   ```bash
   flutter --version
   ```
2. Unduh seluruh dependensi paket:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi di emulator, perangkat fisik, atau web:
   ```bash
   flutter run
   ```
4. Jalankan analisis kode statis dan seluruh pengujian widget/unit:
   ```bash
   flutter analyze
   flutter test
   ```
