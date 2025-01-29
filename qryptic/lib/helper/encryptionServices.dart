import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final Key key = Key.fromUtf8('16charssecretkey'); // Temporary key
  final IV iv = IV.fromLength(16);

  String encrypt(String plainText) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
