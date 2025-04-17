import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:pointycastle/export.dart';

class AESHelper {
  static final _random = Random.secure();
  static const int _ivLength = 16; // AES block size
  static const int _keyLength = 32; // 256 bits

  // Generate a secure key from password using PBKDF2
  static Uint8List deriveKeyFromPassword(String password, Uint8List salt,
      {int iterations = 10000}) {
    final pbkdf2Params = Pbkdf2Parameters(salt, iterations, _keyLength);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(pbkdf2Params);

    final passwordBytes = utf8.encode(password);
    return pbkdf2.process(Uint8List.fromList(passwordBytes));
  }

  static Uint8List generateSalt() {
    return Uint8List.fromList(
        List<int>.generate(16, (_) => _random.nextInt(256)));
  }

  static Uint8List generateIV() {
    return Uint8List.fromList(
        List<int>.generate(_ivLength, (_) => _random.nextInt(256)));
  }

  // Encrypts the file and prepends Salt + IV to the result
  static Uint8List encryptFile(Uint8List fileBytes, String password) {
    try {
      final salt = generateSalt();
      final key = deriveKeyFromPassword(password, salt);
      final iv = generateIV();

      // Setup cipher parameters
      final params = PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(key), iv), null);

      // Create and initialize the cipher
      final cipher = PaddedBlockCipher("AES/CBC/PKCS7")..init(true, params);

      // Process the file data
      final encrypted = cipher.process(fileBytes);

      // Create the final output with salt + iv + encrypted data
      final result = Uint8List(salt.length + iv.length + encrypted.length);
      result.setRange(0, salt.length, salt);
      result.setRange(salt.length, salt.length + iv.length, iv);
      result.setRange(salt.length + iv.length, result.length, encrypted);

      return result;
    } catch (e) {
      print('Encryption error: $e');
      rethrow;
    }
  }

  static Uint8List decryptFile(Uint8List encryptedBytes, String password) {
    try {
      // Ensure we have enough data (salt + iv + at least some encrypted content)
      if (encryptedBytes.length <= 32) {
        throw Exception('Invalid encrypted data: too short');
      }

      // Extract the salt, IV and encrypted data
      final salt = encryptedBytes.sublist(0, 16);
      final iv = encryptedBytes.sublist(16, 32);
      final encryptedData = encryptedBytes.sublist(32);

      // Derive the key using the same method as during encryption
      final key = deriveKeyFromPassword(password, salt);

      // Setup cipher parameters
      final params = PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(key), iv), null);

      // Create and initialize the cipher for decryption
      final cipher = PaddedBlockCipher("AES/CBC/PKCS7")..init(false, params);

      // Decrypt the data
      return cipher.process(encryptedData);
    } catch (e) {
      print('Decryption error: $e');
      rethrow;
    }
  }
}
