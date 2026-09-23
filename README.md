<div align="center">

# ⏱️ TitikWaktu

**Aplikasi jadwal & alarm Android dengan sistem pengulangan fleksibel**

Dibangun untuk kebutuhan nyata sehari-hari — dari alarm harian sederhana sampai jadwal tidak berpola seperti kalender pertandingan olahraga.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Kotlin](https://img.shields.io/badge/Kotlin-Native%20Alarm-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](#)

</div>

---

## 📱 Tentang Aplikasi

Alarm bawaan HP itu kaku — cuma bisa "sekali" atau "pilih hari", tidak ada
ruang untuk kasus yang lebih kompleks. **TitikWaktu** dibangun untuk
menjawab itu: sistem pengulangan lengkap (harian, mingguan hari spesifik,
bulanan, custom interval, exception dates), pengelompokan jadwal lewat
kategori, sampai fitur bulk-add untuk jadwal yang tidak mengikuti pola
matematis sama sekali (misal jadwal pertandingan liga sepak bola).

> 📸 *Screenshot & demo akan ditambahkan di sini*
>
> `assets/screenshots/dashboard.png` · `assets/screenshots/categories.png` · `assets/screenshots/alarm.png`

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🔁 **Recurrence Engine Lengkap** | Sekali, harian, mingguan (pilih hari spesifik), bulanan, custom interval, hingga exception dates |
| ⏰ **Native Alarm Scheduling** | Dibangun langsung di atas Android `AlarmManager` via platform channel — bukan package wrapper pihak ketiga — untuk reliabilitas maksimal termasuk saat reboot dan di bawah battery optimization agresif (teruji di MIUI/HyperOS) |
| 🔔 **Dua Mode Notifikasi** | Alarm penuh (full-screen, audio looping, wake lock) atau notifikasi ringan — dipilih per jadwal |
| 🏷️ **Kategori & Bulk Scheduling** | Kelompokkan jadwal, dan untuk jadwal tidak berpola (bukan recurring), pilih banyak tanggal sekaligus lewat kalender dan set jam per tanggal dalam satu alur |
| 🎵 **Custom Ringtone** | Nada alarm per kategori atau default global — pilih dari nada sistem atau file sendiri |
| 🎨 **Desain Custom** | Design system sendiri (bukan default Material template), mendukung light/dark mode penuh dengan token warna konsisten |
| 📊 **Dashboard Cerdas** | Hero card "Jadwal Berikutnya", ringkasan kategori, dan daftar jadwal harian dalam satu tampilan |

## 🏗️ Tech Stack & Arsitektur

- **Framework**: Flutter, state management [Riverpod](https://riverpod.dev)
- **Database**: [Drift](https://drift.simonbinder.eu) (SQLite type-safe) dengan migration bertahap
- **Routing**: [go_router](https://pub.dev/packages/go_router) dengan `StatefulShellRoute` untuk navigasi bertab persisten
- **Native Layer**: Kotlin — `AlarmManager`, `BroadcastReceiver` (boot persistence), `ForegroundService` (alarm penuh dengan audio looping), dijembatani ke Flutter lewat `MethodChannel`
- **Kalender**: [table_calendar](https://pub.dev/packages/table_calendar) untuk pemilihan tanggal multi-select

Keputusan desain arsitektur yang cukup krusial: scheduling alarm **tidak**
menggunakan package wrapper populer seperti `android_alarm_manager_plus`,
melainkan diimplementasikan native langsung di atas `AlarmManager` Android
untuk menghindari risiko ketidakcocokan versi di masa depan dan memberi
kontrol penuh atas exact alarm, full-screen intent, dan reboot persistence.

## 🚀 Menjalankan Project

```bash
# Clone repo
git clone https://github.com/FahroziAldinata/titikwaktu.git
cd titikwaktu

# Install dependencies
flutter pub get

# Generate kode Drift (database)
dart run build_runner build --delete-conflicting-outputs

# Jalankan di device/emulator Android
flutter run
```

**Requirement**: Flutter 3.x, Android SDK dengan minimum API level sesuai
`android/app/build.gradle`, dan device/emulator Android (aplikasi ini
platform Android saja, belum mendukung iOS).

## 📂 Struktur Project

```
lib/
├── database/            # Drift schema, DAO
├── features/            # Screen per fitur (schedule, categories, settings, splash)
├── providers/           # Riverpod providers
├── repositories/        # Repository pattern (data access layer)
├── services/             # AlarmService, NotificationService, dll
├── theme/                # Design system (AppColors, AppTheme)
└── utils/                # Router, helper

android/app/src/main/
├── kotlin/.../alarm/      # Native alarm layer (AlarmService, Receivers, ForegroundService)
```

## 🗺️ Roadmap

- [x] MVP jadwal dasar + recurrence engine lengkap
- [x] Native alarm scheduling (exact alarm, reboot persistence, full-screen intent)
- [x] Kategori & bulk scheduling
- [x] Custom ringtone
- [x] Design system & dashboard redesign
- [ ] Cloud sync (opsional, multi-device)
- [ ] Backup/export data manual
- [ ] Statistik konsistensi kegiatan

## 📝 Catatan Pengembangan

Project ini dikembangkan dengan bantuan AI coding assistant di bawah arahan,
review, dan verifikasi manual langsung di device fisik untuk setiap fitur
yang ditambahkan — termasuk debugging masalah nyata seperti kompatibilitas
versi Android Gradle Plugin, battery optimization di MIUI, dan penanganan
scoped storage untuk file audio custom.

## 📄 Lisensi

Project ini dilisensikan di bawah [MIT License](LICENSE).

---

<div align="center">
Dibuat dengan ⏱️ oleh <a href="https://github.com/FahroziAldinata">Fahrozi Aldinata</a>
</div>
