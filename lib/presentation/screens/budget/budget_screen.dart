import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/platform/image_persist.dart' as image_persist;
import '../../providers/settings_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/budget_warning_helper.dart';
import '../../../database/app_database.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/budget_progress_card.dart';
import '../../widgets/budget_warning_banner.dart';
import '../../widgets/savings_goal_card.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});
  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(budgetWithSpentProvider);
    final savingsAsync = ref.watch(savingsGoalsStreamProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8)), clipBehavior: Clip.antiAlias, child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20))),
          const SizedBox(width: 10),
          const Text('Anggaran', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: CircleAvatar(backgroundColor: scheme.primary, child: const Icon(Icons.person, color: Colors.white, size: 18)))],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(),
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Column(children: [Text('Ringkasan Anggaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), SizedBox(height: 4), Text('Pantau pengeluaran Anda', style: TextStyle(fontSize: 12, color: Colors.grey))])),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Expanded(child: Text('Anggaran Bulanan', style: TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              TextButton.icon(onPressed: _copyLastMonth, icon: const Icon(Icons.content_copy, size: 16), label: const Text('Salin', style: TextStyle(fontSize: 12))),
              TextButton.icon(onPressed: _showAddBudgetDialog, icon: const Icon(Icons.add, size: 16), label: const Text('Atur', style: TextStyle(fontSize: 12))),
            ]),
            const SizedBox(height: 8),
            budgetAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (list) {
                if (list.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Column(children: [Icon(Icons.account_balance_wallet_outlined, size: 40, color: scheme.outline), const SizedBox(height: 8), Text('Belum ada anggaran', style: TextStyle(color: scheme.outline)), const SizedBox(height: 12), FilledButton.tonal(onPressed: _showAddBudgetDialog, child: const Text('Buat Anggaran'))])),
                  );
                }
                // Fase 2: warning banner 80% + over-budget + auto snackbar sekali per load
                // (hormati toggle Pengaturan → Peringatan Anggaran)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final warnEnabled = ref.read(settingsStreamProvider).valueOrNull?.budgetWarningEnabled ?? true;
                  if (warnEnabled && list.any((b) => b.isOver)) {
                    // hanya tampilkan snackbar jika ada over, hindari spam dengan cek mounted
                    if (context.mounted) BudgetWarningHelper.showBudgetWarningSnackbars(context, list);
                  }
                });
                return Column(
                  children: [
                    BudgetWarningBanner(budgets: list),
                    ...list.map((b) => Padding(padding: const EdgeInsets.only(bottom: 12), child: BudgetProgressCard(data: b, onTap: () => _showEditBudgetDialog(b)))),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Target Menabung', style: TextStyle(fontWeight: FontWeight.w600)),
              TextButton.icon(onPressed: _showAddGoalDialog, icon: const Icon(Icons.add, size: 16), label: const Text('Buat Target', style: TextStyle(fontSize: 12))),
            ]),
            const SizedBox(height: 8),
            savingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (goals) {
                if (goals.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Column(children: [Icon(Icons.savings_outlined, size: 40, color: scheme.outline), const SizedBox(height: 8), Text('Belum ada target', style: TextStyle(color: scheme.outline)), const SizedBox(height: 12), FilledButton.tonal(onPressed: _showAddGoalDialog, child: const Text('Buat Target Baru'))])),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: goals.length,
                  itemBuilder: (context, i) => SavingsGoalCard(
                    goal: goals[i],
                    onTap: () => _showGoalDetail(goals[i]),
                    onAdd: () => _showAddContributionDialog(goals[i]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBudgetDialog() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _BudgetFormSheet());
  }

  /// v1.1: salin anggaran bulan lalu ke bulan berjalan (dengan konfirmasi).
  Future<void> _copyLastMonth() async {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1, 1);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Salin Anggaran?'),
        content: Text('Salin semua anggaran bulan ${months[prev.month - 1]} ke bulan ${months[now.month - 1]}? Kategori yang sudah ada bulan ini akan ditimpa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salin')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final count = await ref.read(budgetNotifierProvider).copyFromPreviousMonth(month: now.month, year: now.year);
    ref.invalidate(budgetWithSpentProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(count == 0 ? 'Tidak ada anggaran bulan ${months[prev.month - 1]}' : '$count anggaran disalin dari bulan ${months[prev.month - 1]}'),
      ));
    }
  }

  void _showEditBudgetDialog(BudgetWithSpent data) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _BudgetFormSheet(existing: data));
  }

  void _showAddGoalDialog() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _GoalFormSheet());
  }

  void _showAddContributionDialog(SavingsGoal goal) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _ContributionSheet(goal: goal));
  }

  void _showGoalDetail(SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalDetailSheet(goal: goal),
    );
  }
}

class _BudgetFormSheet extends ConsumerStatefulWidget {
  final BudgetWithSpent? existing;
  const _BudgetFormSheet({this.existing});
  @override
  ConsumerState<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<_BudgetFormSheet> {
  int? selectedCatId;
  final amountCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      selectedCatId = widget.existing!.budget.categoryId;
      amountCtrl.text = CurrencyFormatter.formatWithoutSymbol(widget.existing!.budget.amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'Atur Anggaran' : 'Edit Anggaran', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            catsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (cats) {
                final expenseCats = cats.where((c) => c.type == 'expense').toList();
                return DropdownButtonFormField<int>(
                  initialValue: selectedCatId,
                  decoration: InputDecoration(labelText: 'Kategori', filled: true, fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  hint: const Text('Pilih kategori'),
                  items: expenseCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => selectedCatId = v),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: InputDecoration(labelText: 'Jumlah Anggaran (Rp)', prefixText: 'Rp ', filled: true, fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final amount = CurrencyFormatter.parse(amountCtrl.text);
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jumlah tidak valid')));
                    return;
                  }
                  final now = DateTime.now();
                  await ref.read(budgetNotifierProvider).setBudget(categoryId: selectedCatId, amount: amount, month: now.month, year: now.year);
                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(budgetWithSpentProvider);
                },
                child: Text(widget.existing == null ? 'Simpan' : 'Update'),
              ),
            ),
            if (widget.existing != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(budgetNotifierProvider).deleteBudget(widget.existing!.budget.id);
                    if (context.mounted) Navigator.pop(context);
                    ref.invalidate(budgetWithSpentProvider);
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
                  child: const Text('Hapus Anggaran'),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _GoalFormSheet extends ConsumerStatefulWidget {
  const _GoalFormSheet();
  @override
  ConsumerState<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<_GoalFormSheet> {
  final nameCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  String? imagePath;

  /// Fase 2 (PRD Risiko + ERROR.md §2.2): persist image_picker via
  /// platform helper (IO: copy ke documents/goal_images, Web: blob URL).
  /// Hemat penyimpanan HP: foto dikompres (max 1280px, kualitas 75).
  Future<String?> _pickAndPersistImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 75,
    );
    if (x == null) return null;
    return image_persist.persistGoalImage(x);
  }
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Buat Target Menabung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nama Target', hintText: 'Contoh: Laptop Baru', filled: true, fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(controller: targetCtrl, keyboardType: TextInputType.number, inputFormatters: [ThousandsSeparatorInputFormatter()], decoration: InputDecoration(labelText: 'Target Jumlah (Rp)', prefixText: 'Rp ', filled: true, fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final persisted = await _pickAndPersistImage();
                if (persisted != null) setState(() => imagePath = persisted);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12), border: Border.all(color: scheme.outlineVariant)),
                child: Row(children: [
                  Icon(Icons.image, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(imagePath == null ? 'Pilih Gambar (Opsional)' : imagePath!.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (imagePath != null) IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => imagePath = null)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final target = CurrencyFormatter.parse(targetCtrl.text);
                  if (nameCtrl.text.trim().isEmpty || target <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi nama dan target')));
                    return;
                  }
                  await ref.read(savingsNotifierProvider).createGoal(name: nameCtrl.text.trim(), target: target, imagePath: imagePath);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Simpan Target'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ContributionSheet extends ConsumerStatefulWidget {
  final SavingsGoal goal;
  const _ContributionSheet({required this.goal});
  @override
  ConsumerState<_ContributionSheet> createState() => _ContributionSheetState();
}

class _ContributionSheetState extends ConsumerState<_ContributionSheet> {
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.8,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Tambah Tabungan - ${widget.goal.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Terkumpul: ${CurrencyFormatter.format(widget.goal.currentAmount)} / ${CurrencyFormatter.format(widget.goal.targetAmount)}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, inputFormatters: [ThousandsSeparatorInputFormatter()], decoration: InputDecoration(labelText: 'Jumlah Kontribusi (Rp)', prefixText: 'Rp ', filled: true, fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(controller: noteCtrl, decoration: InputDecoration(labelText: 'Catatan (opsional)', filled: true, fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final amount = CurrencyFormatter.parse(amountCtrl.text);
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jumlah tidak valid')));
                    return;
                  }
                  await ref.read(savingsNotifierProvider).addContribution(widget.goal.id, amount, note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim());
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Tambahkan'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _GoalDetailSheet extends ConsumerWidget {
  final SavingsGoal goal;
  const _GoalDetailSheet({required this.goal});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final contributionsAsync = ref.watch(savingsContributionsProvider(goal.id));
    final progress = goal.targetAmount == 0 ? 0.0 : (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(goal.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${CurrencyFormatter.format(goal.currentAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: scheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation(scheme.primary))),
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerRight, child: Text('${(progress * 100).toStringAsFixed(1)}% terkumpul', style: TextStyle(fontSize: 12, color: scheme.primary, fontWeight: FontWeight.w600))),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Riwayat Kontribusi', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(onPressed: () async {
                final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Hapus Target?'), content: const Text('Semua kontribusi akan ikut terhapus.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus'))]));
                if (confirm == true) {
                  await ref.read(savingsNotifierProvider).deleteGoal(goal.id);
                  if (context.mounted) Navigator.pop(context);
                }
              }, icon: Icon(Icons.delete_outline, color: scheme.error)),
            ]),
            const SizedBox(height: 8),
            contributionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (list) {
                if (list.isEmpty) return Padding(padding: const EdgeInsets.all(16), child: Center(child: Text('Belum ada kontribusi', style: TextStyle(color: scheme.outline))));
                return Column(children: list.map((c) => ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle), child: Icon(Icons.savings, size: 16, color: scheme.onSecondaryContainer)), title: Text(CurrencyFormatter.format(c.amount), style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(c.note ?? '-'), trailing: Text('${c.date.day}/${c.date.month}/${c.date.year}', style: TextStyle(fontSize: 11, color: scheme.outline)))).toList());
              },
            ),
          ]),
        ),
      ),
    );
  }
}
