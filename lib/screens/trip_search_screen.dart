import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelbuddyapp/widgets/side_menu.dart';
import '../data/models/trip_advice_model.dart';
import '../data/models/travel_request_model.dart';
import '../data/models/station_model.dart'; 
import '../data/services/trip_advice_service.dart';
import '../data/services/travel_request_service.dart';
import '../data/services/station_service.dart'; 

class TripSearchScreen extends StatefulWidget {
  const TripSearchScreen({super.key});

  @override
  State<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  // Services
  final TripAdviceService _tripAdviceService = TripAdviceService();
  final TravelRequestService _travelRequestService = TravelRequestService();
  final StationService _stationService = StationService();

  List<TripAdvice> _tripAdvices = []; 
  bool _isLoading = false; 
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<Station> _stations = [];
  bool _isLoadingStations = true;
  String? _fromStationCode;
  String? _toStationCode;

  @override
  void initState() {
    super.initState();
    _loadStations(); 
  }

  Future<void> _loadStations() async {
    try {
      final fetchedStations = await _stationService.fetchStations();
      if (mounted) {
        setState(() {
          _stations = fetchedStations;
          _isLoadingStations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoadingStations = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kon stationslijst niet laden. Check je backend.')),
        );
      }
    }
  }

  String _getStationName(String? code) {
    if (code == null) return '';
    final station = _stations.firstWhere(
      (s) => s.code == code,
      orElse: () => Station(code: code, name: code), 
    );
    return station.name;
  }

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
    if (_fromStationCode == null || _toStationCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies a.u.b. geldige vertrek- en aankomststations uit de suggesties.')),
      );
      return;
    }

    setState(() { 
      _isLoading = true; 
    });

    try {
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
        _fromStationCode!,
        _toStationCode!,
        tijdOmTeZoeken,
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

  Future<void> _handleCreateRequest(TripAdvice advice) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String? currentTravellerId = prefs.getString('travellerId'); 
      final String? token = prefs.getString('authToken'); 

      if (currentTravellerId == null || token == null) {
        if (!mounted) return;
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Je bent niet (meer) ingelogd. Log opnieuw in om een reisverzoek aan te maken.'),
            backgroundColor: Colors.red,
          ),
        );
        return; 
      }

      final requestModel = TravelRequestModel(
        travellerId: currentTravellerId,
        departureStation: _fromStationCode!, 
        arrivalStation: _toStationCode!,     
        departureTime: DateTime.parse(advice.departureTime), 
        nsTripId: advice.tripId
      );

      await _travelRequestService.createTravelRequest(requestModel);

      if (!mounted) return;
      Navigator.pop(context); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reisverzoek succesvol aangemaakt! Er wordt gezocht naar een match.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij aanmaken reisverzoek: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
      drawer: const SideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column (
          children: [
            if (_isLoadingStations)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())), 
              )
            else ...[
              Autocomplete<Station>(
                displayStringForOption: (Station option) => option.name,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Station>.empty();
                  }
                  return _stations.where((Station station) {
                    return station.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (Station selection) {
                  setState(() { _fromStationCode = selection.code; });
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: (){
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Van station',
                      hintText: 'Bijv. Amsterdam Centraal',
                      prefixIcon: Icon(Icons.search),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              Autocomplete<Station>(
                displayStringForOption: (Station option) => option.name,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Station>.empty();
                  }
                  return _stations.where((Station station) {
                    return station.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (Station selection) {
                  setState(() { _toStationCode = selection.code; });
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: (){
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Naar station',
                      hintText: 'Bijv. Utrecht Centraal',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  );
                },
              ),
            ],

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

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.train),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getStationName(_fromStationCode)} - ${_getStationName(_toStationCode)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatTime(advice.departureTime)} - ${_formatTime(advice.arrivalTime)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text('Spoor ${advice.departureTrack}'),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _handleCreateRequest(advice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Kies reis'),
                      ),
                    ),
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