import '../models/operator_model.dart';
import '../providers/topup_provider.dart';

class TopupRepository {
  final TopupProvider _provider;

  TopupRepository(this._provider);

  Future<ApiResponse<TopupTransaction>> submitTopup(TopupRequest request) {
    return _provider.submitTopup(request);
  }

  Future<ApiResponse<List<TopupTransaction>>> getTransactions({
    String? operatorFilter,
    String? searchQuery,
    int page = 1,
    int limit = 50,
  }) {
    return _provider.getTransactions(
      operatorFilter: operatorFilter,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<String>> exportTransactions({String format = 'csv'}) {
    return _provider.exportTransactions(format: format);
  }
}
