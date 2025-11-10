import 'package:crmMobileUi/services/api_service.dart';
import 'package:flutter/material.dart';

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

  // Controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController titleController;
  late TextEditingController departmentController;
  late TextEditingController accountNameController;

  // Dropdown values
  late String contactOwner;
  String? selectedLeadSource;
  String? selectedSalutation;
  late List<Map<String, dynamic>> owners = [];
  String? selectedOwnerName;
  String? selectedOwnerId;

  // Dropdown lists
  List<Map<String, dynamic>> salutations = [];
  List<Map<String, dynamic>> leadSources = [];
  //List<String> contactOwners = ["James Merced", "Alex Smith", "John Doe"];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    owners = widget.contactOwners;
    _fetchMasterDropdownData();

    // Initialize fields
    firstNameController = TextEditingController(
      text: contact['firstName'] ?? '',
    );
    lastNameController = TextEditingController(text: contact['lastName'] ?? '');
    emailController = TextEditingController(text: contact['email'] ?? '');
    titleController = TextEditingController(text: contact['title'] ?? '');
    departmentController = TextEditingController(
      text: contact['department'] ?? '',
    );
    accountNameController = TextEditingController(
      text: contact['account'] ?? '',
    );
    //contactOwner = contact['owner'] ?? 'James Merced';
    // prefill from contact if available
    selectedOwnerName = widget.contact['owner'] ?? null;
    selectedOwnerId = widget.contact['ownerId'] ?? null;
    selectedLeadSource = contact['leadSource'] ?? null;
    selectedSalutation = contact['salutation'] ?? null;
  }

  // 🔹 Fetch dropdown data (Salutation & Lead Source)
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    titleController.dispose();
    departmentController.dispose();
    accountNameController.dispose();
    super.dispose();
  }

  // 🔹 Save contact (submit handler)
  void _saveContact() async {
    try {
      setState(() => isLoading = true);

      final updatedContact = {
        'id':
            widget.contact['id'], // 👈 ensure you pass the existing contact ID
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'title': titleController.text.trim(),
        'department': departmentController.text.trim(),
        'account': accountNameController.text.trim(),
        'ownerId': selectedOwnerId,
        "leadSourceId": _getIdFromList(leadSources, selectedLeadSource),
        'leadSource': selectedLeadSource,
        'salutation': selectedSalutation,
        "salutationId": _getIdFromList(salutations, selectedSalutation),
      };

      // 🔹 Call update API
      await _apiService.updateContact(updatedContact);

      // 🔹 Fetch updated contact by ID
      final refreshedContact = await _apiService.getContactById(
        widget.contact['id'],
      );

      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact updated successfully!')),
      );

      // 🔹 Navigate back to Contact List, passing the refreshed contact
      Navigator.pop(context, refreshedContact);
    } catch (e) {
      debugPrint("❌ Error saving contact: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update contact: $e")));
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

  // ---------- UI ----------
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ---------- Lead Image ----------
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

                  // ---------- Section Header ----------
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

                  // ---------- Editable Fields ----------
                  // _buildInfoTile("Contact Owner", contactOwner, () {
                  //   _showSelectionDialog(
                  //     "Select Contact Owner",
                  //     contactOwners,
                  //     (val) {
                  //       setState(() => contactOwner = val);
                  //     },
                  //   );
                  // }),
                  _buildDropdown(
                    "Contact Owner",
                    owners.map((e) => e["display_name"].toString()).toList(),
                    selectedOwnerName,
                    (value) {
                      setState(() {
                        selectedOwnerName = value;

                        // Find corresponding userId
                        final selectedUser = owners.firstWhere(
                          (u) => u["display_name"] == value,
                          orElse: () => {},
                        );
                        selectedOwnerId = selectedUser["userId"];
                      });
                    },
                  ),

                  // ✅ Salutation Dropdown
                  _buildDropdown(
                    "Salutation",
                    salutations
                        .map((e) => e["displayName"].toString())
                        .toList(),
                    selectedSalutation,
                    (v) => setState(() => selectedSalutation = v),
                  ),

                  // ✅ Lead Source Dropdown
                  _buildDropdown(
                    "Lead Source",
                    leadSources
                        .map((e) => e["displayName"].toString())
                        .toList(),
                    selectedLeadSource,
                    (v) => setState(() => selectedLeadSource = v),
                  ),

                  _buildTextField("First Name", firstNameController),
                  _buildTextField("*Last Name", lastNameController),
                  _buildTextField("Account Name", accountNameController),
                  _buildTextField("Email", emailController),
                  _buildTextField("Title", titleController),
                  _buildTextField("Department", departmentController),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ---------- Helper Widgets ----------

  Widget _buildInfoTile(String label, String value, VoidCallback onTap) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.purple),
      onTap: onTap,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        value: selectedValue,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
        items: items
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showSelectionDialog(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, index) => ListTile(
              title: Text(options[index]),
              onTap: () {
                Navigator.pop(ctx);
                onSelect(options[index]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
