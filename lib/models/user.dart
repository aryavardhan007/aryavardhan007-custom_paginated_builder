

class User {
  final String name;
  final String email;
  final String picture;

  User({required this.name, required this.email, required this.picture});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: "${json['name']['first']} ${json['name']['last']}",
      email: json['email'],
      picture: json['picture']['thumbnail'],
    );
  }
}
