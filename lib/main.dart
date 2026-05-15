import 'package:flutter/material.dart';
import 'screens/trip_search_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TravelBuddy',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 211, 99, 116)),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
        ),
        useMaterial3: true,
      ),
    
      home: const TripSearchScreen(), // Hier geven we aan dat de eerste pagina die wordt getoond de TripSearchScreen is
    );
  }
}


