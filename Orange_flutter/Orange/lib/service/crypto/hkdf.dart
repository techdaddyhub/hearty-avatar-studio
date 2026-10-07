import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// RFC 5869 HMAC-based Extract-and-Expand Key Derivation Function (HKDF)
/// Used in Signal Protocol / Double Ratchet for deriving root, chain, and message keys.
class HKDF {
  /// HKDF-Extract: PRK = HMAC-Hash(salt, IKM)
  static Uint8List extract({Uint8List? salt, required Uint8List ikm}) {
    final effectiveSalt = salt ?? Uint8List(32); // 32 zeros for SHA-256
    final hmac = Hmac(sha256, effectiveSalt);
    return Uint8List.fromList(hmac.convert(ikm).bytes);
  }

  /// HKDF-Expand: OKM = HMAC-Hash(PRK, info || 0x01) || ...
  static Uint8List expand({
    required Uint8List prk,
    Uint8List? info,
    required int length,
  }) {
    final effectiveInfo = info ?? Uint8List(0);
    final n = (length / 32).ceil();
    final hmac = Hmac(sha256, prk);
    final okm = BytesBuilder();
    var previousT = Uint8List(0);

    for (int i = 1; i <= n; i++) {
      final input = BytesBuilder();
      input.add(previousT);
      input.add(effectiveInfo);
      input.addByte(i);
      previousT = Uint8List.fromList(hmac.convert(input.toBytes()).bytes);
      okm.add(previousT);
    }

    return Uint8List.fromList(okm.toBytes().sublist(0, length));
  }

  /// Full HKDF Extract & Expand pipeline
  static Uint8List deriveKey({
    Uint8List? salt,
    required Uint8List ikm,
    Uint8List? info,
    required int length,
  }) {
    final prk = extract(salt: salt, ikm: ikm);
    return expand(prk: prk, info: info, length: length);
  }
}
