import 'package:flutter/material.dart';
import 'widgets/heat_map_widget.dart'; // Ensure this path is correct

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Added for safety
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeetCode Heatmap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: Colors.amber,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: LeetCodeHeatMapWidget(username: "krish_Agarwal-"),
          ),
        ),
      ),
    );
  }
}