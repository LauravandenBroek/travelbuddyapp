class Traveller {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? stripeSessionId;
  final String verificationStatus;

  Traveller({
    required this.id,
    required this.name,
    required this.birthDate,
    this.stripeSessionId,
    required this.verificationStatus,
  });

  factory Traveller.fromJson(Map<String, dynamic> json) {
    return Traveller(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      stripeSessionId: json['stripeSessionId'],
      verificationStatus: json['verificationStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'stripeSessionId': stripeSessionId,
      'verificationStatus': verificationStatus,
    };
  }
}
