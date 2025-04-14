class TokenResponse {
  final String token;
  final int expiresAt;

  TokenResponse({
    required this.token,
    required this.expiresAt,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'],
      expiresAt: json['expiresAt'],
    );
  }
} 