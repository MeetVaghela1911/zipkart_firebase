import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipkart_firebase/data/repositories/auth_repository.dart';
import 'package:zipkart_firebase/Models/app_user.dart';
import 'package:zipkart_firebase/providers/auth_state_provider.dart';

/// Sign Up State
/// 
/// Represents the state of the sign up process.
class SignUpState {
  final bool isLoading;
  final AppUser? user;
  final String? error;
  final bool isSuccess;

  SignUpState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isSuccess = false,
  });

  SignUpState copyWith({
    bool? isLoading,
    AppUser? user,
    String? error,
    bool? isSuccess,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  /// Clear error state
  SignUpState clearError() {
    return SignUpState(
      isLoading: isLoading,
      user: user,
      error: null,
      isSuccess: isSuccess,
    );
  }
}

/// Sign Up Notifier
/// 
/// Manages the sign up flow state and business logic.
/// 
/// RESPONSIBILITIES:
/// - Validate input data
/// - Call AuthRepository to create user
/// - Manage loading, success, and error states
/// 
/// SECURITY:
/// - Never stores passwords in state
/// - All auth operations delegated to AuthRepository
class SignUpNotifier extends StateNotifier<SignUpState> {
  final AuthRepository _repository;

  SignUpNotifier(this._repository) : super(SignUpState());

  /// Sign up with email and password
  /// 
  /// FLOW:
  /// 1. Validate inputs (email, password, username)
  /// 2. Set loading state
  /// 3. Call repository to create user
  /// 4. Update state with result
  /// 
  /// VALIDATION:
  /// - Email must be valid format
  /// - Password must be at least 6 characters
  /// - Username must not be empty
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String role, // "buyer" | "seller"
    XFile? profileImage,
  }) async {
    debugPrint('🟢 [SignUpNotifier] signUp called');
    debugPrint('🟢 [SignUpNotifier] Email: ${email.trim()}, Username: $username, Role: $role');
    
    // Clear previous errors
    state = state.clearError();
    debugPrint('🟢 [SignUpNotifier] Previous errors cleared');

    // Validate inputs
    debugPrint('🟢 [SignUpNotifier] Validating inputs...');
    final validationError = _validateInputs(
      email: email,
      password: password,
      username: username,
    );

    if (validationError != null) {
      debugPrint('❌ [SignUpNotifier] Validation failed: $validationError');
      state = state.copyWith(error: validationError);
      return;
    }
    debugPrint('✅ [SignUpNotifier] Input validation passed');

    // Set loading state
    debugPrint('🟢 [SignUpNotifier] Setting loading state...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call repository to create user
      // Repository handles:
      // 1. Firebase Auth user creation
      // 2. Profile image upload (if provided)
      // 3. Firestore profile creation
      debugPrint('🟢 [SignUpNotifier] Calling repository.signUp()...');
      final appUser = await _repository.signUp(
        email: email,
        password: password,
        username: username,
        phone: phone,
        role: role,
        profileImage: profileImage,
      );

      debugPrint('✅ [SignUpNotifier] Repository signUp completed successfully');
      debugPrint('✅ [SignUpNotifier] Created user: ${appUser.username} (${appUser.uid})');

      // Success - update state
      state = state.copyWith(
        isLoading: false,
        user: appUser,
        isSuccess: true,
        error: null,
      );
      debugPrint('✅ [SignUpNotifier] State updated with success');
    } catch (e, stackTrace) {
      debugPrint('❌ [SignUpNotifier] Error during sign up: $e');
      debugPrint('❌ [SignUpNotifier] Stack trace: $stackTrace');
      
      // Error - update state with error message
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ [SignUpNotifier] Setting error state: $errorMessage');
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        isSuccess: false,
      );
    }
  }

  /// Validate sign up inputs
  /// 
  /// Returns error message if validation fails, null if valid.
  String? _validateInputs({
    required String email,
    required String password,
    required String username,
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

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Validate username
    if (username.trim().isEmpty) {
      return 'Please enter your username';
    }

    if (username.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }

    return null; // All validations passed
  }

  /// Reset state (useful after successful sign up)
  void reset() {
    state = SignUpState();
  }
}

/// Sign Up Provider
/// 
/// Provides SignUpNotifier instance to the app.
final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpNotifier(repository);
});

