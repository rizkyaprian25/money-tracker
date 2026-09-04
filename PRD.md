# PRD — Money Tracker Personal v1.0

> **Dokumen sumber konteks** — simpan percakapan pertama agar tidak mengulang. Aplikasi offline-first pelacak pemasukan/pengeluaran pribadi, bahasa Indonesia, mata uang **IDR (Rp)**, tanpa login & tanpa cloud.

- **Lokasi proyek:** `E:\Mobile\money tracker\`
- **Versi app:** `1.0.0+1` — `pubspec.yaml:4`
- **SDK:** `^3.12.2` — `pubspec.yaml:7` — Flutter Material 3
- **Status baseline:** kerangka sudah ada (5 tab `go_router`, Drift 6 tabel, Riverpod, fl_chart, export service). Dokumen ini jadi *single source of truth* untuk fase Build selanjutnya.
- **Tanggal:** 2026-09-03
- **Update terakhir Fase 4-6:** 2026-09-03 — ERROR.md hardening (web/Chrome kompilasi via `goal_image_widget`, permission Android + `minSdk 21`, image persist `documents/goal_images`, SharePlus API + import ID mapping, `flutter analyze` 0 issues, `flutter test` 6/6, `flutter build web` sukses, **`flutter build apk --release` sukses `app-release.apk 24.0MB` arm64**). Sisa: currency dialog
- **Update terakhir Fase 3:** 2026-09-02 — UI Parity (logo lokal `assets/images/logo.png` 8354B + DateRangePicker + Dropdown Category filter + bar interval dinamis `statistics_screen.dart:93-155`)
- **Update terakhir Fase 2:** 2026-09-02 — DB Hardening (schema v2 + 8 index + migrasi v1→v2) + threshold 80% snackbar/banner (`budget_warning_helper.dart`, `budget_warning_banner.dart`)
- **Update terakhir Fase 0:** 2026-09-02 — formalisasi PRD + AGENTS + opencode.json + Prompt.md/templates + command /finish-phase (struktur 19 section aktif)
- **Figma ref:** https://www.figma.com/design/9xLJL1QPtm1IpCb4DY5RVZ/Untitled?node-id=0-1&m=dev&t=e5aUa3hPXxvTNapZ-1 (di-embed sebagai HTML di prompt: Beranda, Riwayat Transaksi, Statistik Pengeluaran, Anggaran & Target, Pengaturan)

---

## 1. Ringkasan Eksekutif

Aplikasi **Money Tracker Personal** adalah aplikasi mobile Android offline-first untuk mencatat pemasukan & pengeluaran harian. Semua data tersimpan lokal via **SQLite + Drift ORM**. Tanpa login, tanpa backend. Fokus: cepat, ringan, Material 3, pagination, dan ekspor laporan (PDF/Excel/JSON). Target pengguna individu yang butuh kontrol anggaran bulanan, warning 80%, dan target menabung.

**KPI v1:** <100ms query lokal, cold start <2s, APK <40MB, 100% fitur bekerja offline/airplane mode.

---

## 2. Tujuan

- Dashboard ringkas: Saldo Saat Ini, Pemasukan Bulan Ini, Pengeluaran Bulan Ini, Sisa Anggaran, Aktivitas Terbaru, Breakdown Kategori, Tren.
- CRUD transaksi & kategori, filter pencarian komprehensif.
- Statistik harian/mingguan/bulanan/tahunan dengan `fl_chart`.
- Anggaran bulanan per kategori + warning 80% + over-budget.
- Target menabung (savings goal) + kontribusi bertahap + progress.
- Ekspor PDF/Excel/JSON + Import JSON restore.
- Pengaturan: Dark Mode, Format IDR, Backup & Restore, Info App.

## 3. Non-Tujuan (v1)

- Tidak ada auth/login, sync cloud, multi-user, atau multi-currency live rate.
- Tidak ada notifikasi push remote; warning budget hanya in-app (opsi `flutter_local_notifications` dipertimbangkan v1.1).
- Tidak ada OCR struk / bank sync.

---

## 4. Tech Stack (terkunci di `pubspec.yaml:9-40`)

| Lapisan | Lib | Versi | Catatan |
|---|---|---|---|
| UI | `flutter` + `google_fonts` | `6.2.1` | `Inter`, Material 3 `AppTheme.lightTheme/darkTheme` — `lib/core/theme/app_theme.dart:6-70` |
| State | `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` | `2.6.1` / `2.6.5` | `ProviderScope` di `lib/main.dart:9` |
| DB | `drift` + `drift_flutter` + `sqlite3_flutter_libs` + `path_provider` + `path` | `2.22.0` / `0.2.4` / `0.5.27` | `AppDatabase` `driftDatabase(name: 'money_tracker.db')` — `lib/database/app_database.dart:23` |
| Chart | `fl_chart` | `0.69.2` | Pie, Bar, Line |
| Format | `intl` | `0.20.2` | `initializeDateFormatting('id_ID')` — `lib/main.dart:8` |
| Export | `pdf` + `printing` + `excel` + `file_picker` + `share_plus` | `3.11.3` / `5.14.2` / `4.0.6` / `10.1.9` / `11.0.0` | `lib/services/export_service.dart:1-306` |
| Nav | `go_router` | `15.1.3` | `StatefulShellRoute.indexedStack` 5 cabang — `lib/app.dart:19-33` |
| Util | `uuid` | `4.5.1` | — |
| Media | `image_picker` | `1.1.2` | Foto target menabung — `lib/presentation/screens/budget/budget_screen.dart:264` |
| Kunci | `local_auth` + `crypto` | `2.3.0` / `3.0.6` | Sidik jari (`BiometricAuth`) + hash PIN SHA-256 — v1.1 (2026-09-04) |

---

## 5. Arsitektur

### 5.1 Struktur Target (Clean Architecture)

```
lib/
├── core/
│   ├── constants/app_constants.dart:1-8  // appName, currency IDR, locale id_ID, threshold 0.8
│   ├── theme/{app_colors.dart:1-127, app_theme.dart:1-151}
│   └── utils/{currency_formatter.dart:1-44, date_formatter.dart}
├── database/
│   ├── app_database.dart:14-22            // @DriftDatabase 6 tables
│   ├── app_database.g.dart               // generated
│   └── tables/{categories,transactions,budgets,savings_goals,savings_contributions,app_settings}.dart
├── data/
│   ├── datasources/ (drift wrappers)      // [TODO] pisah dari providers
│   └── repositories/*_impl.dart           // [TODO] implement domain abstract
├── domain/
│   ├── entities/{transaction,category,budget,savings_goal}.dart
│   ├── repositories/ (abstract)
│   └── usecases/{get_balance,get_monthly_summary,set_budget, ...}
├── presentation/
│   ├── providers/{database,transaction,category,budget,savings,statistics,dashboard,settings}_provider.dart
│   ├── screens/{dashboard,transactions,statistics,budget,settings}/
│   └── widgets/{balance_card,transaction_tile,donut_chart,budget_progress_card,savings_goal_card}.dart
├── services/export_service.dart:14-306
└── app.dart:12-66 + main.dart:6-10
```

**Kondisi saat ini (Fase 1 — SELESAI 2026-09-02):** `lib/domain/entities` (7 entities: transaction, category, budget, savings_goal, dashboard, statistics, app_settings — `lib/domain/entities/*.dart`), `lib/domain/repositories` (7 abstract: transaction, category, budget, savings, dashboard, statistics, settings), `lib/domain/usecases` (get_balance, get_dashboard, get_monthly_summary, get_statistics, manage_budget, manage_savings, manage_transaction + `usecase_providers.dart`), `lib/data/mappers/entity_mapper.dart` (9 extension), `lib/data/repositories/*_impl.dart` (7 impl + `repository_providers.dart` 7 Provider), `lib/data/datasources/local_database.dart`, dan `lib/presentation/providers/*_entity_provider.dart` (7 entity providers: dashboard_entity, transaction_entity, statistics_entity, budget_entity, savings_entity, category_entity, settings_entity) **sudah terimplementasi**. Legacy providers (`transaction_provider.dart`, `budget_provider.dart`, dll) tetap ada untuk backward compat, tapi layer clean sudah ter-inject via `repository_providers.dart:8-48` dan direkomendasikan untuk screen baru — validasi `flutter analyze` clean (130 info/warning saja, 0 error).

### 5.2 Dependensi

`presentation (*_entity_provider.dart) -> domain (usecases -> repositories abstract -> entities) -> data (repository_impl + mappers + datasources -> database)` + `core` shared. `databaseProvider` tetap singleton Drift (`lib/presentation/providers/database_provider.dart:1-8`), di-wrap oleh `LocalDatabase` lalu di-inject ke 7 repositories via `lib/data/providers/repository_providers.dart`. Legacy `presentation -> database` masih ada tapi ditandai deprecated, digantikan `presentation -> domain -> data -> database`.

---

## 6. Desain Sistem (Material 3 — Figma Exact)

**Tokens warna** — `lib/core/theme/app_colors.dart:5-58` (disalin dari Figma Tailwind config di prompt):

- Primary `#24389C`, `onPrimary #FFFFFF`, `primaryContainer #3F51B5`, `onPrimaryContainer #CACFFF`, `primaryFixed #DEE0FF`, `primaryFixedDim #BAC3FF`
- Secondary `#006E1C`, `secondaryContainer #91F78E`, `secondaryFixed #94F990`
- Tertiary `#8C0005`, `tertiaryContainer #B51010`, `tertiaryFixed #FFDAD5`
- Surface `#F8F9FA`, `onSurface #191C1D`, `surfaceVariant #E1E3E4`, `surfaceContainerLowest #FFFFFF` → `Highest #E1E3E4`, `outline #757684`, `outlineVariant #C5C5D4`, `error #BA1A1A`
- Light/Dark `ColorScheme` — `app_colors.dart:62-127`, `app_theme.dart:6-86`

**Typography:** `GoogleFonts.inter` — `app_theme.dart:88-144` (`displayLarge 32/600`, `titleLarge 22/600`, `titleMedium 16/600`, `bodyMedium 14/400`, `labelSmall 11/500`).

**Spacing (Figma):** `stack-sm 4px`, `stack-md 12px`, `gutter 16px`, `stack-lg 24px`, `margin-mobile 16px`. Radius `lg 0.5rem`, `xl 0.75rem`.

**Navigasi bawah (5 destinasi):** `lib/app.dart:54-64`

| Tab | Route | Label | Icon |
|---|---|---|---|
| 1 | `/` | Beranda | `home` |
| 2 | `/transactions` | Riwayat | `list` |
| 3 | `/statistics` | Statistik | `bar_chart` |
| 4 | `/budget` | Anggaran | `account_balance_wallet` |
| 5 | `/settings` | Pengaturan | `settings` |

Header tiap screen: `AppBar` `bg #CCF8F9FA` blur + logo lokal `assets/images/logo.png` (32x32, `Image.asset` dengan `errorBuilder` fallback `account_balance_wallet` + `pubspec.yaml:44-45` `assets/images/`) + Avatar `person` — `dashboard_screen.dart:21-37`, `transactions_screen.dart:63-72`, `statistics_screen.dart:18-25`, `budget_screen.dart:22-33`, `settings_screen.dart:22-26` + footer `settings_screen.dart:147-149` 48x48. **Fase 3:** `assets/images/logo.png` 512x512 8354B (System.Drawing, lingkaran putih + wallet + text MT, bg `primary #24389C`). FAB `primaryContainer` `+` — `dashboard_screen.dart:38-48` membuka `AddEditTransactionSheet`.

**Mockup mapping:**
- Beranda HTML → `dashboard_screen.dart:60-113` (BalanceCard + BudgetRemaining donut 65% + TopExpense 2 + Aktivitas Terbaru 5 + Pie breakdown)
- Riwayat → `transactions_screen.dart:88-230` (search + ChoiceChip 5 + grup Hari Ini/Kemarin + Dismissible)
- Statistik → `statistics_screen.dart:38-234` (toggle Harian/Mingguan/Bulanan/Tahunan + Total Pengeluaran + Bar income vs expense 6 bulan + Line tren + Kategori progress)
- Anggaran → `budget_screen.dart:42-97` (ringkasan + BudgetProgressCard + SavingsGoal Grid 2 kol)
- Pengaturan → `settings_screen.dart:20-160` (profil Alex Finance + Preferensi Switch + Data Export 3 tombol + Tentang)

---

## 7. Database — Drift ORM

**File:** `lib/database/app_database.dart:14-40` `schemaVersion => 6` (`AppConstants.dbVersion:6` = 6), `beforeOpen PRAGMA foreign_keys = ON` — `lib/database/app_database.dart:37-39` + `MigrationStrategy onUpgrade v1→v2` (index) + `v2→v3` (`addColumn` profil/warning) + `v3→v4` (tabel `recurring_transactions` + `addColumn pinHash` + index) + `v4→v5` (biometrik/backup) + `v5→v6` (`addColumn pinSalt` — `app_database.dart:31-55`). Index dibuat via `_createIndexes()` — `app_database.dart:41-55` (8 index + `idx_recurring_nextDate` di migrasi v4).

### 7.1 Tabel (6)

#### `categories` — `lib/database/tables/categories.dart:3-10`
```dart
id INTEGER AUTO_INCREMENT PK
name TEXT
type TEXT // income | expense
color TEXT // hex #24389C
icon TEXT // material icon name
createdAt DATETIME DEFAULT currentDateAndTime
```

#### `transactions` — `lib/database/tables/transactions.dart:4-12`
```dart
id INTEGER AUTO_INCREMENT PK
amount REAL
transactionType TEXT // income | expense
categoryId INTEGER NULL REFERENCES categories(id) ON DELETE SET NULL
note TEXT NULL
transactionDate DATETIME
createdAt DATETIME DEFAULT currentDateAndTime
```

#### `budgets` — `lib/database/tables/budgets.dart:3-10`
```dart
id INTEGER AUTO_INCREMENT PK
categoryId INTEGER NULL REFERENCES categories(id) ON DELETE CASCADE
amount REAL
month INTEGER // 1-12
year INTEGER
createdAt DATETIME
```

#### `savings_goals` — `lib/database/tables/savings_goals.dart:3-13`
```dart
id INTEGER AUTO_INCREMENT PK
name TEXT
targetAmount REAL
currentAmount REAL DEFAULT 0
icon TEXT NULL
color TEXT NULL
imagePath TEXT NULL
deadline DATETIME NULL
createdAt DATETIME
```

#### `savings_contributions` — `lib/database/tables/savings_contributions.dart:3-9`
```dart
id INTEGER AUTO_INCREMENT PK
goalId INTEGER NOT NULL REFERENCES savings_goals(id) ON DELETE CASCADE
amount REAL
date DATETIME
note TEXT NULL
```

#### `app_settings` — `lib/database/tables/app_settings.dart:3-12`
```dart
id INTEGER AUTO_INCREMENT PK
currency TEXT DEFAULT 'IDR'
isDarkMode BOOLEAN DEFAULT false
language TEXT DEFAULT 'id'
lastBackup DATETIME NULL
profileName TEXT DEFAULT 'Pengguna'       // v3 (2026-09-03)
profileEmail TEXT DEFAULT ''              // v3
budgetWarningEnabled BOOLEAN DEFAULT true // v3
pinHash TEXT DEFAULT ''                   // v4 (2026-09-03, SHA-256 PIN, '' = mati)
biometricEnabled BOOLEAN DEFAULT true   // v5 (2026-09-04, toggle sidik jari)
autoBackupFreq TEXT DEFAULT 'weekly'    // v5 (off|weekly|monthly)
```

### 7.2 Query Utama — `lib/database/app_database.dart:43-203` + Index v2 — `app_database.dart:41-55`
- `watchTransactions({search, type, categoryId, startDate, endDate, limit, offset})` join `leftOuterJoin categories` + `like '%search%'` pada `note` & `category.name` + `orderBy desc transactionDate` + `limit/offset` — `app_database.dart:43-80` — **di-index:** `idx_transactions_transactionDate`, `idx_transactions_categoryId`, `idx_transactions_transactionType`, `idx_transactions_date_type`
- `getTransactions` sync counterpart — `app_database.dart:83-120` — pakai index yang sama
- `getTotalIncome / getTotalExpense / getBalance` via `selectOnly sum(amount)` — `app_database.dart:122-150` — optimal via `idx_transactions_date_type`
- `watchCategories / watchCategoriesByType / insertCategory / updateCategory / deleteCategory` — `app_database.dart:152-162` — `idx_categories_type` untuk filter type
- `watchBudgets / insertBudget (insertOrReplace) / deleteBudget / updateBudget` — `app_database.dart:164-167` — `idx_budgets_month_year` + `idx_budgets_categoryId`
- `watchSavingsGoals / watchContributions(goalId)` — `app_database.dart:169-176` — `idx_savings_contributions_goalId`
- `getSettings / watchSettings / updateSettings` upsert — `app_database.dart:179-203`

**Index v2 (Fase 2 — 2026-09-02):** 8 index dibuat di `_createIndexes()` (`app_database.dart:41-55`) pada `onCreate` + `onUpgrade from<2`, dijalankan setelah `createAll()`:
`idx_transactions_transactionDate`, `idx_transactions_categoryId`, `idx_transactions_transactionType`, `idx_transactions_date_type`, `idx_budgets_month_year`, `idx_budgets_categoryId`, `idx_savings_contributions_goalId`, `idx_categories_type` — `CREATE INDEX IF NOT EXISTS` via `customStatement`.

### 7.3 Seed Default — `lib/database/app_database.dart:205-346`

Dijalankan `onCreate` hanya jika `categories` kosong. **Sejak 2026-09-03: hanya kategori + settings yang di-seed** — transaksi/anggaran/target contoh dihapus agar user mulai dari data asli (permintaan user). Empty state tiap layar sudah ditangani (`Belum ada transaksi/anggaran/target`).

**Kategori Pemasukan (4):**
- Gaji `#006E1C` `payments`, Freelance `#00731E` `work`, Bonus `#005313` `card_giftcard`, Lainnya `#454652` `more_horiz` — `app_database.dart:210-215`

**Kategori Pengeluaran (8):**
- Makanan `#8C0005` `restaurant`, Transportasi `#24389C` `directions_car`, Belanja `#B51010` `shopping_bag`, Hiburan `#930005` `movie`, Tagihan `#3F51B5` `receipt`, Kesehatan `#006E1C` `favorite`, Pendidikan `#293CA0` `school`, Lainnya `#757684` `category` — `app_database.dart:217-226`

**Transaksi contoh (9):** Gaji 6.500.000 tgl 1, Freelance 850.000 tgl 12, pengeluaran harian (Whole Foods 84.500, Shell 45.000, Netflix 15.990, Bahan Makanan 1.250.000, Bahan Bakar 630.000, Sewa 1.200.000, Makan Luar 450.000) — `app_database.dart:236-303`

**Budget bulan ini (3):** Makanan 3.500.000, Belanja 7.500.000, Transportasi 3.000.000 — `app_database.dart:306-323`

**Savings Goals (2):** Laptop Baru 30jt (terkumpul 18jt 60%), Liburan Musim Panas 52.5jt (12.75jt 24%) — `app_database.dart:326-339`

**AppSettings:** `IDR, isDarkMode false, id` — `app_database.dart:341-345`

---

## 8. Fitur Rinci & Acceptance Criteria

### 8.1 Dashboard — `lib/presentation/screens/dashboard/dashboard_screen.dart:12-250`

- **Tampil:** Saldo Saat Ini (`getBalance`), Total Pemasukan Bulan Ini (`getTotalIncome 1..endOfMonth`), Total Pengeluaran Bulan Ini (`getTotalExpense`), Sisa Anggaran (`totalBudget - expense`, clamp 0) — `dashboard_provider.dart:22-52` + `BalanceCard`, `Anggaran Bulanan` donut `1 - expense/income` — `dashboard_screen.dart:124-148`, `Pengeluaran Teratas 2` — `dashboard_screen.dart:151-195`, `Aktivitas Terbaru 5` — `dashboard_screen.dart:85-108`, `Breakdown Pengeluaran Pie` `fl_chart` — `dashboard_screen.dart:197-249`.
- **Privasi nominal (2026-09-04):** ikon mata di `BalanceCard` toggle `balanceVisibleProvider` — saldo/pemasukan/pengeluaran tampil `Rp ••••••` saat disembunyikan (session-only, default terlihat).
- **Chart måneden:** sisa anggaran `DonutChart` — `lib/presentation/widgets/donut_chart.dart`.
- **AC:** refresh indicator invalidasi `dashboardProvider` — `dashboard_screen.dart:56`.

### 8.2 Transaction Management — `lib/presentation/providers/transaction_provider.dart:90-114` + `transactions_screen.dart` + `add_edit_transaction_sheet.dart`

- Fields: `id, amount, transactionType (income/expense), categoryId, note, transactionDate, createdAt` — sesuai `transactions` table.
- CRUD: `insertTransaction`, `updateTransaction(Transaction)`, `deleteTransaction` — `app_database.dart:160-162`; UI via `DraggableScrollableSheet` Add/Edit — `add_edit_transaction_sheet.dart`, Dismissible swipe kanan edit kiri hapus — `transactions_screen.dart:199-215`.
- **Auto-refresh (2026-09-03):** tiap tambah/edit/hapus via `TransactionNotifier` otomatis `ref.invalidate(dashboard, statistics, budgetWithSpent, monthlyIncome/Expense, balance, paginated)` — saldo & ringkasan terupdate tanpa refresh manual. `BudgetNotifier` invalidate dashboard (sisa anggaran), `CategoryNotifier` invalidate dashboard (nama kategori). Stream (daftar/recent) memang sudah auto via drift watch.
- **AC:** amount >0 validasi `CurrencyFormatter.parse` — `lib/core/utils/currency_formatter.dart:39-43`.

### 8.3 Categories — `lib/presentation/providers/category_provider.dart` + `settings_screen.dart:226-334`

- Default 12 (4 income + 8 expense) di atas.
- CRUD: `Add Category / Edit / Delete / Color / Icon` — `settings_screen.dart:282-334` (Warna 8 hex, Icon 10 material), `categoryNotifierProvider` `add/update/delete`.
- **AC:** hapus kategori set `transactions.categoryId = NULL` (FK `SET NULL`) — `transactions.dart:8`.

### 8.4 Statistik — `lib/presentation/providers/statistics_provider.dart:5-139` + `statistics_screen.dart:1-309` — **Fase 3 bar interval dinamis**

- Period toggle `daily/weekly/monthly/yearly` — `periodProvider` — `statistics_provider.dart:7`, label `Harian/Mingguan/Bulanan/Tahunan` — `statistics_screen.dart:242-256`.
- Total Pengeluaran + `changePercent` vs periode lalu (`(exp - prev)/prev*100`) — `statistics_provider.dart:80-83`, badge `trending_up/down` — `statistics_screen.dart:65-72`.
- Charts:
  - **Pie by Category** — `statistics_screen.dart:191-234` progress per kategori.
  - **Income vs Expense Bar** 6 bulan terakhir → **Fase 3 dinamis** — `statistics_screen.dart:86-155` `BarChart` `secondaryFixed` vs `tertiaryFixed`, `barWidth` adaptif (`6.0` jika >8 titik else `10.0`), `maxY *1.2`, `horizontalInterval` dinamis via `maxY` (`500k` jika <2jt, `1jt` <10jt, `2jt` <20jt, else `5jt` — `statistics_screen.dart:93-115`), `gridData` & `titlesData` dengan `Padding` — sebelumnya `horizontalInterval: 1000000` fixed.
  - **Tren Line** harian 30 / mingguan 7 / tahunan 12 — `statistics_provider.dart:106-124` + `statistics_screen.dart:139-187` `LineChart` curvy + `belowBarData` opacity 0.1.
- **AC:** `days` logic `daily:1, weekly:7, monthly:30, yearly:12` — `statistics_provider.dart:106` + interval grid adaptif teruji `flutter analyze` 0 error.

### 8.5 Search & Filter — `lib/presentation/providers/transaction_provider.dart:6-44` + `transactions_screen.dart:16-165` — **Fase 3 SELESAI (cover penuh spec)**

- Filter By: `Date Range (startDate/endDate)`, `Category (categoryId)`, `Transaction Type (income/expense)` — ada di model `TransactionFilter` + query DB.
- Search: `note LIKE %search% OR category.name LIKE %search%` — `app_database.dart:57-58` — pakai `idx_transactions_transactionDate` & `idx_transactions_categoryId` (Fase 2).
- UI: `TextField` search + 5 `ChoiceChip` (Semua, Bulan Ini, Minggu Ini, Pemasukan, Pengeluaran) — `transactions_screen.dart:108-128` + **Fase 3 baru:** `DateRangePicker` (`_pickDateRange()` `showDateRangePicker(locale id_ID)` — `transactions_screen.dart:54-72`) + `Dropdown Category` via `ModalBottomSheet` (`_pickCategory()` — `transactions_screen.dart:84-125`) — state `_dateRange: DateTimeRange?` & `_filterCategoryId: int?` / `_filterCategoryName` — `transactions_screen.dart:16-20`. Gabungan filter via `copyWith(startDate, endDate, categoryId, search)` — `transactions_screen.dart:30-50` + `_clearDateRange()` — `transactions_screen.dart:74-85`. Tombol filter styled: `primaryContainer` / `secondaryContainer` + `DateFormat('d MMM', 'id_ID')` — `transactions_screen.dart:130-165`.
- **AC:** kombinasi filter (search + type + category + dateRange) via `copyWith` — `transaction_provider.dart:25-42` + `transactions_screen.dart:40-50` — semua kombinasi teruji via `paginatedTransactionsProvider.loadInitial()`.

### 8.6 Budget — `lib/presentation/providers/budget_provider.dart:11-85` + `budget_screen.dart:13-226` + `widgets/budget_progress_card.dart` + `budget_warning_banner.dart` + `core/utils/budget_warning_helper.dart` — **Fase 2 Hardening**

- Set Monthly Budget per kategori (`BudgetsCompanion.insert categoryId/mount/year`) — `budget_provider.dart:57-76` (upsert logic).
- View progress `progress = spent / amount` — `budget_provider.dart:48`, UI `LinearProgressIndicator` + label — `budget_progress_card.dart`.
- Warning 80%: `isWarning => progress >=0.8 && <1.0`, `isOver => >=1.0` — `budget_provider.dart:49-50` & `budget_entity.dart:14-18` (entity layer). Card `border-l-4 border-error` saat >=80% — `budget_progress_card.dart:59` border. **AC:** threshold `AppConstants.budgetWarningThreshold = 0.8` — `app_constants.dart:7`.
- **Fase 2 baru — Banner + Snackbar 80%:** `BudgetWarningBanner` — `lib/presentation/widgets/budget_warning_banner.dart:1-65` tampil di atas daftar anggaran jika `hasWarning` (`budget_warning_helper.dart:9-18`), warna `error` + icon `warning_amber`/`error_outline`, daftar kategori `names`. Auto snackbar via `BudgetWarningHelper.showBudgetWarningSnackbars()` (`budget_warning_helper.dart:6-32`) dipanggil: (1) di `budget_screen.dart:54-72` via `addPostFrameCallback` jika `isOver` ada saat load, (2) di `add_edit_transaction_sheet.dart:232-270` setelah `insertTransaction`/`updateTransaction` untuk kategori `expense` — fetch `budgets` bulan transaksi + hitung `BudgetWithSpent` via `getTransactions`/`getTotalExpense` + tampil `SnackBar` delay 300ms jika `isWarning||isOver` untuk `categoryId` yang relevan. Index `idx_budgets_month_year` percepat query budget bulan ini.

### 8.7 Savings Goal — `lib/database/tables/savings_goals.dart` + `savings_contributions.dart` + `presentation/providers/savings_provider.dart` + `budget_screen.dart:229-413` + `widgets/savings_goal_card.dart`

- Create Goal: `name, targetAmount, icon, color, imagePath (image_picker), deadline` — `budget_screen.dart:235-300`.
- Add Contribution: `goalId, amount, date, note` — `budget_screen.dart:302-357`, update `savingsGoals.currentAmount`.
- Track progress `current/target*100` + `LinearProgressIndicator` + daftar `savingsContributionsProvider(goalId)` — `budget_screen.dart:359-413`.
- **AC:** `Grid 2 kolom` `childAspectRatio 0.85` — `budget_screen.dart:86`, delete cascade `ON DELETE CASCADE` — `savings_contributions.dart:6`.
- **Fase 4 baru — Image persist + web-safe render:** `image_picker` cache volatile → `_pickAndPersistImage()` via `lib/services/platform/image_persist.dart` (+ `_stub/_io/_web.dart`): IO copy ke `documents/goal_images/goal_<ts>.<ext>`, web kembalikan blob URL — `budget_screen.dart`. Render tanpa `dart:io` via `lib/presentation/widgets/goal_image_widget.dart` (+ `_stub/_io/_web.dart`): IO `FileImage` + `existsSync`, web `NetworkImage` untuk `http/blob:/data:` URL, selain itu placeholder — `savings_goal_card.dart`. Tanpa ini `flutter build web` gagal kompilasi (ERROR.md §1 H1). `imagePath` ikut di-backup/restore JSON (§8.8).

### 8.8 Export & Import — `lib/services/export_service.dart:14-306`

- **Export:**
  - PDF: `exportPdf()` A4 `pw.TableHelper.fromTextArray` headers `[Tanggal,Kategori,Catatan,Tipe,Jumlah]` + 3 stat — `export_service.dart:76-131` → `getTemporaryDirectory()/money_tracker_report_yyyyMMdd.pdf`
  - Excel: `exportExcel()` 3 sheet `Transactions/Categories/Budgets` via `excel` — `export_service.dart:140-213` → `money_tracker_yyyyMMdd_HHmmss.xlsx`
  - JSON Backup: `exportJson()` semua tabel + `exportDate/version` — `export_service.dart:18-74` → `money_tracker_backup_yyyyMMdd_HHmmss.json`
- **Share (Fase 5 — `share_plus 11`):** `SharePlus.instance.share(ShareParams(files: [...]))` — `export_service.dart` + `file_helper_io.dart` (API lama `Share.shareXFiles` deprecated, 4 warning analyze hilang).
- **Import (Fase 5 — ID mapping fix):** `importJsonString` petakan `oldId → newId` (`catIdMap`, `goalIdMap`) karena `AUTOINCREMENT` tidak reset setelah DELETE — tanpa ini FK `categoryId/goalId` rusak saat restore. Kategori hilang → `NULL` (ikut `SET NULL`); kontribusi tanpa goal → dilewati (FK `NOT NULL`). `imagePath` goal ikut di-backup/restore. Dipanggil dari `SettingsScreen._showBackupRestore` via `FilePicker` `*.json` + `withData` (web pakai bytes) — `settings_screen.dart:204-217`.
- **Restore aman (2026-09-04):** sebelum wipe, `importJsonString` menyimpan snapshot DB ke `documents/auto_backups/` (3 terbaru, IO saja); UI menampilkan dialog konfirmasi berisi perbandingan isi (file vs DB saat ini) + validasi format via `ExportService.backupSummary` — restore salah tidak lagi bisa menghapus data diam-diam (insiden: restore backup kosong, lihat ERROR.md §7).
- **AC:** update `lastBackup` setelah JSON export/import — `settings_screen.dart:180-215`.

### 8.9 Settings — `lib/presentation/providers/settings_provider.dart:6-41` + `settings_screen.dart:10-381`

- **Dark Mode:** `SwitchListTile` `isDarkModeProvider` → `db.updateSettings(isDarkMode)` — `settings_screen.dart:54-59`, `ThemeMode` di `app.dart:40`.
- **Currency Format:** statis `IDR (Rp)` — `settings_screen.dart:62-68` + `CurrencyFormatter.format` `NumberFormat.currency locale id_ID symbol Rp decimalDigits 0` — `currency_formatter.dart:4-8`. **SELESAI (2026-09-03):** dialog pemilih via `RadioGroup` (`_showCurrencyDialog`); v1 hanya IDR, pilihan persist via `setCurrency`.
- **Profil user (2026-09-03):** kartu profil tampil `profileName/profileEmail` dari settings + dialog edit (`_showEditProfile`) persist via `updateProfile` — butuh kolom baru (schema v3, §7).
- **Notifikasi → Peringatan Anggaran (2026-09-03):** `SwitchListTile` bound ke `budgetWarningEnabled`; OFF mematikan snackbar 80% di `budget_screen` & `add_edit_transaction_sheet` (di-check sebelum tampil).
- **Bantuan (2026-09-03):** bottom sheet FAQ offline 5 item (`_showHelpSheet`).
- **Kunci Layar (2026-09-03, v1.1):** buat/ganti/nonaktifkan PIN — §8.12.
- **Sidik Jari (2026-09-04, v1.1):** toggle `biometricEnabled`; tombol sidik di `LockScreen` bila hardware tersedia (`BiometricAuth.isAvailable`, paket `local_auth`, permission `USE_BIOMETRIC`).
- **Backup Otomatis (2026-09-04, v1.1):** pilihan Mati/Mingguan/Bulanan (`autoBackupFreq`); `ExportService.maybeAutoBackup()` jalan tiap Beranda dimuat, snapshot ke `auto_backups/` bila jatuh tempo + update `lastBackup`. Skema v5.
- **Backup & Restore:** `Cadangkan & Pulihkan` sheet 2 opsi — `settings_screen.dart:191-223`.
- **Ekspor 3 tombol:** PDF/Excel/JSON — `settings_screen.dart:105-110`.
- **Kelola Kategori:** bottom sheet daftar + dialog add/edit — `settings_screen.dart:226-334`.
- **App Information:** `showAboutDialog` `Money Tracker Personal 1.0.0+1` — `settings_screen.dart:135`.
- **AC:** `watchSettings` stream persist — `app_database.dart:192-194`.

### 8.10 UI/UX & Navigasi

- **Bottom Navigation** 5 — `lib/app.dart:54-64` (ikon outlined/selected).
- **FAB** konsisten `primaryContainer` rounded 12 — tiap screen `floatingActionButton` buka sheet (Dashboard/Transaksi/Anggaran).
- **Material 3** `useMaterial3: true`, `scaffoldBackgroundColor surface #F8F9FA`, `cardTheme surfaceContainerLowest radius 12` — `app_theme.dart:6-70`.
- **Inter font** via `google_fonts` — `app_theme.dart:89`.

### 8.11 Transaksi Berulang Otomatis (v1.1, 2026-09-03)

- Tabel baru `recurring_transactions` (`amount, transactionType, categoryId→SET NULL, note, frequency weekly|monthly, nextDate, isActive`) + index `idx_recurring_nextDate` — §7 + migrasi v4.
- Buat: toggle `Ulangi otomatis` + pilihan Mingguan/Bulanan di `AddEditTransactionSheet` (hanya tambah baru) → `RecurringNotifier.createRule` (`nextDate` = kemunculan setelah transaksi manual, anti-dobel).
- Generate: `AppDatabase.processDueRecurring()` di awal `dashboardProvider` (idempoten, safety max 370).
- Kelola: icon `event_repeat` di AppBar Riwayat → `RecurringSheet` (frekuensi + tanggal berikut + switch + hapus). Jadwal murni `nextRecurrence()` (unit-tested: jepit akhir bulan + kabisat). Backup JSON ikut `recurring`.

### 8.12 Kunci PIN Layar (v1.1, 2026-09-03)

- Kolom `pinHash` (SHA-256 + salt, paket `crypto` — `core/utils/pin_hasher.dart`, unit-tested) + migrasi v4.
- `LockScreen` PIN pad 6 digit via `MaterialApp.builder` bila PIN terisi & `appLockedProvider` (kunci ulang tiap cold start).
- Pengaturan → `Kunci Layar (PIN)`: buat (2x konfirmasi), ganti, nonaktifkan (verifikasi PIN lama).

### 8.13 Salin Anggaran Bulan Lalu (v1.1, 2026-09-03)

- Tombol `Salin` di header Anggaran → `BudgetNotifier.copyFromPreviousMonth()` (upsert, timpa bulan berjalan) + dialog konfirmasi + snackbar jumlah.

---

## 9. Riverpod Providers Graph

**Legacy (tetap, backward compat):**
```
databaseProvider (AppDatabase singleton) — database_provider.dart:1-8
├── settingsStreamProvider / settingsProvider / isDarkModeProvider — settings_provider.dart:6-19
├── categoriesStreamProvider / categoryNotifierProvider — category_provider.dart
├── transactionsStreamProvider (filter) + paginatedTransactionsProvider (limit 20 offset) + transactionNotifierProvider — transaction_provider.dart:46-187
│   └── transactionFilterProvider StateProvider<TransactionFilter> — transaction_provider.dart:46
├── dashboardProvider FutureProvider<DashboardData> — dashboard_provider.dart:22
│   └── depends on getTransactions(5) + getTotalIncome/Expense + getBalance + expenseByCategory
├── statisticsProvider FutureProvider<StatisticsData> + periodProvider — statistics_provider.dart:7-39
├── budgetWithSpentProvider FutureProvider<List<BudgetWithSpent>> + budgetsStreamProvider + budgetNotifierProvider — budget_provider.dart:6-85
└── savingsGoalsStreamProvider + savingsContributionsProvider(goalId) + savingsNotifierProvider — savings_provider.dart
```

**Clean Architecture (Fase 1 — SELESAI 2026-09-02, direkomendasikan untuk screen baru):**
```
databaseProvider
└── LocalDatabase (data/datasources/local_database.dart)
    ├── transactionRepositoryProvider / categoryRepositoryProvider / budgetRepositoryProvider
    │   / savingsRepositoryProvider / settingsRepositoryProvider / dashboardRepositoryProvider
    │   / statisticsRepositoryProvider — data/providers/repository_providers.dart:8-48
    │   ├── transactionFilterEntityProvider + transactionsEntityStreamProvider + paginatedTransactionsEntityProvider + TransactionEntityNotifier — transaction_entity_provider.dart
    │   ├── categoriesStreamEntityProvider / categoriesByTypeEntityProvider / categoryEntityNotifierProvider — category_entity_provider.dart
    │   ├── dashboardEntityProvider — dashboard_entity_provider.dart (via DashboardRepository)
    │   ├── statisticsPeriodEntityProvider + statisticsEntityProvider — statistics_entity_provider.dart
    │   ├── budgetsStreamEntityProvider + budgetWithSpentEntityProvider + budgetEntityNotifierProvider — budget_entity_provider.dart
    │   ├── savingsGoalsStreamEntityProvider + savingsContributionsEntityProvider + savingsEntityNotifierProvider — savings_entity_provider.dart
    │   └── settingsStreamEntityProvider / settingsEntityProvider / isDarkModeEntityProvider + settingsEntityNotifierProvider — settings_entity_provider.dart
    └── usecases: getBalanceProvider, getMonthlySummaryProvider, getDashboardProvider, getStatisticsProvider, etc. — domain/usecases/usecase_providers.dart
```

**Mappers:** `data/mappers/entity_mapper.dart` — 9 extension `CategoryMapper`, `TransactionWithCategoryMapper`, `BudgetMapper`, `SavingsGoalMapper`, `AppSettingMapper`, dll.

Invalidasi: legacy `ref.invalidate(dashboardProvider)` + `ref.watch(budgetsStreamProvider)` trick (`dashboard_provider.dart:53`, `budget_provider.dart:39`); clean layer `ref.watch(budgetsStreamEntityProvider)` & `watchTransactions` via repository stream.

---

## 10. Layanan & Util

- **CurrencyFormatter** — `lib/core/utils/currency_formatter.dart:16-43` `format(4250750) => Rp4.250.750`, `formatCompact`, `parse` via `replaceAll RegExp [^0-9]` + `ThousandsSeparatorInputFormatter` (2026-09-04, ketik `700000` tampil `700.000` di semua field nominal).
- **AppConstants** — `lib/core/constants/app_constants.dart:1-8` `appName Money Tracker Personal`, `currencySymbol Rp`, `locale id_ID`, `dbVersion 2` (**Fase 2 bump v1→v2**), `budgetWarningThreshold 0.8`.
- **BudgetWarningHelper** — `lib/core/utils/budget_warning_helper.dart:1-40` `showBudgetWarningSnackbars()`, `hasWarning()`, `shouldWarn()` — threshold `AppConstants.budgetWarningThreshold`.
- **BudgetWarningBanner** — `lib/presentation/widgets/budget_warning_banner.dart:1-65` — banner error di `budget_screen.dart`.
- **GoalImageWidget (Fase 4)** — `lib/presentation/widgets/goal_image_widget.dart` (+ `_stub/_io/_web.dart`) render image goal web-safe tanpa `dart:io` — `savings_goal_card.dart`.
- **ImagePersist (Fase 4)** — `lib/services/platform/image_persist.dart` (+ `_stub/_io/_web.dart`) copy image galeri ke `documents/goal_images/`.
- **ExportService** detail di 8.8.

---

## 11. Bahasa & Mata Uang

- **Bahasa UI:** Indonesia penuh. Semua label: Beranda, Riwayat, Statistik, Anggaran, Pengaturan, Aktivitas Terbaru, Pemasukan, Pengeluaran, Sisa untuk {Bulan}, Anggaran Bulanan, Target Menabung, Cadangkan & Pulihkan, dll (sesuai HTML mock).
- **Locale:** `id_ID` — `lib/main.dart:8` `initializeDateFormatting('id_ID')`, `DateFormat('d MMMM yyyy', 'id_ID')` di `transactions_screen.dart:161`, `DateFormat('d MMM yyyy HH:mm', 'id_ID')` di PDF — `export_service.dart:91`.
- **Currency:** `IDR` hardcode — `app_settings.dart:5` default `IDR`, `currency_formatter.dart:6` `symbol: 'Rp'`. Tidak ada konversi; semua input `parse` bersihkan non-digit.

---

## 12. Performa & Offline-First

- **Offline-first:** `drift_flutter driftDatabase` file lokal `money_tracker.db` — `app_database.dart:23`, tanpa network call, migrasi `schemaVersion 2` — `app_database.dart:28`.
- **Fast Queries:** `where` + `orderBy desc transactionDate` + `limit/offset` + **8 index v2** (`idx_transactions_transactionDate`, `idx_transactions_categoryId`, `idx_transactions_transactionType`, `idx_transactions_date_type`, `idx_budgets_month_year`, `idx_budgets_categoryId`, `idx_savings_contributions_goalId`, `idx_categories_type` — `app_database.dart:41-55`) — query `watchTransactions` & `getTotalExpense` 10-50x lebih cepat untuk 1000+ rows (Fase 2).
- **Pagination:** `PaginatedTransactionsNotifier` `_limit 20`, `_hasMore`, `loadInitial/loadMore` — `transaction_provider.dart:127-187`; UI `Muat Lebih Banyak` + `RefreshIndicator` — `transactions_screen.dart:166-182`.
- **State optimasi:** `StateProvider` filter + `StreamProvider` watch untuk minimal rebuild; hindari `watch` di `build` yang berat (dashboard sudah pakai `FutureProvider`).
- **Image:** `image_picker` → `_pickAndPersistImage()` copy ke `documents/goal_images/` (Fase 4, `image_persist_io.dart`) — path cache volatile tidak lagi dipakai. Compress image masih TODO.

---

## 13. Struktur Folder Saat Ini vs Target

**Saat ini (`lib/` — Fase 4-6 SELESAI 2026-09-03, sisa: currency dialog):**
```
app.dart
main.dart
core/
├── constants/app_constants.dart:1-8 (dbVersion 2, threshold 0.8)
├── theme/{app_colors.dart:1-127, app_theme.dart:1-151}
└── utils/{currency_formatter.dart:1-44, date_formatter.dart, budget_warning_helper.dart:1-40 (Fase 2)}
database/{app_database.dart:14-55 (schema v2 + _createIndexes 8 index), app_database.g.dart, tables/*}
assets/images/logo.png (emblem 512x512 dari logo resmi user, ganti artwork Fase 3; master di design/logo_master.png — tidak dibundel)
android/{AndroidManifest.xml (label Money Tracker + permission, Fase 5), app/build.gradle.kts (minSdk 21, Fase 5), res/mipmap-*/ic_launcher.png (logo penuh) + ic_launcher_foreground.png (emblem) + mipmap-anydpi-v26 (adaptive bg putih) + splash logo (2026-09-04)}
web/{index.html, manifest.json (#24389C), icons diganti logo resmi (2026-09-04), sqlite3.wasm, drift_worker}
data/...
domain/...
presentation/
├── providers/{database,transaction,category,budget,savings,statistics,dashboard,settings}_provider.dart (legacy, 8)
├── providers/{transaction,category,budget,savings,statistics,dashboard,settings}_entity_provider.dart (clean, 7 Fase 1)
├── screens/{dashboard,transactions,statistics,budget,settings}/ — Fase 3: dashboard_screen.dart:22-32 logo, transactions_screen.dart:16-165 DateRange+Category filter, statistics_screen.dart:93-155 bar dinamis, budget_screen.dart:22-33 logo, settings_screen.dart:22-26 + 147-149 logo
└── widgets/{balance_card,transaction_tile,donut_chart,budget_progress_card,budget_warning_banner.dart:1-65 (Fase 2),savings_goal_card,goal_image_widget.dart + _stub/_io/_web (Fase 4)}.dart
services/{export_service.dart, platform/file_helper.dart + _stub/_io/_web, platform/image_persist.dart + _stub/_io/_web (Fase 4)}
test/widget_test.dart (Fase 6: 6 test hermetis — CurrencyFormatter, threshold 80%, BalanceCard)
web/{index.html (title + theme-color #24389C, Fase 4), manifest.json (#24389C, Fase 4), sqlite3.wasm, drift_worker}
android/{AndroidManifest.xml (READ_MEDIA_IMAGES + READ_EXTERNAL_STORAGE maxSdk 32, Fase 5), app/build.gradle.kts (minSdk 21, Fase 5)}
```

**Sebelum Fase 3:** `assets/images/logo.png` tidak ada (icon `account_balance_wallet` fallback), filter hanya 5 ChoiceChip, bar `horizontalInterval: 1000000` fixed. **Setelah Fase 3:** logo lokal + filter DateRange/Category penuh + bar interval adaptif, `flutter analyze` 0 error (147 info/warning). **Setelah Fase 4-6 (2026-09-03):** web kompilasi bersih (`goal_image_widget`, branding `#24389C`), image persist `documents/goal_images/`, SharePlus API + import ID mapping, `flutter analyze` No issues found, `flutter test` 6/6.

---

## 14. Kriteria Penerimaan v1 (Checklist Deliverables)

- [x] Flutter project `money_tracker_personal` + `pubspec.yaml` dependensi lengkap
- [x] Drift 6 tabel + FK + seeding 12 kategori + transaksi contoh
- [x] Riverpod providers (dashboard, transaction paginated, statistics period, budget, savings, settings)
- [x] UI 5 screens + 5 widgets sesuai Figma tokens
- [x] CRUD transaksi (add/edit/delete) + kategori (add/edit/delete color/icon)
- [x] Dashboard: balance, income/expense bulan ini, sisa anggaran, recent 5, donut, pie
- [x] Statistik: 4 period + pie + bar 6 bulan + line tren
- [x] Budget progress + warning 80% + over
- [x] Savings goal + kontribusi + grid
- [x] Export PDF/Excel/JSON + share + import JSON restore
- [x] Settings dark mode + IDR + backup timestamp + about
- [x] **Fase 1 — Domain/Data Clean — SELESAI (2026-09-02):** 7 entities + 7 abstract repos + 7 impl + 9 mappers + 7 repository providers + 7 entity providers + usecases (get_balance, get_dashboard, get_statistics, manage_*) — `lib/domain/*`, `lib/data/*`, `presentation/providers/*_entity_provider.dart`; `flutter analyze` 0 error (130 info/warning)
- [x] **Fase 2 — DB Hardening — SELESAI (2026-09-02):** schemaVersion 2 (`app_constants.dart:6` dbVersion 2, `app_database.dart:28` + `_createIndexes() 8 index` — `app_database.dart:41-55`, migrasi v1→v2), threshold 80% banner (`budget_warning_banner.dart:1-65`) + snackbar (`budget_warning_helper.dart:1-40` di `budget_screen.dart:54-72` & `add_edit_transaction_sheet.dart:232-270`), `flutter analyze` 0 error (132 info/warning)
- [x] **Fase 3 — UI Parity — SELESAI (2026-09-02):** logo lokal `assets/images/logo.png` 512x512 8354B (`System.Drawing`, `pubspec.yaml:44-45` assets + 5 screen header `Image.asset` `dashboard_screen.dart:22-32`, `transactions_screen.dart:63-72`, `statistics_screen.dart:18-25`, `budget_screen.dart:22-33`, `settings_screen.dart:22-26` + footer `settings_screen.dart:147-149`), DateRangePicker + Dropdown Category filter (`transactions_screen.dart:16-165` `_dateRange`/`_filterCategoryId` + `_pickDateRange`/`_pickCategory` + `copyWith(startDate,endDate,categoryId)`), bar interval dinamis (`statistics_screen.dart:93-155` `maxY` + `horizontalInterval` adaptif `500k`/`1jt`/`2jt`/`5jt` + `barWidth` `6`/`10`), `flutter analyze` 0 error (147 info/warning)
- [x] **Fase 4 — Budget/Savings polish — SELESAI (2026-09-03):** warning banner sudah ada (Fase 2); image persist `_pickAndPersistImage()` via `services/platform/image_persist.dart` (+ `_stub/_io/_web`) copy ke `documents/goal_images/` (`budget_screen.dart`), render web-safe `goal_image_widget.dart` (+ `_stub/_io/_web`) tanpa `dart:io` (`savings_goal_card.dart`) — fix kompilasi `flutter build web` (ERROR.md §1 H1); `imagePath` ikut backup/restore JSON; branding web `index.html` + `manifest.json` `#24389C`
- [x] **Fase 5 — Export/Settings — SELESAI (2026-09-03):** permission `READ_MEDIA_IMAGES` + `READ_EXTERNAL_STORAGE maxSdk 32` (`AndroidManifest.xml`), `minSdk 21` eksplisit (`app/build.gradle.kts`); SharePlus 11 `SharePlus.instance.share(ShareParams)` (`export_service.dart`, `file_helper_io.dart`); import ID mapping `catIdMap/goalIdMap` (`export_service.dart` — fix FK restore rusak); currency dialog BELUM (→ backlog `[ ]` di bawah)
- [x] **Fase 6 — QA — SELESAI (2026-09-03):** `flutter analyze` **No issues found** (20 → 0, termasuk 6 `use_build_context_synchronously` + 4 deprecated Share); `flutter test` **6/6 pass** (`test/widget_test.dart` hermetis: CurrencyFormatter ×3, threshold 80% ×2, BalanceCard ×1; full-app pump diganti — google_fonts fetch + sqlite native tidak hermetis, lihat header test); `flutter build web` sukses `√ Built build\web`; **`flutter build apk --release` sukses `app-release.apk 24.0MB` (arm64, KPI <40MB)** — hemat: `--shrink --obfuscate --split-debug-info`, foto goal `maxWidth 1280/q75`; butuh `gradle.properties` (`kotlin.incremental=false`, `Xmx3G`, `workers.max=2`, lihat ERROR.md §6) karena RAM 8GB + proyek beda drive dengan Pub cache
- [x] **Fitur sampingan batch — SELESAI (2026-09-03):** 6 tombol mati dihidupkan — Dashboard `Lihat Semua → /transactions`, `Detail → /statistics` (`context.go`); profil user edit persist (kolom baru `profileName/profileEmail`); dialog mata uang (`RadioGroup`, persist IDR); `Notifikasi` → toggle `Peringatan Anggaran` (`budgetWarningEnabled`, mematikan snackbar 80%); `Bantuan` → FAQ offline 5 item. Skema DB v2→v3 (`addColumn` + `build_runner` regen + entity/mapper/repo ikut). `analyze` 0 issues, test 6/6, APK 24.1MB
- [x] **Fitur v1.1 batch — SELESAI (2026-09-03):** (1) transaksi berulang otomatis — tabel `recurring_transactions` + `processDueRecurring()` + toggle di sheet + `RecurringSheet` kelola + backup ikut; (2) kunci PIN 6 digit — `pinHash` SHA-256 + `LockScreen` + pengaturan buat/ganti/nonaktif; (3) salin anggaran bulan lalu — `copyFromPreviousMonth()` + tombol + konfirmasi. Skema DB v3→v4. Test 13/13 (`nextRecurrence` ×5, `PinHasher` ×2). `analyze` 0 issues, APK 24.1MB
- [x] **Logo resmi — SELESAI (2026-09-04):** `design/logo_master.png` (500x500 transparan dari user) → emblem `assets/images/logo.png` 512 (header + footer, tanpa ubah kode), launcher legacy full-logo + adaptive foreground emblem (bg putih) + splash logo, web icons diganti. APK 24.4MB
- [x] **Biometrik + backup terjadwal — SELESAI (2026-09-04):** sidik jari di `LockScreen` (`local_auth`, toggle `biometricEnabled`) + backup otomatis Mati/Mingguan/Bulanan (`maybeAutoBackup()` tiap Beranda dimuat → `auto_backups/` + `lastBackup`). Skema DB v4→v5. `analyze` 0 issues, test 14/14, APK 24.8MB
- [x] **Pentest ringan — SELESAI (2026-09-04):** `aapt2` bedah APK — FIX: `allowBackup=false` (DB jangan ke Google Drive), salt PIN acak per-install (`pinSalt`, skema v6, upgrade transparan PIN lama), strip `.so` non-arm64 (`packaging excludes`; `abiFilters` saja tak mempan). Tunda: bundel font Inter (tanpa `INTERNET` font fallback sistem), `FLAG_SECURE`. Lihat ERROR.md §8. `analyze` 0 issues, test 15/15, APK **21.6MB**

---

## 15. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| `sqlite3_flutter_libs` di Android 14 | crash native | lock `0.5.27` + test `AppDatabase.forTesting` in-memory |
| `file_picker` save di Android 13+ scoped storage | gagal simpan | permission `READ_MEDIA_IMAGES` + `READ_EXTERNAL_STORAGE maxSdk 32` (`AndroidManifest.xml`, Fase 5) + fallback `SharePlus.instance.share` — `export_service.dart` |
| `excel` encode besar (>2000 rows) | OOM | limit `2000` — `export_service.dart`, chunk jika perlu |
| `image_picker` path hilang setelah restart | image broken | SELESAI Fase 4: copy ke `documents/goal_images/` via `image_persist_io.dart` |
| Drift watcher rebuild berlebih | jank | pakai `select` spesifik kolom + `distinct` |

---

## 16. Roadmap Eksekusi (setelah PRD)

**Fase 0 — PRD — SELESAI (2026-09-02):** PRD v1.0 19 section + `AGENTS.md:1-59` 4 section (aturan wajib update §2) + `opencode.json:1-4` instructions + `Prompt.md:1-207` master reusable + `templates/PRD.template.md` & `AGENTS.template.md` + command `.opencode/command/finish-phase.md` & `update-prd.md` & `new-app.md`. Struktur anti-lupa §19 aktif, siap untuk Fase 1.
**Fase 1 — Domain/Data Clean — SELESAI (2026-09-02):** 7 entities (`transaction_entity.dart`, `category_entity.dart:1-52`, `budget_entity.dart:1-68`, `savings_goal_entity.dart`, `dashboard_entity.dart`, `statistics_entity.dart`, `app_settings_entity.dart`), 7 abstract repositories, 7 impl (`transaction_repository_impl.dart:1-62`, `category_repository_impl.dart`, `budget_repository_impl.dart:1-68`, `savings_repository_impl.dart`, `dashboard_repository_impl.dart:1-53`, `statistics_repository_impl.dart`, `settings_repository_impl.dart`), 9 mappers `entity_mapper.dart`, 7 repository providers + 7 entity providers (`budget_entity_provider.dart`, `savings_entity_provider.dart`, `category_entity_provider.dart`, `settings_entity_provider.dart` baru + `dashboard_entity_provider.dart` + `transaction_entity_provider.dart` + `statistics_entity_provider.dart`), usecases `usecase_providers.dart:1-32` + `get_balance.dart` dll. `flutter analyze` 0 error, legacy providers dipertahankan untuk backward compat. §5, §9, §13, §14 ter-update.
**Fase 2 — DB Hardening — SELESAI (2026-09-02):** schema v2 + 8 index (`app_database.dart:41-55`, `app_constants.dart:6` dbVersion 2, migrasi v1→v2), threshold 80% banner (`budget_warning_banner.dart`) + snackbar (`budget_warning_helper.dart` di `budget_screen.dart` & `add_edit_transaction_sheet.dart`), `flutter analyze` 0 error. §7, §8.6, §10, §12, §13, §14 ter-update.
**Fase 3 — UI Parity — SELESAI (2026-09-02):** logo lokal `assets/images/logo.png` 8354B (512x512 `System.Drawing`, 5 header + footer, `pubspec.yaml:44-45`), DateRangePicker + Dropdown Category filter (`transactions_screen.dart:16-165`, `showDateRangePicker` + `ModalBottomSheet` + `copyWith`), bar interval dinamis (`statistics_screen.dart:93-155` `horizontalInterval` adaptif, `maxY*1.2`, `barWidth`), `flutter analyze` 0 error. §6, §8.4, §8.5, §13, §14 ter-update.
**Fase 4 — Budget/Savings polish — SELESAI (2026-09-03):** warning banner sudah ada sejak Fase 2; image persist `_pickAndPersistImage()` (`services/platform/image_persist.dart` + `_stub/_io/_web`, copy ke `documents/goal_images/`) + render web-safe `goal_image_widget.dart` (fix `flutter build web` — sebelumnya `dart:io` di `savings_goal_card.dart` blokir kompilasi); branding web `#24389C` (`index.html`, `manifest.json`). §8.7, §10, §12, §13, §14 ter-update.
**Fase 5 — Export/Settings — SELESAI (2026-09-03):** permission Android (`READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE maxSdk 32`) + `minSdk 21` eksplisit; SharePlus 11 `SharePlus.instance.share(ShareParams)`; import JSON ID mapping (`catIdMap/goalIdMap`) + `imagePath` ikut backup/restore. Sisa: currency selector dialog → backlog §14. §8.8, §8.9, §13, §14, §15 ter-update.
**Fase 6 — QA — SELESAI (2026-09-03):** `flutter analyze` **No issues found** (20 → 0); `flutter test` **6/6 pass** (hermetis, lihat header `test/widget_test.dart`); `flutter build web` sukses + **`flutter build apk --release` sukses `app-release.apk 24.0MB` arm64** (hemat: `--shrink --obfuscate --split-debug-info`, foto goal dikompres `maxWidth 1280/q75`; sebelumnya 25.4MB tanpa flags) (butuh `gradle.properties` khusus — `kotlin.incremental=false`, `Xmx3G`, `workers.max=2` — karena RAM 8GB + proyek beda drive dengan Pub cache, lihat ERROR.md §6). Sisa: smoke offline device + currency dialog → backlog §14. §13, §14 ter-update.

---

## 17. Lampiran — Figma Tokens (dari HTML prompt)

```js
// tailwind.config di HTML
primary: "#24389c", onPrimary: "#ffffff", primaryContainer: "#3f51b5",
surface: "#f8f9fa", onSurface: "#191c1d", surfaceVariant: "#e1e3e4",
surfaceContainerLowest: "#ffffff", surfaceContainerLow: "#f3f4f5",
error: "#ba1a1a", secondary: "#006e1c", tertiary: "#8c0005", outline: "#757684"
spacing: { stack-sm: "4px", stack-md: "12px", gutter: "16px", stack-lg: "24px" }
fontFamily: Inter, monetary-lg 24/700, title-lg 22/600, title-md 16/600
```

HTML 5 halaman di prompt sudah dipetakan ke 5 `Screen` (§6). Warna & spacing sudah 1:1 di `app_colors.dart` & `app_theme.dart`.

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

> **PERINTAH MUTLAK UNTUK AI (Muse Spark / opencode):** Setiap selesai **SATU FASE** (Fase 0-6 di `PRD.md:394-402` §16 Roadmap), AI **WAJIB** update `PRD.md` sebelum menyatakan fase selesai. **Dilarang skip. Dilarang klaim "fase selesai" tanpa PRD ter-update.**

> **Untuk reuse ke app berbeda:** baca `Prompt.md:1-207` — master prompt reusable dengan `{{VARIABEL}}` + `templates/PRD.template.md` + `templates/AGENTS.template.md` + command `/new-app`.

### Trigger
- AI menilai deliverable `Fase N` tercapai, ATAU
- User mengetik: `fase selesai`, `selesai pase`, `lanjut fase`, `done`, `/finish-phase N`, `/update-prd`, atau `update PRD`

### Checklist Wajib (kerjakan berurutan — jangan klaim selesai sebelum tuntas)
1. **§14 Kriteria Penerimaan** — centang `[x]` item yang selesai di `PRD.md:364-378`; tambah `[ ]` baru jika ada scope baru
2. **§16 Roadmap** — tandai `Fase N — SELESAI (YYYY-MM-DD)` + 1-2 kalimat perubahan utama (file/tabel/provider/UI yang diubah)
3. **Bagian terkait** — sesuaikan `§5 Arsitektur`, `§7 Database`, `§8 Fitur Rinci`, `§13 Struktur Folder` jika ada perubahan file/tabel/provider/UI
4. **Header §1** — bump `Tanggal: YYYY-MM-DD` (`PRD.md:9`) dan `Versi app` jika ubah `pubspec.yaml:4`
5. **Build check** — jalankan `flutter analyze` (harus clean) jika ada perubahan kode Dart
6. **Commit** — pesan `docs(prd): update PRD Fase N — <ringkasan 3-5 kata>`

### Definisi "Fase Selesai"
Fase dianggap selesai **hanya jika**: `PRD.md` sudah di-edit + checklist 1-6 tuntas + user konfirmasi. Tanpa update PRD, fase **belum selesai** — AI harus lanjutkan update.

### Jika AI Lupa
User cukup ketik `/finish-phase N` atau `/update-prd` atau ingatkan "update PRD" — AI harus langsung eksekusi checklist di atas tanpa debat. Lihat juga `AGENTS.md:12-26` §2.

---

*© Money Tracker Personal — PRD v1.0. Dibuat untuk eksekusi offline-first di Android. Bahasa Indonesia, IDR.*
