# PRD — {{APP_NAME}} v{{VERSION}}

> **Dokumen sumber konteks** — {{APP_IDEA}}, bahasa {{LOCALE}}, mata uang **{{CURRENCY}}**, tanpa login & tanpa cloud.

- **Lokasi proyek:** `{{PROJECT_PATH}}`
- **Versi app:** `{{VERSION}}` — `pubspec.yaml:4`
- **SDK:** `{{SDK}}` — `pubspec.yaml:7` — Flutter Material 3
- **Status baseline:** kerangka sudah ada ({{NAV_TABS}}, {{TABEL_DB}}, {{TECH_STACK}}). Dokumen ini jadi *single source of truth* untuk fase Build selanjutnya.
- **Tanggal:** {{TANGGAL}}
- **Figma ref:** {{FIGMA_URL}}

---

## 1. Ringkasan Eksekutif

{{APP_NAME}} adalah {{APP_IDEA}} di {{PLATFORM}}. Semua data tersimpan lokal via **SQLite + Drift ORM**. Tanpa login, tanpa backend. Fokus: cepat, ringan, Material 3, pagination, dan ekspor laporan.

**KPI v1:** <100ms query lokal, cold start <2s, APK <40MB, 100% fitur bekerja offline/airplane mode.

---

## 2. Tujuan

{{TUJUAN_LIST}}
<!-- Contoh Money Tracker:
- Dashboard ringkas: Saldo Saat Ini, Pemasukan Bulan Ini, ...
- CRUD transaksi & kategori, filter pencarian komprehensif.
- Statistik harian/mingguan/bulanan/tahunan dengan fl_chart.
- Anggaran bulanan per kategori + warning 80% + over-budget.
- Target menabung + kontribusi bertahap + progress.
- Ekspor PDF/Excel/JSON + Import JSON restore.
- Pengaturan: Dark Mode, Format IDR, Backup & Restore.
-->

## 3. Non-Tujuan (v1)

- Tidak ada auth/login, sync cloud, multi-user, atau multi-currency live rate.
- Tidak ada notifikasi push remote; warning hanya in-app.
- Tidak ada OCR / bank sync.

---

## 4. Tech Stack (terkunci di `pubspec.yaml:9-40`)

| Lapisan | Lib | Versi | Catatan |
|---|---|---|---|
| UI | `flutter` + `google_fonts` | `6.2.1` | `Inter`, Material 3 `AppTheme.lightTheme/darkTheme` — `{{THEME_FILE}}` |
| State | `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` | `2.6.1` / `2.6.5` | `ProviderScope` di `lib/main.dart:9` |
| DB | `drift` + `drift_flutter` + `sqlite3_flutter_libs` + `path_provider` + `path` | `2.22.0` / `0.2.4` / `0.5.27` | `AppDatabase` `driftDatabase(name: '{{DB_NAME}}')` — `{{DB_FILE}}` |
| Chart | `fl_chart` | `0.69.2` | Pie, Bar, Line |
| Format | `intl` | `0.20.2` | `initializeDateFormatting('{{LOCALE}}')` — `lib/main.dart:8` |
| Export | `pdf` + `printing` + `excel` + `file_picker` + `share_plus` | `3.11.3` / `5.14.2` / `4.0.6` / `10.1.9` / `11.0.0` | `lib/services/export_service.dart:1-306` |
| Nav | `go_router` | `15.1.3` | `StatefulShellRoute.indexedStack` {{NAV_TABS}} — `lib/app.dart:19-33` |
| Util | `uuid` | `4.5.1` | — |
| Media | `image_picker` | `1.1.2` | Foto — `lib/presentation/screens/budget/budget_screen.dart:264` |

> Sesuaikan baris sesuai {{TECH_STACK}} untuk app baru.

---

## 5. Arsitektur

### 5.1 Struktur Target (Clean Architecture)

```
lib/
├── core/
│   ├── constants/app_constants.dart:1-8
│   ├── theme/{app_colors.dart:1-127, app_theme.dart:1-151}
│   └── utils/{currency_formatter.dart:1-44, date_formatter.dart}
├── database/
│   ├── app_database.dart:14-22            // @DriftDatabase {{TABEL_DB}}
│   ├── app_database.g.dart
│   └── tables/{...}.dart
├── data/
│   ├── datasources/
│   └── repositories/*_impl.dart
├── domain/
│   ├── entities/
│   ├── repositories/ (abstract)
│   └── usecases/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
├── services/export_service.dart:14-306
└── app.dart:12-66 + main.dart:6-10
```

### 5.2 Dependensi

`presentation -> domain -> data -> database` + `core` shared. `databaseProvider` sebagai singleton Drift.

---

## 6. Desain Sistem (Material 3 — Figma Exact)

**Tokens warna** — `{{THEME_FILE}}`:
- Primary `#24389C`, `onPrimary #FFFFFF`, dll
- Surface `#F8F9FA`, `error #BA1A1A`

**Typography:** `GoogleFonts.inter` — `app_theme.dart:88-144`
**Spacing:** `stack-sm 4px`, `stack-md 12px`, `gutter 16px`, `stack-lg 24px`
**Navigasi bawah ({{NAV_TABS}}):** `lib/app.dart:54-64`

| Tab | Route | Label | Icon |
|---|---|---|---|
| 1 | `/` | Beranda | `home` |
| 2 | `/transactions` | Riwayat | `list` |
| ... | ... | ... | ... |

---

## 7. Database — Drift ORM

**File:** `{{DB_FILE}}` `schemaVersion => 1`, `beforeOpen PRAGMA foreign_keys = ON`

### 7.1 Tabel (sesuai {{TABEL_DB}})

```dart
// Contoh Money Tracker — ganti sesuai {{TABEL_DB}} untuk app baru
categories: id INTEGER PK, name TEXT, type TEXT, color TEXT, icon TEXT, createdAt DATETIME
transactions: id PK, amount REAL, transactionType TEXT, categoryId FK, note TEXT, transactionDate DATETIME
budgets: id PK, categoryId FK, amount REAL, month INTEGER, year INTEGER
savings_goals: id PK, name TEXT, targetAmount REAL, currentAmount REAL, icon TEXT, color TEXT, imagePath TEXT, deadline DATETIME
savings_contributions: id PK, goalId FK, amount REAL, date DATETIME, note TEXT
app_settings: id PK, currency TEXT DEFAULT '{{CURRENCY}}', isDarkMode BOOLEAN, language TEXT, lastBackup DATETIME
```

### 7.2 Query Utama — `lib/database/app_database.dart:43-203`

- `watchTransactions({search, type, categoryId, startDate, endDate, limit, offset})`
- `getTotalIncome / getTotalExpense / getBalance`
- `watchCategories / insertCategory / updateCategory / deleteCategory`
- `watchBudgets / insertBudget / deleteBudget`
- `watchSavingsGoals / watchContributions`
- `getSettings / watchSettings / updateSettings`

### 7.3 Seed Default — `lib/database/app_database.dart:205-346`

Dijalankan `onCreate` hanya jika tabel kosong. Sesuaikan dengan domain {{APP_NAME}}.

---

## 8. Fitur Rinci & Acceptance Criteria

### 8.1 Dashboard — `lib/presentation/screens/dashboard/dashboard_screen.dart:12-250`
- Tampil: Saldo, Pemasukan/Pengeluaran Bulan Ini, Sisa Anggaran, Aktivitas Terbaru 5, chart donut/pie
- AC: refresh indicator invalidasi

### 8.2 Transaction Management — `lib/presentation/providers/transaction_provider.dart:90-114`
- CRUD + validasi amount >0

### 8.3 Categories — `lib/presentation/providers/category_provider.dart`
- CRUD + color/icon, FK SET NULL

### 8.4 Statistik — `lib/presentation/providers/statistics_provider.dart:5-139`
- Period toggle daily/weekly/monthly/yearly + bar/line chart

### 8.5 Search & Filter — `lib/presentation/providers/transaction_provider.dart:6-44`
- Filter DateRange, Category, Type + search LIKE

### 8.6 Budget — `lib/presentation/providers/budget_provider.dart:11-85`
- Warning 80% threshold `app_constants.dart:7`

### 8.7 Savings Goal — `lib/database/tables/savings_goals.dart` + contributions
- Create goal + kontribusi + progress

### 8.8 Export & Import — `lib/services/export_service.dart:14-306`
- PDF, Excel, JSON + share + import restore

### 8.9 Settings — `lib/presentation/providers/settings_provider.dart:6-41`
- Dark mode, currency {{CURRENCY}}, backup timestamp

### 8.10 UI/UX & Navigasi
- Bottom Navigation {{NAV_TABS}}, FAB, Material 3

> Sesuaikan §8 dengan {{FITUR_UTAMA}} untuk app baru.

---

## 9. Riverpod Providers Graph

```
databaseProvider (AppDatabase singleton)
├── settingsStreamProvider / settingsProvider / isDarkModeProvider
├── categoriesStreamProvider / categoryNotifierProvider
├── transactionsStreamProvider (filter) + paginatedTransactionsProvider
├── dashboardProvider FutureProvider<DashboardData>
├── statisticsProvider FutureProvider<StatisticsData> + periodProvider
├── budgetWithSpentProvider + budgetsStreamProvider + budgetNotifierProvider
└── savingsGoalsStreamProvider + savingsContributionsProvider(goalId)
```

---

## 10. Layanan & Util

- **CurrencyFormatter** — `lib/core/utils/currency_formatter.dart:16-43`
- **AppConstants** — `lib/core/constants/app_constants.dart:1-8`
- **ExportService** detail di 8.8.

---

## 11. Bahasa & Mata Uang

- **Bahasa UI:** {{BAHASA_OUTPUT}}
- **Locale:** `{{LOCALE}}` — `lib/main.dart:8`
- **Currency:** `{{CURRENCY}}` hardcode

---

## 12. Performa & Offline-First

- **Offline-first:** `drift_flutter driftDatabase` file lokal `{{DB_NAME}}`
- **Pagination:** limit 20 offset
- **State optimasi:** StateProvider + StreamProvider + FutureProvider

---

## 13. Struktur Folder Saat Ini vs Target

**Saat ini (`lib/`):**
```
app.dart
main.dart
core/{theme, utils, constants}
database/{app_database.dart, tables/*}
presentation/{providers, screens, widgets}
services/export_service.dart
```
**Target:** tambah `lib/domain/entities`, `lib/domain/repositories`, `lib/domain/usecases`, `lib/data/datasources`, `lib/data/repositories`

---

## 14. Kriteria Penerimaan v1 (Checklist Deliverables)

- [x] Flutter project `{{APP_ID}}` + `pubspec.yaml` dependensi lengkap
- [x] Drift tabel + FK + seeding
- [x] Riverpod providers
- [x] UI screens + widgets sesuai Figma tokens
- [x] CRUD utama
- [x] Dashboard
- [x] Statistik
- [x] Budget / fitur domain utama
- [x] Export PDF/Excel/JSON + share + import
- [x] Settings dark mode + backup
- [ ] Sisa PRD (fase Build): filter UI lengkap, index DB, domain layer, test & flutter analyze clean, APK release

---

## 15. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| `sqlite3_flutter_libs` di Android 14 | crash native | lock `0.5.27` + test in-memory |
| `file_picker` scoped storage | gagal simpan | fallback `Share.shareXFiles` |
| `excel` encode besar | OOM | limit `2000` chunk |
| `image_picker` path hilang | broken | copy ke `getApplicationDocumentsDirectory` |
| Drift watcher rebuild berlebih | jank | select spesifik kolom + distinct |

---

## 16. Roadmap Eksekusi (setelah PRD)

**Fase 0 — PRD (selesai):** dokumen ini.
**Fase 1 — Domain/Data Clean:** buat entities & repos, refactor providers inject.
**Fase 2 — DB Hardening:** index, threshold snackbar, migrasi v2.
**Fase 3 — UI Parity:** logo lokal `assets/images/logo.png`, filter, chart dinamis.
**Fase 4 — Domain polish:** warning banner, image persist.
**Fase 5 — Export/Settings:** permission Android, dialog.
**Fase 6 — QA:** `flutter analyze --fatal-infos`, `flutter test`, `flutter build apk --release` offline smoke.

---

## 17. Lampiran — Figma Tokens

```js
primary: "#24389c", surface: "#f8f9fa", error: "#ba1a1a", ...
spacing: { stack-sm: "4px", stack-md: "12px", gutter: "16px", stack-lg: "24px" }
fontFamily: Inter
```

---

## 18. Cara Pakai Dokumen Ini di Sesi Berikutnya

- Jangan ulang konteks — cukup rujuk `PRD.md` ini.
- Setiap perubahan spec update bagian terkait + bump `Versi app` di `pubspec.yaml:4`.
- **Wajib baca `AGENTS.md:1-40` — aturan update PRD tiap fase otomatis dibaca AI tiap sesi.**
- Build command acuan:
  ```bash
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  flutter analyze
  flutter test
  flutter run
  flutter build apk --release
  ```

---

## 19. Aturan Wajib AI — Update PRD Tiap Selesai Fase

> **PERINTAH MUTLAK UNTUK AI (Muse Spark / opencode):** Setiap selesai **SATU FASE** (Fase 0-{{FASE_COUNT}} di `PRD.md:394-402` §16 Roadmap), AI **WAJIB** update `PRD.md` sebelum menyatakan fase selesai. **Dilarang skip. Dilarang klaim "fase selesai" tanpa PRD ter-update.**

### Trigger
- AI menilai deliverable `Fase N` tercapai, ATAU
- User mengetik: `fase selesai`, `selesai pase`, `lanjut fase`, `done`, `/finish-phase N`, `/update-prd`, atau `update PRD`

### Checklist Wajib (kerjakan berurutan — jangan klaim selesai sebelum tuntas)
1. **§14 Kriteria Penerimaan** — centang `[x]` item yang selesai; tambah `[ ]` baru jika ada scope baru
2. **§16 Roadmap** — tandai `Fase N — SELESAI (YYYY-MM-DD)` + 1-2 kalimat perubahan utama
3. **Bagian terkait** — sesuaikan `§5 Arsitektur`, `§7 Database`, `§8 Fitur Rinci`, `§13 Struktur Folder` jika ada perubahan file/tabel/provider/UI
4. **Header §1** — bump `Tanggal: YYYY-MM-DD` dan `Versi app` jika ubah `pubspec.yaml:4`
5. **Build check** — jalankan `flutter analyze` (harus clean) jika ada perubahan kode Dart
6. **Commit** — pesan `docs(prd): update PRD Fase N — <ringkasan 3-5 kata>`

### Definisi "Fase Selesai"
Fase dianggap selesai **hanya jika**: `PRD.md` sudah di-edit + checklist 1-6 tuntas + user konfirmasi. Tanpa update PRD, fase **belum selesai**.

### Jika AI Lupa
User cukup ketik `/finish-phase N` atau `/update-prd` atau ingatkan "update PRD" — AI harus langsung eksekusi checklist di atas tanpa debat. Lihat juga `AGENTS.md:12-26` §2.

---

*© {{APP_NAME}} — PRD v{{VERSION}}. Dibuat untuk eksekusi offline-first di {{PLATFORM}}. Bahasa {{BAHASA_OUTPUT}}, {{CURRENCY}}.*
