import 'package:encrypt/encrypt.dart';

class SecurityService {
  // กุญแจลับ 32 ตัวอักษร (AES-256)
  static const String _passphrase = "SAUMU_LUCKY_SECURE_2026_GEMINI_A"; 
  // IV ลับ 16 ตัวอักษร (ต้องตรงกันทั้งตอนเข้ารหัสและถอดรหัส)
  static const String _ivString = "SAUMU_LUCKY_IV16"; 

  static final _key = Key.fromUtf8(_passphrase);
  static final _iv = IV.fromUtf8(_ivString);

  /// ใช้สำหรับถอดรหัส API Key ที่ดึงมาจาก Sheet
  static String decryptKey(String encryptedBase64) {
    try {
      final encrypter = Encrypter(AES(_key));
      final decrypted = encrypter.decrypt64(encryptedBase64, iv: _iv);
      return decrypted;
    } catch (e) {
      print("SECURITY_ERROR: Decryption Failed. Details: $e");
      return "ERROR_DECRYPTING";
    }
  }

  /// ใช้สำหรับ "คุณ" เพื่อสร้างรหัสไปแปะใน Google Sheet
  /// ให้เรียกใช้ตัวนี้ในโหมด Debug เพื่อเอารหัสลับ
  static String encryptKey(String rawKey) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(rawKey, iv: _iv);
    return encrypted.base64;
  }
}
