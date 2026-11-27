import 'package:flutter/foundation.dart';
import '../models/finance_models.dart';

class FinanceController extends ChangeNotifier {
  final List<Client> _clients = [];
  final List<ProviderMember> _providers = [];
  final List<Project> _projects = [];
  final List<FinancialEntry> _entries = [];

  FinanceController() {
    _seedInitialData();
  }

  List<Client> get clients => List.unmodifiable(_clients);
  List<ProviderMember> get providers => List.unmodifiable(_providers);
  List<Project> get projects => List.unmodifiable(_projects);
  List<FinancialEntry> get entries => List.unmodifiable(_entries);

  // Saldo realizado em caixa (apenas valores efetivamente pagos/recebidos)
  double get currentBalance {
    double total = 0;
    for (final e in _entries) {
      if (e.type == TransactionType.receita) {
        total += e.paidAmount;
      } else {
        total -= e.paidAmount;
      }
    }
    return total;
  }

  // Total a receber (pendente + vencido)
  double get totalReceivable => _entries
      .where((e) => e.type == TransactionType.receita)
      .fold(0.0, (sum, e) => sum + e.remainingAmount);

  // Total a pagar (pendente + vencido)
  double get totalPayable => _entries
      .where((e) => e.type == TransactionType.despesa)
      .fold(0.0, (sum, e) => sum + e.remainingAmount);

  // Saldo projetado (caixa atual + a receber - a pagar)
  double get projectedBalance =>
      currentBalance + totalReceivable - totalPayable;

  // Contas vencidas ou vencendo nos próximos 5 dias (RF10)
  List<FinancialEntry> get urgentEntries {
    final limit = DateTime.now().add(const Duration(days: 5));
    return _entries.where((e) {
      if (e.isFullyPaid) return false;
      return e.status == PaymentStatus.vencido || e.dueDate.isBefore(limit);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Resultado financeiro por projeto (RF08 / RN08)
  double projectRealizedResult(String projectId) {
    double rev = 0;
    double exp = 0;
    for (final e in _entries.where((item) => item.projectId == projectId)) {
      if (e.type == TransactionType.receita) {
        rev += e.paidAmount;
      } else {
        exp += e.paidAmount;
      }
    }
    return rev - exp;
  }

  double projectPlannedCosts(String projectId) {
    return _entries
        .where((e) =>
            e.projectId == projectId && e.type == TransactionType.despesa)
        .fold(0.0, (sum, e) => sum + e.totalAmount);
  }

  Client? clientById(String? id) {
    if (id == null) return null;
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Project? projectById(String? id) {
    if (id == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Ações de cadastro
  void addClient(String name, String contact) {
    _clients.add(Client(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      contact: contact,
    ));
    notifyListeners();
  }

  void addProvider(String name, String role, double contractedValue) {
    _providers.add(ProviderMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      role: role,
      contractedValue: contractedValue,
    ));
    notifyListeners();
  }

  void addProject({
    required String name,
    required String clientId,
    required double contractedValue,
    required DateTime deadline,
  }) {
    _projects.add(Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      clientId: clientId,
      contractedValue: contractedValue,
      deadline: deadline,
    ));
    notifyListeners();
  }

  void addEntry(FinancialEntry entry) {
    _entries.insert(0, entry);
    notifyListeners();
  }

  // Registrar pagamento total ou parcial (RF05 / RN05)
  void registerPayment(String entryId, double amount) {
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index == -1) return;
    final entry = _entries[index];
    entry.paidAmount =
        (entry.paidAmount + amount).clamp(0, entry.totalAmount);
    notifyListeners();
  }

  void _seedInitialData() {
    final now = DateTime.now();

    _clients.addAll([
      Client(id: 'c1', name: 'Horizonte Eventos', contact: '(81) 99123-4567'),
      Client(id: 'c2', name: 'Estúdio Aurora', contact: 'contato@aurora.com'),
    ]);

    _providers.addAll([
      ProviderMember(
        id: 'pr1',
        name: 'Lucas Andrade',
        role: 'Designer UI/UX',
        contractedValue: 2200.00,
      ),
      ProviderMember(
        id: 'pr2',
        name: 'Mariana Costa',
        role: 'Consultora Técnica',
        contractedValue: 1800.00,
      ),
    ]);

    _projects.addAll([
      Project(
        id: 'p1',
        name: 'Redesign Portal Institucional',
        clientId: 'c1',
        contractedValue: 8500.00,
        deadline: now.add(const Duration(days: 20)),
      ),
      Project(
        id: 'p2',
        name: 'Campanha Digital Q4',
        clientId: 'c2',
        contractedValue: 5000.00,
        deadline: now.add(const Duration(days: 10)),
      ),
    ]);

    _entries.addAll([
      FinancialEntry(
        id: 'e1',
        title: 'Entrada 50% - Redesign Portal',
        type: TransactionType.receita,
        totalAmount: 4250.00,
        paidAmount: 4250.00,
        dueDate: now.subtract(const Duration(days: 5)),
        clientId: 'c1',
        projectId: 'p1',
      ),
      FinancialEntry(
        id: 'e2',
        title: 'Parcela Final - Redesign Portal',
        type: TransactionType.receita,
        totalAmount: 4250.00,
        paidAmount: 1250.00, // Exemplo de recebimento parcial
        dueDate: now.add(const Duration(days: 3)),
        clientId: 'c1',
        projectId: 'p1',
      ),
      FinancialEntry(
        id: 'e3',
        title: 'Pagamento Prestador - Lucas Andrade',
        type: TransactionType.despesa,
        totalAmount: 2200.00,
        paidAmount: 1000.00,
        dueDate: now.subtract(const Duration(days: 2)), // Exemplo vencido
        projectId: 'p1',
        providerId: 'pr1',
        expenseCategory: ExpenseCategory.projeto,
      ),
      FinancialEntry(
        id: 'e4',
        title: 'Hospedagem e Ferramentas Cloud',
        type: TransactionType.despesa,
        totalAmount: 480.00,
        paidAmount: 480.00,
        dueDate: now.subtract(const Duration(days: 7)),
        expenseCategory: ExpenseCategory.fixa,
      ),
    ]);
  }
}