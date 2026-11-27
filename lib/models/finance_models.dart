enum TransactionType { receita, despesa }

enum ExpenseCategory { fixa, variavel, projeto }

enum PaymentStatus { pago, pendente, vencido }

class Client {
  final String id;
  final String name;
  final String contact;

  Client({
    required this.id,
    required this.name,
    required this.contact,
  });
}

class ProviderMember {
  final String id;
  final String name;
  final String role;
  final double contractedValue;

  ProviderMember({
    required this.id,
    required this.name,
    required this.role,
    required this.contractedValue,
  });
}

class Project {
  final String id;
  final String name;
  final String clientId;
  final double contractedValue;
  final DateTime deadline;

  Project({
    required this.id,
    required this.name,
    required this.clientId,
    required this.contractedValue,
    required this.deadline,
  });
}

class FinancialEntry {
  final String id;
  final String title;
  final TransactionType type;
  final double totalAmount;
  double paidAmount; // Permite pagamento/recebimento parcial (RF05 / RN05)
  final DateTime dueDate;
  final String? clientId;
  final String? projectId;
  final String? providerId;
  final ExpenseCategory? expenseCategory;

  FinancialEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueDate,
    this.clientId,
    this.projectId,
    this.providerId,
    this.expenseCategory,
  });

  double get remainingAmount =>
      (totalAmount - paidAmount).clamp(0, double.infinity);

  bool get isFullyPaid => remainingAmount <= 0.009;

  PaymentStatus get status {
    if (isFullyPaid) return PaymentStatus.pago;
    final today = DateTime.now();
    final pureToday = DateTime(today.year, today.month, today.day);
    final pureDue = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (pureDue.isBefore(pureToday)) return PaymentStatus.vencido;
    return PaymentStatus.pendente;
  }
}