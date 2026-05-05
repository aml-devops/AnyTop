import '../models/operator_model.dart';
import 'api_provider.dart';

class OperatorProvider extends ApiProvider {
  Future<ApiResponse<List<OperatorModel>>> getOperators() async {
    return getRequest<List<OperatorModel>>(
      '/api/sims/balances',
      decoder: (data) {
        final operatorsList = data['operators'] as List;
        final grandTotal = (data['grandTotalBalance'] ?? 0).toDouble();

        final operators = operatorsList
            .map((e) =>
                OperatorModel.fromBalanceJson(e as Map<String, dynamic>))
            .toList();

        operators.add(OperatorModel(
          name: 'All Operators',
          balance: grandTotal,
        ));

        return operators;
      },
    );
  }

  Future<ApiResponse<OperatorModel>> getOperator(String name) async {
    if (name == 'All Operators') {
      return getRequest<OperatorModel>(
        '/api/sims',
        decoder: (data) {
          final sims = (data as List)
              .map((e) => ELoadCard.fromJson(e as Map<String, dynamic>))
              .toList();

          final totalBalance =
              sims.fold<double>(0, (sum, card) => sum + card.balance);

          return OperatorModel(
            name: 'All Operators',
            balance: totalBalance,
            eLoadCards: sims,
          );
        },
      );
    }

    return getRequest<OperatorModel>(
      '/api/sims/operator',
      query: {'operator': name},
      decoder: (data) {
        final sims = (data as List)
            .map((e) => ELoadCard.fromJson(e as Map<String, dynamic>))
            .toList();

        final totalBalance =
            sims.fold<double>(0, (sum, card) => sum + card.balance);

        return OperatorModel(
          name: name,
          balance: totalBalance,
          eLoadCards: sims,
        );
      },
    );
  }

  Future<ApiResponse<bool>> toggleCard(int cardId, bool active) async {
    final int isActive;
    active? isActive = 1 : isActive = 0;
    return putRequest<bool>(
      '/api/sims/$cardId/status?isActive=$isActive',
      decoder: (data) => data as bool,
    );
  }
}
