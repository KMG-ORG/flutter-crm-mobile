import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  final VoidCallback onClose;
  const MorePage({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": Icons.work_outline, "label": "Opportunity"},
      {"icon": Icons.campaign_outlined, "label": "Campaigns"},
      {"icon": Icons.description_outlined, "label": "Quote Ai"},
      {"icon": Icons.show_chart_outlined, "label": "Sales"},
      {"icon": Icons.widgets_outlined, "label": "Products"},
      {"icon": Icons.confirmation_num_outlined, "label": "Tickets"},
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient App Bar
          Container(
            padding: const EdgeInsets.only(
              top: 15,
              left: 10,
              right: 16,
              bottom: 7,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A5AE0), Color(0xFFB35FE5)], // purple → blue
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
                const Text(
                  "More",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 30), // for balance
              ],
            ),
          ),

          // Section label
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Other Links",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),

          // List of items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item["icon"] as IconData,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item["label"] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
