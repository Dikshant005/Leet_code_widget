import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
class StaticHeatMap extends StatelessWidget {
  final Map<String, dynamic> data;

  const StaticHeatMap({super.key, required this.data});

  Color _colorForCount(int count) {
    if (count == 0) return const Color(0xFF2C2C2C);
    if (count == 1) return const Color(0xFF1B5E20);
    if (count <= 3) return const Color(0xFF2E7D32);
    return const Color(0xFF4CAF50);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Parse Data
    final calendarMap = data["submissionCalendar"] is String
        ? Map<String, dynamic>.from(jsonDecode(data["submissionCalendar"]))
        : data["submissionCalendar"];

    final Map<String, int> normalizedMap = {};
    if (calendarMap != null) {
      calendarMap.forEach((key, value) {
        final date = DateTime.fromMillisecondsSinceEpoch(int.parse(key) * 1000);
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        normalizedMap[dateKey] = value;
      });
    }

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
              // REDUCED PADDING: Gives more room for the "Zoom"
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center, // Centered Header
                children: [
                  // --- Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "LeetCode",
                        style: TextStyle(
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
                  const SizedBox(height: 6), // Reduced gap

                  // --- The Grid ---
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      // ALIGNMENT CHANGED: Moves it from Left to Center
                      alignment: Alignment.center, 
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(14, (weekIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4), // Increased gap slightly
                            child: Column(
                              children: List.generate(7, (dayIndex) {
                                final index = (weekIndex * 7) + dayIndex;
                                final count = days.length > index ? days[index]["count"] : 0;
                                
                                return Container(
                                  // ZOOM FACTOR: Increased from 10 to 18
                                  width: 18, 
                                  height: 18,
                                  margin: const EdgeInsets.only(bottom: 4), // Increased gap
                                  decoration: BoxDecoration(
                                    color: _colorForCount(count),
                                    borderRadius: BorderRadius.circular(3), // Slightly rounder
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