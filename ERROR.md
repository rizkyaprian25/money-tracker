# ERROR.md — Panduan Penyelesaian Error Money Tracker Personal

> **Tanggal:** 2026-09-02 | **Versi app:** `1.0.0+1` (`pubspec.yaml:4`) | **SDK:** `^3.12.2` | **Stack:** Flutter Material 3 + Drift + Riverpod — `PRD.md:40-52`
> **Konteks:** Chrome hanya untuk testing, final tetap **APK Android** offline-first (`PRD.md:1`). Dokumen ini rangkum error umum + solusi cepat tanpa ubah arsitektur produksi.

---

## 1. Error: `flutter run -d chrome` Minta Restart Extension Berulang (Loop)

### 1.1 Gejala

- Terminal: `Waiting for connection from Dart debug extension at http://localhost:XXXX` lalu `Please restart the Dart Debug Extension` berulang.
- Chrome tab putih / `flutter_bootstrap.js` tidak load, `DevTools` tidak connect.
- `flutter run -d chrome -v` berhenti di `Waiting for connection...` atau `Failed to compile`.
- Kadang muncul `MissingPluginException` / `Unsupported operation: Cannot open database` terkait `sqlite3_flutter_libs`.

### 1.2 Penyebab Root

| # | Penyebab | Penjelasan | Rujukan |
|---|---|---|---|
| **H1** | **App Android-only dijalankan di Web tanpa adapter Wasm** | `pubspec.yaml:15-17` pakai `drift: ^2.22.0` + `drift_flutter: ^0.2.4` + `sqlite3_flutter_libs: ^0.5.27` + `path_provider: ^2.1.5`. `lib/database/app_database.dart:22` pakai `driftDatabase(name: 'money_tracker.db')` yang di Android pakai native `sqlite3`, tapi di Web butuh Wasm/IndexedDB. `sqlite3_flutter_libs` tidak ada di Web → kompilasi gagal → `dwds` (Dart Web Debug Service) tidak start → extension retry loop. `lib/services/export_service.dart:1-306` juga pakai `dart:io` (`getTemporaryDirectory()`, `File`) yang tidak ada di Web. | `pubspec.yaml:15-30`, `lib/database/app_database.dart:14-26`, `lib/services/export_service.dart:14-30` |
| **H2** | **Dart Debug Extension usang / Chrome tidak Developer Mode** | Extension versi lama (<1.80) belum support Manifest V3 + Flutter 3.44 (`flutter --version` saat ini `3.44.4` / Dart `3.12.2`). Chrome tanpa `Developer mode` block `localhost` + `file://` access. | `chrome://extensions` |
| **H3** | **Cache build korup** | `.dart_tool/`, `build/web/`, `web/canvaskit/` usang setelah `flutter pub get` / update Flutter. `flutter_tools` cache `web` tidak sinkron. | `.dart_tool/`, `build/` |

> **Catatan penting:** Karena final adalah APK (`PRD.md:1` offline-first tanpa cloud), **H1 bukan bug produksi** — hanya limitasi testing di Chrome. Solusi produksi tetap jalankan di Android Emulator/Device.

### 1.3 Diagnosis Cepat (2 menit)

Jalankan berurutan, catat output:

```powershell
# 1. Cek versi & device
flutter --version
flutter doctor -v
flutter devices

# 2. Cek detail error kompilasi web
flutter run -d chrome -v 2>&1 | Select-String -Pattern "error|Error|Failed|sqlite|path_provider" -CaseSensitive:$false

# 3. Cek Chrome
# Buka chrome://extensions → cari "Dart Debug Extension" → catat versi
# Pastikan "Developer mode" (kanan atas) ON
# Pastikan "Allow access to file URLs" ON untuk extension tersebut
```

- Jika `run -v` muncul `sqlite3` / `path_provider` / `MissingPluginException` / `dart:io` → **H1**.
- Jika tidak ada error kompilasi tapi `Waiting for connection...` terus → **H2/H3**.

### 1.4 Solusi A — Fix Loop Extension untuk Testing Chrome (Tanpa Ubah Kode, 7 Langkah)

> Gunakan ini jika **tetap ingin testing di Chrome**. Urut, jangan lompat.

**Langkah 1 — Update Chrome & Extension:**
1. Update Chrome ke versi terbaru (`chrome://settings/help`).
2. Buka `chrome://extensions` → aktifkan `Developer mode` (toggle kanan atas).
3. Cari **Dart Debug Extension** → `Remove` → install ulang dari [Chrome Web Store - Dart Debug Extension](https://chrome.google.com/webstore/detail/dart-debug-extension) (versi terbaru).
4. Setelah install, di card extension → `Details` → aktifkan `Allow access to file URLs`.

**Langkah 2 — Bersihkan Cache Flutter:**
```powershell
flutter clean
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Langkah 3 — Restart IDE & Chrome:**
- Tutup semua tab Chrome (termasuk `chrome://extensions`).
- Tutup VS Code / Android Studio.
- Buka kembali, jalankan:
```powershell
flutter run -d chrome --web-renderer canvaskit -v
```
- Jika masih loop, coba fallback renderer:
```powershell
flutter run -d chrome --web-renderer html
```

**Langkah 4 — Coba Browser Alternatif:**
```powershell
flutter run -d edge -v
# atau
flutter run -d web-server
# lalu buka manual http://localhost:8080
```

**Langkah 5 — Cek Port & Firewall:**
- Pastikan antivirus/firewall tidak block `localhost:5353`, `localhost:8080`, `localhost:1234`.
- Coba `flutter run -d chrome --web-port 0` (auto port).

**Langkah 6 — Cek `flutter config`:**
```powershell
flutter config --list
# Jika enable-web tidak diperlukan untuk testing web, biarkan default.
# Jika ingin sembunyikan Chrome dari device list (fokus APK):
flutter config --no-enable-web
flutter devices  # Chrome akan hilang, loop tidak muncul lagi
# Untuk aktifkan kembali: flutter config --enable-web
```

**Langkah 7 — Jika Masih Gagal:**
- Jalankan `flutter doctor -v` pastikan `[√] Chrome - develop for the web`.
- Coba Chrome profile baru: `chrome.exe --user-data-dir="%TEMP%\chrome-flutter-test"` lalu `flutter run -d chrome`.
- Laporan bug sertakan `flutter run -d chrome -v > run_chrome.log 2>&1`.

### 1.5 Solusi B — Rekomendasi Utama (Karena Final APK, Bukan Web)

> **Ini jalur yang disarankan PRD** (`PRD.md:16` Roadmap Fase 6 — `flutter build apk --release` offline). Testing Chrome opsional saja.

**Opsi B1 — Testing di Android (Paling Akurat):**
```powershell
# Lihat emulator
flutter emulators

# Buat & jalankan emulator (jika belum ada)
flutter emulators --create

# Jalankan app di Android
flutter run
# atau spesifik
flutter run -d android
```

**Opsi B2 — Testing di Windows Desktop (Tanpa Emulator):**
```powershell
flutter config --enable-windows-desktop
flutter run -d windows
```
> Butuh Visual Studio `Desktop development with C++` (`flutter doctor -v` saat ini `[X] Visual Studio not installed` — install jika pilih jalur ini).

**Opsi B3 — Nonaktifkan Web Jika Tidak Butuh Testing Chrome:**
```powershell
flutter config --no-enable-web
flutter clean; flutter pub get
# Chrome/Edge hilang dari flutter devices, build APK tidak terpengaruh
flutter build apk --release
```
Untuk aktifkan lagi: `flutter config --enable-web`.

### 1.6 Kapan Perlu Aktifkan Web (Opsi Lanjutan — Tidak Wajib APK)

Jika di masa depan butuh `flutter run -d chrome` benar-benar jalan (misal demo web), baru tambahkan adapter Wasm:

- Tambah `lib/database/connection/` dengan conditional import `kIsWeb` → `WasmDatabase` + `IndexedDb` (lihat docs `drift_flutter`).
- Ganti `lib/database/app_database.dart:22` `AppDatabase() : super(driftDatabase(...))` → pakai `connect()` yang pilih native vs Wasm.
- Branch `kIsWeb` di `lib/services/export_service.dart:14-306` pakai `AnchorElement` blob download, bukan `File`.
- Update `web/index.html:43` & `web/manifest.json:5-6` `theme_color #24389C`.

> **Tidak dilakukan sekarang** karena final APK dan stack `PRD.md:40-52` terkunci. Lihat `PRD.md:394-402` Fase 5-6 hanya polish export & QA APK.

### 1.7 Verifikasi Sukses

| Perintah | Harapan |
|---|---|
| `flutter analyze` | `0 error` (info/warning boleh) |
| `flutter run -d chrome` (jika testing web) | `Connected to Chrome` + app muncul, tidak minta restart |
| `flutter run` (Android) | `Connected to android` + Dashboard muncul |
| `flutter build apk --release` | `✓ Built build/app/outputs/flutter-apk/app-release.apk` (<40MB — `PRD.md:1` KPI) |

---

## 2. Error Umum Lainnya

### 2.1 `sqlite3_flutter_libs` Crash di Android 14

- **Gejala:** `dlopen failed` saat launch APK.
- **Solusi:** Versi `0.5.27` (`pubspec.yaml:17`) sudah lock untuk Android 14. Jalankan `flutter clean; flutter pub get; flutter build apk --release` + test di emulator API 34. Jika masih crash, cek `android/app/src/main/AndroidManifest.xml` `minSdkVersion` ≥21.

### 2.2 `file_picker` / `image_picker` Gagal di Android 13+ Scoped Storage

- **Gejala:** Export PDF/Excel gagal save.
- **Solusi:** `lib/services/export_service.dart:215-230` sudah fallback `Share.shareXFiles` jika save gagal. Pastikan permission `READ_MEDIA_IMAGES` di `AndroidManifest.xml` (Fase 5 PRD).

### 2.3 `flutter pub get` Gagal `path_provider` / `excel` OOM

- **Gejala:** `OutOfMemory` saat `exportExcel()` >2000 rows.
- **Solusi:** `export_service.dart:153` sudah limit `2000` rows. Jika dataset besar, chunk export.

### 2.4 `dart run build_runner` Conflict

- **Solusi:** `dart run build_runner build --delete-conflicting-outputs` (perintah acuan `AGENTS.md:31-32`).

---

## 3. Checklist Sebelum Lapor Bug

Sertakan saat buka issue / minta bantuan:

```powershell
flutter --version > debug.log 2>&1
flutter doctor -v >> debug.log 2>&1
flutter analyze >> debug.log 2>&1
flutter run -d chrome -v 2>&1 | Select-Object -First 120 >> debug.log 2>&1
# Lampirkan debug.log + screenshot chrome://extensions + versi Chrome (chrome://version)
```

---

## 4. Perintah Build Acuan (AGENTS.md:31-38)

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run                 # Android (utama)
flutter run -d chrome       # testing web opsional
flutter build apk --release # final APK
```

---

## 5. Log Perbaikan (2026-09-03 — 5 Fase, `flutter analyze` No issues found, `flutter test` 6/6 pass)

> Semua error di dokumen ini diperbaiki berurutan per fase. Status awal: 20 analyze issues (0 error), `flutter test` gagal, `flutter build web` belum pernah diverifikasi.

### Fase 1 — Web/Chrome polish (§1.6 sisa + H1)
- **Temuan:** `lib/presentation/widgets/savings_goal_card.dart` import `dart:io` langsung (`File.existsSync`, `FileImage`) → kompilasi web GAGAL → loop `Waiting for connection...` (§1 H1).
- **Fix:**
  - Baru: `lib/presentation/widgets/goal_image_widget.dart` (+ `_stub/_io/_web.dart`, pola conditional export sama seperti `file_helper`) — IO pakai `FileImage`, web pakai `NetworkImage` untuk `http/blob:/data:` URL, selain itu placeholder (tidak crash).
  - `web/index.html`: title `Money Tracker Personal`, description ID, `theme-color #24389C`.
  - `web/manifest.json`: `name Money Tracker Personal`, `theme_color/background #24389C/#F8F9FA`, description ID.
- **Verifikasi:** `flutter build web` → `√ Built build\web` (72s; warning Wasm dry-run hanya dari paket `image` pihak ketiga, non-blokir).

### Fase 2 — Android permissions + image persist (§2.1, §2.2)
- **Fix:**
  - `AndroidManifest.xml`: `READ_MEDIA_IMAGES` (galeri API 33+) + `READ_EXTERNAL_STORAGE maxSdkVersion 32` (restore JSON API ≤32). Export tetap fallback share.
  - `android/app/build.gradle.kts`: `minSdk = 21` eksplisit (sebelumnya variabel implisit).
  - Baru: `lib/services/platform/image_persist.dart` (+ `_stub/_io/_web.dart`) — IO copy `image_picker` cache → `documents/goal_images/goal_<ts>.<ext>` agar path survive restart (PRD §15 Risiko); web kembalikan blob URL. `budget_screen.dart` pakai helper ini (tanpa `dart:io` langsung agar web tetap kompilasi).

### Fase 3 — Export/Share modernisasi (§2.2, §2.3)
- **Fix:**
  - `share_plus 11`: `Share.shareXFiles` deprecated → `SharePlus.instance.share(ShareParams(files: [...]))` di `export_service.dart` + `file_helper_io.dart` (4 warning hilang).
  - **Bug restore:** `importJsonString` pakai ID lama mentah, padahal `AUTOINCREMENT` tidak reset setelah DELETE → FK `categoryId/goalId` rusak. Sekarang petakan `oldId → newId` (`catIdMap`, `goalIdMap`); kategori hilang → `NULL` (ikut `SET NULL`); kontribusi tanpa goal → dilewati (FK `NOT NULL`).
  - `exportJson`/`import` sertakan `imagePath` savings goal (sebelumnya hilang saat backup).
  - Limit Excel 2000 rows dipertahankan (anti-OOM §2.3).

### Fase 4 — `flutter analyze` clean (20 → 0)
- Hapus import/variabel mati (`currency_formatter`, `dashboard_screen`, `statistics_screen`, `budget_warning_banner`, `transaction_tile` + helper `_colorFromHex` yang memang tak terpakai).
- Hapus `default:` unreachable pada switch exhaustive (`statistics_repository_impl`, `statistics_provider`).
- `use_build_context_synchronously`: guard pakai `context.mounted` milik builder-context sendiri (6 titik di `budget_screen`, `add_edit_transaction_sheet`) + guard setelah `showDatePicker`.
- Hasil: `flutter analyze` → **No issues found!**

### Fase 5 — Verifikasi final (§1.7, §3, §4)
- `dart run build_runner build --delete-conflicting-outputs` → 161 outputs OK (warning `categories` di `customConstraint` string pre-existing, non-blokir).
- `flutter test` diperbaiki (test lama gagal sejak awal — bukan regresi):
  - DB native file → `AppDatabase.forTesting(NativeDatabase.memory())` + `runAsync` (isolate real-async vs fake_async).
  - Tambah `initializeDateFormatting('id_ID')` + pecah overflow `_TopExpenseCard` (`Expanded` + ellipsis, `dashboard_screen.dart`).
  - Full-app pump diganti test hermetis (alasan di header `test/widget_test.dart`): google_fonts fetch network selalu gagal pasca-test di sandbox. 6 test: CurrencyFormatter ×3, threshold 80% ×2, BalanceCard widget ×1 → **All tests passed!**
- Pola untuk test widget ber-DB kelak: in-memory + `runAsync` + unmount/flush dalam body + `allowRuntimeFetching=false` (lihat riwayat `test/widget_test.dart`).

---

## 6. Error Build APK & Environment (2026-09-03 — teratasi, APK 25.4MB)

> Konteks mesin: RAM 8GB (~2GB bebas), proyek di drive `E:`, Pub cache di `C:`. Tiga error berbeda muncul berurutan — semuanya environment, bukan bug kode.

### 6.1 Flutter Daemon terminated — `adb` exit -1073741523

- **Gejala:** VS Code popup "The Flutter Daemon has terminated" + log `Unable to run adb... exit code -1073741523`.
- **Diagnosis:** `adb.exe` sehat saat dicek manual (`adb version/start-server/devices` semua exit 0, satu-satunya SDK di `Sdk/`, tidak ada adb ganda di PATH). Crash bersifat **transien** (kemungkinan tabrakan saat Gradle build jalan paralel).
- **Solusi:** klik **Restart Extension** di popup (atau Reload Window). Tidak perlu reinstall platform-tools. Jika berulang: cek port 5037 bentrok, hapus `%USERPROFILE%\.android\adbkey` korup, atau cek antivirus mengkarantina `adb.exe`.

### 6.2 Dart VM crash — `Could not start thread DartWorker: 22`

- **Gejala:** `flutter build apk --release` (default 3 ABI) mati dengan `os_thread.cc: Could not start thread`.
- **Penyebab:** RAM habis saat AOT compile 3 arsitektur sekaligus.
- **Solusi:** build arm64 saja (cukup untuk HP modern + APK lebih kecil): `flutter build apk --release --target-platform android-arm64`.

### 6.3 Kotlin incremental — `different roots`

- **Gejala:** `:image_picker_android/:file_picker/:share_plus:compileReleaseKotlin` gagal — `this and base files have different roots: C:\...\Pub\Cache\...` vs `E:\Mobile\money tracker\android`.
- **Penyebab:** cache incremental Kotlin tidak bisa merelativkan source plugin (drive `C:`) terhadap proyek (drive `E:`).
- **Solusi (permanen):** di `android/gradle.properties` tambah `kotlin.incremental=false`.

### 6.4 Gradle daemon OOM — `hs_err_pid*.log`, malloc gagal

- **Gejala:** `Gradle build daemon disappeared`, `hs_err` = `insufficient memory, malloc failed`, padahal `Xmx8G` (lebih besar dari RAM mesin!).
- **Solusi (permanen):** di `android/gradle.properties`: `org.gradle.jvmargs=-Xmx3G ...`, `org.gradle.workers.max=2`. Sebelum build, kill daemon yatim (`Stop-Process` pada `java.exe` Gradle/Kotlin), tutup tab browser tak perlu. Lalu `flutter clean; flutter pub get; flutter build apk --release --target-platform android-arm64`.
- **Hasil:** `√ Built build\app\outputs\flutter-apk\app-release.apk (25.4MB)` — lolos KPI <40MB (`PRD.md:1`).

---

## 7. Insiden: Restore Menghapus Transaksi (2026-09-04 — diperkeras)

- **Gejala:** setelah update APK, semua transaksi hilang, tapi nama profil + PIN (tabel `app_settings`) utuh.
- **Akar masalah:** satu-satunya wipe massal di kode adalah `importJsonString` (`export_service.dart`) — ia menghapus 5 tabel tapi **sengaja tidak menyentuh `app_settings`**. Sidik jari cocok persis: restore dari backup yang isi transaksinya kosong (mis. backup dibuat saat DB masih kosong, lalu dipulihkan setelah data asli masuk) menghapus diam-diam tanpa konfirmasi. Bukan bug `flutter install` (`adb install -r` mempertahankan data) dan bukan bug migrasi (semua migrasi non-destruktif).
- **Perbaikan:**
  1. `importJsonString` selalu menyimpan snapshot DB ke `documents/auto_backups/` (3 terbaru) **sebelum** wipe — `saveAutoBackup()` (`file_helper` + `_io/_web/_stub`).
  2. UI restore (`_showBackupRestore`): baca + validasi file dulu (`backupSummary`), tampilkan dialog konfirmasi berisi perbandingan isi file vs DB saat ini. File invalid ditolak dengan pesan.
- **Pemulihan bila sudah terjadi:** cek file `money_tracker_backup_*.json` di HP (folder Download/share) → Pulihkan dari File. Tanpa backup, baris SQLite yang terhapus tidak bisa kembali.

---

## 8. Pentest Ringan (2026-09-04 — `aapt2` + audit kode; `dart pub audit` tak tersedia di Dart 3.12)

Metode: `aapt2 dump badging/xmltree` pada APK release + `jar tf` (isi `.so`) + grep secret di `lib/` (nihil) + review permission/manifest. Tidak ada backend (offline) jadi fokus ke APK + penyimpanan lokal.

| # | Temuan | Level | Status |
|---|---|---|---|
| P1 | `allowBackup` default true → DB keuangan ikut Auto Backup Google Drive | Medium | ✅ FIX: `allowBackup=false` + `fullBackupOnly=false` (`AndroidManifest.xml`; backup resmi via JSON in-app) |
| P2 | Salt PIN statis app-wide → hash PIN sama di semua install | Medium | ✅ FIX: salt acak per-install (`pinSalt`, skema v6) + upgrade transparan PIN lama (`verifyLegacy`) |
| P3 | `.so` plugin (`sqlite3`, `dartjni`) ikut untuk 3 ABI (+-3MB) meski build arm64 | Low | ✅ FIX: `packaging.jniLibs.excludes` (`abiFilters` saja terbukti tak mempan — plugin Flutter menimpanya). APK 24.8 → **21.6MB** |
| P4 | `minSdk` efektif 24 padahal `build.gradle` tulis 21 (plugin menaikkan) | Info | ✅ FIX: tulis eksplisit `24` (jujur; Android 5-6 memang tak didukung) |
| P5 | Tanpa permission `INTERNET` → font Inter gagal fetch di HP, fallback font sistem | Low | ⏳ Tunda: bundel font +1MB; tampilan tetap rapi. Opsi kapan saja |
| P6 | Layar sensitif terlihat di recent-apps (tanpa `FLAG_SECURE`) | Low | ⏳ Backlog: butuh kode native `MainActivity` |
| — | `debuggable` false, tanpa `INTERNET`/lokasi/SMS, provider `exported=false`, `taskAffinity=""`, `extractNativeLibs=false`, tanpa secret di kode, dependensi tanpa advisory kritis yang relevan (offline, tanpa parsing file asing kecuali Excel/JSON user sendiri) | Aman | ✅ Lolos |

---

*Dokumen ini single source untuk troubleshooting. Update tiap tambah error baru. Rujuk `PRD.md:19` & `AGENTS.md:1-40`.*
