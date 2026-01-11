import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/core/service/api_service/ApiEndpoints.dart';
import 'package:zipkart_firebase/core/service/api_service/ApiServices.dart';
import 'package:zipkart_firebase/screen/userLayout/AppInit/Provider/Login/State.dart';

import 'Repo.dart';

StateNotifierProvider<LoginController, LogInState> loginProvider =
StateNotifierProvider<LoginController, LogInState>(
      (ref) => LoginController(),
);

class LoginController extends StateNotifier<LogInState>{
  LoginController(): super(LogInState());

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    final res = await logInUser(email: email, password: password);

    if(res != null && res.statusCode == 200  && res.data['response'] == '1'){
      state = state.copyWith(isLoading: false, isSuccess: true);
    }
    else {
      state = state.copyWith(isLoading: false, error: res?.data['responseMessage']);
    }
  }
}