import '../models/operator_model.dart';
import '../providers/operator_provider.dart';

class OperatorRepository {
  final OperatorProvider _provider;

  OperatorRepository(this._provider);

  Future<ApiResponse<List<OperatorModel>>> getOperators() {
    return _provider.getOperators();
  }

  Future<ApiResponse<OperatorModel>> getOperator(String name) {
    return _provider.getOperator(name);
  }

  Future<ApiResponse<bool>> toggleCard(int cardId, bool active) {
    return _provider.toggleCard(cardId, active);
  }
}
