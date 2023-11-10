class SignInResponse {
  String? kind;
  bool? registered;
  String? localId;
  String? email;
  String? idToken;
  String? refreshToken;
  String? expiresIn;

  SignInResponse(
      {this.kind, this.registered, this.localId, this.email, this.idToken, this.refreshToken, this.expiresIn});

  SignInResponse.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    registered = json['registered'];
    localId = json['localId'];
    email = json['email'];
    idToken = json['idToken'];
    refreshToken = json['refreshToken'];
    expiresIn = json['expiresIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kind'] = kind;
    data['registered'] = registered;
    data['localId'] = localId;
    data['email'] = email;
    data['idToken'] = idToken;
    data['refreshToken'] = refreshToken;
    data['expiresIn'] = expiresIn;
    return data;
  }
}
