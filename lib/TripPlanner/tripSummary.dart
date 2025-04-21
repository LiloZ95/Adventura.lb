import 'package:flutter/material.dart';

class TripResultPage extends StatelessWidget {
  final Map plan;

  const TripResultPage({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = plan["days"] ?? [];
    final cost = plan["cost_summary"] ?? {};

    // Recalculate average cost using only days with activities
    final validDays =
        days.where((d) => (d["activities"] as List).isNotEmpty).toList();
    final avgPerDay = validDays.isNotEmpty
        ? (cost["activities_cost"] ?? 0) / validDays.length
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Trip Plan"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 🔹 Trip Summary Intro
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🌍 Trip Summary",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.blue.shade900,
                      fontFamily: 'poppins'),
                ),
                SizedBox(height: 8),
                Text(
                  plan["summary"] ?? "Let’s get planning!",
                  style: TextStyle(fontSize: 16, fontFamily: 'poppins'),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 🔹 Daily Activity Cards
          ...List.generate(days.length, (index) {
            final day = days[index];
            final activities = day["activities"] ?? [];

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? Colors.grey[850] : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Day ${index + 1} - ${day["date"]}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: 'poppins'),
                    ),
                    SizedBox(height: 12),

                    // 🔸 If no activities
                    if (activities.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              "No activities found 😔",
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontFamily: 'poppins'),
                            ),
                          ],
                        ),
                      ),

                    // 🔸 If activities exist
                    ...activities.map<Widget>((act) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.explore_outlined,
                            color: Colors.deepPurple),
                        title: Text(
                          act["name"],
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontFamily: 'poppins',
                          ),
                        ),
                        subtitle: Text(
                          act["type"] == "recurrent"
                              ? "🕒 Slot: ${act["slot"]}"
                              : "🕒 Time: ${act["time"]}",
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            fontFamily: 'poppins',
                          ),
                        ),
                        trailing: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "\$${act["price"]}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                              fontFamily: 'poppins',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }),

          Divider(),
          SizedBox(height: 12),

          // 🔹 Cost Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: \$${cost["total_estimated_cost"] ?? 0}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'poppins'),
              ),
              Text(
                "Avg/Day: \$${avgPerDay.toStringAsFixed(2)}",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'poppins'),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
