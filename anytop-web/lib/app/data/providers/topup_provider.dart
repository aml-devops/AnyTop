import '../models/operator_model.dart';
import 'api_provider.dart';

class TopupProvider extends ApiProvider {
  static const bool _useDummyData = true;

  Future<ApiResponse<TopupTransaction>> submitTopup(TopupRequest request) async {
    if (_useDummyData) {

      final txn = TopupTransaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        operatorName: request.operatorName,
        phoneNumber: request.phoneNumber,
        amount: request.amount.toDouble(),
        status: 'Success',
        date: DateTime.now(),
        cardName: request.cardName,
      );
      return ApiResponse.ok(txn, message: 'Topup successful');
    }

    return postRequest<TopupTransaction>(
      '/topup',
      decoder: (data) =>
          TopupTransaction.fromJson(data as Map<String, dynamic>),
      body: request.toJson(),
    );
  }

  Future<ApiResponse<List<TopupTransaction>>> getTransactions({
    String? operatorFilter,
    String? searchQuery,
    int page = 1,
    int limit = 50,
  }) async {
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.ok(_dummyTransactions);
    }

    return getRequest<List<TopupTransaction>>(
      '/transactions',
      decoder: (data) => (data as List)
          .map((e) => TopupTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      query: {
        if (operatorFilter != null && operatorFilter != 'All')
          'operator': operatorFilter,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
  }

  Future<ApiResponse<String>> exportTransactions({String format = 'csv'}) async {
    if (_useDummyData) {
      await Future.delayed(const Duration(seconds: 1));
      return ApiResponse.ok('export_${DateTime.now().millisecondsSinceEpoch}.$format',
          message: 'Export ready');
    }

    // TODO: Replace with real API call
    return getRequest<String>(
      '/transactions/export',
      decoder: (data) => data['download_url'] as String,
      query: {'format': format},
    );
  }
}


final List<TopupTransaction> _dummyTransactions = [
  TopupTransaction(
    id: 'TXN001',
    operatorName: 'MPT',
    phoneNumber: '09500012345',
    amount: 5000,
    status: 'Success',
    date: DateTime(2026, 4, 14, 10, 30),
    cardName: 'MPT-1',
  ),
  TopupTransaction(
    id: 'TXN002',
    operatorName: 'Atom',
    phoneNumber: '09700054321',
    amount: 3000,
    status: 'Success',
    date: DateTime(2026, 4, 14, 9, 15),
    cardName: 'Atom-1',
  ),
  TopupTransaction(
    id: 'TXN003',
    operatorName: 'U9',
    phoneNumber: '09600098765',
    amount: 10000,
    status: 'Pending',
    date: DateTime(2026, 4, 13, 16, 45),
    cardName: 'U9-2',
  ),
  TopupTransaction(
    id: 'TXN004',
    operatorName: 'Mytel',
    phoneNumber: '09800011111',
    amount: 2000,
    status: 'Failed',
    date: DateTime(2026, 4, 13, 14, 20),
    cardName: 'Mytel-1',
  ),
  TopupTransaction(
    id: 'TXN005',
    operatorName: 'MPT',
    phoneNumber: '09500099999',
    amount: 1000,
    status: 'Success',
    date: DateTime(2026, 4, 12, 11, 0),
    cardName: 'MPT-2',
  ),
  TopupTransaction(
    id: 'TXN006',
    operatorName: 'Atom',
    phoneNumber: '09700077777',
    amount: 5000,
    status: 'Success',
    date: DateTime(2026, 4, 12, 8, 30),
    cardName: 'Atom-1',
  ),
];
