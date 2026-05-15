import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/trip_advice_model.dart';
import '../data/services/trip_advice_service.dart';

class TripSearchScreen extends StatefulWidget {
  const TripSearchScreen({super.key});
  @override
  State<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen>  {
  // Controllers for text fields
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  final TripAdviceService _tripAdviceService = TripAdviceService();

  // State viariabelen om de trip adviezen en eventuele foutmeldingen op te slaan
  // elke keer we setstate aanroepen en deze aanpassen, tekent flutter het scherm opnieuw 
  List<TripAdvice> _tripAdvices = []; //De ns adviezen uit de api
  bool _isLoading = false; 

  Future<void> _search() async {
    setState(() { 
      _isLoading = true; 
    });

    try {
      final results = await _tripAdviceService.fetchTripAdvice(
        _fromController.text.trim(),
        _toController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _tripAdvices = results;
      });
    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij zoeken! Controleer je verbinding.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
      }
    }
  }

  String _formatTime(String rawTime) {
    try {
      DateTime parsedTime = DateTime.parse(rawTime);
      
      return DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      return rawTime; 
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zoek je reis')), //appbar is de fixed balk bovenaan in de app
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column (
          children: [
            TextField(
              controller: _fromController,
              decoration: InputDecoration(labelText: 'Van station (bijv. UT)'),
            ),
            TextField(
              controller: _toController,
              decoration: InputDecoration(labelText: 'Naar station (bijv. Schiedam Centraal)'),
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _search,
                
              child: _isLoading 
              ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Zoek'),
            ),

            SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _tripAdvices.length,
                itemBuilder: (context, index) {
                  final advice = _tripAdvices[index];

                  return ListTile(
                    leading: Icon(Icons.train),
                    title: Text('${_formatTime(advice.departureTime)} - ${_formatTime(advice.arrivalTime)}'),
                    subtitle: Text('Spoor ${advice.departureTrack}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

