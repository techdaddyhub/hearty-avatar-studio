import 'dart:math';
import 'dart:typed_data';

/// RFC 7748 X25519 Elliptic Curve Diffie-Hellman (ECDH) Key Agreement
/// Used by Signal Protocol and WeChat E2EE for fast, secure key exchange.
class X25519 {
  static final BigInt _p = BigInt.two.pow(255) - BigInt.from(19);
  static final BigInt _a24 = BigInt.from(121665);

  /// Generate a cryptographically secure 32-byte private key with RFC 7748 clamping
  static Uint8List generatePrivateKey() {
    final rng = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      bytes[i] = rng.nextInt(256);
    }
    bytes[0] &= 248;
    bytes[31] &= 127;
    bytes[31] |= 64;
    return bytes;
  }

  /// Derive the 32-byte public key from a private key using the base point (9)
  static Uint8List scalarMultBase(Uint8List scalar) {
    final basePoint = Uint8List(32);
    basePoint[0] = 9;
    return scalarMult(scalar, basePoint);
  }

  /// Perform scalar multiplication: result = scalar * uCoordinate
  static Uint8List scalarMult(Uint8List scalar, Uint8List uCoordinate) {
    final clamped = Uint8List.fromList(scalar);
    clamped[0] &= 248;
    clamped[31] &= 127;
    clamped[31] |= 64;

    BigInt k = _decodeScalar(clamped);
    BigInt x1 = _decodeUCoordinate(uCoordinate);

    BigInt x2 = BigInt.one;
    BigInt z2 = BigInt.zero;
    BigInt x3 = x1;
    BigInt z3 = BigInt.one;
    int swap = 0;

    for (int t = 254; t >= 0; t--) {
      int kt = (k >> t).isOdd ? 1 : 0;
      swap ^= kt;
      if (swap != 0) {
        var tmp = x2; x2 = x3; x3 = tmp;
        tmp = z2; z2 = z3; z3 = tmp;
      }
      swap = kt;

      BigInt a = (x2 + z2) % _p;
      BigInt aa = (a * a) % _p;
      BigInt b = (x2 - z2) % _p;
      BigInt bb = (b * b) % _p;
      BigInt e = (aa - bb) % _p;
      BigInt c = (x3 + z3) % _p;
      BigInt d = (x3 - z3) % _p;
      BigInt da = (d * a) % _p;
      BigInt cb = (c * b) % _p;

      x3 = ((da + cb) * (da + cb)) % _p;
      z3 = (x1 * ((da - cb) * (da - cb))) % _p;
      x2 = (aa * bb) % _p;
      z2 = (e * (aa + (_a24 * e) % _p)) % _p;
    }

    if (swap != 0) {
      var tmp = x2; x2 = x3; x3 = tmp;
      tmp = z2; z2 = z3; z3 = tmp;
    }

    BigInt result = (x2 * _modInverse(z2, _p)) % _p;
    return _encodeUCoordinate(result);
  }

  static BigInt _decodeScalar(Uint8List k) {
    BigInt res = BigInt.zero;
    for (int i = 31; i >= 0; i--) {
      res = (res << 8) | BigInt.from(k[i]);
    }
    return res;
  }

  static BigInt _decodeUCoordinate(Uint8List u) {
    BigInt res = BigInt.zero;
    for (int i = 31; i >= 0; i--) {
      res = (res << 8) | BigInt.from(u[i]);
    }
    return res % _p;
  }

  static Uint8List _encodeUCoordinate(BigInt val) {
    var v = val % _p;
    if (v.isNegative) v += _p;
    final res = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      res[i] = (v & BigInt.from(0xff)).toInt();
      v >>= 8;
    }
    return res;
  }

  static BigInt _modInverse(BigInt n, BigInt m) {
    return n.modInverse(m);
  }
}
