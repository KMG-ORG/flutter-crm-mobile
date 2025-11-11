import 'package:crmMobileUi/features/leads/edit_lead_page.dart';
import 'package:flutter/material.dart';

class LeadViewPage extends StatefulWidget {
  final Map<String, dynamic> leadData;

  const LeadViewPage({Key? key, required this.leadData}) : super(key: key);

  @override
  State<LeadViewPage> createState() => _LeadViewPageState();
}

class _LeadViewPageState extends State<LeadViewPage> {
  int selectedTabIndex = 0; // 0 -> Related, 1 -> Emails, 2 -> Details

  @override
  Widget build(BuildContext context) {
    final lead = widget.leadData;
    final name = lead['fullName'] ?? "No Name";
    final email = lead['email'] ?? "No Email";
    final phone = lead['phone'] ?? "No Phone";
    final owner = lead['owner'] ?? "Unknown";
    final account = lead['accountName'] ?? "N/A";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context, true), // ✅ Return true
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                padding: const EdgeInsets.all(4.5),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          title: const Text(
            "Lead",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final updatedLead = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditLeadPage(
                        lead: lead,
                        leadOwners: [],
                        // contact: contact,
                        //contactOwners: contactOwners,
                      ),
                    ),
                  );
                  if (updatedLead != null && mounted) {
                    setState(() {
                      widget.leadData.clear();
                      widget.leadData.addAll(updatedLead);
                    });
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.more_vert, color: Colors.white, size: 26),
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

      // --- BODY ---
      body: Column(
        children: [
          // 🔹 PROFILE CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black12,
              //     blurRadius: 4,
              //     offset: Offset(0, 2),
              //   ),
              // ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFE0E0E0),
                  child: Icon(
                    Icons.person_outline,
                    size: 30,
                    color: Colors.deepPurple.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Color(0xFF724ACE),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Color(0xFF724ACE),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFFEEECF9), // line color
            thickness: 2, // line thickness
            // indent: 16,              // left spacing
            // endIndent: 16,           // right spacing
          ),
          // 🔹 Owner Info
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    "E",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Owner",
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 TAB BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFDBE0FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    _buildTab("Related", 0),
                    _buildTab("Emails", 1),
                    _buildTab("Details", 2),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 TAB CONTENT
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
                  _buildLeadDetailsSection(lead),
                ],
              ],
            ),
          ),
          const Divider(
            color: Color(0xFFEEECF9), // line color
            thickness: 2, // line thickness
            // indent: 16,              // left spacing
            // endIndent: 16,           // right spacing
          ),
        ],
      ),

      // 🔹 BOTTOM NAV
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

  // 🔹 Tabs
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
            gradient: selectedTabIndex == index
                ? const LinearGradient(
                    colors: [Color(0xFF5733C7), Color(0xFF9A24C3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null, // no gradient for unselected
            color: selectedTabIndex == index
                ? null
                : Colors.transparent, // fallback for unselected
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

  // 🔹 Expandable Tiles (Related Tab)
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

  // 🔹 Emails Tab
  Widget _buildEmailTabSection() {
    return Column(
      children: [
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

  // 🔹 Details Tab (Dynamic)
  Widget _buildLeadDetailsSection(Map<String, dynamic> lead) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          "Lead Information",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _buildInfoRow("Lead Owner", lead["owner"] ?? "Unknown"),
        _buildInfoRow("Company", lead["companyName"] ?? "N/A"),
        _buildInfoRow("Lead Source", lead["leadSource"] ?? "-None-"),
        _buildInfoRow("Email", lead["email"] ?? "-"),
        _buildInfoRow("Phone", lead["phone"] ?? "-"),
        _buildInfoRow("Status", lead["status"] ?? "-"),
        _buildInfoRow("Description", lead["description"] ?? "-"),

        const SizedBox(height: 16),
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
