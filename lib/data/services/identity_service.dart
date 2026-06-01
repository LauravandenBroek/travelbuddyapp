import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class IdentityService {
  final String baseUrl = "http://localhost:8080/api/identity";

  // 1. Parameter toegevoegd
  Future<void> startVerification(String travellerId) async {
    
    final response = await http.post(
      Uri.parse('$baseUrl/start-verification'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'travellerId': travellerId, // 2. Wordt nu direct uit de parameter gehaald
      }),
    );

    if (response.statusCode == 200) {
      final url = jsonDecode(response.body)['url'];
      await _launchURL(url);
    } else {
      throw Exception('Failed to start verification.');
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}