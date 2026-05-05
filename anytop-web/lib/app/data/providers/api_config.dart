class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';

  static const int timeoutSeconds = 30;

  static bool get useDummyData => baseUrl.isEmpty;

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
