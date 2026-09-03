---
description: Generate project baru dari Prompt.md + templates — buat PRD, AGENTS, opencode.json dengan struktur identik
agent: build
---

User ingin membuat aplikasi baru: **$ARGUMENTS**

Format $ARGUMENTS: `APP_NAME | APP_IDEA | PROJECT_PATH` atau cukup nama app. Contoh: `Kasir UMKM Pro | kasir untuk toko kelontong | E:\Mobile\kasir umkm`

Langkah WAJIB:

1. Baca `Prompt.md` (master prompt reusable) dan `templates/PRD.template.md` + `templates/AGENTS.template.md` sebagai skeleton.
2. Baca `PRD.md:1-463` dan `AGENTS.md:1-53` sebagai contoh terisi Money Tracker (referensi struktur 19 section + 4 section).
3. Parse $ARGUMENTS. Jika variabel kurang (APP_NAME, APP_ID, PROJECT_PATH, FITUR_UTAMA, TECH_STACK, dll), TANYAKAN ke user dengan tabel:
   | Variabel | Contoh | Nilai user |
   |---|---|---|
   | APP_NAME | Money Tracker Personal | ? |
   | APP_ID | money_tracker_personal | ? |
   | PROJECT_PATH | E:\Mobile\money tracker | ? |
   | FITUR_UTAMA | Dashboard, CRUD, statistik | ? |
   Tampilkan daftar lengkap dari `Prompt.md` Daftar Variabel.
4. Setelah variabel lengkap, generate 4 file sesuai `Prompt.md` Output Wajib:
   - `PRD.md` 19 section (jangan hilangkan §19 Aturan Wajib AI)
   - `AGENTS.md` 4 section (jangan hilangkan §2 ATURAN MUTLAK)
   - `opencode.json` dengan instructions ["AGENTS.md","PRD.md"]
   - `.opencode/command/finish-phase.md` + `update-prd.md`
5. Ganti semua {{VARIABEL}} di template dengan nilai real. Pastikan path:line_number tetap akurat.
6. Ringkas hasil ke user + ingatkan: **quit & restart opencode** agar config baru ter-load. Tawarkan untuk langsung isi roadmap Fase 0-6 untuk app baru.

Jika $ARGUMENTS kosong, tanyakan: "Mau bikin aplikasi apa? Sebutkan nama, ide singkat, dan lokasi folder."
