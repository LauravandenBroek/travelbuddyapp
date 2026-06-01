class RegisterRequestModel {
  final String email;
  final String password;
  final String name;
  final DateTime birthDate;

  RegisterRequestModel({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'birthDate': birthDate.toIso8601String().split('T')[0], // Format as yyyy-MM-dd
    };
  }
}
