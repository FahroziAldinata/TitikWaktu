# PRD & Roadmap: Aplikasi Jadwal & Alarm Kegiatan (Flutter)

## 1. Ringkasan Produk

Aplikasi Android untuk mengatur jadwal kegiatan pribadi, mirip alarm bawaan HP tapi dengan sistem pengulangan yang jauh lebih fleksibel: harian, mingguan (hari tertentu), bulanan, custom interval, hingga pengecualian tanggal (skip hari libur, dsb). Setiap jadwal bisa dipicu sebagai **alarm penuh** (bunyi keras, harus di-dismiss) atau **notifikasi biasa** (ringan, bisa di-swipe) — dipilih per-jadwal oleh user.

**Target platform:** Android
**Penyimpanan data:** Lokal (offline-first), cloud sync menyusul di fase lanjutan
**Tim:** Kamu + AI coding agent

---

## 2. Masalah yang Diselesaikan

Alarm/reminder bawaan HP biasanya:
- Pengulangan terbatas (cuma "sekali", "harian", atau pilih hari doang)
- Tidak bisa custom interval (misal: tiap 3 hari, tiap 2 minggu)
- Tidak bisa exception tanggal (misal: skip kalau tanggal merah)
- Semua notifikasi diperlakukan sama (semuanya alarm keras atau semuanya notifikasi biasa)

Aplikasi ini menyelesaikan itu dengan sistem jadwal yang fleksibel + kontrol tipe notifikasi per-jadwal.

---

## 3. Target Pengguna

Kamu sendiri (personal use / power user) yang butuh manajemen jadwal harian lebih kompleks dari alarm bawaan — misal jadwal kuliah, kerja shift, olahraga, minum obat, dsb.

---

## 4. Fitur Inti (Core Features)

### 4.1 Manajemen Jadwal (CRUD)
- Tambah, edit, hapus, duplikat jadwal
- Field per jadwal:
  - Judul kegiatan
  - Deskripsi/catatan (opsional)
  - Waktu (jam:menit)
  - Tanggal mulai
  - Tipe pengulangan (lihat 4.2)
  - Tipe notifikasi (alarm penuh / notifikasi biasa)
  - Suara alarm/notifikasi (pilih dari preset atau custom)
  - Warna/label kategori (opsional, untuk visual)
  - Status aktif/nonaktif (toggle tanpa hapus)

### 4.2 Sistem Pengulangan (Recurrence Engine) — Lengkap
Ini bagian paling kompleks, mirip RRULE (iCalendar):
- **Sekali** (tidak berulang)
- **Harian** — tiap N hari (misal tiap 1 hari, tiap 3 hari)
- **Mingguan** — pilih hari spesifik (Senin, Rabu, Jumat) + interval minggu (tiap 1 minggu, tiap 2 minggu)
- **Bulanan** — tanggal spesifik (misal tanggal 15) atau pola (misal "Senin pertama tiap bulan")
- **Custom interval** — tiap N hari/minggu/bulan bebas
- **Tanggal berakhir** — pengulangan bisa "selamanya", "sampai tanggal X", atau "sebanyak N kali"
- **Pengecualian tanggal (exception dates)** — skip tanggal tertentu tanpa menghapus jadwal (misal libur nasional, cuti)
- **Reschedule sekali** — geser satu occurrence tanpa mengubah keseluruhan pola (seperti Google Calendar "edit this event only")

### 4.3 Sistem Notifikasi & Alarm
- **Mode Alarm Penuh**: full-screen intent, bunyi keras looping, butuh aksi dismiss/snooze, tetap bunyi meski HP silent/DND (perlu izin khusus)
- **Mode Notifikasi Biasa**: notifikasi standar Android, bisa di-swipe, bunyi sekali
- Snooze (durasi bisa diatur: 5/10/15 menit)
- Preview/tes suara sebelum menyimpan jadwal

### 4.4 Tampilan Jadwal
- **View Harian**: daftar jadwal hari ini, urut waktu
- **View Mingguan**: kalender mingguan, lihat semua jadwal dalam 7 hari
- **View Bulanan** (opsional fase 2): kalender bulan penuh dengan indikator jadwal
- Indikator visual jadwal yang sudah lewat/terlewat vs akan datang

### 4.5 Riwayat & Status
- Log riwayat: jadwal mana yang sudah dijalankan/di-dismiss/di-snooze/terlewat
- Statistik sederhana (opsional): konsistensi kegiatan per minggu

---

## 5. Fitur Non-Fungsional / Teknis Kritis

Ini bagian yang paling sering jadi masalah di aplikasi alarm Android — harus direncanakan dari awal:

| Kebutuhan | Detail |
|---|---|
| **Exact alarm scheduling** | Android 12+ butuh izin `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` |
| **Bertahan setelah reboot** | Re-schedule semua alarm aktif saat `BOOT_COMPLETED` |
| **Battery optimization** | Minta user whitelist app dari Doze/App Standby, atau app alarm akan meleset |
| **Full-screen intent** | Untuk mode "alarm penuh", perlu `USE_FULL_SCREEN_INTENT` (Android 14+ makin ketat izinnya) |
| **Background execution** | Gunakan `AlarmManager` native (via platform channel), BUKAN cuma `flutter_local_notifications` timer biasa, karena Dart isolate bisa dibunuh sistem |
| **Foreground service** | Untuk alarm yang sedang berbunyi (looping sound + tombol dismiss di layar kunci) |

---

## 6. Rekomendasi Tech Stack

- **Framework**: Flutter (state management: Riverpod atau Bloc — pilih salah satu, konsisten)
- **Local DB**: Drift (SQLite wrapper, type-safe, cocok untuk data relasional seperti jadwal + exception dates) atau Isar sebagai alternatif lebih simpel
- **Scheduling**: `android_alarm_manager_plus` atau native `AlarmManager` via MethodChannel untuk exact alarm + full-screen intent
- **Notifikasi**: `flutter_local_notifications`
- **Recurrence logic**: bisa pakai library `rrule` (dart) yang implementasi RFC 5545, biar tidak reinvent the wheel
- **Cloud sync (fase lanjutan)**: Firebase (Firestore + Auth) — paling cepat diintegrasikan dengan Flutter

---

## 7. Roadmap Pengembangan

### Fase 0 — Persiapan (1 minggu)
- Setup project Flutter, struktur folder, state management
- Setup Drift/Isar schema: tabel `schedules`, `recurrence_rules`, `exception_dates`, `history_log`
- Setup izin Android (exact alarm, full-screen intent, boot receiver, battery optimization)

### Fase 1 — MVP Jadwal Sederhana (2-3 minggu)
- CRUD jadwal dasar (judul, waktu, tanggal)
- Pengulangan sederhana dulu: sekali, harian, mingguan (pilih hari)
- Notifikasi biasa (belum alarm full-screen)
- View harian (list jadwal hari ini)
- Alarm bertahan setelah reboot

**Goal fase ini: alarm bisa jalan reliable dulu, sebelum nambah fitur kompleks.**

### Fase 2 — Recurrence Engine Lengkap (2 minggu)
- Tambah: custom interval, bulanan, exception dates, end date/count
- Integrasi library `rrule` atau bangun sendiri recurrence resolver
- Edit "this occurrence only" vs "all occurrences"
- View mingguan (kalender 7 hari)

### Fase 3 — Mode Alarm Penuh (2 minggu)
- Full-screen intent + foreground service untuk alarm looping
- Layar dismiss/snooze kayak alarm bangun tidur
- Toggle per-jadwal: alarm penuh vs notifikasi biasa
- Custom suara alarm

### Fase 4 — Polish & Riwayat (1-2 minggu)
- Riwayat/log status jadwal (dijalankan/terlewat/snooze)
- View bulanan (opsional)
- Kategori/label warna
- Testing menyeluruh di berbagai versi Android (khususnya battery optimization berbagai vendor: Xiaomi/Oppo/Samsung terkenal agresif membunuh background alarm)

### Fase 5 — Cloud Sync (opsional, belakangan)
- Setup Firebase Auth + Firestore
- Sync jadwal antar device
- Konflik resolution (last-write-wins atau merge)

---

## 8. Risiko & Hal yang Perlu Diwaspadai

1. **Vendor Android custom (MIUI, ColorOS, One UI)** sering membunuh background process meski sudah pakai AlarmManager — perlu edukasi user untuk whitelist manual di beberapa merek.
2. **Kompleksitas recurrence engine** adalah bagian paling berisiko meleset waktunya — sebaiknya pakai library matang (`rrule`) daripada bikin sendiri dari nol.
3. **Full-screen intent di Android 14+** butuh permission yang lebih eksplisit dari user (approve manual di settings), perlu di-handle dengan onboarding flow yang jelas.
4. **Testing alarm timing** susah diotomatisasi penuh — perlu manual testing di device fisik untuk skenario reboot, doze mode, dsb.

---

## 9. Yang Perlu Didiskusikan Lebih Lanjut

- Prioritas fase: mulai dari Fase 1 dulu (MVP) sebelum lanjut ke recurrence lengkap?
- Nama & branding aplikasi
- Target versi Android minimum (misal minSdk 26 ke atas, biar lebih mudah handle exact alarm)
- Apakah butuh onboarding/tutorial untuk minta izin battery optimization & full-screen intent di awal pakai?
