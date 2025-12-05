import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui'as ui;

class StaticHeatMap extends StatelessWidget {
  final Map<String, dynamic> data;

  const StaticHeatMap({super.key, required this.data});

  // FIXED: Brighter colors so they are visible on the widget
  Color _colorForCount(int count) {
    if (count == 0) return const Color(0xFF2C2C2C); // Empty (Dark Grey)
    if (count == 1) return Colors.green.shade800;   // Low (Visible Dark Green)
    if (count <= 3) return Colors.green.shade600;   // Medium (Green)
    return Colors.green.shade400;                   // High (Bright Green)
  }

  @override
  Widget build(BuildContext context) {
    // 1. Robust Data Parsing
    // We explicitly treat the calendar as a Map<String, dynamic> to avoid type errors
    Map<String, dynamic> calendarMap = {};
    
    try {
      if (data["submissionCalendar"] != null) {
        if (data["submissionCalendar"] is String) {
          calendarMap = jsonDecode(data["submissionCalendar"]);
        } else {
          calendarMap = data["submissionCalendar"];
        }
      }
    } catch (e) {
      print("Error parsing calendar: $e");
    }

    // Convert timestamps to "yyyy-MM-dd"
    final Map<String, int> normalizedMap = {};
    int totalSubmissionsCalculated = 0; // For Debugging

    calendarMap.forEach((key, value) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(int.parse(key) * 1000);
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final count = value as int;
        normalizedMap[dateKey] = count;
        totalSubmissionsCalculated += count;
      } catch (e) {
        // Skip bad keys
      }
    });

    // 2. Prepare Data (Last 14 weeks)
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 97)); 
    
    List<Map<String, dynamic>> days = List.generate(98, (index) {
      final currentDate = startDate.add(Duration(days: index));
      final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
      return {
        "count": normalizedMap[dateKey] ?? 0,
      };
    });

    // 3. Render
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Theme(
        data: ThemeData.dark(), 
        child: Material(
          color: const Color(0xFF101010),
          child: SizedBox(
            width: 300,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Added Debug Count to verify data is present
                      Text(
                        "LeetCode ($totalSubmissionsCalculated)", 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 14
                        ),
                      ),
                      Text(
                        "${data['totalActiveDays'] ?? 0} Active Days",
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // --- The Grid ---
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center, 
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(14, (weekIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Column(
                              children: List.generate(7, (dayIndex) {
                                final index = (weekIndex * 7) + dayIndex;
                                final count = days.length > index ? days[index]["count"] : 0;
                                
                                return Container(
                                  width: 18, 
                                  height: 18,
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: _colorForCount(count),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}