import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Request permission for notifications
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Save token to user document
  Future<void> saveTokenToUser(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'updatedAt': Timestamp.now(),
    });
  }

  // Send notification to user (via Cloud Functions or backend)
  // This is a placeholder - actual implementation would call a backend API
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // In a real implementation, this would call a backend API
    // or use Firebase Cloud Functions to send the notification
    // For now, we'll just log it
    print('Sending notification to $userId: $title - $body');
  }

  // Send SMS notification (would integrate with SMS service)
  Future<void> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    // This would integrate with an SMS service provider
    // For MVP, this is a placeholder
    print('Sending SMS to $phoneNumber: $message');
  }

  // Send OTP via SMS
  Future<void> sendOTPviaSMS({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final message = 'Votre code OTP YOBULMA est: $otpCode. Valide pendant 15 minutes.';
    await sendSMS(phoneNumber: phoneNumber, message: message);
  }
}

