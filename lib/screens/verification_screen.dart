import 'package:flutter/material.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart'; 
import '../data/services/identity_service.dart';

class VerificationScreen extends StatefulWidget {
  final String travellerId; 

  const VerificationScreen({super.key, required this.travellerId});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final IdentityService _identityService = IdentityService();
  
  // De correcte instantie voor de native iOS plugin
  final StripeIdentityPlugin _stripeIdentity = StripeIdentityPlugin(); 
  
  bool _isLoading = false;

  Future<void> _startVerification() async {
    setState(() => _isLoading = true);

    try {
      // 1. Haal de beide keys op van je server
      final sessionData = await _identityService.fetchSessionData(widget.travellerId);

      // 2. Start de native iOS camera overlay en geef beide parameters mee
      await _stripeIdentity.startVerification(
        id: sessionData['sessionId']!,
        key: sessionData['ephemeralKeySecret']!,
      );

      // 3. Als we hier zijn, is de sheet succesvol afgerond door de gebruiker
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploaden voltooid. Controle in de achtergrond gestart!')),
        );
      }

    } catch (error) {
      // Vangt annuleringen of camera-weigeringen op
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verificatie afgebroken: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identiteit Verifiëren'),
      ),
      body: Center(
        child: _isLoading 
            ? const CircularProgressIndicator() 
            : ElevatedButton.icon(
                onPressed: _startVerification,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Paspoort of ID'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
      ),
    );
  }
}