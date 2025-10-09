import 'package:flutter/material.dart';

class SortFilterPage extends StatefulWidget {
  @override
  _SortFilterPageState createState() => _SortFilterPageState();
}

class _SortFilterPageState extends State<SortFilterPage> {
  String selectedField = "Account Name";
  String orderType = "Asc";

  final fields = [
    "Account Name",
    "Campaign Name",
    "Email",
    "Contact Owner",
    "Title",
    "Department",
    "LinkedIn",
    "Lead Source",
    "State",
    "Zip Code",
    "Created By",
    "Updated By",
    "Mailing City",
    "Mailing zip",
    "Reporting To",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sort by"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5733C7), Color(0xFF9A24C3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selected Field",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  selectedField,
                  style: const TextStyle(color: Colors.black54),
                ),
                const Spacer(),
                ToggleButtons(
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 2,
                      ),
                      child: Text('Asc', style: TextStyle(fontSize: 13)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 2,
                      ),
                      child: Text('Dec', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                  isSelected: [orderType == "Asc", orderType == "Dec"],
                  onPressed: (index) {
                    setState(() {
                      orderType = index == 0 ? "Asc" : "Dec";
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: const Color(0xFF9A24C3),
                  color: Colors.purple,
                  borderColor: Colors.purple[100],
                  constraints: const BoxConstraints(
                    minHeight: 28, // Control height for compact appearance
                    minWidth: 36, // Adjust width as needed
                  ),
                  // visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Choose a Field",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: fields.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.grey, height: 1),
                itemBuilder: (context, index) {
                  final field = fields[index];
                  return ListTile(
                    title: Text(
                      field,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    onTap: () {
                      setState(() {
                        selectedField = field;
                      });
                    },
                    selected: selectedField == field,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
