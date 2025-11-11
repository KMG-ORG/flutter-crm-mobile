import 'package:flutter/material.dart';
import 'package:crmMobileUi/services/api_service.dart';

class EditLeadPage extends StatefulWidget {
  final Map<String, dynamic> lead;
  final List<Map<String, dynamic>> leadOwners;

  const EditLeadPage({super.key, required this.lead, required this.leadOwners});

  @override
  State<EditLeadPage> createState() => _EditLeadPageState();
}

class _EditLeadPageState extends State<EditLeadPage> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController companyNameController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController titleController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController faxController;

  // Dropdown data
  List<Map<String, dynamic>> leadSources = [];
  List<Map<String, dynamic>> salutations = [];
  List<Map<String, dynamic>> companies = [];
  //List<Map<String, dynamic>> owners = [];

  // Selected values
  String? selectedLeadSource;
  String? selectedLeadSourceId;
  String? selectedSalutation;
  String? selectedSalutationId;
  String? selectedCompanyName;
  String? selectedCompanyId;
  //String? selectedOwnerName;
  //String? selectedOwnerId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // owners = widget.leadOwners;

    final lead = widget.lead;

    // Initialize text fields
    companyNameController = TextEditingController(
      text: lead['companyName'] ?? '',
    );
    firstNameController = TextEditingController(text: lead['firstName'] ?? '');
    lastNameController = TextEditingController(text: lead['lastName'] ?? '');
    titleController = TextEditingController(text: lead['title'] ?? '');
    emailController = TextEditingController(text: lead['email'] ?? '');
    phoneController = TextEditingController(text: lead['phone'] ?? '');
    faxController = TextEditingController(text: lead['fax'] ?? '');

    // Initialize dropdowns
    // selectedOwnerName = lead['owner'] ?? null;
    //selectedOwnerId = lead['ownerId'] ?? null;
    selectedCompanyName = lead['companyName'] ?? null;
    selectedSalutation = lead['salutation'] ?? null;
    selectedLeadSource = lead['leadSource'] ?? null;

    _fetchDropdownData();
    // _fetchCompanies();
  }

  Future<void> _fetchDropdownData() async {
    try {
      setState(() => isLoading = true);
      final data = await _apiService.getFilteredMasterData();
      setState(() {
        salutations = List<Map<String, dynamic>>.from(data["Salutation"] ?? []);
        if (selectedSalutation != null && selectedSalutationId == null) {
          final match = salutations.firstWhere(
            (s) => s['displayName'] == selectedSalutation,
            orElse: () => {},
          );
          if (match.isNotEmpty) {
            selectedSalutationId = match['id']?.toString();
          }
        }
        leadSources = List<Map<String, dynamic>>.from(data["LeadSource"] ?? []);
        if (selectedLeadSource != null && selectedLeadSourceId == null) {
          final match = leadSources.firstWhere(
            (s) => s['displayName'] == selectedLeadSource,
            orElse: () => {},
          );
          if (match.isNotEmpty) {
            selectedLeadSourceId = match['id']?.toString();
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load dropdown data: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Future<void> _fetchCompanies() async {
  //   try {
  //     final data = await _apiService.getAccountNamesList();
  //     setState(() {
  //       companies = data;
  //       if (selectedCompanyId != null &&
  //           companies.indexWhere((c) => c["id"] == selectedCompanyId) == -1) {
  //         companies.insert(0, {
  //           "id": selectedCompanyId,
  //           "name": selectedCompanyName,
  //         });
  //       }
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Failed to load companies: $e")),
  //     );
  //   }
  // }

  void _saveLead() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      final updatedLead = {
        'id': widget.lead['id'],
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'title': titleController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'fax': faxController.text.trim(),
        'sourceName': widget.lead['sourceName'],
        'industry': widget.lead['industry'],
        'industryId': widget.lead['industryId'],
        'leadSourceId': selectedLeadSourceId,
        'leadSource': selectedLeadSource,
        'salutation': selectedSalutation,
        'salutationId': selectedSalutationId,
        'companyName': companyNameController.text.trim(),
        'owner': widget.lead['owner'],
        'ownerId': widget.lead['ownerId'],

        //'ownerId': selectedOwnerId,
      };

      await _apiService.updateLead(updatedLead);
      final refreshedLead = await _apiService.getLeadById(widget.lead['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lead updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, refreshedLead);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update lead: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    companyNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    titleController.dispose();
    emailController.dispose();
    phoneController.dispose();
    faxController.dispose();
    super.dispose();
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Lead"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveLead,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  const Text(
                    "Lead information",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDropdownField(
                    "Lead Source",
                    leadSources,
                    selectedLeadSourceId,
                    (id) {
                      setState(() {
                        selectedLeadSourceId = id;
                        selectedLeadSource = leadSources.firstWhere(
                          (o) => o['id'] == id,
                        )['displayName'];
                      });
                    },
                    labelKey: "displayName",
                    valueKey: "id",
                  ),
                  _buildTextField("Company Name", companyNameController),
                  _buildDropdownField(
                    "Salutation",
                    salutations,
                    selectedSalutationId,
                    (id) {
                      setState(() {
                        selectedSalutationId = id;
                        selectedSalutation = salutations.firstWhere(
                          (s) => s['id'] == id,
                        )['displayName'];
                      });
                    },
                    labelKey: "displayName",
                    valueKey: "id",
                  ),
                  _buildTextField("First Name", firstNameController),
                  _buildTextField(
                    "*Last Name",
                    lastNameController,
                    isRequired: true,
                  ),
                  _buildTextField("Title", titleController),
                  _buildTextField("Email", emailController),
                  _buildTextField("Phone", phoneController),
                  _buildTextField("Fax", faxController),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ---------- Helper Widgets ----------

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFE8E0FB),
            child: Icon(Icons.person, color: Colors.purple, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            "${firstNameController.text} ${lastNameController.text}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<Map<String, dynamic>> items,
    String? selectedValue,
    ValueChanged<String?> onChanged, {
    String labelKey = 'name',
    String valueKey = 'id',
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          border: const UnderlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) {
          if (isRequired && (v == null || v.isEmpty)) {
            return "$label is required";
          }
          return null;
        },
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item[valueKey]?.toString(),
            child: Text(item[labelKey]?.toString() ?? ''),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            final cleanLabel = label.replaceAll('*', '').trim();
            return '$cleanLabel is required';
          }
          return null;
        },
      ),
    );
  }
}
