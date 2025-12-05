import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart'; 

class LeetCodeHeatMapWidget extends StatefulWidget {
  final String username;

  const LeetCodeHeatMapWidget({super.key, required this.username});

  @override
  State<LeetCodeHeatMapWidget> createState() => _LeetCodeHeatMapWidgetState();
}

class _LeetCodeHeatMapWidgetState extends State<LeetCodeHeatMapWidget> {
  int selectedYear = DateTime.now().year;
  late Future<Map<String, dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureData = LeetCodeCalendarService().fetchCalendar(widget.username, selectedYear);
    });
  }

  void updateYear(int year) {
    selectedYear = year;
    _loadData();
  }

  Color _colorForCount(int count) {
    if (count == 0) return Colors.grey.shade900;
    if (count <= 2) return Colors.green.shade800;
    if (count <= 5) return Colors.green.shade500;
    return Colors.green.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureData,
      builder: (context, snapshot) {
        // 1. LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. ERROR
        if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // 3. SUCCESS
        final data = snapshot.data!;

        // ------------------------------------------------------------------
        // Trigger the Home Screen Widget update here!
        // This runs once the UI is built, sending the data to the Android widget.
        // ------------------------------------------------------------------
        WidgetsBinding.instance.addPostFrameCallback((_) {
           WidgetUpdateService.updateHomeScreenWidget(data);
        });
        
        // Parse Data
        final rawCalendarMap = jsonDecode(data["submissionCalendar"]) as Map<String, dynamic>;
        final Map<String, int> normalizedMap = {};
        rawCalendarMap.forEach((key, value) {
          final date = DateTime.fromMillisecondsSinceEpoch(int.parse(key) * 1000);
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          normalizedMap[dateKey] = value;
        });

        int totalActiveDays = data["totalActiveDays"];
        int maxStreak = data["streak"];

        // Prepare Grid Data
        final startDate = DateTime(selectedYear, 1, 1);
        final endDate = DateTime(selectedYear, 12, 31);
        final daysInYear = endDate.difference(startDate).inDays + 1;

        List<Map<String, dynamic>> allDays = List.generate(daysInYear, (index) {
          final currentDate = startDate.add(Duration(days: index));
          final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
          return {
            "date": currentDate,
            "count": normalizedMap[dateKey] ?? 0,
          };
        });

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        dropdownColor: Colors.grey[900],
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        onChanged: (v) => updateYear(v!),
                        items: List.generate(5, (i) {
                          final year = DateTime.now().year - i;
                          return DropdownMenuItem(value: year, child: Text("$year"));
                        }),
                      ),
                    ),
                  ),
                  // Stats
                  Row(
                    children: [
                      _buildStat("Active Days", "$totalActiveDays"),
                      const SizedBox(width: 12),
                      _buildStat("Max Streak", "$maxStreak"),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              // The Grid
              SizedBox(
                height: 120,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Labels
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                           SizedBox(height: 14),
                           Text("Mon", style: TextStyle(fontSize: 9, color: Colors.grey)),
                           SizedBox(height: 14),
                           Text("Wed", style: TextStyle(fontSize: 9, color: Colors.grey)),
                           SizedBox(height: 14),
                           Text("Fri", style: TextStyle(fontSize: 9, color: Colors.grey)),
                           SizedBox(height: 14),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Blocks
                      Wrap(
                        direction: Axis.vertical,
                        spacing: 3,
                        runSpacing: 3,
                        children: allDays.map((dayItem) {
                          final count = dayItem["count"] as int;
                          final date = dayItem["date"] as DateTime;
                          
                          return Tooltip(
                            message: "$count submissions on ${DateFormat.yMMMd().format(date)}",
                            child: Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                color: _colorForCount(count),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }
}