class Staff {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  Staff({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }
}
