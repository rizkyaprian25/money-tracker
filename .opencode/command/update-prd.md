---
description: Update PRD.md secara manual (alias /finish-phase) — centang §14, update §16, bump tanggal versi
agent: build
---

User meminta update `PRD.md` manual: $ARGUMENTS

Eksekusi checklist `PRD.md:438-470` §19 + `AGENTS.md:12-26`:

1. Tanya fase berapa jika $ARGUMENTS kosong, atau pakai fase yang disebut.
2. Baca PRD.md §14, §16, §1 dan file yang baru diubah (git diff / diskusi terakhir).
3. Update PRD.md:
   - §14 checklist
   - §16 Roadmap tandai SELESAI + tanggal hari ini (UTC+7) + ringkasan
   - §5/§7/§8/§13 jika perlu
   - §1 Tanggal & Versi app
4. Ringkas perubahan untuk user dan sarankan commit `docs(prd): update PRD Fase N — ...`
