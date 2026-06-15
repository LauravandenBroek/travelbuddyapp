import 'package:flutter/material.dart';
import '../data/services/travel_request_service.dart';
import '../data/services/match_service.dart';

class MyTripsScreen extends StatefulWidget {
  final String travellerId;

  const MyTripsScreen({
    Key? key,
    required this.travellerId,
  }) : super(key: key);

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  late Future<List<dynamic>> _travelRequestsFuture; 
  late Future<List<dynamic>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
      _travelRequestsFuture = TravelRequestService().fetchTravelRequests(widget.travellerId);
      _matchesFuture = MatchService().fetchMatches(widget.travellerId);
   
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mijn Reizen'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Mijn Verzoeken'),
              Tab(icon: Icon(Icons.handshake), text: 'Matches'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTravelRequestsTab(),
            _buildMatchesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelRequestsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _travelRequestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fout: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Je hebt nog geen reisverzoeken.'));
        }

        final requests = snapshot.data!; 
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.train, color: Colors.blue),
                title: Text('${request.departureStation} - ${request.arrivalStation}'),
                subtitle: const Text('Status: Wachten op match...'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMatchesTab() {
    return FutureBuilder<List<dynamic>>(
      future: _matchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fout: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nog geen matches gevonden.'));
        }

        final matches = snapshot.data!; 

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('Reis met ${match.buddyName}'),
                subtitle: Text('Status: ${match.status.toString().split('.').last}'),
                trailing: match.status.toString().split('.').last == 'pending' 
                    ? ElevatedButton(
                        onPressed: () {
                          print('Accepteer match ${match.matchId}');
                        },
                        child: const Text('Accepteer'),
                      )
                    : const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }
}