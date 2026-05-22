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

  // State variabelen
  List<TripAdvice> _tripAdvices = []; 
  bool _isLoading = false; 
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime.now().add(const Duration(days: 30)), 
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _search() async {
    setState(() { 
      _isLoading = true; 
    });

    try {
      // Bepaal de tijd die we naar de API sturen
      DateTime tijdOmTeZoeken;
      if (_selectedDate != null && _selectedTime != null) {
        tijdOmTeZoeken = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      } else {
        tijdOmTeZoeken = DateTime.now(); 
      }

      final results = await _tripAdviceService.fetchTripAdvice(
        _fromController.text.trim(),
        _toController.text.trim(),
        tijdOmTeZoeken, // Zorg dat je TripAdviceService deze 3e parameter verwacht!
      );

      if (!mounted) return;

      setState(() {
        _tripAdvices = results;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fout bij zoeken! Controleer je verbinding.')),
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
      appBar: AppBar(title: const Text('Zoek je reis')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column (
          children: [
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(labelText: 'Van station (bijv. UT)'),
            ),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(labelText: 'Naar station (bijv. Schiedam Centraal)'),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _selectedDate == null || _selectedTime == null
                          ? 'Vertrek: Nu' 
                          : 'Vertrek: ${_selectedDate!.day}-${_selectedDate!.month} om ${_selectedTime!.format(context)}',
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _selectedTime = null;
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _search,
              child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Zoek'),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _tripAdvices.length,
                itemBuilder: (context, index) {
                  final advice = _tripAdvices[index];

                  return ListTile(
                    leading: const Icon(Icons.train),
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