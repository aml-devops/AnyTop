class OperatorModel {
  final String name;
  final double balance;
  final List<ELoadCard> eLoadCards;
  final List<int> topUpAmounts;

  const OperatorModel({
    required this.name,
    required this.balance,
    this.eLoadCards = const [],
    this.topUpAmounts = const [1000, 2000, 3000, 5000, 10000],
  });

  int get totalCards => eLoadCards.length;
  int get activeCardCount => eLoadCards.where((c) => c.isActive).length;

  String get formattedBalance {
    final formatted = balance
        .toInt()
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$formatted MMK';
  }

  String get activeCardsLabel => '$activeCardCount/$totalCards active';

  factory OperatorModel.fromBalanceJson(Map<String, dynamic> json) {
    return OperatorModel(
      name: json['operator'] ?? '',
      balance: (json['totalBalance'] ?? 0).toDouble(),
    );
  }

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      name: json['operator'] ?? json['name'] ?? '',
      balance: (json['totalBalance'] ?? json['balance'] ?? 0).toDouble(),
      eLoadCards: (json['eload_cards'] as List<dynamic>?)
              ?.map((e) => ELoadCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topUpAmounts: (json['topup_amounts'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1000, 2000, 3000, 5000, 10000],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operator': name,
      'totalBalance': balance,
      'eload_cards': eLoadCards.map((e) => e.toJson()).toList(),
      'topup_amounts': topUpAmounts,
    };
  }
}

class ELoadCard {
  final int id;
  final String name;
  final double balance;
  final bool isActive;
  final String operatorName;

  const ELoadCard({
    required this.id,
    required this.name,
    required this.balance,
    this.isActive = true,
    this.operatorName = '',
  });

  String get formattedBalance {
    return balance
        .toInt()
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  factory ELoadCard.fromJson(Map<String, dynamic> json) {
    return ELoadCard(
      id: json['id'] ?? 0,
      name: json['simName'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      operatorName: json['operator'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'simName': name,
      'balance': balance,
      'isActive': isActive,
      'operator': operatorName,
    };
  }
}

class TopupTransaction {
  final String id;
  final String operatorName;
  final String phoneNumber;
  final double amount;
  final String status;
  final DateTime date;
  final String cardName;

  const TopupTransaction({
    required this.id,
    required this.operatorName,
    required this.phoneNumber,
    required this.amount,
    required this.status,
    required this.date,
    required this.cardName,
  });

  String get formattedAmount {
    final formatted = amount
        .toInt()
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$formatted MMK';
  }

  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  factory TopupTransaction.fromJson(Map<String, dynamic> json) {
    return TopupTransaction(
      id: json['id'] ?? '',
      operatorName: json['operator_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      cardName: json['card_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operator_name': operatorName,
      'phone_number': phoneNumber,
      'amount': amount,
      'status': status,
      'date': date.toIso8601String(),
      'card_name': cardName,
    };
  }
}

class TopupRequest {
  final String phoneNumber;
  final int amount;
  final String operatorName;
  final String cardName;

  const TopupRequest({
    required this.phoneNumber,
    required this.amount,
    required this.operatorName,
    required this.cardName,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'amount': amount,
      'operator_name': operatorName,
      'card_name': cardName,
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.ok(T data, {String? message}) => ApiResponse(
        success: true,
        data: data,
        message: message,
        statusCode: 200,
      );

  factory ApiResponse.error(String message, {int? statusCode}) => ApiResponse(
        success: false,
        message: message,
        statusCode: statusCode,
      );
}
