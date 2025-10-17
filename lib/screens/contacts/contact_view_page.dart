import 'package:flutter/material.dart';

class ContactDetailsPage extends StatefulWidget {
  const ContactDetailsPage({super.key});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  int selectedTabIndex = 0; // 0 -> Related, 1 -> Emails, 2 -> Details
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Contacts",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 12,
              ), // 👈 added margin from right
              child: Icon(Icons.edit, color: Colors.white, size: 24),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5733C7), Color(0xFF9A24C3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // PROFILE CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 28,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Christopher Maclead",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.purple,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "erinMitchell@company.com",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Colors.purple,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "555-453-3453",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ACCOUNT NAME
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: const [
                Text(
                  "Erin Mitchell",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 6),
                Text(
                  "Account",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          // TAB BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F1FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTab("Related", 0),
                  _buildTab("Emails", 1),
                  _buildTab("Details", 2),
                ],
              ),
            ),
          ),

          // EXPANDABLE SECTIONS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (selectedTabIndex == 0) ...[
                  _buildExpandableTile("Notes & Tech Details", true),
                  _buildExpandableTile("Attachments", false),
                  _buildExpandableTile("Campaigns", false),
                  _buildExpandableTile("Timeline", false),
                ] else if (selectedTabIndex == 1) ...[
                  _buildEmailTabSection(),
                ] else if (selectedTabIndex == 2) ...[
                  _buildContactInfoSection(),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4A00E0),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album_outlined),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.phone_outlined), label: ""),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selectedTabIndex == index
                ? const Color(0xFF8E2DE2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selectedTabIndex == index
                  ? Colors.white
                  : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableTile(String title, bool hasIcons) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcons) ...[
              const Icon(Icons.add, color: Color(0xFF8E2DE2), size: 20),
              const SizedBox(width: 6),
              const Icon(Icons.mic_none, color: Color(0xFF8E2DE2), size: 20),
            ] else
              const Icon(Icons.add, color: Color(0xFF8E2DE2), size: 20),
          ],
        ),
      ),
    );
  }

  // --- Contact Info Section (Details Tab Content) ---
  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          "Contact Information",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _buildInfoRow("Contact Owner", "James Merced"),
        _buildInfoRow("Lead Source", "-None-"),
        _buildInfoRow("Contact Name", "Sam Disuja"),
        _buildInfoRow("Account Name", "BareMinimum Pvt Ltd"),
        _buildInfoRow("Email", "maloonpvt@gmail.com"),
        _buildInfoRow("Title", "Mr."),
        _buildInfoRow("Department", "Sales"),
        _buildInfoRow("Assistant", "James Merced"),
        _buildInfoRow("Reports To", "James Merced"),

        const SizedBox(height: 16),
      ],
    );
  }

  // --- EMAIL TAB SECTION ---
  Widget _buildEmailTabSection() {
    return Column(
      children: [
        // Filter Header Card
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: "Applied  ",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: "Filters: Emails sent from CRM",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.filter_alt_outlined, color: Color(0xFF8E2DE2)),
            ],
          ),
        ),

        // No Emails Placeholder
        const SizedBox(height: 60),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3F8),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              children: const [
                Icon(Icons.mail_outline, size: 48, color: Colors.black87),
                SizedBox(height: 10),
                Text(
                  "No Emails",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
