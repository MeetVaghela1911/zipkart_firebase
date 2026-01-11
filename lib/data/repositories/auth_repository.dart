import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipkart_firebase/Models/app_user.dart';

/// AuthRepository
/// 
/// Repository layer for authentication and user profile operations.
/// 
/// RESPONSIBILITIES:
/// - Firebase Auth operations (sign up, sign in, sign out)
/// - Firestore user profile CRUD operations
/// - Firebase Storage image uploads
/// 
/// SECURITY RULES:
/// 1. Never store passwords - Firebase Auth handles this
/// 2. Use Firebase Auth UID as Firestore document ID
/// 3. All operations must be authenticated
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Get current authenticated user from Firebase Auth
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  /// 
  /// This stream emits whenever the user signs in, signs out, or token refreshes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  /// 
  /// FLOW:
  /// 1. Create user in Firebase Auth
  /// 2. Upload profile image to Storage (if provided)
  /// 3. Create user profile in Firestore
  /// 
  /// THROWS: FirebaseAuthException for auth errors
  /// THROWS: FirebaseException for Firestore/Storage errors
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String role, // "buyer" | "seller"
    XFile? profileImage,
  }) async {
    debugPrint('🔵 [AuthRepository] SignUp started for email: ${email.trim()}');
    
    try {
      // Step 1: Create user in Firebase Auth
      // This is the ONLY place where password is used
      debugPrint('🔵 [AuthRepository] Step 1: Creating user in Firebase Auth...');
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User user = credential.user!;
      final String uid = user.uid;
      debugPrint('✅ [AuthRepository] Step 1: User created in Firebase Auth. UID: $uid');

      // Step 2: Upload profile image to Firebase Storage (if provided)
      String? photoUrl;
      if (profileImage != null) {
        debugPrint('🔵 [AuthRepository] Step 2: Uploading profile image...');
        try {
          photoUrl = await _uploadProfileImage(uid, profileImage);
          debugPrint('✅ [AuthRepository] Step 2: Profile image uploaded. URL: $photoUrl');
        } catch (e) {
          debugPrint('⚠️ [AuthRepository] Step 2: Image upload failed: $e');
          // Continue without image - don't fail sign up
        }
      } else {
        debugPrint('ℹ️ [AuthRepository] Step 2: No profile image provided, skipping upload');
      }

      // Step 3: Create user profile in Firestore
      // Use UID as document ID for security and easy lookup
      debugPrint('🔵 [AuthRepository] Step 3: Creating user profile in Firestore...');
      debugPrint('🔵 [AuthRepository] Step 3: UID: $uid, Email: ${email.trim()}, Username: ${username.trim()}, Role: $role');
      
      final appUser = AppUser(
        uid: uid,
        email: email.trim(),
        username: username.trim(),
        phone: phone.trim(),
        role: role,
        photoUrl: photoUrl,
        isActive: true, // New users are active by default
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userData = appUser.toFirestore();
      debugPrint('🔵 [AuthRepository] Step 3: User data to save: $userData');

      try {
        // Check if user is authenticated before writing to Firestore
        final currentAuthUser = _auth.currentUser;
        debugPrint('🔵 [AuthRepository] Step 3: Current auth user: ${currentAuthUser?.uid}');
        
        if (currentAuthUser == null || currentAuthUser.uid != uid) {
          debugPrint('❌ [AuthRepository] Step 3: User not authenticated or UID mismatch!');
          throw Exception('User authentication failed. Cannot create profile.');
        }
        
        debugPrint('🔵 [AuthRepository] Step 3: Writing to Firestore path: users/$uid');
        await _firestore
            .collection('users')
            .doc(uid) // Use UID as document ID
            .set(userData, SetOptions(merge: false));
        
        debugPrint('✅ [AuthRepository] Step 3: User profile saved to Firestore successfully');
        
        // Verify the document was created
        debugPrint('🔵 [AuthRepository] Step 3: Verifying document creation...');
        final verifyDoc = await _firestore.collection('users').doc(uid).get();
        if (verifyDoc.exists) {
          debugPrint('✅ [AuthRepository] Step 3: Verified - Document exists in Firestore');
          debugPrint('🔵 [AuthRepository] Step 3: Document data: ${verifyDoc.data()}');
        } else {
          debugPrint('❌ [AuthRepository] Step 3: ERROR - Document does not exist after save!');
          debugPrint('❌ [AuthRepository] Step 3: This might be a Firestore security rules issue');
          throw Exception('Failed to create user profile in Firestore. Document was not created.');
        }
      } on FirebaseException catch (firestoreError) {
        debugPrint('❌ [AuthRepository] Step 3: FirebaseException occurred');
        debugPrint('❌ [AuthRepository] Step 3: Error code: ${firestoreError.code}');
        debugPrint('❌ [AuthRepository] Step 3: Error message: ${firestoreError.message}');
        debugPrint('❌ [AuthRepository] Step 3: Error plugin: ${firestoreError.plugin}');
        
        // Provide more specific error messages
        String errorMessage;
        switch (firestoreError.code) {
          case 'permission-denied':
            errorMessage = 'Permission denied. Please check Firestore security rules.';
            break;
          case 'unavailable':
            errorMessage = 'Firestore is currently unavailable. Please try again later.';
            break;
          case 'deadline-exceeded':
            errorMessage = 'Request timed out. Please check your internet connection.';
            break;
          default:
            errorMessage = 'Failed to create user profile: ${firestoreError.message}';
        }
        
        throw Exception(errorMessage);
      } catch (firestoreError) {
        debugPrint('❌ [AuthRepository] Step 3: Unexpected error: $firestoreError');
        debugPrint('❌ [AuthRepository] Step 3: Error type: ${firestoreError.runtimeType}');
        rethrow;
      }

      debugPrint('✅ [AuthRepository] SignUp completed successfully for UID: $uid');
      return appUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthRepository] FirebaseAuthException: ${e.code} - ${e.message}');
      // Re-throw with user-friendly messages
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthRepository] Unexpected error during sign up: $e');
      debugPrint('❌ [AuthRepository] Stack trace: $stackTrace');
      
      // If user was created but profile creation failed, delete the auth user
      if (_auth.currentUser != null) {
        debugPrint('🔵 [AuthRepository] Cleaning up: Deleting Firebase Auth user due to Firestore failure...');
        try {
          await _auth.currentUser!.delete();
          debugPrint('✅ [AuthRepository] Firebase Auth user deleted successfully');
        } catch (deleteError) {
          debugPrint('⚠️ [AuthRepository] Failed to delete Firebase Auth user: $deleteError');
          // Ignore deletion errors
        }
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  /// 
  /// FLOW:
  /// 1. Authenticate with Firebase Auth
  /// 2. Fetch user profile from Firestore
  /// 3. Check if user is active (blocked users cannot sign in)
  /// 
  /// THROWS: FirebaseAuthException for auth errors
  /// THROWS: Exception if user is blocked (isActive == false)
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    debugPrint('🔵 [AuthRepository] SignIn started for email: ${email.trim()}');
    
    try {
      // Step 1: Authenticate with Firebase Auth
      debugPrint('🔵 [AuthRepository] Step 1: Authenticating with Firebase Auth...');
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User user = credential.user!;
      final String uid = user.uid;
      debugPrint('✅ [AuthRepository] Step 1: Authentication successful. UID: $uid');

      // Step 2: Fetch user profile from Firestore
      debugPrint('🔵 [AuthRepository] Step 2: Fetching user profile from Firestore...');
      final AppUser appUser = await getUserProfile(uid);
      debugPrint('✅ [AuthRepository] Step 2: User profile fetched. Username: ${appUser.username}, Role: ${appUser.role}');

      // Step 3: Check if user is active
      // Blocked users should not be able to sign in
      debugPrint('🔵 [AuthRepository] Step 3: Checking if user is active...');
      if (!appUser.isActive) {
        debugPrint('❌ [AuthRepository] Step 3: User is blocked (isActive: false)');
        // Sign out the user immediately
        await signOut();
        throw Exception('Your account has been deactivated. Please contact support.');
      }
      debugPrint('✅ [AuthRepository] Step 3: User is active');

      debugPrint('✅ [AuthRepository] SignIn completed successfully for UID: $uid');
      return appUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthRepository] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthRepository] Error during sign in: $e');
      debugPrint('❌ [AuthRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get user profile from Firestore
  /// 
  /// THROWS: Exception if user profile doesn't exist
  Future<AppUser> getUserProfile(String uid) async {
    debugPrint('🔵 [AuthRepository] getUserProfile called for UID: $uid');
    
    try {
      debugPrint('🔵 [AuthRepository] Fetching document from Firestore: users/$uid');
      final doc = await _firestore.collection('users').doc(uid).get();

      debugPrint('🔵 [AuthRepository] Document exists: ${doc.exists}');
      
      if (!doc.exists) {
        debugPrint('❌ [AuthRepository] User profile not found in Firestore for UID: $uid');
        throw Exception('User profile not found. Please sign up first.');
      }

      debugPrint('✅ [AuthRepository] Document data: ${doc.data()}');
      final appUser = AppUser.fromFirestore(doc);
      debugPrint('✅ [AuthRepository] User profile parsed successfully: ${appUser.username}');
      
      return appUser;
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthRepository] Error fetching user profile: $e');
      debugPrint('❌ [AuthRepository] Stack trace: $stackTrace');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Stream user profile from Firestore
  /// 
  /// This provides real-time updates to the user profile.
  Stream<AppUser?> streamUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Upload profile image to Firebase Storage
  /// 
  /// PATH: users/{uid}/profile.jpg
  /// 
  /// Returns the download URL of the uploaded image.
  Future<String> _uploadProfileImage(String uid, XFile image) async {
    debugPrint('🔵 [AuthRepository] _uploadProfileImage started for UID: $uid');
    
    try {
      // Create reference to storage path
      final Reference ref = _storage.ref().child('users/$uid/profile.jpg');
      debugPrint('🔵 [AuthRepository] Storage reference created: users/$uid/profile.jpg');

      // Upload file
      // Convert XFile to Uint8List for web compatibility
      debugPrint('🔵 [AuthRepository] Reading image bytes...');
      final Uint8List imageBytes = await image.readAsBytes();
      debugPrint('✅ [AuthRepository] Image bytes read: ${imageBytes.length} bytes');
      
      debugPrint('🔵 [AuthRepository] Starting upload to Firebase Storage...');
      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      debugPrint('🔵 [AuthRepository] Waiting for upload to complete...');
      final TaskSnapshot snapshot = await uploadTask;
      debugPrint('✅ [AuthRepository] Upload completed. Bytes transferred: ${snapshot.bytesTransferred}');

      // Get download URL
      debugPrint('🔵 [AuthRepository] Getting download URL...');
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('✅ [AuthRepository] Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthRepository] Error uploading profile image: $e');
      debugPrint('❌ [AuthRepository] Stack trace: $stackTrace');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

