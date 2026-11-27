import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../state/finance_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class DashboardScreen extends StatelessWidget {
  final FinanceController controller;

  const DashboardScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final urgent = controller.urgentEntries;

    final realizedIn = controller.entries
        .where((e) => e.type == TransactionType.receita)
        .fold(0.0, (s, e) => s + e.paidAmount);
    final plannedIn = controller.entries
        .where((e) => e.type == TransactionType.receita)
        .fold(0.0, (s, e) => s + e.totalAmount);

    final realizedOut = controller.entries
        .where((e) => e.type == TransactionType.despesa)
        .fold(0.0, (s, e) => s + e.paidAmount);
    final plannedOut = controller.entries
        .where((e) => e.type == TransactionType.despesa)
        .fold(0.0, (s, e) => s + e.totalAmount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card Principal de Saldo (Laranja destaque + detalhes em azul)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryOrange, AppColors.softOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo Disponível em Caixa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'REALIZADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppFormatters.brl(controller.currentBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up,
                            color: AppColors.royalBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Saldo Projetado:',
                          style: TextStyle(
                            color: AppColors.navyBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppFormatters.brl(controller.projectedBalance),
                      style: TextStyle(
                        color: controller.projectedBalance >= 0
                            ? AppColors.royalBlue
                            : AppColors.danger,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Resumo A Receber vs A Pagar (RF14)
        Row(
          children: [
            Expanded(
              child: _SummaryMiniCard(
                title: 'A Receber',
                value: AppFormatters.brl(controller.totalReceivable),
                icon: Icons.arrow_downward_rounded,
                accentColor: AppColors.royalBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryMiniCard(
                title: 'A Pagar',
                value: AppFormatters.brl(controller.totalPayable),
                icon: Icons.arrow_upward_rounded,
                accentColor: AppColors.primaryOrange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Fluxo de Caixa: Realizado vs Previsto (RF09)
        const Text(
          'Fluxo de Caixa (Realizado vs. Previsto)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.navyBlue,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _CashFlowBar(
                  label: 'Entradas (Receitas)',
                  realized: realizedIn,
                  planned: plannedIn,
                  barColor: AppColors.royalBlue,
                ),
                const Divider(height: 24),
                _CashFlowBar(
                  label: 'Saídas (Despesas)',
                  realized: realizedOut,
                  planned: plannedOut,
                  barColor: AppColors.primaryOrange,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Controle de Vencimentos (RF10)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Atenção aos Vencimentos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navyBlue,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.royalBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${urgent.length} pendente(s)',
                style: const TextStyle(
                  color: AppColors.royalBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (urgent.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhuma conta vencida ou vencendo nos próximos dias.',
                style: TextStyle(color: AppColors.royalBlue),
              ),
            ),
          )
        else
          ...urgent.map((entry) => _UrgentEntryTile(
                entry: entry,
                onPay: () => _showQuickPayDialog(context, entry),
              )),
      ],
    );
  }

  void _showQuickPayDialog(BuildContext context, FinancialEntry entry) {
    final textCtrl = TextEditingController(
      text: entry.remainingAmount.toStringAsFixed(2),
    );
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
              'Saldo restante: ${AppFormatters.brl(entry.remainingAmount)}',
              style: const TextStyle(color: AppColors.royalBlue, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor pago agora (permite parcial)',
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
              final raw = textCtrl.text.replaceAll(',', '.');
              final val = double.tryParse(raw) ?? 0;
              if (val > 0) {
                controller.registerPayment(entry.id, val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _SummaryMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: accentColor.withValues(alpha: 0.12),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.navyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashFlowBar extends StatelessWidget {
  final String label;
  final double realized;
  final double planned;
  final Color barColor;

  const _CashFlowBar({
    required this.label,
    required this.realized,
    required this.planned,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = planned > 0 ? (realized / planned).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
              ),
            ),
            Text(
              '${AppFormatters.brl(realized)} / ${AppFormatters.brl(planned)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.royalBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.lightBlue.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _UrgentEntryTile extends StatelessWidget {
  final FinancialEntry entry;
  final VoidCallback onPay;

  const _UrgentEntryTile({required this.entry, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final isOverdue = entry.status == PaymentStatus.vencido;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOverdue
              ? AppColors.danger.withValues(alpha: 0.12)
              : AppColors.paleOrange,
          child: Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
            color: isOverdue ? AppColors.danger : AppColors.primaryOrange,
          ),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.navyBlue,
          ),
        ),
        subtitle: Text(
          'Venc.: ${AppFormatters.date(entry.dueDate)} • Restante: ${AppFormatters.brl(entry.remainingAmount)}',
          style: TextStyle(
            fontSize: 12,
            color: isOverdue ? AppColors.danger : AppColors.royalBlue,
            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: FilledButton.tonal(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
          ),
          onPressed: onPay,
          child: const Text('Baixar'),
        ),
      ),
    );
  }
}