import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../services/export_service.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/category_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    final settings = settingsAsync.valueOrNull;
    final isDark = settings?.isDarkMode ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8)), clipBehavior: Clip.antiAlias, child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20))),
          const SizedBox(width: 10),
          const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: CircleAvatar(backgroundColor: scheme.primary, child: const Icon(Icons.person, color: Colors.white, size: 18)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Stack(children: [
                  CircleAvatar(radius: 24, backgroundColor: scheme.primaryContainer, child: Icon(Icons.person, color: scheme.onPrimaryContainer)),
                  Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: scheme.secondaryFixed, shape: BoxShape.circle, border: Border.all(color: scheme.surfaceContainerLow, width: 2)))),
                ]),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Alex Finance', style: TextStyle(fontWeight: FontWeight.w600)), Text('alex.finance@example.com', style: TextStyle(fontSize: 12, color: Colors.grey))])),
                IconButton(onPressed: () {}, icon: Icon(Icons.edit, color: scheme.primary)),
              ]),
            ),
            const SizedBox(height: 20),
            Text('Preferensi'.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.primary, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
              child: Column(children: [
                SwitchListTile(
                  secondary: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle), child: Icon(Icons.dark_mode, size: 18, color: scheme.onSurfaceVariant)),
                  title: const Text('Mode Gelap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Sinkronisasi dengan sistem', style: TextStyle(fontSize: 12)),
                  value: isDark,
                  onChanged: (v) => ref.read(settingsNotifierProvider).setDarkMode(v),
                ),
                Divider(height: 1, indent: 56, color: scheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle), child: Icon(Icons.payments, size: 18, color: scheme.onSurfaceVariant)),
                  title: const Text('Format Mata Uang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('IDR (Rp)', style: TextStyle(fontSize: 12)),
                  trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  onTap: () {},
                ),
                Divider(height: 1, indent: 56, color: scheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle), child: Icon(Icons.notifications, size: 18, color: scheme.onSurfaceVariant)),
                  title: const Text('Notifikasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Pengingat harian aktif', style: TextStyle(fontSize: 12)),
                  trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  onTap: () {},
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Text('Manajemen Data'.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.primary, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
              child: Column(children: [
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle), child: Icon(Icons.cloud_sync, size: 18, color: scheme.onSurfaceVariant)),
                  title: const Text('Cadangkan & Pulihkan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(settings?.lastBackup != null ? 'Cadangan terakhir: ${DateFormat('d MMM yyyy HH:mm', 'id_ID').format(settings!.lastBackup!)}' : 'Belum ada cadangan', style: const TextStyle(fontSize: 12)),
                  trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  onTap: () => _showBackupRestore(context, ref),
                ),
                Divider(height: 1, indent: 56, color: scheme.outlineVariant.withValues(alpha: 0.3)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle), child: Icon(Icons.download, size: 18, color: scheme.onSurfaceVariant)),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ekspor Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), Text('Buat laporan untuk pajak atau pribadi', style: TextStyle(fontSize: 12, color: Colors.grey))])),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Row(children: [
                          Expanded(child: _ExportButton(icon: Icons.picture_as_pdf, label: 'PDF', color: scheme.error, onTap: () => _export(context, ref, 'pdf'))),
                          const SizedBox(width: 8),
                          Expanded(child: _ExportButton(icon: Icons.table_chart, label: 'Excel', color: scheme.secondary, onTap: () => _export(context, ref, 'excel'))),
                          const SizedBox(width: 8),
                          Expanded(child: _ExportButton(icon: Icons.data_object, label: 'JSON', color: scheme.onSurfaceVariant, onTap: () => _export(context, ref, 'json'))),
                        ]),
                      ),
                    ]),
                  ]),
                ),
                Divider(height: 1, indent: 56, color: scheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle), child: Icon(Icons.category, size: 18, color: scheme.onSurfaceVariant)),
                  title: const Text('Kelola Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  onTap: () => _showCategoryManager(context, ref),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Text('Tentang'.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.primary, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
              child: Column(children: [
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle), child: Icon(Icons.info, size: 18, color: scheme.onSurfaceVariant)),
                  title: const Text('Informasi Aplikasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  onTap: () => showAboutDialog(context: context, applicationName: 'Money Tracker Personal', applicationVersion: '1.0.0+1', children: [const Text('Aplikasi pelacak keuangan pribadi offline-first. Dibuat dengan Flutter, Riverpod, Drift, Material 3.')]),
                ),
                Divider(height: 1, indent: 56, color: scheme.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle), child: Icon(Icons.help, size: 18, color: scheme.onSurfaceVariant)),
                  title: const Text('Bantuan & Dukungan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.open_in_new, size: 18, color: scheme.onSurfaceVariant),
                  onTap: () {},
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/logo.png', width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)))),
                const SizedBox(height: 12),
                Text('Money Tracker Personal', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant.withValues(alpha: 0.7))),
                Text('Versi 1.0.0 (Build 1)', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant.withValues(alpha: 0.7))),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Dibuat dengan ', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant.withValues(alpha: 0.7))), Icon(Icons.favorite, size: 12, color: scheme.error), Text(' oleh Money Tracker', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant.withValues(alpha: 0.7)))]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref, String type) async {
    final db = ref.read(databaseProvider);
    final service = ExportService(db);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membuat file $type...')));
    try {
      String path;
      String fileName;
      if (type == 'pdf') {
        path = await service.exportPdf();
        fileName = 'money_tracker_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      } else if (type == 'excel') {
        path = await service.exportExcel();
        fileName = 'money_tracker_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      } else {
        path = await service.exportJson();
        fileName = 'money_tracker_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
        // also update last backup
        await ref.read(settingsNotifierProvider).updateLastBackup(DateTime.now());
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File dibuat: $fileName'), action: SnackBarAction(label: 'Bagikan', onPressed: () => service.shareFile(path))));
        await service.shareFile(path);
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal ekspor: $e'), backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  void _showBackupRestore(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Cadangkan & Pulihkan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.backup), title: const Text('Cadangkan Sekarang (JSON)'), onTap: () async { Navigator.pop(c); await _export(context, ref, 'json'); }),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Pulihkan dari File'),
            onTap: () async {
              Navigator.pop(c);
              final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: true);
              if (result != null && result.files.singleOrNull != null) {
                final file = result.files.single;
                final service = ExportService(ref.read(databaseProvider));
                bool ok = false;
                if (file.bytes != null) {
                  ok = await service.importJsonBytes(file.bytes!);
                } else if (file.path != null) {
                  ok = await service.importJson(file.path!);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Berhasil dipulihkan!' : 'Gagal memulihkan'), backgroundColor: ok ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error));
                  if (ok) await ref.read(settingsNotifierProvider).updateLastBackup(DateTime.now());
                }
              }
            },
          ),
          SizedBox(height: MediaQuery.of(c).padding.bottom + 10),
        ]),
      ),
    );
  }

  void _showCategoryManager(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Consumer(builder: (context, ref2, _) {
            final catsAsync = ref2.watch(categoriesStreamProvider);
            return Column(children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Kelola Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddCategoryDialog(context, ref2))]),
              ),
              Expanded(
                child: catsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (cats) => ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: cats.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final cat = cats[i];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: _hexToColor(cat.color).withValues(alpha: 0.15), child: Icon(_iconFromName(cat.icon), color: _hexToColor(cat.color), size: 18)),
                        title: Text(cat.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(cat.type, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showAddCategoryDialog(context, ref2, existing: cat)),
                          IconButton(icon: Icon(Icons.delete, size: 18, color: Theme.of(context).colorScheme.error), onPressed: () async {
                            final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Hapus Kategori?'), content: Text('Hapus "${cat.name}"? Transaksi terkait akan jadi tanpa kategori.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus'))]));
                            if (ok == true) await ref2.read(categoryNotifierProvider).deleteCategory(cat.id);
                          }),
                        ]),
                      );
                    },
                  ),
                ),
              ),
            ]);
          }),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref, {dynamic existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    String type = existing?.type ?? 'expense';
    String color = existing?.color ?? '#24389C';
    String icon = existing?.icon ?? 'category';
    final colors = ['#24389C', '#006E1C', '#8C0005', '#B51010', '#3F51B5', '#757684', '#FF6F00', '#009688'];
    final icons = ['restaurant', 'directions_car', 'shopping_bag', 'movie', 'receipt', 'favorite', 'school', 'payments', 'work', 'category'];

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(existing == null ? 'Tambah Kategori' : 'Edit Kategori'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Kategori', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [DropdownMenuItem(value: 'income', child: Text('Pemasukan')), DropdownMenuItem(value: 'expense', child: Text('Pengeluaran'))],
                onChanged: (v) => setState(() => type = v!),
                decoration: const InputDecoration(labelText: 'Tipe', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerLeft, child: Text('Warna', style: TextStyle(fontSize: 12))),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: colors.map((col) => GestureDetector(onTap: () => setState(() => color = col), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: _hexToColor(col), shape: BoxShape.circle, border: color == col ? Border.all(color: Colors.black, width: 2) : null)))).toList()),
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerLeft, child: Text('Icon', style: TextStyle(fontSize: 12))),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: icons.map((ic) => GestureDetector(onTap: () => setState(() => icon = ic), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: icon == ic ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)), child: Icon(_iconFromName(ic), size: 18, color: icon == ic ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant)))).toList()),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                if (existing == null) {
                  await ref.read(categoryNotifierProvider).addCategory(nameCtrl.text.trim(), type, color, icon);
                } else {
                  await ref.read(categoryNotifierProvider).updateCategory(existing.copyWith(name: nameCtrl.text.trim(), type: type, color: color, icon: icon));
                }
                if (c.mounted) Navigator.pop(c);
              },
              child: Text(existing == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        );
      }),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', 'FF'), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  IconData _iconFromName(String name) {
    const map = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'shopping_cart': Icons.shopping_cart,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'favorite': Icons.favorite,
      'school': Icons.school,
      'payments': Icons.payments,
      'work': Icons.work,
      'card_giftcard': Icons.card_giftcard,
      'category': Icons.category,
      'more_horiz': Icons.more_horiz,
    };
    return map[name] ?? Icons.circle;
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ExportButton({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, color: color, size: 20), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
      ),
    );
  }
}
