class Usuario {
  final String uid;
  final String email;
  final String nombreUsuario;
  final int colorFavorito;
  final int highScore;

  Usuario({
    required this.uid,
    required this.email,
    this.nombreUsuario = '',
    this.colorFavorito = 0xFFFF0000,
    this.highScore = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombreUsuario': nombreUsuario,
      'colorFavorito': colorFavorito,
      'highScore': highScore,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map, String uid) {
    return Usuario(
      uid: uid,
      email: map['email'] ?? '',
      nombreUsuario: map['nombreUsuario'] ?? '',
      colorFavorito: map['colorFavorito'] ?? 0xFFFF0000,
      highScore: map['highScore'] ?? 0,
    );
  }

  Usuario copyWith({
    String? nombreUsuario,
    int? colorFavorito,
    int? highScore,
  }) {
    return Usuario(
      uid: uid,
      email: email,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      colorFavorito: colorFavorito ?? this.colorFavorito,
      highScore: highScore ?? this.highScore,
    );
  }
}
