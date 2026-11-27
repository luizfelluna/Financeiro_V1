import 'package:flutter/material.dart';
import '../state/finance_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ProjectsRegistryScreen extends StatelessWidget {
  final FinanceController controller;

  const ProjectsRegistryScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: AppColors.background,
            child: const TabBar(
              labelColor: AppColors.primaryOrange,
              unselectedLabelColor: AppColors.royalBlue,
              indicatorColor: AppColors.primaryOrange,
              tabs: [
                Tab(text: 'Projetos'),
                Tab(text: 'Clientes'),
                Tab(text: 'Prestadores'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ProjectsTab(controller: controller),
                _ClientsTab(controller: controller),
                _ProvidersTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Aba 1: Projetos e Resultado Financeiro Individual (RF02 / RF08)
class _ProjectsTab extends StatelessWidget {
  final FinanceController controller;
  const _ProjectsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 84),
        itemCount: controller.projects.length,
        itemBuilder: (context, index) {
          final p = controller.projects[index];
          final client = controller.clientById(p.clientId);
          final realizedResult = controller.projectRealizedResult(p.id);
          final plannedCosts = controller.projectPlannedCosts(p.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyBlue,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.paleOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Prazo: ${AppFormatters.date(p.deadline)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cliente: ${client?.name ?? 'Não informado'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.royalBlue,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MetricColumn(
                        label: 'Valor Contratado',
                        value: AppFormatters.brl(p.contractedValue),
                        color: AppColors.navyBlue,
                      ),
                      _MetricColumn(
                        label: 'Custos Vinculados',
                        value: AppFormatters.brl(plannedCosts),
                        color: AppColors.royalBlue,
                      ),
                      _MetricColumn(
                        label: 'Resultado Realizado',
                        value: AppFormatters.brl(realizedResult),
                        color: realizedResult >= 0
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addProjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Projeto'),
      ),
    );
  }

  void _addProjectDialog(BuildContext context) {
    if (controller.clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre ao menos um cliente antes de criar projeto.'),
        ),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    String selectedClient = controller.clients.first.id;
    DateTime deadline = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Cadastrar Projeto',
              style: TextStyle(color: AppColors.navyBlue)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nome do Projeto'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedClient,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  items: controller.clients
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setStateDialog(() => selectedClient = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor Contratado',
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: deadline,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setStateDialog(() => deadline = picked);
                    }
                  },
                  icon: const Icon(Icons.event, color: AppColors.royalBlue),
                  label: Text('Prazo: ${AppFormatters.date(deadline)}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final val =
                    double.tryParse(valueCtrl.text.replaceAll(',', '.')) ?? 0;
                if (nameCtrl.text.trim().isEmpty || val <= 0) return;
                controller.addProject(
                  name: nameCtrl.text.trim(),
                  clientId: selectedClient,
                  contractedValue: val,
                  deadline: deadline,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Aba 2: Cadastro de Clientes (RF01)
class _ClientsTab extends StatelessWidget {
  final FinanceController controller;
  const _ClientsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 84),
        itemCount: controller.clients.length,
        itemBuilder: (context, index) {
          final c = controller.clients[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.royalBlue.withValues(alpha: 0.12),
                child: const Icon(Icons.business, color: AppColors.royalBlue),
              ),
              title: Text(
                c.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyBlue,
                ),
              ),
              subtitle: Text(c.contact,
                  style: const TextStyle(color: AppColors.royalBlue)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addClientDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Cliente'),
      ),
    );
  }

  void _addClientDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cadastrar Cliente',
            style: TextStyle(color: AppColors.navyBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Nome / Razão Social'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contactCtrl,
              decoration:
                  const InputDecoration(labelText: 'Telefone ou E-mail'),
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
              if (nameCtrl.text.trim().isEmpty) return;
              controller.addClient(
                  nameCtrl.text.trim(), contactCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

// Aba 3: Cadastro de Prestadores (RF03)
class _ProvidersTab extends StatelessWidget {
  final FinanceController controller;
  const _ProvidersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 84),
        itemCount: controller.providers.length,
        itemBuilder: (context, index) {
          final pr = controller.providers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.paleOrange,
                child: const Icon(Icons.engineering,
                    color: AppColors.primaryOrange),
              ),
              title: Text(
                pr.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyBlue,
                ),
              ),
              subtitle: Text(
                '${pr.role} • Contrato: ${AppFormatters.brl(pr.contractedValue)}',
                style: const TextStyle(color: AppColors.royalBlue),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addProviderDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Prestador'),
      ),
    );
  }

  void _addProviderDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cadastrar Prestador',
            style: TextStyle(color: AppColors.navyBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleCtrl,
              decoration:
                  const InputDecoration(labelText: 'Função / Especialidade'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor Contratado',
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
                  double.tryParse(valueCtrl.text.replaceAll(',', '.')) ?? 0;
              if (nameCtrl.text.trim().isEmpty || val <= 0) return;
              controller.addProvider(
                nameCtrl.text.trim(),
                roleCtrl.text.trim(),
                val,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.royalBlue),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}