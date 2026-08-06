import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Encrypts scanned document images/PDFs (driver's licence, registration,
/// insurance, etc.) at rest. Isar (the version this app is on, v3) has no
/// native database encryption — the sensitive payload here is the
/// photographed document files, not the surrounding title/description
/// metadata, so encryption is applied at the file layer instead.
class DocumentFileCrypto {
  DocumentFileCrypto._();

  static const _secureStorage = FlutterSecureStorage();
  static const _keyStorageKey = 'document_vault_aes_key_v1';
  static enc.Key? _cachedKey;

  static Future<enc.Key> _getOrCreateKey() async {
    final cached = _cachedKey;
    if (cached != null) return cached;
    final existing = await _secureStorage.read(key: _keyStorageKey);
    if (existing != null) {
      final key = enc.Key(base64Decode(existing));
      _cachedKey = key;
      return key;
    }
    final key = enc.Key.fromSecureRandom(32);
    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64Encode(key.bytes),
    );
    _cachedKey = key;
    return key;
  }

  /// Encrypts [sourceFile]'s bytes into a new file under the app's
  /// documents directory, deletes the plaintext source, and returns the
  /// new file's path (what gets persisted as `imagePath`).
  static Future<String> encryptIntoVault(File sourceFile) async {
    final key = await _getOrCreateKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final plainBytes = await sourceFile.readAsBytes();
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

    final dir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${dir.path}/document_vault');
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_${sourceFile.uri.pathSegments.last}.enc';
    final destFile = File('${vaultDir.path}/$fileName');
    // IV (16 bytes) is prefixed to the ciphertext so each file is
    // self-contained for decryption.
    await destFile.writeAsBytes([...iv.bytes, ...encrypted.bytes]);

    try {
      if (await sourceFile.exists()) {
        await sourceFile.delete();
      }
    } catch (_) {
      // Best-effort cleanup of the picker's temp copy; not fatal if the OS
      // cache file lingers.
    }

    return destFile.path;
  }

  /// Decrypts a file written by [encryptIntoVault]. Returns null if it
  /// can't be decrypted (e.g. a pre-encryption legacy plaintext file, or a
  /// missing/corrupt file) so callers can fall back to treating [path] as
  /// a plain file instead of crashing.
  static Future<Uint8List?> decrypt(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.length <= 16) return null;
      final key = await _getOrCreateKey();
      final iv = enc.IV(Uint8List.fromList(bytes.sublist(0, 16)));
      final ciphertext = Uint8List.fromList(bytes.sublist(16));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(
        enc.Encrypted(ciphertext),
        iv: iv,
      );
      return Uint8List.fromList(decrypted);
    } catch (_) {
      return null;
    }
  }
}
