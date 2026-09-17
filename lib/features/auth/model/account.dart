class Account {
  const Account({required this.email, required this.password});

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    email: json['email'] as String,
    password: json['password'] as String,
  );

  final String email;
  final String password;

  bool matches(String email, String password) =>
      this.email.toLowerCase() == email.trim().toLowerCase() &&
      this.password == password;
}
