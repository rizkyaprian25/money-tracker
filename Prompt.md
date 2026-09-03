# Prompt.md — Master Prompt Reusable untuk Generate Project Baru

> File ini adalah **prompt konfigurasi siap copy-paste** untuk membuat aplikasi berbeda dengan struktur yang **SAMA PERSIS** seperti `Money Tracker Personal` (`PRD.md:1-463`, `AGENTS.md:1-53`, `opencode.json:1-4`, `.opencode/command/finish-phase.md`). Tinggal ganti `{{VARIABEL}}`.

---

## Cara Pakai (3 langkah)

1. **Copy** seluruh isi `## Prompt Siap Copy-Paste` di bawah
2. **Ganti** semua `{{VARIABEL}}` sesuai app baru (lihat `## Daftar Variabel` untuk penjelasan)
3. **Paste** ke sesi chat AI baru (Muse Spark / opencode) — AI akan otomatis generate `PRD.md`, `AGENTS.md`, `opencode.json`, dan `.opencode/command/*`

> Untuk reuse di project `Money Tracker` sendiri, lihat `PRD.md:439-459` §19 dan `AGENTS.md:12-26` §2 — aturan update tiap fase tetap berlaku.

---

## Prompt Siap Copy-Paste

```
Kamu adalah arsitek Flutter senior untuk project offline-first.

TUGAS: Generate 4 artefak project baru dengan struktur IDENTIK seperti template Money Tracker Personal di bawah. JANGAN kurangi section, JANGAN ubah urutan. Hanya ganti nilai spesifik sesuai variabel.

VARIABEL WAJIB (ganti {{}} dengan nilai app baru):
- APP_NAME = {{APP_NAME}} | contoh: Money Tracker Personal
- APP_ID = {{APP_ID}} | contoh: money_tracker_personal (snake_case, untuk pubspec.yaml:1 name)
- APP_IDEA = {{APP_IDEA}} | contoh: Aplikasi offline-first pelacak pemasukan/pengeluaran pribadi
- PROJECT_PATH = {{PROJECT_PATH}} | contoh: E:\Mobile\money tracker
- VERSION = {{VERSION}} | contoh: 1.0.0+1 (pubspec.yaml:4)
- SDK = {{SDK}} | contoh: ^3.12.2 (pubspec.yaml:7)
- PLATFORM = {{PLATFORM}} | contoh: Android offline-first
- LOCALE = {{LOCALE}} | contoh: id_ID
- CURRENCY = {{CURRENCY}} | contoh: IDR (Rp)
- TECH_STACK = {{TECH_STACK}} | contoh terkunci: Flutter Material 3 + Drift + Riverpod + go_router + fl_chart (lihat PRD.md:40-52)
- DB_NAME = {{DB_NAME}} | contoh: money_tracker.db
- DB_FILE = {{DB_FILE}} | contoh: lib/database/app_database.dart:14-26
- TABEL_DB = {{TABEL_DB}} | contoh: 6 tabel (categories, transactions, budgets, savings_goals, savings_contributions, app_settings) + FK ON
- NAV_TABS = {{NAV_TABS}} | contoh: 5 tab go_router StatefulShellRoute.indexedStack — lib/app.dart:19-33
- THEME_FILE = {{THEME_FILE}} | contoh: lib/core/theme/app_colors.dart:5-58 & app_theme.dart:6-70
- FITUR_UTAMA = {{FITUR_UTAMA}} | contoh: Dashboard saldo, CRUD transaksi & kategori, statistik fl_chart, budget warning 80%, savings goal, export PDF/Excel/JSON
- FIGMA_URL = {{FIGMA_URL}} | contoh: https://www.figma.com/design/... (kosongkan jika tidak ada)
- BAHASA_OUTPUT = {{BAHASA_OUTPUT}} | contoh: Indonesia
- FASE_COUNT = {{FASE_COUNT}} | contoh: 6 (Fase 0-6 di PRD.md:394-402)

OUTPUT WAJIB GENERATE (4 file, struktur harus 1:1 dengan contoh):

1. PRD.md — 19 section LENGKAP, ikuti skeleton ini persis:
   # PRD — {{APP_NAME}} v{{VERSION}}
   > Dokumen sumber konteks — {{APP_IDEA}}, bahasa {{LOCALE}}, mata uang {{CURRENCY}}, tanpa login & tanpa cloud.
   - Lokasi proyek: `{{PROJECT_PATH}}` — Versi app: `{{VERSION}}` — pubspec.yaml:4 — SDK: `{{SDK}}` — pubspec.yaml:7 — Flutter Material 3
   - Status baseline, Tanggal, Figma ref
   ## 1. Ringkasan Eksekutif — deskripsi {{APP_IDEA}} + KPI (<100ms query, cold start <2s, APK <40MB, 100% offline)
   ## 2. Tujuan — bullet fitur dari {{FITUR_UTAMA}}
   ## 3. Non-Tujuan (v1) — apa yang TIDAK dibuat (auth/cloud, notifikasi remote, OCR)
   ## 4. Tech Stack (terkunci di pubspec.yaml:9-40) — tabel | Lapisan | Lib | Versi | Catatan | sesuai {{TECH_STACK}}
   ## 5. Arsitektur — 5.1 Struktur Target Clean Architecture lib/ + 5.2 Dependensi presentation->domain->data->database
   ## 6. Desain Sistem (Material 3 — Figma Exact) — tokens warna di {{THEME_FILE}}, typography, spacing, navigasi {{NAV_TABS}}
   ## 7. Database — Drift ORM — {{DB_FILE}} schemaVersion, 7.1 Tabel (sesuai {{TABEL_DB}}), 7.2 Query Utama, 7.3 Seed Default
   ## 8. Fitur Rinci & Acceptance Criteria — 8.1 Dashboard ... 8.10 UI/UX — tiap fitur sebut file path:line_number + AC
   ## 9. Riverpod Providers Graph — tree databaseProvider -> ...
   ## 10. Layanan & Util — CurrencyFormatter, AppConstants, ExportService
   ## 11. Bahasa & Mata Uang — {{LOCALE}} & {{CURRENCY}}
   ## 12. Performa & Offline-First — drift_flutter {{DB_NAME}}, pagination, watcher
   ## 13. Struktur Folder Saat Ini vs Target — lib/ saat ini vs target clean
   ## 14. Kriteria Penerimaan v1 (Checklist Deliverables) — [x]/[ ] checklist
   ## 15. Risiko & Mitigasi — tabel Risiko|Dampak|Mitigasi
   ## 16. Roadmap Eksekusi (setelah PRD) — Fase 0 (PRD selesai) sampai Fase {{FASE_COUNT}} (QA)
   ## 17. Lampiran — Figma Tokens
   ## 18. Cara Pakai Dokumen Ini di Sesi Berikutnya — rujuk AGENTS.md:1-40 + build command
   ## 19. Aturan Wajib AI — Update PRD Tiap Selesai Fase — PERINTAH MUTLAK, Trigger, Checklist 6 langkah, Definisi Selesai, Jika AI Lupa (lihat AGENTS.md:12-26) — WAJIB ADA, JANGAN HAPUS

2. AGENTS.md — 4 section, ikuti skeleton ini persis:
   # AGENTS.md — Aturan Project {{APP_NAME}}
   > Dokumen ini otomatis dibaca AI (Muse Spark / opencode) tiap sesi. Jangan hapus.
   ## 1. Konteks Wajib Baca — single source PRD.md, lokasi {{PROJECT_PATH}}, versi pubspec.yaml:4, stack {{TECH_STACK}}, DB {{DB_FILE}}, bahasa {{LOCALE}}
   ## 2. ATURAN MUTLAK: Wajib Update PRD.md Tiap Selesai Fase — PERINTAH MUTLAK, Trigger (selesai Fase N / "fase selesai"/"lanjut fase"/"done"), Checklist 6 langkah (§14, §16, §5/§7/§8/§13, Header §1, flutter analyze, commit docs(prd):...), Definisi Selesai, Jika AI Lupa (/finish-phase N, /update-prd)
   ## 3. Perintah Build Acuan — flutter pub get; dart run build_runner build --delete-conflicting-outputs; flutter analyze; flutter test; flutter run; flutter build apk --release
   ## 4. Gaya Kerja — bahasa {{BAHASA_OUTPUT}}, offline-first, Material 3, google_fonts Inter, path:line_number, verifikasi via eksekusi

3. opencode.json — di root project:
   {
     "$schema": "https://opencode.ai/config.json",
     "instructions": ["AGENTS.md", "PRD.md"]
   }

4. .opencode/command/finish-phase.md dan .opencode/command/update-prd.md:
   - finish-phase.md: description "Tandai Fase N selesai dan wajib update PRD.md (§14, §16, §1) sesuai AGENTS.md & PRD §19", agent build, body checklist 6 langkah dengan $ARGUMENTS
   - update-prd.md: description "Update PRD.md secara manual", agent build, body checklist PRD §19

ATURAN GENERATE:
- Bahasa: {{BAHASA_OUTPUT}}
- Selalu rujuk file dengan format path:line_number saat menyebut kode
- Offline-first, tanpa login/cloud kecuali diminta di {{FITUR_UTAMA}}
- Jangan hapus §19 di PRD dan §2 di AGENTS — ini anti-lupa
- Setelah generate, ingatkan user untuk quit & restart opencode agar opencode.json ter-load
```

---

## Daftar Variabel (wajib isi sebelum paste)

| Variabel | Contoh Money Tracker | Deskripsi | Wajib? |
|---|---|---|---|
| `{{APP_NAME}}` | Money Tracker Personal | Nama app tampil | Ya |
| `{{APP_ID}}` | money_tracker_personal | `pubspec.yaml:1` name snake_case | Ya |
| `{{APP_IDEA}}` | Aplikasi offline-first pelacak pemasukan/pengeluaran pribadi | 1 kalimat ide inti | Ya |
| `{{PROJECT_PATH}}` | `E:\Mobile\money tracker\` | Lokasi folder project | Ya |
| `{{VERSION}}` | 1.0.0+1 | `pubspec.yaml:4` | Ya |
| `{{SDK}}` | ^3.12.2 | `pubspec.yaml:7` environment sdk | Ya |
| `{{PLATFORM}}` | Android offline-first | Target platform | Ya |
| `{{LOCALE}}` | id_ID | Locale `lib/main.dart:8` initializeDateFormatting | Ya |
| `{{CURRENCY}}` | IDR (Rp) | Mata uang + simbol | Ya |
| `{{TECH_STACK}}` | Flutter Material 3 + Drift 6 tabel + Riverpod + go_router 5 tab + fl_chart | Stack terkunci `PRD.md:40-52` | Ya |
| `{{DB_NAME}}` | money_tracker.db | Nama file DB `app_database.dart:23` | Ya |
| `{{DB_FILE}}` | `lib/database/app_database.dart:14-26` | Path file DB | Ya |
| `{{TABEL_DB}}` | 6 tabel: categories, transactions, budgets, savings_goals, savings_contributions, app_settings | Daftar tabel + relasi FK | Ya |
| `{{NAV_TABS}}` | 5 tab go_router StatefulShellRoute | Jumlah & nama tab | Ya |
| `{{THEME_FILE}}` | `lib/core/theme/app_colors.dart:5-58` | File tokens warna | Ya |
| `{{FITUR_UTAMA}}` | Dashboard, CRUD transaksi, statistik fl_chart, budget warning 80%, savings goal, export PDF/Excel/JSON | Bullet fitur §2 | Ya |
| `{{FIGMA_URL}}` | https://www.figma.com/design/... | Link Figma (kosongkan jika tidak ada) | Tidak |
| `{{BAHASA_OUTPUT}}` | Indonesia | Bahasa PRD & AGENTS | Ya |
| `{{FASE_COUNT}}` | 6 | Jumlah fase roadmap §16 | Ya |

---

## Contoh Terisi (Money Tracker — referensi)

```
APP_NAME = Money Tracker Personal
APP_ID = money_tracker_personal
APP_IDEA = Aplikasi offline-first pelacak pemasukan/pengeluaran pribadi
PROJECT_PATH = E:\Mobile\money tracker
VERSION = 1.0.0+1
SDK = ^3.12.2
PLATFORM = Android offline-first
LOCALE = id_ID
CURRENCY = IDR (Rp)
TECH_STACK = Flutter Material 3 + Drift 6 tabel + Riverpod + go_router 5 tab + fl_chart + pdf/printing/excel/file_picker/share_plus + uuid + image_picker
DB_NAME = money_tracker.db
DB_FILE = lib/database/app_database.dart:14-26
TABEL_DB = categories, transactions, budgets, savings_goals, savings_contributions, app_settings (FK ON)
NAV_TABS = 5 tab: Beranda (/), Riwayat (/transactions), Statistik (/statistics), Anggaran (/budget), Pengaturan (/settings)
THEME_FILE = lib/core/theme/app_colors.dart:5-58 & app_theme.dart:6-70 (Primary #24389C, dll)
FITUR_UTAMA = Dashboard saldo & chart, CRUD transaksi & kategori, filter search, statistik 4 period, budget warning 80%, savings goal, export PDF/Excel/JSON, settings dark mode
FIGMA_URL = https://www.figma.com/design/9xLJL1QPtm1IpCb4DY5RVZ/Untitled?node-id=0-1&m=dev
BAHASA_OUTPUT = Indonesia
FASE_COUNT = 6
```

Output contoh sudah ada di `PRD.md:1-463` dan `AGENTS.md:1-53` — itu adalah hasil generate dari prompt di atas dengan variabel terisi.

---

## Contoh Terisi (App Berbeda — Kasir UMKM)

```
APP_NAME = Kasir UMKM Pro
APP_ID = kasir_umkm_pro
APP_IDEA = Aplikasi kasir offline-first untuk UMKM toko kelontong
PROJECT_PATH = E:\Mobile\kasir umkm
VERSION = 1.0.0+1
SDK = ^3.12.2
PLATFORM = Android offline-first
LOCALE = id_ID
CURRENCY = IDR (Rp)
TECH_STACK = Flutter Material 3 + Drift + Riverpod + go_router 4 tab + fl_chart
DB_NAME = kasir_umkm.db
DB_FILE = lib/database/app_database.dart:14-26
TABEL_DB = 5 tabel: products, categories, transactions, transaction_items, app_settings (FK ON)
NAV_TABS = 4 tab: Beranda (/), Produk (/products), Transaksi (/transactions), Pengaturan (/settings)
THEME_FILE = lib/core/theme/app_colors.dart:5-58
FITUR_UTAMA = Katalog produk, keranjang & checkout, stok, laporan harian/mingguan/bulanan, cetak struk PDF, backup JSON
FIGMA_URL = (kosong)
BAHASA_OUTPUT = Indonesia
FASE_COUNT = 6
```

Paste variabel ini ke prompt di atas → AI akan hasilkan PRD 19 section untuk Kasir UMKM dengan struktur identik.

---

## Template File Pendukung

- **Template mentah (opsional):** `templates/PRD.template.md` dan `templates/AGENTS.template.md` — berisi skeleton dengan `{{VARIABEL}}` siap replace (akan dibuat jika diperlukan)
- **Command generator:** `.opencode/command/new-app.md` — ketik `/new-app Kasir UMKM Pro | kasir untuk UMKM` untuk trigger prompt di atas secara interaktif

---

## Checklist Setelah Generate (AI wajib lakukan)

1. Pastikan `PRD.md` punya §19 Aturan Wajib AI (jangan sampai hilang)
2. Pastikan `AGENTS.md` punya §2 ATURAN MUTLAK 6 checklist
3. Pastikan `opencode.json` punya `instructions: ["AGENTS.md","PRD.md"]`
4. Pastikan `.opencode/command/finish-phase.md` ada dengan `$ARGUMENTS`
5. Ingatkan user: **quit & restart opencode** agar config baru ter-load

---

## Cara Pakai di Sesi Berikutnya (untuk app berbeda)

1. Buka `Prompt.md` ini
2. Copy blok `Prompt Siap Copy-Paste`
3. Ganti semua `{{VARIABEL}}` (minimal APP_NAME, APP_ID, PROJECT_PATH, FITUR_UTAMA)
4. Paste di chat baru — AI akan generate 4 file
5. Jika AI lupa update PRD tiap fase, ketik: `/finish-phase N` atau `update PRD` (sesuai `PRD.md:439-459` §19)

*© Prompt Master Reusable — turunan dari Money Tracker Personal PRD v1.0. Struktur 19 section + 4 section AGENTS + opencode.json + commands dipertahankan untuk konsistensi.*
