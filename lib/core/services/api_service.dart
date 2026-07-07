import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://reqres.in/api';
  static const String _apiKey = String.fromEnvironment('REQRES_API_KEY');
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_apiKey.isNotEmpty) 'x-api-key': _apiKey,
      },
    ));
    // We can add interceptors here if needed for logging
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('error')) {
        if (data['error'] == 'missing_api_key') {
          return Exception('ReqRes API key is not configured');
        }
        return Exception(data['error']);
      }
      return Exception("Failed with status: ${e.response?.statusCode}");
    }
    return Exception(e.message ?? "An unexpected error occurred");
  }
}
