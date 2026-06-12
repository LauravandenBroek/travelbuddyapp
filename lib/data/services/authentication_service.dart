import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelbuddyapp/data/models/login_response_model.dart';
import '../models/register_request_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AuthenticationService {
  final String baseUrl = '${dotenv.env['BASE_URL']}/auth';

  Future<void> register(RegisterRequestModel registerRequest) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(registerRequest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to register.');
    }
  }

  Future<LoginResponseModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login.');
    }
  }
}