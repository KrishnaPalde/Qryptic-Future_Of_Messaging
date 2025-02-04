// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:encrypt/encrypt.dart';

// class EncryptionService {
//   static const _storage = FlutterSecureStorage();

//   // Generate or Retrieve AES Key
//   static Future<String> _getOrCreateAESKey() async {
//     const keyName = "secure_aes_key";
//     String? storedKey = await _storage.read(key: keyName);

//     if (storedKey == null) {
//       final key = Key.fromSecureRandom(32); // 256-bit AES Key
//       await _storage.write(key: keyName, value: base64Encode(key.bytes));
//       return base64Encode(key.bytes);
//     }
//     return storedKey;
//   }

//   // Correct Secure Storage Options
//   static AndroidOptions _androidOptions() => AndroidOptions(
//         encryptedSharedPreferences: true,
//       );

//   static IOSOptions _iosOptions() => const IOSOptions(
//         accountName:
//             "flutter_secure_storage_service", // ✅ Corrected iOS setting
//       );

//   // Encrypt and Store Quantum Key
//   static Future<void> storeQuantumKey(String quantumKey) async {
//     try {
//       // final aesKey = await _getOrCreateAESKey();
//       final aesKey = "3ie49LG70bR4NdUZTyvLtZ7n0csjISK8aLr+VEQJ3bA=";
//       final key = Key(base64Decode(aesKey));
//       final iv = IV.fromLength(12); // AES-GCM recommended IV size

//       final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
//       final encrypted = encrypter.encrypt(quantumKey, iv: iv);

//       print(aesKey);
//       print(quantumKey);
//       await _storage.write(
//         key: "quantum_key",
//         value: jsonEncode({
//           "ciphertext": base64Encode(encrypted.bytes),
//           "iv": base64Encode(iv.bytes),
//         }),
//         aOptions: _androidOptions(),
//         iOptions: _iosOptions(),
//       );
//       print("stored");
//     } catch (e) {
//       print(e);
//     }
//   }

//   // Retrieve and Decrypt Quantum Key
//   static Future<String?> getQuantumKey() async {
//     try {
//       // final aesKey = await _getOrCreateAESKey();
//       final aesKey = "3ie49LG70bR4NdUZTyvLtZ7n0csjISK8aLr+VEQJ3bA=";
//       final storedData = await _storage.read(key: "quantum_key");
//       print(storedData);
//       if (storedData == null) return null;

//       final key = Key(base64Decode(aesKey));
//       final jsonData = jsonDecode(storedData);
//       final iv = IV.fromBase64(jsonData["iv"]);
//       final cipherText = base64Decode(jsonData["ciphertext"]);

//       final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
//       final decrypted = encrypter.decrypt(Encrypted(cipherText), iv: iv);

//       return decrypted;
//     } catch (e) {
//       print(e);
//     }
//   }
// }

import 'dart:typed_data'; // For Uint8List
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const String iv = "81e51bc8add62ae9d18d89408e76f0d5";
  // Method to convert binary string to Uint8List
  static Uint8List binaryStringToBytes(String binary) {
    print(binary.length);
    if (binary.length != 256) {
      throw Exception("The binary key must be exactly 256 bits.");
    }

    int length = binary.length;
    List<int> bytes = [];
    for (int i = 0; i < length; i += 8) {
      bytes.add(int.parse(binary.substring(i, i + 8), radix: 2));
    }
    return Uint8List.fromList(bytes);
  }

  // Encrypt and Store Quantum Key
  static Future<void> storeQuantumKey(String qkey, String quantumKey) async {
    try {
      print("Storing Quantum Key: $qkey|$quantumKey");
      await _storage.write(
        key: qkey,
        value: quantumKey,
      );
      print("Quantum Key stored");
    } catch (e) {
      print("Error storing key: $e");
    }
  }

  // Retrieve Quantum Key
  static Future<Map<String, String>?> getQuantumKey(String qkey) async {
    try {
      Map<String, String> storedData = await _storage.readAll();
      return storedData;
    } catch (e) {
      print("Error retrieving key: $e");
    }
  }

  // Encrypt a message using the quantum key
  static Future<String?> encryptMessage(String qKey, String message) async {
    try {
      final quantumKey = await getQuantumKey(qKey);
      if (quantumKey == null) {
        print("No quantum key found.");
        return null;
      } else {
        print(quantumKey);
        print(quantumKey[qKey]);
      }

      // Convert the binary key to bytes (ensure it is 256 bits for AES-256 encryption)
      Uint8List keyBytes = binaryStringToBytes(quantumKey[qKey]!);

      // Ensure key length is correct (256 bits = 32 bytes for AES-256)
      if (keyBytes.length != 32) {
        throw Exception(
            'Invalid key length. AES requires 128, 192, or 256 bit keys.');
      }

      final key = encrypt.Key(keyBytes);
      final iv = encrypt.IV
          .fromBase16(EncryptionService.iv); // AES standard IV size (16 bytes)
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encrypted = encrypter.encrypt(message, iv: iv);
      return encrypted.base64;
    } catch (e) {
      print("Error encrypting message: $e");
      throw e; // Rethrow the exception if needed
    }
  }

  // Decrypt a message using the quantum key
  static Future<String?> decryptMessage(
      String qKey, String encryptedMessage) async {
    try {
      final quantumKey = await getQuantumKey(qKey);
      if (quantumKey == null) {
        print("No quantum key found.");
        return null;
      } else {
        print(quantumKey.keys);
        print(qKey);
        print(quantumKey['c8N4oVo9kpcP4q2OEPY6QhA3H832']);
      }

      // Convert the binary key to bytes
      Uint8List keyBytes = binaryStringToBytes(quantumKey[qKey]!);

      // Ensure key length is5 correct (256 bits = 32 bytes)
      if (keyBytes.length != 32) {
        throw Exception(
            'Invalid key length. AES requires 128, 192, or 256 bit keys.');
      }

      final key = encrypt.Key(keyBytes);
      final iv = encrypt.IV
          .fromBase16(EncryptionService.iv); // AES standard IV size (16 bytes)
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encryptedData = encrypt.Encrypted.fromBase64(encryptedMessage);
      final decrypted = encrypter.decrypt(encryptedData, iv: iv);

      return decrypted;
    } catch (e) {
      print("Error decrypting message: $e");
      throw e; // Rethrow the exception if needed
    }
  }
}
