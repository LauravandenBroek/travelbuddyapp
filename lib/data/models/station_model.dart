class Station {
  final String code;
  final String name;

  Station({
    required this.code,
    required this.name,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}