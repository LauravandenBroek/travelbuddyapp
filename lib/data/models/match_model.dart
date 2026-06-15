// match_model.dart

enum MatchStatus {
  pending,
  accepted,
  rejected,
  canceled;

  static MatchStatus fromString(String status) {
    return MatchStatus.values.firstWhere(
      (e) =>  e.toString().split('.').last == status,
      orElse: () => MatchStatus.pending,
    );
  }
}

class MatchResult {
  final int? matchId; 
  final MatchStatus status;
  final String buddyName;

  MatchResult({
    required this.matchId,
    required this.status,
    required this.buddyName,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      matchId: json['matchId'] as int?,
      status: MatchStatus.fromString(json['status'] ?? 'pending'),
      buddyName: json['buddyName'] ?? 'Anoniem',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'status': status.toString().split('.').last, 
      'buddyName': buddyName,
    };
  }
}