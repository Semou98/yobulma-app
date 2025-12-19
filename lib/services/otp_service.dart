import 'dart:math';
import '../utils/constants.dart';

class OTPService {
  // Generate random OTP code
  static String generateOTP() {
    final random = Random();
    final buffer = StringBuffer();
    
    for (int i = 0; i < AppConstants.otpLength; i++) {
      buffer.write(random.nextInt(10));
    }
    
    return buffer.toString();
  }

  // Validate OTP code
  static bool validateOTP(String providedOTP, String expectedOTP) {
    return providedOTP.trim() == expectedOTP.trim();
  }

  // Check if OTP is expired
  static bool isOTPExpired(DateTime? expiresAt) {
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }

  // Get expiration time
  static DateTime getOTPExpiration() {
    return DateTime.now().add(
      Duration(minutes: AppConstants.otpExpirationMinutes),
    );
  }
}

