import 'package:dio/dio.dart';
import 'package:zipkart_firebase/core/service/api_service/ApiEndpoints.dart';
import 'package:zipkart_firebase/core/service/api_service/ApiServices.dart';

Future<Response?> logInUser({
  required String email,
  required String password,
}) async {
  final res = await MyApiService().post(
      ApiEndpoints.login,
      data: {
        "email": "$email",
        "password": "$password",
      }
  );

  return res;
}