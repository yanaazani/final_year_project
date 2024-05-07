class User {
  int id = 0;
  String email = "";
  String username = "";
  String password = "";
  String country = "";
  String state = "";

  User(
    this.id,
    this.email,
    this.username,
    this.password,
    this.country,
    this.state,
  );

  User.fromJson(Map<String, dynamic> json) {
    id = json["id"]?.toInt() ?? 0;
    email = json["email"] ?? "";
    username = json["username"] ?? "";
    password = json["password"] ?? "";
    country = json["country"] ?? "";
    state = json["state"] ?? "";
  }

  int get _Id => id;
  set _Id(int value) => id = value;

  String get _username => username;
  set _username(String value) => username = value;

  String get _Email => email;
  set _Email(String value) => email = value;

  String get _password => password;
  set _password(String value) => password = value;

  String get _country => country;
  set _country(String value) => country = value;

  String get _state => state;
  set _state(String value) => state = value;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "username": username,
      "password": password,
      "country": country,
      "state": state,
    };
  }
}
