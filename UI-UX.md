UI/UX REDESIGN - Implementation Prompt

Project TitikWaktu sudah punya fondasi fungsional (database, CRUD, native
alarm) yang sedang/sudah diverifikasi lewat TASK_005. Task ini fokus ke
redesign visual + 1 fitur baru (kategori), TERPISAH dari kerja testing
fungsional yang sedang berjalan. Baca dulu semua bagian sebelum eksekusi.

## KOORDINASI DENGAN SESI LAIN
Kalau ada agent lain yang sedang mengerjakan TASK_005 (testing fitur) di
project yang sama secara bersamaan, JANGAN mulai kerja ini dulu - berpotensi
konflik file/state, terutama karena task ini butuh migration database baru
(tabel Category). Konfirmasi dulu tidak ada proses lain yang sedang jalan,
atau tunggu sampai TASK_005 selesai dan sudah di-commit.

===============================================================
BAGIAN 1: DESIGN SYSTEM (referensi warna & style, pakai ini konsisten
di semua layar, jangan improvisasi warna baru di luar daftar ini)
===============================================================

## Palet Warna

### Light mode
- Background utama: #FAFAF9
- Surface/card: #FFFFFF
- Border halus: #E5E4E1
- Teks utama: #1C1C1A
- Teks sekunder/muted: #8A8985

### Dark mode
- Background utama: #151412
- Surface/card: #1C1B18
- Border halus: #33322D
- Teks utama: #F0EFEA
- Teks sekunder/muted: #8A8985

### Warna aksen - Amber (dipakai KHUSUS untuk elemen terkait alarm/waktu,
JANGAN dipakai di semua tombol/elemen sembarangan)
- Light mode: icon/indicator #BA7517, highlight card background #FCF6EC,
  highlight card border #F3E1BE, highlight text title #633806,
  highlight text subtitle #854F0B
- Dark mode: icon/indicator #FAC775, highlight card background #241C0D,
  highlight card border #4A3714, highlight text title #FAC775,
  highlight text subtitle #EF9F27

### Warna kategori (palet pilihan warna dot untuk kategori, user pilih salah
satu saat membuat kategori baru - sediakan minimal 6 pilihan ini):
- Hijau: #639922
- Biru: #378ADD
- Coral: #D85A30
- Pink: #D4537E
- Teal: #1D9E75
- Amber: #BA7517
(gunakan warna solid ini untuk dot indicator, jangan buat gradient)

## Tipografi
Pakai font sistem default (tidak perlu custom font). Hierarki:
- Waktu besar (di empty state, di header waktu form): 38-40px, weight 500
- Judul jadwal di card: 13-15px, weight 400-500
- Subtitle/metadata di card: 11px, warna teks sekunder
- Judul halaman (AppBar): 15-17px, weight 500

## Komponen
- Card jadwal: border-radius 12px, border 0.5px solid warna border,
  padding 12px 14px, TIDAK pakai shadow/elevation (flat, dibedakan
  lewat warna & border saja)
- FAB: bulat 44px, background warna teks utama (hitam di light/putih
  di dark) dengan icon plus warna kebalikannya - BUKAN warna amber
- Form input: underline style (border-bottom saja), bukan outline box
  penuh seperti Material default
- Tombol notifikasi/alarm di form: dua kartu toggle side-by-side
  (bukan dropdown), kartu terpilih dapat border+background amber
- Empty state: judul app kecil di atas, jam real-time besar di
  tengah, subtitle status, tombol outline "+ Tambah jadwal"

===============================================================
BAGIAN 2: FITUR BARU - KATEGORI/PENGELOMPOKAN
===============================================================

## Perubahan Data Model
1. Tambah tabel baru `Categories` di Drift schema:
   - id (int, primary key, autoincrement)
   - name (text, required)
   - colorHex (text, required - simpan salah satu dari 6 warna kategori
     di atas)
2. Tambah kolom `categoryId` (int, nullable) di tabel `Schedules` -
   nullable karena jadwal boleh tidak punya kategori.
3. Relasi: satu Schedule punya MAKSIMAL SATU Category (bukan many-to-many).
4. Buat migration baru untuk perubahan schema ini - JANGAN edit migration
   yang sudah ada/sudah dijalankan sebelumnya, buat migration step baru.
5. Setelah schema berubah, jalankan build_runner untuk regenerate model.

## CategoryDao & CategoryRepository
Buat DAO dan Repository baru untuk Category, mengikuti pola yang sama
persis dengan SchedulesDao/ScheduleRepository yang sudah ada (CRUD dasar:
insert, update, delete, getAll, getById).

## UI untuk Kategori
1. Halaman baru "Kelola Kategori" - list kategori yang ada, tombol tambah
   kategori baru (input nama + pilih 1 dari 6 warna), tap kategori untuk
   edit/hapus.
2. Di form Tambah/Edit Jadwal: tambahkan field pemilih kategori (dropdown
   atau bottom sheet pilih dari kategori yang ada, dengan opsi "Tanpa
   kategori").
3. Di card jadwal (home screen): tampilkan dot warna kategori di kiri
   card (8px diameter, sesuai colorHex kategori) dan nama kategori di
   baris subtitle. Kalau jadwal tidak punya kategori, jangan tampilkan
   dot (sembunyikan elemen tersebut, bukan tampilkan dot abu-abu default).

===============================================================
BAGIAN 3: REDESIGN LAYAR YANG SUDAH ADA
===============================================================

## Home Screen
1. Terapkan palet warna & style card sesuai Bagian 1.
2. Tambahkan dot kategori di tiap card (Bagian 2).
3. Jadwal yang akan terjadi dalam waktu dekat (misal dalam 15 menit ke
   depan) dapat styling highlight khusus (background/border amber muda,
   lihat token warna "highlight" di Bagian 1) - dan subtitle-nya diganti
   jadi menunjukkan hitungan mundur ("X menit lagi") alih-alih nama
   kategori. Kalau tidak ada jadwal yang akan datang dalam rentang itu,
   tampilkan subtitle normal (nama kategori) seperti biasa.
4. FAB sesuai spec Bagian 1.

## Empty State
Ganti total sesuai spec Bagian 1 (judul app + jam real-time besar +
subtitle + tombol outline). Jam harus live-update (pakai Timer.periodic
1 detik atau sejenisnya), bukan angka statis.

## Form Tambah/Edit Jadwal
1. Terapkan underline input style.
2. Waktu & tanggal ditampilkan besar sebagai angka (tap untuk buka
   picker), bukan text field kecil.
3. Tipe notifikasi jadi dua kartu toggle (Bagian 1).
4. Tambahkan field kategori (Bagian 2).
5. Field pengulangan tetap dropdown/pemilih seperti sekarang untuk versi
   awal ini (custom interval/bulanan/exception date belum perlu redesign
   di task ini - itu scope terpisah nanti).

===============================================================
BAGIAN 4: SPLASH SCREEN
===============================================================

Buat splash screen sederhana yang tampil saat app pertama dibuka (sebelum
masuk ke home screen):
1. Tema selaras dengan konsep waktu - misal animasi jarum jam sederhana
   berputar sebentar, atau angka waktu yang fade-in, durasi total
   maksimal 1.5-2 detik (jangan bikin user menunggu lama).
2. Gunakan warna dari design system Bagian 1 (background sesuai light/
   dark mode, aksen amber untuk elemen animasi kalau relevan).
3. Setelah animasi selesai, otomatis navigasi ke home screen.
4. Implementasi dengan native splash screen API Flutter (flutter_native_splash
   package untuk splash native OS-level) DIKOMBINASIKAN dengan animated
   splash widget di sisi Flutter untuk animasi tambahan setelah native
   splash hilang - jangan cuma salah satu, karena native splash yang
   penting untuk menghindari "flash putih" saat app baru dibuka sebelum
   Flutter engine siap.

===============================================================
BAGIAN 5: ANIMASI TRANSISI ANTAR HALAMAN
===============================================================

Terapkan shared-axis transition (horizontal slide, mengikuti Material
Motion "shared axis" pattern) di SEMUA navigasi antar halaman:
1. Gunakan package `animations` (resmi dari Flutter team, berisi
   SharedAxisTransition) atau implementasi PageRouteBuilder custom
   dengan SlideTransition kalau tidak mau nambah dependency.
2. Terapkan konsisten: home→form, home→detail, home→kelola kategori,
   dan navigasi back sebaliknya.
3. Durasi transisi disarankan 250-300ms, jangan terlalu lambat (terasa
   lag) atau terlalu cepat (tidak terasa smooth).

===============================================================
VERIFIKASI AKHIR
===============================================================

1. flutter analyze - harus 0 error setelah semua perubahan.
2. Test manual dengan screenshot: home screen (light & dark), empty
   state (light & dark), form dengan kategori terisi, halaman kelola
   kategori, splash screen (bisa direkam sebagai beberapa screenshot
   berurutan atau dijelaskan durasinya).
3. Test toggle light/dark mode - pastikan SEMUA elemen (termasuk yang
   baru: dot kategori, splash, highlight card) menyesuaikan dengan
   benar, tidak ada teks yang jadi tidak terbaca di salah satu mode.
4. Test transisi halaman - konfirmasi animasi jalan smooth tanpa jank
   (boleh direkam video singkat kalau tools mendukung, atau jelaskan
   observasi manual).
5. Laporkan dengan bukti seperti biasa (screenshot/raw output), bukan
   ringkasan naratif tanpa bukti.

Kalau menemukan keputusan desain yang belum jelas dari spec ini
(misalnya harus buat sesuatu yang tidak disebutkan di atas), STOP dan
tanyakan dulu daripada berimprovisasi sendiri.
