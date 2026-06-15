import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/station_model.dart';

class StationService {
  final String baseUrl = '${dotenv.env['BASE_URL']}/stations'; 

  Future<List<Station>> fetchStations() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Station.fromJson(json)).toList();
    } else {
      throw Exception('Fout bij ophalen stations: ${response.statusCode}');
    }
  }
}