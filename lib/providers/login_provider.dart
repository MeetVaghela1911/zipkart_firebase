import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/data/repositories/auth_repository.dart';
import 'package:zipkart_firebase/Models/app_user.dart';
import 'package:zipkart_firebase/providers/auth_state_provider.dart';

/// Login State
/// 
/// Represents the state of the login process.
class LoginState {
  final bool isLoading;
  final AppUser? user;
  final String? error;
  final bool isSuccess;

  LoginState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    AppUser? user,
    String? error,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  /// Clear error state
  LoginState clearError() {
    return LoginState(
      isLoading: isLoading,
      user: user,
      error: null,
      isSuccess: isSuccess,
    );
  }
}

/// Login Notifier
/// 
/// Manages the login flow state and business logic.
/// 
/// RESPONSIBILITIES:
/// - Validate input data
/// - Call AuthRepository to authenticate user
/// - Check if user is active (blocked users cannot login)
/// - Manage loading, success, and error states
/// 
/// SECURITY:
/// - Never stores passwords in state
/// - All auth operations delegated to AuthRepository
/// - Handles blocked users (isActive == false)
class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _repository;

  LoginNotifier(this._repository) : super(LoginState());

  /// Sign in with email and password
  /// 
  /// FLOW:
  /// 1. Validate inputs (email, password)
  /// 2. Set loading state
  /// 3. Call repository to authenticate user
  /// 4. Repository checks if user is active
  /// 5. Update state with result
  /// 
  /// VALIDATION:
  /// - Email must be valid format
  /// - Password must not be empty
  /// 
  /// SECURITY:
  /// - If user is blocked (isActive == false), they are signed out immediately
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    debugPrint('🟢 [LoginNotifier] signIn called for email: ${email.trim()}');
    
    // Clear previous errors
    state = state.clearError();
    debugPrint('🟢 [LoginNotifier] Previous errors cleared');

    // Validate inputs
    debugPrint('🟢 [LoginNotifier] Validating inputs...');
    final validationError = _validateInputs(
      email: email,
      password: password,
    );

    if (validationError != null) {
      debugPrint('❌ [LoginNotifier] Validation failed: $validationError');
      state = state.copyWith(error: validationError);
      return;
    }
    debugPrint('✅ [LoginNotifier] Input validation passed');

    // Set loading state
    debugPrint('🟢 [LoginNotifier] Setting loading state...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call repository to authenticate user
      // Repository handles:
      // 1. Firebase Auth authentication
      // 2. Fetching user profile from Firestore
      // 3. Checking if user is active (blocks inactive users)
      debugPrint('🟢 [LoginNotifier] Calling repository.signIn()...');
      final appUser = await _repository.signIn(
        email: email,
        password: password,
      );

      debugPrint('✅ [LoginNotifier] Repository signIn completed successfully');
      debugPrint('✅ [LoginNotifier] Logged in user: ${appUser.username} (${appUser.uid})');

      // Success - update state
      state = state.copyWith(
        isLoading: false,
        user: appUser,
        isSuccess: true,
        error: null,
      );
      debugPrint('✅ [LoginNotifier] State updated with success');
    } catch (e, stackTrace) {
      debugPrint('❌ [LoginNotifier] Error during sign in: $e');
      debugPrint('❌ [LoginNotifier] Stack trace: $stackTrace');
      
      // Error - update state with error message
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ [LoginNotifier] Setting error state: $errorMessage');
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        isSuccess: false,
      );
    }
  }

  /// Validate login inputs
  /// 
  /// Returns error message if validation fails, null if valid.
  String? _validateInputs({
    required String email,
    required String password,
  }) {
    // Validate email
    if (email.trim().isEmpty) {
      return 'Please enter your email';
    }

    // Basic email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }

    // Validate password
    if (password.isEmpty) {
      return 'Please enter your password';
    }

    return null; // All validations passed
  }

  /// Reset state (useful after successful login or logout)
  void reset() {
    state = LoginState();
  }
}

/// Login Provider
/// 
/// Provides LoginNotifier instance to the app.
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginNotifier(repository);
});

