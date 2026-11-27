import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../state/finance_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class EntriesScreen extends StatefulWidget {
  final FinanceController controller;

  const EntriesScreen({super.key, required this.controller});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  String _filter = 'todos'; // todos | receitas | despesas | pendentes

  @override
  Widget build(BuildContext context) {
    final filtered = widget.controller.entries.where((e) {
      if (_filter == 'receitas') return e.type == TransactionType.receita;
      if (_filter == 'despesas') return e.type == TransactionType.despesa;
      if (_filter == 'pendentes') return !e.isFullyPaid;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Barra de filtros com detalhes em azul
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                _FilterChipItem(
                  label: 'Todos',
                  selected: _filter == 'todos',
                  onTap: () => setState(() => _filter = 'todos'),
                ),
                const SizedBox(width: 8),
                _FilterChipItem(
                  label: 'Receitas',
                  selected: _filter == 'receitas',
                  onTap: () => setState(() => _filter = 'receitas'),
                ),
                const SizedBox(width: 8),
                _FilterChipItem(
                  label: 'Despesas',
                  selected: _filter == 'despesas',
                  onTap: () => setState(() => _filter = 'despesas'),
                ),
                const SizedBox(width: 8),
                _FilterChipItem(
                  label: 'Em Aberto',
                  selected: _filter == 'pendentes',
                  onTap: () => setState(() => _filter = 'pendentes'),
                ),
              ],
            ),
          ),

          // Lista de lançamentos
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum lançamento encontrado neste filtro.',
                      style: TextStyle(color: AppColors.royalBlue),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return _EntryCard(
                        entry: entry,
                        projectName:
                            widget.controller.projectById(entry.projectId)?.name,
                        clientName:
                            widget.controller.clientById(entry.clientId)?.name,
                        onPay: entry.isFullyPaid
                            ? null
                            : () => _openPartialPaymentDialog(context, entry),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewEntrySheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Lançamento'),
      ),
    );
  }

  void _openPartialPaymentDialog(BuildContext context, FinancialEntry entry) {
    final amountCtrl =
        TextEditingController(text: entry.remainingAmount.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          entry.type == TransactionType.receita
              ? 'Registrar Recebimento'
              : 'Registrar Pagamento',
          style: const TextStyle(color: AppColors.navyBlue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              'Pago: ${AppFormatters.brl(entry.paidAmount)} de${AppFormatters.brl(entry.totalAmount)}',
              style: const TextStyle(fontSize: 13, color: AppColors.royalBlue),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor a baixar (parcial ou total)',
                prefixText: 'R\$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final val =
                  double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
              if (val > 0) {
                widget.controller.registerPayment(entry.id, val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Salvar Baixa'),
          ),
        ],
      ),
    );
  }

  void _openNewEntrySheet(BuildContext context) {
    TransactionType type = TransactionType.receita;
    ExpenseCategory category = ExpenseCategory.fixa;
    final titleCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final paidCtrl = TextEditingController(text: '0');
    DateTime selectedDate = DateTime.now();
    String? selectedClientId = widget.controller.clients.isNotEmpty
        ? widget.controller.clients.first.id
        : null;
    String? selectedProjectId = widget.controller.projects.isNotEmpty
        ? widget.controller.projects.first.id
        : null;
    String? selectedProviderId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Novo Lançamento Financeiro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.receita,
                        label: Text('Receita'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: TransactionType.despesa,
                        label: Text('Despesa'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (val) =>
                        setModalState(() => type = val.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (ex.: Parcela 2, Servidor, etc.)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: totalCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Valor Total',
                            prefixText: 'R\$ ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: paidCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Já Pago/Recebido',
                            prefixText: 'R\$ ',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Data de Vencimento (dd/mm/aaaa)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today,
                        size: 18, color: AppColors.royalBlue),
                    label: Text(
                      'Vencimento: ${AppFormatters.date(selectedDate)}',
                      style: const TextStyle(color: AppColors.navyBlue),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (type == TransactionType.receita) ...[
                    DropdownButtonFormField<String?>(
                      initialValue: selectedClientId,
                      decoration: const InputDecoration(labelText: 'Cliente'),
                      items: widget.controller.clients
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => selectedClientId = v),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    DropdownButtonFormField<ExpenseCategory>(
                      initialValue: category,
                      decoration: const InputDecoration(
                          labelText: 'Categoria da Despesa'),
                      items: const [
                        DropdownMenuItem(
                          value: ExpenseCategory.fixa,
                          child: Text('Despesa Fixa'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseCategory.variavel,
                          child: Text('Despesa Variável'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseCategory.projeto,
                          child: Text('Custo de Projeto / Prestador'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => category = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedProviderId,
                      decoration: const InputDecoration(
                          labelText: 'Prestador (opcional)'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Nenhum prestador')),
                        ...widget.controller.providers.map((pr) =>
                            DropdownMenuItem(
                                value: pr.id,
                                child: Text('${pr.name} (${pr.role})'))),
                      ],
                      onChanged: (v) =>
                          setModalState(() => selectedProviderId = v),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Projeto opcional para vincular resultado financeiro (RF08)
                  DropdownButtonFormField<String?>(
                    initialValue: selectedProjectId,
                    decoration: const InputDecoration(
                        labelText: 'Vincular a Projeto (opcional)'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Sem vínculo de projeto')),
                      ...widget.controller.projects.map((p) =>
                          DropdownMenuItem(value: p.id, child: Text(p.name))),
                    ],
                    onChanged: (v) =>
                        setModalState(() => selectedProjectId = v),
                  ),
                  const SizedBox(height: 18),

                  FilledButton(
                    onPressed: () {
                      final total = double.tryParse(
                              totalCtrl.text.replaceAll(',', '.')) ??
                          0;
                      final paid = double.tryParse(
                              paidCtrl.text.replaceAll(',', '.')) ??
                          0;
                      if (titleCtrl.text.trim().isEmpty || total <= 0) return;

                      widget.controller.addEntry(
                        FinancialEntry(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          type: type,
                          totalAmount: total,
                          paidAmount: paid.clamp(0, total),
                          dueDate: selectedDate,
                          clientId: type == TransactionType.receita
                              ? selectedClientId
                              : null,
                          projectId: selectedProjectId,
                          providerId: type == TransactionType.despesa
                              ? selectedProviderId
                              : null,
                          expenseCategory: type == TransactionType.despesa
                              ? category
                              : null,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Salvar Lançamento'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primaryOrange,
      backgroundColor: AppColors.surfaceLight,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.navyBlue,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected
            ? AppColors.primaryOrange
            : AppColors.lightBlue.withValues(alpha: 0.4),
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final FinancialEntry entry;
  final String? projectName;
  final String? clientName;
  final VoidCallback? onPay;

  const _EntryCard({
    required this.entry,
    this.projectName,
    this.clientName,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final isRev = entry.type == TransactionType.receita;
    final status = entry.status;

    Color badgeColor;
    String badgeText;
    switch (status) {
      case PaymentStatus.pago:
        badgeColor = AppColors.success;
        badgeText = 'PAGO';
        break;
      case PaymentStatus.vencido:
        badgeColor = AppColors.danger;
        badgeText = 'VENCIDO';
        break;
      case PaymentStatus.pendente:
        badgeColor = AppColors.royalBlue;
        badgeText = 'PENDENTE';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isRev ? Icons.arrow_circle_down : Icons.arrow_circle_up,
                  color: isRev ? AppColors.royalBlue : AppColors.primaryOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  'Venc.: ${AppFormatters.date(entry.dueDate)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.royalBlue),
                ),
                if (clientName != null)
                  Text(
                    'Cliente: $clientName',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.royalBlue),
                  ),
                if (projectName != null)
                  Text(
                    'Projeto: $projectName',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.royalBlue),
                  ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: ${AppFormatters.brl(entry.totalAmount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    if (!entry.isFullyPaid)
                      Text(
                        'Pago: ${AppFormatters.brl(entry.paidAmount)} • Resta: ${AppFormatters.brl(entry.remainingAmount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                if (onPay != null)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                      side: const BorderSide(color: AppColors.primaryOrange),
                    ),
                    onPressed: onPay,
                    child: const Text('Registrar Baixa'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}