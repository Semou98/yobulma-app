import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/enums.dart';

class UserRepository {
  final AuthService _authService = AuthService();

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    return await _authService.getUserData(user.uid);
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    return await _authService.getUserData(userId);
  }

  // Update user
  Future<bool> updateUser(UserModel user) async {
    return await _authService.updateUserData(user);
  }

  // Update livreur location
  Future<bool> updateLivreurLocation({
    required String livreurId,
    required double latitude,
    required double longitude,
  }) async {
    return await _authService.updateLivreurLocation(
      livreurId: livreurId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Auth state stream
  Stream<User?> get authStateChanges => _authService.authStateChanges;
}

