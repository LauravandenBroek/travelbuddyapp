class TripAdvice {
  final String tripId;
  final String departureTime;
  final String departureTrack;
  final String arrivalTime;
  final String status; 

  TripAdvice({
    required this.tripId,
    required this.departureTime,
    required this.departureTrack,
    required this.arrivalTime,
    required this.status,
  });
  factory TripAdvice.fromJson(Map<String, dynamic> json) {
    return TripAdvice(
      tripId: json['tripId'] as String,
      departureTime: json['departureTime'] as String,
      departureTrack: json['departureTrack'] as String,
      arrivalTime: json['arrivalTime'] as String,
      status: json['status'] as String,
    );
  }
}
