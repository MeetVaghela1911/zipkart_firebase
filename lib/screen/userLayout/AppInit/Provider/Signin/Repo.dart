import 'package:dio/dio.dart';
import 'package:zipkart_firebase/core/service/api_service/ApiEndpoints.dart';
import 'package:zipkart_firebase/core/service/api_service/ApiServices.dart';
import 'package:zipkart_firebase/screen/CommanWidget/Log.dart';

Future<Response?> signInUser({
  required String email,
  required String password,
  required String userName,
  required String phone,
}) async {
  final res = await MyApiService().post(
    ApiEndpoints.singIn,
    data: {
      "fullName": "$userName",
      "email": "$email",
      "phone": "$phone",
      "password": "$password",
    }
  );

  print(res.toString());

  return res;
}