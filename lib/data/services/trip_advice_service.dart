import 'dart:convert';
import '../models/trip_advice_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class TripAdviceService {

  final String baseUrl = dotenv.env['BASE_URL']!; 

  // Future is een async functie bij flutter, het geeft aan dat deze functie asynchroon is en een waarde zal teruggeven in de toekomst (in dit geval een lijst van TripAdvice)
  Future<List<TripAdvice>> fetchTripAdvice(String from, String to, DateTime dateTime) async {
    // Uri.encodeComponent zorgt ervoor dat speciale tekens in de locatie (zoals spaties) correct worden gecodeerd in de URL
    // Bijvoorbeeld, "Amsterdam Centraal" wordt "Amsterdam%20Centraal" 
    final String encodedFrom = Uri.encodeComponent(from);
    final String encodedTo = Uri.encodeComponent(to);
    final String encodedDateTime = Uri.encodeComponent(dateTime.toIso8601String());

    // de volledige url voor de api call, met de geëncodeerde locaties als query parameters
    final String url = '$baseUrl/trips/advice?from=$encodedFrom&to=$encodedTo&dateTime=$encodedDateTime';

    // de api call zelf
    final response = await http.get(Uri.parse(url));
    // als de respone goed is, zet dan de json data om in een lijst van trip adviezen
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => TripAdvice.fromJson(json)).toList();

      // Als het niet goed gaat, gooi een foutmelding.
    } else {
      throw Exception('Failed to load trip advice');
    }
  }
}