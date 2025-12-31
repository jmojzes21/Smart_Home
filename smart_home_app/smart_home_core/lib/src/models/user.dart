class User {
  String username;
  String firstName;
  String lastName;

  User({required this.username, required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(username: json['username'], firstName: json['first_name'], lastName: json['last_name']);
  }
}
