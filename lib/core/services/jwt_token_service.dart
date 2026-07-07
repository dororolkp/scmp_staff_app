import 'dart:convert';

import 'package:crypto/crypto.dart';

class JwtTokenService {
  static const String _secret = 'scmp_staff_app_local_secret';

  static String issueToken({
    required int userId,
    required String email,
    Duration expiresIn = const Duration(hours: 8),
  }) {
    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };
    final now = DateTime.now().toUtc();
    final payload = {
      'sub': userId,
      'email': email,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(expiresIn).millisecondsSinceEpoch ~/ 1000,
    };

    final encodedHeader = _encodeSegment(header);
    final encodedPayload = _encodeSegment(payload);
    final signature = _sign('$encodedHeader.$encodedPayload');
    return '$encodedHeader.$encodedPayload.$signature';
  }

  static Map<String, dynamic>? verifyToken(String token) {
    final segments = token.split('.');
    if (segments.length != 3) {
      return null;
    }

    final expectedSignature = _sign('${segments[0]}.${segments[1]}');
    if (expectedSignature != segments[2]) {
      return null;
    }

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(segments[1]))),
    );
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    final exp = payload['exp'];
    if (exp is! int) {
      return null;
    }

    final nowInSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    if (exp <= nowInSeconds) {
      return null;
    }

    return payload;
  }

  static String _encodeSegment(Map<String, dynamic> data) {
    final encoded = base64Url.encode(utf8.encode(jsonEncode(data)));
    return encoded.replaceAll('=', '');
  }

  static String _sign(String input) {
    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode(input));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
