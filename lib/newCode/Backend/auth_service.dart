// // lib/Backend/auth_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// /// A service class to handle all Firebase Authentication and Firestore-related
// /// user data interactions.
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// Signs in a user with email and password.
//   /// Throws a [FirebaseAuthException] on failure.
//   Future<User?> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//       return userCredential.user;
//     } on FirebaseAuthException {
//       rethrow;
//     }
//   }

//   /// Creates a new user with email and password and saves user data to Firestore.
//   /// Throws a [FirebaseAuthException] on failure.
//   Future<User?> signUpUser({
//     required String email,
//     required String password,
//     required Map<String, dynamic> userData,
//   }) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );

//       User? user = userCredential.user;
//       if (user != null) {
//         // Send email verification to the new user.
//         await sendEmailVerification();
//         // Save the provided user data to Firestore under their UID.
//         await _firestore.collection('users').doc(user.uid).set(userData);
//       }
//       return user;
//     } on FirebaseAuthException {
//       rethrow;
//     }
//   }

//   /// Sends a password reset email to the specified email address.
//   /// Throws a [FirebaseAuthException] on failure.
//   Future<void> sendPasswordResetEmail(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//     } on FirebaseAuthException {
//       rethrow;
//     }
//   }

//   /// Sends a verification email to the currently authenticated user.
//   /// This method is now **reusable** and can be called from any part of the app.
//   Future<void> sendEmailVerification() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       await user.sendEmailVerification();
//     }
//   }

//   /// Checks if a user's document exists in the Firestore database.
//   Future<bool> doesUserExist(String uid) async {
//     DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
//     return userDoc.exists;
//   }

//   /// Signs out the currently authenticated user.
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }
