import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelbuddyapp/data/services/identity_service.dart';
import 'package:travelbuddyapp/screens/login_screen.dart';

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

  void _verifyIdentity() async {
    if (_travellerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kan identiteit niet verifiëren: geen ID gevonden.')),
      );
      return;
    }

    try {
      final identityService = IdentityService();
      // Parameter toegevoegd
      await identityService.startVerification(_travellerId!);
    } catch (e) {
      if (!mounted) return; // Veiligheidscheck voor context gebruik
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
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
          if (_verificationStatus == 'UNVERIFIED')
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Verify Identity'),
              onTap: () {
                _verifyIdentity();
                Navigator.pop(context);
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
              
              if (!context.mounted) return; // Ook hier de safety check
              
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