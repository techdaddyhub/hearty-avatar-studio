import 'dart:typed_data';

/// Pure Dart AES-256 (FIPS-197) Implementation
/// Used for zero-knowledge end-to-end symmetric encryption of messages and media blobs.
class AES256 {
  static const int keySize = 32; // 256 bits
  static const int blockSize = 16; // 128 bits
  static const int rounds = 14;

  static final List<int> _sBox = [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5e, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
  ];

  static final List<int> _rCon = [
    0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36
  ];

  static Uint32List keyExpansion(Uint8List key) {
    if (key.length != 32) throw ArgumentError('Key must be 32 bytes (256 bits)');
    final w = Uint32List(4 * (rounds + 1));
    for (int i = 0; i < 8; i++) {
      w[i] = (key[4 * i] << 24) |
          (key[4 * i + 1] << 16) |
          (key[4 * i + 2] << 8) |
          key[4 * i + 3];
    }
    for (int i = 8; i < w.length; i++) {
      int temp = w[i - 1];
      if (i % 8 == 0) {
        temp = _subWord(_rotWord(temp)) ^ (_rCon[i ~/ 8] << 24);
      } else if (i % 8 == 4) {
        temp = _subWord(temp);
      }
      w[i] = w[i - 8] ^ temp;
    }
    return w;
  }

  static int _rotWord(int w) => ((w << 8) | ((w >> 24) & 0xff)) & 0xffffffff;

  static int _subWord(int w) {
    return ((_sBox[(w >> 24) & 0xff] << 24) |
        (_sBox[(w >> 16) & 0xff] << 16) |
        (_sBox[(w >> 8) & 0xff] << 8) |
        _sBox[w & 0xff]) &
        0xffffffff;
  }

  static void encryptBlock(Uint32List w, Uint8List input, int inOff, Uint8List output, int outOff) {
    final state = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      state[i] = input[inOff + i];
    }

    _addRoundKey(state, w, 0);

    for (int round = 1; round < rounds; round++) {
      _subBytes(state);
      _shiftRows(state);
      _mixColumns(state);
      _addRoundKey(state, w, round);
    }

    _subBytes(state);
    _shiftRows(state);
    _addRoundKey(state, w, rounds);

    for (int i = 0; i < 16; i++) {
      output[outOff + i] = state[i];
    }
  }

  static void _addRoundKey(Uint8List state, Uint32List w, int round) {
    for (int c = 0; c < 4; c++) {
      final keyWord = w[round * 4 + c];
      state[c * 4] ^= (keyWord >> 24) & 0xff;
      state[c * 4 + 1] ^= (keyWord >> 16) & 0xff;
      state[c * 4 + 2] ^= (keyWord >> 8) & 0xff;
      state[c * 4 + 3] ^= keyWord & 0xff;
    }
  }

  static void _subBytes(Uint8List state) {
    for (int i = 0; i < 16; i++) {
      state[i] = _sBox[state[i]];
    }
  }

  static void _shiftRows(Uint8List state) {
    int temp = state[1];
    state[1] = state[5]; state[5] = state[9]; state[9] = state[13]; state[13] = temp;

    temp = state[2];
    state[2] = state[10]; state[10] = temp;
    temp = state[6];
    state[6] = state[14]; state[14] = temp;

    temp = state[15];
    state[15] = state[11]; state[11] = state[7]; state[7] = state[3]; state[3] = temp;
  }

  static int _xt(int b) => (((b << 1) ^ (((b >> 7) & 1) * 0x1b)) & 0xff);

  static void _mixColumns(Uint8List s) {
    for (int c = 0; c < 4; c++) {
      final idx = c * 4;
      final a0 = s[idx], a1 = s[idx + 1], a2 = s[idx + 2], a3 = s[idx + 3];
      final t = a0 ^ a1 ^ a2 ^ a3;
      final u0 = a0;
      s[idx] = a0 ^ _xt(a0 ^ a1) ^ t;
      s[idx + 1] = a1 ^ _xt(a1 ^ a2) ^ t;
      s[idx + 2] = a2 ^ _xt(a2 ^ a3) ^ t;
      s[idx + 3] = a3 ^ _xt(a3 ^ u0) ^ t;
    }
  }

  /// CTR Mode Stream Cipher (symmetric encrypt/decrypt)
  static Uint8List processCtr({required Uint8List key, required Uint8List iv, required Uint8List data}) {
    if (iv.length != 16) throw ArgumentError('IV must be 16 bytes for AES-CTR');
    final w = keyExpansion(key);
    final counter = Uint8List.fromList(iv);
    final keystream = Uint8List(16);
    final out = Uint8List(data.length);

    for (int i = 0; i < data.length; i += 16) {
      encryptBlock(w, counter, 0, keystream, 0);
      final blockSize = (i + 16 <= data.length) ? 16 : data.length - i;
      for (int b = 0; b < blockSize; b++) {
        out[i + b] = data[i + b] ^ keystream[b];
      }
      // Increment 128-bit big-endian counter
      for (int c = 15; c >= 0; c--) {
        counter[c] = (counter[c] + 1) & 0xff;
        if (counter[c] != 0) break;
      }
    }
    return out;
  }
}

