import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/Models/UserDetails.dart';
import 'package:zipkart_firebase/providers/auth_provider.dart';

// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider to fetch user data from Firestore
final userDataProvider = StreamProvider.family<UserDetails?, String>((ref, userId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('usersData')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        return UserDetails(
          userEmail: data['userEmail'] ?? '',
          userImage: data['userImage'] ?? '',
          userName: data['userName'] ?? '',
          userUid: data['userUid'] ?? '',
        );
      }
    }
    return null;
  });
});

// Provider for current user's data
final currentUserDataProvider = StreamProvider<UserDetails?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value(null);
  }
  
  return ref.watch(userDataProvider(currentUser.uid).stream);
});

// Function to add/update user data in Firestore
Future<void> addUserData({
  required Ref ref,
  required User currentUser,
  String? userName,
  String? userImage,
  String? userEmail,
}) async {
  final firestore = ref.read(firestoreProvider);
  
  await firestore.collection('usersData').doc(currentUser.uid).set({
    'userName': userName,
    'userEmail': userEmail,
    'userImage': userImage,
    'userUid': currentUser.uid,
  });
}
