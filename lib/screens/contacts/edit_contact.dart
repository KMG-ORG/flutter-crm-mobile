import 'package:flutter/material.dart';
import 'package:crmMobileUi/services/api_service.dart';

class EditContactPage extends StatefulWidget {
  final Map<String, dynamic> contact;
  final List<Map<String, dynamic>> contactOwners;

  const EditContactPage({
    super.key,
    required this.contact,
    required this.contactOwners,
  });

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController titleController;
  late TextEditingController departmentController;

  // Dropdown lists
  List<Map<String, dynamic>> salutations = [];
  List<Map<String, dynamic>> leadSources = [];
  List<Map<String, dynamic>> owners = [];
  List<Map<String, dynamic>> accounts = [];

  // Selected dropdown values
  String? selectedSalutation;
  String? selectedLeadSource;
  String? selectedOwnerName;
  String? selectedOwnerId;
  String? selectedAccountName;
  String? selectedAccountId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    owners = widget.contactOwners;
    final contact = widget.contact;

    firstNameController = TextEditingController(
      text: contact['firstName'] ?? '',
    );
    lastNameController = TextEditingController(text: contact['lastName'] ?? '');
    emailController = TextEditingController(text: contact['email'] ?? '');
    titleController = TextEditingController(text: contact['title'] ?? '');
    departmentController = TextEditingController(
      text: contact['department'] ?? '',
    );

    selectedOwnerName = contact['owner'] ?? null;
    selectedOwnerId = contact['ownerId'] ?? null;
    selectedLeadSource = contact['leadSource'] ?? null;
    selectedSalutation = contact['salutation'] ?? null;

    // ✅ Pre-fill Account dropdown from existing contact data
    selectedAccountName = contact['account'] ?? null;
    selectedAccountId = contact['accountId'] ?? null;

    _fetchMasterDropdownData();
    _fetchAccounts();
  }

  // Fetch dropdowns (Salutation & Lead Source)
  Future<void> _fetchMasterDropdownData() async {
    try {
      setState(() => isLoading = true);
      final data = await _apiService.getFilteredMasterData();
      setState(() {
        salutations = List<Map<String, dynamic>>.from(data["Salutation"] ?? []);
        leadSources = List<Map<String, dynamic>>.from(data["LeadSource"] ?? []);
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

  // ✅ Fetch Account List from API
  Future<void> _fetchAccounts() async {
    try {
      final payload = {"searchText": "", "pageNumber": 1, "pageSize": 50};
      final data = await _apiService.getAccountNamesList(payload);
      setState(() {
        accounts = data;

        // ✅ If selectedAccountName is not in dropdown yet, add it manually
        if (selectedAccountName != null &&
            accounts.indexWhere((a) => a["id"] == selectedAccountId) == -1) {
          accounts.insert(0, {
            "id": selectedAccountId,
            "name": selectedAccountName,
          });
        }
      });
      print("✅ Accounts loaded: ${accounts.length}");
    } catch (e) {
      print("❌ Error fetching accounts: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load accounts: $e")));
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    titleController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  // 🔹 Save contact
  void _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      final updatedContact = {
        'id': widget.contact['id'],
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'title': titleController.text.trim(),
        'department': departmentController.text.trim(),
        'ownerId': selectedOwnerId,
        'phone': widget.contact['phone'] ?? '',
        'leadSourceId': _getIdFromList(leadSources, selectedLeadSource),
        'leadSource': selectedLeadSource,
        'salutation': selectedSalutation,
        'salutationId': _getIdFromList(salutations, selectedSalutation),
        'account': selectedAccountName,
        'accountId': selectedAccountId,
      };

      await _apiService.updateContact(updatedContact);

      final refreshedContact = await _apiService.getContactById(
        widget.contact['id'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, refreshedContact);
    } catch (e) {
      debugPrint("❌ Error saving contact: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update contact: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _getIdFromList(List<Map<String, dynamic>> list, String? selectedName) {
    if (selectedName == null) return "";
    final match = list.firstWhere(
      (item) => item["displayName"] == selectedName,
      orElse: () => {},
    );
    return match["id"]?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Edit Contact",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _saveContact,
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
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ---------- Profile ----------
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFFE8E0FB),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.purple,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${firstNameController.text} ${lastNameController.text}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      color: const Color(0xFFF4F3F8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      child: const Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    _buildDropdown(
                      "Contact Owner",
                      owners.map((e) => e["display_name"].toString()).toList(),
                      selectedOwnerName,
                      (value) {
                        setState(() {
                          selectedOwnerName = value;
                          final selectedUser = owners.firstWhere(
                            (u) => u["display_name"] == value,
                            orElse: () => {},
                          );
                          selectedOwnerId = selectedUser["userId"];
                        });
                      },
                    ),

                    _buildDropdown(
                      "Salutation",
                      salutations
                          .map((e) => e["displayName"].toString())
                          .toList(),
                      selectedSalutation,
                      (v) => setState(() => selectedSalutation = v),
                    ),

                    _buildDropdown(
                      "Lead Source",
                      leadSources
                          .map((e) => e["displayName"].toString())
                          .toList(),
                      selectedLeadSource,
                      (v) => setState(() => selectedLeadSource = v),
                    ),

                    // ✅ Account Dropdown
                    // _buildDropdown(
                    //   "Account Name",
                    //   accounts.map((e) => e["name"].toString()).toList(),
                    //   selectedAccountName,
                    //   (value) {
                    //     setState(() {
                    //       selectedAccountName = value;
                    //       final selectedAccount = accounts.firstWhere(
                    //         (a) => a["name"] == value,
                    //         orElse: () => {},
                    //       );
                    //       selectedAccountId = selectedAccount["id"];
                    //     });
                    //   },
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedAccountId, // ✅ use unique ID here
                        decoration: InputDecoration(
                          labelText: "Account Name",
                          labelStyle: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
                        items: accounts.map((a) {
                          final id = a["id"]?.toString();
                          final name = a["name"]?.toString() ?? '';
                          return DropdownMenuItem<String>(
                            value: id, // ✅ unique id
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (id) {
                          setState(() {
                            selectedAccountId = id;
                            final selectedAccount = accounts.firstWhere(
                              (a) => a["id"].toString() == id,
                              orElse: () => {},
                            );
                            selectedAccountName = selectedAccount["name"];
                          });
                        },
                      ),
                    ),

                    _buildTextField("First Name", firstNameController),
                    _buildTextField(
                      "*Last Name",
                      lastNameController,
                      isRequired: true,
                    ),
                    _buildTextField("Email", emailController),
                    _buildTextField("Title", titleController),
                    _buildTextField("Department", departmentController),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------- Helpers ----------

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purple),
          ),
        ),
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

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
        items: items
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
