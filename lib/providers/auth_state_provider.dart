import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/data/repositories/auth_repository.dart';
import 'package:zipkart_firebase/Models/app_user.dart';

/// Provider for AuthRepository instance
/// 
/// This provides a singleton instance of AuthRepository to the app.
/// Using Provider ensures we have a single source of truth for auth operations.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Stream provider for Firebase Auth state changes
/// 
/// This watches Firebase Auth and emits whenever:
/// - User signs in
/// - User signs out
/// - Auth token refreshes
/// 
/// Returns null when user is signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Provider for current authenticated user (Firebase Auth User)
/// 
/// This extracts the User from authStateProvider for easier access.
final currentAuthUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Stream provider for current user's profile (AppUser from Firestore)
/// 
/// This combines Firebase Auth state with Firestore user profile.
/// 
/// FLOW:
/// 1. Watch auth state changes
/// 2. When user is authenticated, fetch their profile from Firestore
/// 3. Return null if user is signed out or profile doesn't exist
/// 
/// This provides real-time updates to the user profile.
final currentUserProfileProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) {
        // User is signed out - return empty stream
        return Stream.value(null);
      }
      
      // User is signed in - stream their profile from Firestore
      final repository = ref.watch(authRepositoryProvider);
      return repository.streamUserProfile(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Provider for current user profile (synchronous access)
/// 
/// This extracts the AppUser from currentUserProfileProvider for easier access.
/// Use this when you need the current user profile without watching the stream.
final currentAppUserProvider = Provider<AppUser?>((ref) {
  final profileState = ref.watch(currentUserProfileProvider);
  return profileState.when(
    data: (appUser) => appUser,
    loading: () => null,
    error: (_, __) => null,
  );
});

