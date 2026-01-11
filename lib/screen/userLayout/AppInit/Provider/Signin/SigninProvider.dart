import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Repo.dart';
import 'SignInState.dart';

final signUpProvider =
StateNotifierProvider<SignInController, SignInState>(
      (ref) => SignInController(),
);

class SignInController extends StateNotifier<SignInState> {
  SignInController() : super(SignInState());

  Future<void> signIn({
    required String email,
    required String password,
    required String userName,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true);
    try {

      final response = await signInUser(
        email: email,
        password: password,
        userName: userName,
        phone: phone,
      );

      if(response != null && response.statusCode == 200 && response.data['response'] == '1'){
        // On success
        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        // On failure
        state = state.copyWith(isLoading: false, error: response?.data['responseMessage']);
      }
      // Simulate network request
      // On success
      // state = SingInSuccess();
    } catch (e) {
      // On failure
      // state = SingInFailure(error: e.toString());
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}