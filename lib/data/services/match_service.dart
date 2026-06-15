import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/match_model.dart';

class MatchService {
  final String baseUrl = '${dotenv.env['BASE_URL']}/matches'; 

  Future<List<MatchResult>> fetchMatches(String travellerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/traveller/$travellerId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MatchResult.fromJson(json)).toList();
    } else {
      throw Exception('Fout bij ophalen matches: ${response.statusCode}');
    }
  }
}