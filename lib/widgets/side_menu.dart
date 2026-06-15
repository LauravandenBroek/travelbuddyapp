import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelbuddyapp/screens/verification_screen.dart'; 
import 'package:travelbuddyapp/screens/login_screen.dart';
import '../screens/travel_requests_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String? _verificationStatus;
  String? _travellerId;

  @override
  void initState() {
    super.initState();
    _loadTravellerData();
  }

  Future<void> _loadTravellerData() async {
    final prefs = await SharedPreferences.getInstance();
    final travellerData = prefs.getString('traveller');
    if (travellerData != null) {
      final traveller = jsonDecode(travellerData);
      setState(() {
        _verificationStatus = traveller['verificationStatus'];
        _travellerId = traveller['id']; 
        
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Travel Buddy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.landslide),
            title: const Text('My trips'),
            onTap: () {
              Navigator.pop(context);
              if (_travellerId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gegevens worden nog geladen...')),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyTripsScreen(travellerId: _travellerId!),
                ),
              );
            },
          ),

          if (_verificationStatus == 'UNVERIFIED')
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Verify Identity'),
              onTap: () {
                Navigator.pop(context);

                if (_travellerId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kan identiteit niet verifiëren: geen ID gevonden.')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerificationScreen(travellerId: _travellerId!),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('authToken');
              await prefs.remove('traveller');
              
              if (!context.mounted) return; 
              
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}