import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:home_widget/home_widget.dart';
import '../widgets/static_heat_map.dart';

class LeetCodeCalendarService {
  static const _apiUrl = "https://leetcode.com/graphql";

  Future<Map<String, dynamic>> fetchCalendar(String username, int year) async {
    const query = r'''
      query userProfileCalendar($username: String!, $year: Int) {
        matchedUser(username: $username) {
          userCalendar(year: $year) {
            submissionCalendar
            totalActiveDays
            streak
          }
        }
      }
    ''';
    
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0"
      },
      body: json.encode({
        "query": query,
        "variables": {"username": username, "year": year}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["errors"] != null) throw Exception(data["errors"][0]["message"]);
      return data["data"]["matchedUser"]["userCalendar"];
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }
}

// --- THIS CLASS CONNECTS FLUTTER TO ANDROID ---
class WidgetUpdateService {
  static Future<void> updateHomeScreenWidget(Map<String, dynamic> data) async {
    print("DEBUG: Starting Widget Update Process...");

    try {
      // 1. Render Widget to Image
      // The plugin will generate a temp path (e.g. .../app_flutter/temp_123.png)
      final path = await HomeWidget.renderFlutterWidget(
        StaticHeatMap(data: data), 
        key: 'filename_heatmap', 
        logicalSize: const Size(300, 150),
      );

      print("DEBUG: Image created at: $path");

      // 2. Save Path to SharedPreferences
      // This is CRITICAL. We save the temp path so Kotlin knows exactly where to look.
      await HomeWidget.saveWidgetData('filename_heatmap', path);
      
      // 3. Signal Android to Update
      await HomeWidget.updateWidget(
        name: 'LeetCodeWidgetProvider', 
        iOSName: 'LeetCodeWidget',
      );
      print("DEBUG: Signal sent to Android.");

    } catch (e) {
      print("CRITICAL EXCEPTION IN WIDGET UPDATE: $e");
    }
  }
}