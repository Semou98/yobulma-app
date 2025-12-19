import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with phone number
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Erreur de vérification');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP code
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      return null;
    }
  }

  // Register new user
  Future<UserModel?> register({
    required String phoneNumber,
    String? email,
    required String displayName,
    required UserRole role,
    String? password,
    String? boutiqueName,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    try {
      UserCredential? userCredential;

      // Create auth account
      if (email != null && password != null) {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Phone number registration (requires phone verification first)
        // This should be called after phone verification
        throw Exception('Phone registration requires verification first');
      }

      if (userCredential?.user == null) {
        return null;
      }

      // Create user document
      final user = UserModel(
        id: userCredential!.user!.uid,
        email: email,
        phoneNumber: phoneNumber,
        displayName: displayName,
        role: role,
        boutiqueName: boutiqueName,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore());

      return user;
    } catch (e) {
      return null;
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user data
  Future<bool> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update livreur location
  Future<bool> updateLivreurLocation({
    required String livreurId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('users').doc(livreurId).update({
        'location': GeoPoint(latitude, longitude),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

