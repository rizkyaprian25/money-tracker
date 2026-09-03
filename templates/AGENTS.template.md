# AGENTS.md — Aturan Project {{APP_NAME}}

> Dokumen ini otomatis dibaca AI (Muse Spark / opencode) tiap sesi. Jangan hapus.

## 1. Konteks Wajib Baca

- **Single source of truth:** `PRD.md` — baca sebelum mulai fase apapun.
- **Lokasi proyek:** `{{PROJECT_PATH}}`
- **Versi app:** `pubspec.yaml:4` (`{{VERSION}}`), SDK `{{SDK}}`
- **Stack terkunci:** {{TECH_STACK}} — lihat `PRD.md:40-52`
- **DB:** `{{DB_FILE}}` (`{{DB_NAME}}`, FK ON)
- **Bahasa & mata uang:** {{LOCALE}}, {{CURRENCY}} — `lib/main.dart:8`

## 2. ATURAN MUTLAK: Wajib Update PRD.md Tiap Selesai Fase

> **PERINTAH MUTLAK UNTUK AI:** Setiap selesai SATU FASE (Fase 0-{{FASE_COUNT}} di `PRD.md:394-402` §16 Roadmap), AI **WAJIB** update `PRD.md` sebelum menyatakan fase selesai. **Dilarang skip.**

### Trigger
- Selesai Fase N (sesuai Roadmap §16)
- User bilang: "fase selesai", "lanjut fase", "done", "selesai pase", atau AI sendiri menilai deliverable fase tercapai

### Checklist Wajib (kerjakan berurutan, jangan klaim selesai sebelum ini tuntas)
1. **§14 Kriteria Penerimaan** — centang `[x]` item yang selesai, tambah `[ ]` baru jika ada scope baru
2. **§16 Roadmap** — tandai `Fase N — SELESAI (YYYY-MM-DD)` + 1-2 kalimat perubahan utama
3. **Bagian terkait** — sesuaikan `§5 Arsitektur`, `§7 Database`, `§8 Fitur Rinci`, `§13 Struktur Folder` jika ada perubahan file/tabel/provider/UI
4. **Header §1** — bump `Tanggal: YYYY-MM-DD` dan `Versi app` jika ubah `pubspec.yaml:4`
5. **Build check** — `flutter analyze` harus clean (jika ubah kode Dart)
6. **Commit message** — `docs(prd): update PRD Fase N — <ringkasan 3-5 kata>`

### Definisi "Fase Selesai"
Fase dianggap selesai **hanya jika** `PRD.md` sudah di-edit + checklist di atas tuntas + user konfirmasi. Tanpa update PRD, fase belum selesai.

### Jika AI Lupa
User cukup ketik `/finish-phase N` atau `/update-prd` atau ingatkan "update PRD" — AI harus langsung eksekusi checklist di atas. Lihat juga `PRD.md:19` §19.

## 3. Perintah Build Acuan

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
flutter build apk --release
```

## 4. Gaya Kerja

- Bahasa: {{BAHASA_OUTPUT}}
- Offline-first, tanpa login/cloud
- Material 3, `google_fonts` Inter, warna di `{{THEME_FILE}}`
- Selalu rujuk file dengan format `path:line_number` saat menyebut kode
- Verifikasi via eksekusi, bukan asumsi
