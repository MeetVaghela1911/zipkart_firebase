// import 'dart:io';
//
// import 'package:dio/dio.dart';
//
// import 'ApiEndpoints.dart';
//
// class ApiServices {
//   // Single instance (singleton)
//   ApiServices._internal();
//   static final ApiServices instance = ApiServices._internal();
//
//   // Configure these to match your app
//   static  String _baseUrl = ApiEndpoints.base;
//
//   late final Dio _dio;
//
//   void init({
//     Duration connectTimeout = const Duration(seconds: 20),
//     Duration receiveTimeout = const Duration(seconds: 20),
//     String? baseUrl,
//     bool enableLogging = true,
//   }) {
//     final options = BaseOptions(
//       baseUrl: baseUrl ?? _baseUrl,
//       responseType: ResponseType.json,
//       contentType: 'application/json',
//     );
//
//     _dio = Dio(options);
//
//     // Add logging interceptor (optional)
//     if (enableLogging) {
//       _dio.interceptors.add(LogInterceptor(
//         requestHeader: false,
//         requestBody: true,
//         responseBody: true,
//         responseHeader: false,
//       ));
//     }
//
//   }
//
//   Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
//     try {
//       final resp = await _dio.get(
//         endpoint,
//         queryParameters: queryParameters,
//       );
//       return _handleResponse(resp);
//     } on DioException catch (e) {
//       throw _mapDioErrorToApiException(e);
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }
//
//   Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
//     try {
//       final resp = await _dio.post(
//         endpoint,
//         data: data ?? {},
//       );
//       return _handleResponse(resp);
//     } on DioException catch (e) {
//       throw _mapDioErrorToApiException(e);
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }
//
//   Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
//     try {
//       final resp = await _dio.put(endpoint, data: data ?? {});
//       return _handleResponse(resp);
//     } on DioException catch (e) {
//       throw _mapDioErrorToApiException(e);
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }
//
//   Future<dynamic> delete(String endpoint, {Map<String, dynamic>? data}) async {
//     try {
//       final resp = await _dio.delete(endpoint, data: data ?? {});
//       return _handleResponse(resp);
//     } on DioException catch (e) {
//       throw _mapDioErrorToApiException(e);
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }
//
//   // -----------------------
//   // Multipart / file upload example
//   // -----------------------
//   /// upload file(s) with additional fields
//   Future<dynamic> uploadFiles(
//       String endpoint, {
//         required List<File> files,
//         String fileField = 'files[]',
//         Map<String, dynamic>? fields,
//       }) async {
//     try {
//       final formData = FormData.fromMap({
//         ...?fields,
//         fileField: files.map((f) {
//           final fileName = f.path.split(Platform.pathSeparator).last;
//           return MultipartFile.fromFileSync(f.path, filename: fileName);
//         }).toList(),
//       });
//
//       final resp = await _dio.post(
//         endpoint,
//         data: formData,
//         options: Options(
//           contentType: 'multipart/form-data',
//         ),
//       );
//
//       return _handleResponse(resp);
//     } on DioException catch (e) {
//       throw _mapDioErrorToApiException(e);
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }
//
//   Future<Map<String, dynamic>> uploadCallLog({
//     required File audioFile,
//     required Map<String, dynamic> meta,
//   }) async
//   {
//     final form = FormData.fromMap({
//       ...meta,
//       'file': await MultipartFile.fromFile(audioFile.path,
//           filename: audioFile.path.split(Platform.pathSeparator).last),
//     });
//
//     try {
//       final resp = await _dio.post(
//         ApiEndpoints.uploadCallLog,
//         data: form,
//         options: Options(contentType: 'multipart/form-data'),
//       );
//       return Map<String, dynamic>.from(_handleResponse(resp) as Map);
//     } on DioException catch (e) {
//       throw _mapDioErrorToApiException(e);
//     }
//   }
//
//   // -----------------------
//   // Private helpers
//   // -----------------------
//   dynamic _handleResponse(Response response) {
//     // Customize based on your API contract.
//     // Example: if your API always wraps data as { response: '1', response_message: '', data: {...}}
//     final data = response.data;
//
//     if (response.statusCode == null) {
//       throw ApiException('No response code from server');
//     }
//
//     if (response.statusCode! >= 200 && response.statusCode! < 300) {
//       // If the backend uses a wrapper
//       if (data is Map && (data.containsKey('response') || data.containsKey('data'))) {
//         // if response field indicates success/failure convert accordingly
//         // Example: status where "response":"1" is success
//         final respFlag = data['response']?.toString();
//         if (respFlag != null && (respFlag == '0' || respFlag.toLowerCase() == 'false')) {
//           final msg = data['response_message'] ??
//               data['message'] ??
//               'Unknown server error';
//           throw ApiException(msg, statusCode: response.statusCode);
//         }
//         return data;
//       }
//       return data;
//     }
//
//     // Other non-2xx codes
//     final message = data is Map ? (data['message'] ?? data['error'] ?? data.toString()) : response.statusMessage ?? 'Request failed';
//     throw ApiException(message, statusCode: response.statusCode);
//   }
//
//   ApiException _mapDioErrorToApiException(DioException e) {
//     String message = 'Unexpected network error';
//     int? status;
//
//     if (e.type == DioExceptionType.connectionTimeout ||
//         e.type == DioExceptionType.sendTimeout ||
//         e.type == DioExceptionType.receiveTimeout) {
//       message = 'Connection timed out. Please try again.';
//     } else if (e.type == DioExceptionType.badResponse) {
//       status = e.response?.statusCode;
//       final respData = e.response?.data;
//       message = respData is Map
//           ? (respData['message'] ?? respData['response_message'] ?? respData['error'] ?? respData.toString())
//           : (e.response?.statusMessage ?? 'Server error');
//     } else if (e.type == DioExceptionType.cancel) {
//       message = 'Request cancelled';
//     } else if (e.type == DioExceptionType.unknown) {
//       // Could be no internet or DNS error
//       message = e.error?.toString() ?? 'Network error';
//     } else {
//       message = e.message ?? 'Network error';
//     }
//
//     return ApiException(message, statusCode: status);
//   }
//
// }
//
//
// class ApiException implements Exception {
//   final String message;
//   final int? statusCode;
//   ApiException(this.message, {this.statusCode});
//
//   @override
//   String toString() => 'ApiException(status: $statusCode, message: $message)';
// }


import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Constants/Constant.dart';

class MyApiService {
  // 🔒 Singleton instance
  static final MyApiService _instance = MyApiService._internal();
  factory MyApiService() => _instance;
  MyApiService._internal();

  late Dio _dio;
  String? _baseUrl;
  bool _isInitialized = false;

  // ✅ Initialize once
  Future<void> init() async {
    if (_isInitialized) return;

    // final startUrl = await Constant.getStartUrl();
    // final endUrl = await Constant.ENDING_URL;
    final storedBaseUrl = 'http://zipcart.somee.com' ;

    _baseUrl = storedBaseUrl;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl!,
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
    ));

    _isInitialized = true;
    print("✅ MyApiService initialized with base URL: $_baseUrl");
  }

  // ✅ Update base URL dynamically
  Future<void> updateBaseUrl(String newBaseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("base_url", newBaseUrl);
    _dio.options.baseUrl = newBaseUrl;
    _baseUrl = newBaseUrl;
    print("🔁 Base URL updated to: $newBaseUrl");
  }

  // ✅ Add Bearer token
  void setAuthToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  // ✅ GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    await _ensureInitialized();
    try {
      final res = await _dio.get(endpoint, queryParameters: queryParams);
      print("📥 GET $endpoint → ${res.statusCode}");
      return res;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // ✅ POST request
  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    await _ensureInitialized();
    try {
      final res = await _dio.post(endpoint, data: data);
      print("📤 POST $endpoint → ${res.statusCode}");
      return res;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // ✅ PUT request
  Future<Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    await _ensureInitialized();
    try {
      final res = await _dio.put(endpoint, data: data);
      print("📝 PUT $endpoint → ${res.statusCode}");
      return res;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // ✅ DELETE request
  Future<Response> delete(String endpoint, {Map<String, dynamic>? data}) async {
    await _ensureInitialized();
    try {
      final res = await _dio.delete(endpoint, data: data);
      print("🗑️ DELETE $endpoint → ${res.statusCode}");
      return res;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // ✅ Ensure service initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) await init();
  }

  // ✅ Centralized error handler
  Exception _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return Exception("⏳ Connection timed out. Please check your internet.");
    } else if (error.type == DioExceptionType.sendTimeout) {
      return Exception("⚠️ Send timeout. Try again.");
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return Exception("📡 Receive timeout. Server took too long to respond.");
    } else if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      return Exception("❌ Server error ($statusCode): ${data.toString()}");
    } else if (error.type == DioExceptionType.cancel) {
      return Exception("🚫 Request was cancelled.");
    } else if (error.type == DioExceptionType.unknown) {
      return Exception("🌐 No Internet connection or server unreachable.");
    } else {
      return Exception("💥 Unexpected error: ${error.message}");
    }
  }
}
