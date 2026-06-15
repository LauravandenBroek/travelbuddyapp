import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/travel_request_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TravelRequestService {
    final String baseUrl = '${dotenv.env['BASE_URL']}/travel-requests';


  Future<void> createTravelRequest(TravelRequestModel model) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(model.toJson()), 
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Travel request succesvol aangemaakt!');
    } 
    else {
      throw Exception('Is je identiteit al geverifieerd?');
    }
  }

  Future<List<TravelRequestModel>> fetchTravelRequests(String travellerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl?travellerId=$travellerId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TravelRequestModel.fromJson(json)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Fout bij ophalen reisverzoeken: ${errorBody['message'] ?? response.statusCode}');
    }
  }
}