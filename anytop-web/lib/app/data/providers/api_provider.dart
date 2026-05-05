import 'package:get/get.dart';
import 'api_config.dart';
import '../models/operator_model.dart';

class ApiProvider extends GetConnect {
  @override
  void onInit() {
    super.onInit();

    httpClient.baseUrl = ApiConfig.baseUrl;
    httpClient.timeout = Duration(seconds: ApiConfig.timeoutSeconds);

    httpClient.addRequestModifier<dynamic>((request) {
      request.headers.addAll(ApiConfig.defaultHeaders);
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      return response;
    });
  }

  Future<ApiResponse<T>> getRequest<T>(
    String path, {
    required T Function(dynamic data) decoder,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await get(path, query: query);
      if (response.isOk && response.body != null) {
        final body = response.body;
        if (body is Map<String, dynamic> && body['status'] == true) {
          return ApiResponse.ok(decoder(body['data']));
        }
        return ApiResponse.error(
          body is Map ? body['message'] ?? 'Request failed' : 'Request failed',
          statusCode: response.statusCode,
        );
      }
      return ApiResponse.error(
        response.statusText ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse<T>> postRequest<T>(
    String path, {
    required T Function(dynamic data) decoder,
    dynamic body,
  }) async {
    try {
      final response = await post(path, body);
      if (response.isOk && response.body != null) {
        final resBody = response.body;
        if (resBody is Map<String, dynamic> && resBody['status'] == true) {
          return ApiResponse.ok(decoder(resBody['data']));
        }
        return ApiResponse.error(
          resBody is Map
              ? resBody['message'] ?? 'Request failed'
              : 'Request failed',
          statusCode: response.statusCode,
        );
      }
      return ApiResponse.error(
        response.statusText ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse<T>> putRequest<T>(
    String path, {
    required T Function(dynamic data) decoder,
    dynamic body,
  }) async {
    try {
      final response = await put(path, body);
      if (response.isOk && response.body != null) {
        final resBody = response.body;
        if (resBody is Map<String, dynamic> && resBody['status'] == true) {
          return ApiResponse.ok(decoder(resBody['data']));
        }
        return ApiResponse.error(
          resBody is Map
              ? resBody['message'] ?? 'Request failed'
              : 'Request failed',
          statusCode: response.statusCode,
        );
      }
      return ApiResponse.error(
        response.statusText ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
}
