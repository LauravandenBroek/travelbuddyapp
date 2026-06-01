import 'package:travelbuddyapp/data/models/traveller_model.dart';

class LoginResponseModel {
  final String token;
  final Traveller traveller;

  LoginResponseModel({
    required this.token,
    required this.traveller,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'],
      traveller: Traveller.fromJson(json['traveller']),
    );
  }
}
