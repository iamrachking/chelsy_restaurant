import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/constants/app_constants.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/core/services/storage_service.dart';

class ApiService extends GetxService {
  late dio.Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    //  interceptors
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (options.data is dio.FormData) {
            options.headers.remove('Content-Type');
          }
          AppLogger.debug('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            'API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
            error,
          );

          // Handle 401 Unauthorized - netoyage du token et redirection vers le login
          if (error.response?.statusCode == 401) {
            _storageService.removeToken();
            _storageService.setLoggedIn(false);
          }

          return handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<dio.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<dio.Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<dio.Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle errors
  String _handleError(dio.DioException error) {
    String errorMessage = 'Une erreur est survenue';

    if (error.response != null) {
      // Server responded with error
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // Extraction du message d'erreur de l'API
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          errorMessage = data['message'] as String;
        } else if (data['errors'] != null) {
          // Gestion des erreurs de validation Laravel
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first as String;
          } else if (firstError is String) {
            errorMessage = firstError;
          }
        }
      }

      // Messages par défaut si aucun message spécifique n'est trouvé
      if (errorMessage == 'Une erreur est survenue') {
        switch (statusCode) {
          case 400:
            errorMessage = 'Requête invalide';
            break;
          case 401:
            errorMessage = 'Email ou mot de passe incorrect';
            break;
          case 403:
            errorMessage = 'Accès interdit';
            break;
          case 404:
            errorMessage = 'Ressource non trouvée';
            break;
          case 422:
            errorMessage = 'Erreur de validation. Vérifiez vos informations';
            break;
          case 500:
            errorMessage = 'Erreur serveur';
            break;
        }
      }
    } else if (error.type == dio.DioExceptionType.connectionTimeout ||
        error.type == dio.DioExceptionType.receiveTimeout) {
      errorMessage = 'Timeout. Vérifiez votre connexion internet';
    } else if (error.type == dio.DioExceptionType.connectionError) {
      errorMessage = 'Pas de connexion internet';
    }

    return errorMessage;
  }
}
