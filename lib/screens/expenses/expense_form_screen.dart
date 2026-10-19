import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/format.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../models/wallet.dart';
import '../../services/data_service.dart';
import '../../services/expense_service.dart';

/// Formulaire d'ajout (expense == null) ou de modification d'une dépense.
class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});

  final Expense? expense;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _data = DataService();
  final _service = ExpenseService();

  List<ExpenseCategory> _categories = [];
  List<Wallet> _wallets = [];
  String? _categoryId;
  String? _walletId;
  DateTime _date = DateTime.now();
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    if (e != null) {
      _amountCtrl.text = e.amount.round().toString();
      _descCtrl.text = e.description ?? '';
      _date = e.date;
      _categoryId = e.categoryId;
      _walletId = e.walletId;
    }
    _loadLists();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLists() async {
    try {
      final categories = await _data.expenseCategories();
      final wallets = await _data.wallets();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _wallets = wallets;
        _walletId ??= wallets.isNotEmpty ? wallets.first.id : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount =
        double.parse(_amountCtrl.text.replaceAll(' ', '').replaceAll(',', '.'));
    final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _service.update(
          widget.expense!.id,
          walletId: _walletId!,
          categoryId: _categoryId!,
          amount: amount,
          date: _date,
          description: desc,
        );
      } else {
        await _service.add(
          walletId: _walletId!,
          categoryId: _categoryId!,
          amount: amount,
          date: _date,
          description: desc,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Enregistrement impossible. Vérifiez votre connexion.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la dépense' : 'Nouvelle dépense'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Erreur : $_loadError'),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Montant (Ar)',
                            prefixIcon: Icon(Icons.payments),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = double.tryParse((v ?? '')
                                .replaceAll(' ', '')
                                .replaceAll(',', '.'));
                            if (value == null || value <= 0) {
                              return 'Saisissez un montant supérieur à 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _categoryId,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _categoryId = v),
                          validator: (v) =>
                              v == null ? 'Choisissez une catégorie' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _walletId,
                          decoration: const InputDecoration(
                            labelText: 'Portefeuille',
                            prefixIcon: Icon(Icons.account_balance_wallet),
                            border: OutlineInputBorder(),
                          ),
                          items: _wallets
                              .map((w) => DropdownMenuItem(
                                    value: w.id,
                                    child: Text(w.name),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _walletId = v),
                          validator: (v) =>
                              v == null ? 'Choisissez un portefeuille' : null,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(formatDate(_date)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descCtrl,
                          maxLength: 120,
                          decoration: const InputDecoration(
                            labelText: 'Description (facultatif)',
                            prefixIcon: Icon(Icons.notes),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: _saving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(_isEdit ? 'Enregistrer' : 'Ajouter'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
