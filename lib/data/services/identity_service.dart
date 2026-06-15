import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IdentityService {
  final String baseUrl = '${dotenv.env['BASE_URL']}/identity';
  Future<Map<String, String>> fetchSessionData(String travellerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/start-verification'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'travellerId': travellerId, 
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['sessionId'] == null || data['ephemeralKeySecret'] == null) {
        throw Exception('Kritieke data ontbreekt in backend response!');
      }
      
      return {
        'sessionId': data['sessionId'],
        'ephemeralKeySecret': data['ephemeralKeySecret'],
      };
    } else {
      throw Exception('Backend faalde met statuscode: ${response.statusCode}');
    }
  }
}