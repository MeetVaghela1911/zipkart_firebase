import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zipkart_firebase/UserData/Userdata.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late UserProvider userProvider;

  Future<User?> googleSignUp() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      final FirebaseAuth auth = FirebaseAuth.instance;

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final User? user = (await auth.signInWithCredential(credential)).user;
      // print("signed in " + user!.displayName);
      userProvider.addUserData(
        currentUser: user,
        userEmail: user?.email,
        userImage: user?.photoURL,
        userName: user?.displayName,
      );

      return user;
    } catch (e) {
      try {
        if (kIsWeb) {
          // Sign-in flow for web
          GoogleAuthProvider googleProvider = GoogleAuthProvider();

          try {
            UserCredential userCredential =
                await _auth.signInWithPopup(googleProvider);
            userProvider.addUserData(
              currentUser: userCredential.user,
              userEmail: userCredential.user?.email,
              userImage: userCredential.user?.photoURL,
              userName: userCredential.user?.displayName,
            );
            return userCredential.user;
          } catch (e) {
            // print("Error signing in with Google on Web: $e");
            return null;
          }
        }
      } catch (e) {}
    }
    return null;
  }

  // // Sign in with Google
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     // Start the Google sign-in process
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null; // User canceled the sign-in

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Authenticate with Firebase
  //     UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);
  //     User? user = userCredential.user;

  //     // Check if it's a new user and add to Firestore
  //     if (userCredential.additionalUserInfo?.isNewUser ?? false) {
  //       await _firestore.collection('users').doc(user?.uid).set({
  //         'id': user?.uid,
  //         'name': user?.displayName,
  //         'phone': user?.phoneNumber,
  //         'profile': user?.photoURL,
  //         'email': user?.email,
  //         'createdAt': FieldValue.serverTimestamp(),
  //       });
  //     }

  //     return user;
  //   } catch (e) {
  //     print("Google sign-in error: $e");
  //     return null;
  //   }
  // }

  // Sign in or create an account with Apple
  Future<User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential result = await _auth.signInWithCredential(oauthCredential);
      if (result.additionalUserInfo?.isNewUser ?? false) {
        print("New Apple account created!");
        // Handle additional setup for new users here, if needed
      }

      return result.user;
    } catch (e) {
      print('Apple sign-in error: $e');
      return null;
    }
  }

  // Sign up with Email and Password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("New Email account created!");
      // Handle additional setup for new users here, if needed

      return result.user;
    } catch (e) {
      print('Email sign-up error: $e');
      return null;
    }
  }

  // Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Email sign-in error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign-out error: $e');
    }
  }
}
