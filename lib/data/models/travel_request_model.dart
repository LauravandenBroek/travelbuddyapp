class TravelRequestModel {
  final String travellerId;
  final String departureStation;
  final String arrivalStation;
  final DateTime departureTime;
  final String nsTripId;

  TravelRequestModel({
    required this.travellerId,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.nsTripId,
  });

  factory TravelRequestModel.fromJson(Map<String, dynamic> json) {
    return TravelRequestModel(
      travellerId: json['travellerId'] ?? '',
      departureStation: json['departureStation'] ?? '',
      arrivalStation: json['arrivalStation'] ?? '',
      departureTime: DateTime.parse(json['departureTime']),
      nsTripId: json['nsTripId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travellerId': travellerId,
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
      'departureTime': departureTime.toIso8601String(), 
      'nsTripId': nsTripId,
    };
  }
}