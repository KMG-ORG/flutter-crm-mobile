import 'package:crmMobileUi/services/api_service.dart';
import 'package:flutter/material.dart';

class AddLeadPage extends StatefulWidget {
  const AddLeadPage({super.key});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _apiService = ApiService();

  // --- Controllers ---
  final TextEditingController companyNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController altPhoneCtrl = TextEditingController();
  final TextEditingController websiteCtrl = TextEditingController();
  final TextEditingController writtenPremiumCtrl = TextEditingController();
  final TextEditingController annualRevenueCtrl = TextEditingController();
  final TextEditingController numEmployeesCtrl = TextEditingController();
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController techDetailsCtrl = TextEditingController();
  final TextEditingController otherSourceNameCtrl = TextEditingController();
  final TextEditingController sourceNameCtrl = TextEditingController();

  // --- Dropdown selected values ---
  String? selectedTimeZone;
  String? selectedRevenueType;
  String? selectedSalutation;
  String? selectedIndustry;
  String? selectedLeadSource;
  String? selectedOwner;

  // --- Checkbox ---
  bool emailOptOut = false;

  // --- Dropdown lists (with id & displayName) ---
  List<Map<String, dynamic>> timeZones = [];
  List<Map<String, dynamic>> revenueTypes = [];
  List<Map<String, dynamic>> salutations = [];
  List<Map<String, dynamic>> industries = [];
  List<Map<String, dynamic>> leadSources = [];
  List<String> owners = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMasterDropdownData();
  }

  // 🔹 Fetch dynamic dropdown values from backend
  Future<void> _fetchMasterDropdownData() async {
    try {
      setState(() => isLoading = true);
      final data = await _apiService.getFilteredMasterData();

      setState(() {
        timeZones = List<Map<String, dynamic>>.from(data["TimeZone"] ?? []);
        revenueTypes = List<Map<String, dynamic>>.from(data["RevenueType"] ?? []);
        salutations = List<Map<String, dynamic>>.from(data["Salutation"] ?? []);
        industries = List<Map<String, dynamic>>.from(data["Industry"] ?? []);
        leadSources = List<Map<String, dynamic>>.from(data["LeadSource"] ?? []);
        owners = ["James Merced", "Sarah Carter", "John Doe"];
      });
    } catch (e) {
      debugPrint("Error fetching dropdown data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load dropdown data: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 Submit API call
  Future<void> _submitLead() async {
    if (companyNameCtrl.text.isEmpty || lastNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Company Name and Last Name are required."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final payload = {
        "companyName": companyNameCtrl.text.trim(),
        "displayName": companyNameCtrl.text.trim(),
        "shortName": companyNameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "alternatePhone": altPhoneCtrl.text.trim(),
        "otherSourceName": otherSourceNameCtrl.text.trim(),
        "timeZoneId": _getIdFromList(timeZones, selectedTimeZone),
        "salutationId": _getIdFromList(salutations, selectedSalutation),
        "companyLinkedIn": websiteCtrl.text.trim(),
        "website": websiteCtrl.text.trim(),
        "annualRevenue": int.tryParse(annualRevenueCtrl.text) ?? 0,
        "revenueTypeId": _getIdFromList(revenueTypes, selectedRevenueType),
        "noOfEmployees": int.tryParse(numEmployeesCtrl.text) ?? 0,
        "noOfBeds": "",
        "businessType": "",
        "industryId": _getIdFromList(industries, selectedIndustry),
        "lineOfBusiness": "",
        "leadSourceId": _getIdFromList(leadSources, selectedLeadSource),
        "sourceName": sourceNameCtrl.text.trim(),
        "owner": selectedOwner ?? "",
        "ownerId": "",
        "firstName": firstNameCtrl.text.trim(),
        "middleName": "",
        "lastName": lastNameCtrl.text.trim(),
        "title": titleCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "secondaryEmail": "",
        "directPhone": phoneCtrl.text.trim(),
        "mobile": mobileCtrl.text.trim(),
        "contactLinkedIn": "",
        "emailOptOut": emailOptOut,
        "street": "",
        "city": "",
        "state": "",
        "zipCode": "",
        "country": "",
        "description": descCtrl.text.trim(),
        "technologyDetails": techDetailsCtrl.text.trim(),
        "writtenPremium": int.tryParse(writtenPremiumCtrl.text) ?? 0,
        "companyLogoUrl": "",
        "leadLogoUrl": ""
      };

      final result = await _apiService.createLead(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Lead created successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating lead: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 Helper to get ID from dropdown list
  String _getIdFromList(List<Map<String, dynamic>> list, String? selectedName) {
    if (selectedName == null) return "";
    final match = list.firstWhere(
      (item) => item["displayName"] == selectedName,
      orElse: () => {},
    );
    return match["id"]?.toString() ?? "";
  }

  // --- UI SECTION ---
  @override
  Widget build(BuildContext context) {
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
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                padding: const EdgeInsets.all(4.5),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          title: const Text(
            "Add Lead",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.white, size: 26),
                onPressed: _submitLead,
              ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // --- LEAD IMAGE ---
                    const Text(
                      "Lead Image",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1ECFC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Color(0xFF8E2DE2),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "James Merced",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300, thickness: 1),

                    // --- COMPANY INFORMATION ---
                    _sectionHeader("Company Information"),
                    _buildTextField("*Company Name", companyNameCtrl),
                    _buildDropdown("Time Zone",
                        timeZones.map((e) => e["displayName"].toString()).toList(),
                        selectedTimeZone, (v) => setState(() => selectedTimeZone = v)),
                    _buildDropdown("Revenue Type",
                        revenueTypes.map((e) => e["displayName"].toString()).toList(),
                        selectedRevenueType, (v) => setState(() => selectedRevenueType = v)),
                    _buildNumberField("Written Premium", writtenPremiumCtrl),
                    _buildNumberField("Annual Revenue", annualRevenueCtrl),
                    _buildNumberField("Number of Employees", numEmployeesCtrl),

                    _sectionHeader("Contact Information"),
                    _buildDropdown("Salutation",
                        salutations.map((e) => e["displayName"].toString()).toList(),
                        selectedSalutation, (v) => setState(() => selectedSalutation = v)),
                    _buildTextField("*Last Name", lastNameCtrl),
                    _buildTextField("Email", emailCtrl),
                    _buildCheckbox("Email Opt Out", emailOptOut,
                        (val) => setState(() => emailOptOut = val!)),

                    _sectionHeader("General Information"),
                    _buildDropdown("Industry",
                        industries.map((e) => e["displayName"].toString()).toList(),
                        selectedIndustry, (v) => setState(() => selectedIndustry = v)),
                    _buildDropdown("Lead Source",
                        leadSources.map((e) => e["displayName"].toString()).toList(),
                        selectedLeadSource, (v) => setState(() => selectedLeadSource = v)),
                        _buildTextField("Source Name", sourceNameCtrl),
                         _buildTextField("Other Source Name", otherSourceNameCtrl),
                    _buildDropdown("Owner", owners, selectedOwner,
                        (v) => setState(() => selectedOwner = v)),

                    _sectionHeader("Notes & Tech Details"),
                    _buildTextField("Description", descCtrl),
                    _buildTextField("Tech Details", techDetailsCtrl),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // --- REUSABLE UI WIDGETS ---
  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 16),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      );

  Widget _buildTextField(String label, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8E2DE2))),
          ),
        ),
      );

  Widget _buildNumberField(String label, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8E2DE2))),
          ),
        ),
      );

  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
          ValueChanged<String?> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          value: selectedValue,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          items: items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: onChanged,
        ),
      );

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CheckboxListTile(
          value: value,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF8E2DE2),
          title: Text(label,
              style: const TextStyle(color: Colors.black87, fontSize: 14)),
        ),
      );
}
