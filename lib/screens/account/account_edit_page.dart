import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crmMobileUi/services/api_service.dart';

// 🔹 Formatter for phone numbers (123-456-7890)
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    if (digits.length > 10) digits = digits.substring(0, 10);

    var formatted = '';
    for (int i = 0; i < digits.length; i++) {
      formatted += digits[i];
      if (i == 2 || i == 5) formatted += '-';
    }
    if (formatted.endsWith('-')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EditAccountPage extends StatefulWidget {
  final Map<String, dynamic> account;

  const EditAccountPage({super.key, required this.account});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> updatedAccount;

  // ✅ Controllers
  late TextEditingController websiteController;
  late TextEditingController phoneController;
  late TextEditingController employeesController;
  late TextEditingController revenueController;

  // ✅ Dropdown lists (store id + name)
  List<Map<String, dynamic>> ownerList = [];
  List<Map<String, dynamic>> vendorList = [];
  List<Map<String, dynamic>> industryList = [];

  // ✅ Selected values (store map of id + name)
  Map<String, dynamic>? selectedOwner;
  Map<String, dynamic>? selectedVendor;
  Map<String, dynamic>? selectedIndustry;

  bool isSaving = false;
  bool autoValidate = false;
  bool isLoading = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    updatedAccount = Map<String, dynamic>.from(widget.account);

    websiteController = TextEditingController(
      text: updatedAccount["website"] ?? "",
    );
    phoneController = TextEditingController(
      text: _formatPhone(updatedAccount["phone"] ?? ""),
    );
    employeesController = TextEditingController(
      text: updatedAccount["employees"]?.toString() ?? "",
    );
    revenueController = TextEditingController(
      text: updatedAccount["annualRevenue"]?.toString() ?? "",
    );

    _fetchMasterDropdownData();
  }

  @override
  void dispose() {
    websiteController.dispose();
    phoneController.dispose();
    employeesController.dispose();
    revenueController.dispose();
    super.dispose();
  }

  String _formatPhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6, 10)}';
    }
    return phone;
  }

  // ✅ Fetch dropdown data from APIs
  Future<void> _fetchMasterDropdownData() async {
    try {
      setState(() => isLoading = true);

      // Fetch both APIs in parallel
      final results = await Future.wait([
        _apiService.getFilteredMasterData(),
        _apiService.getOwners(),
      ]);

      final response = results[0];
      final ownerResponse = results[1];

      debugPrint("🔍 Master API type: ${response.runtimeType}");
      debugPrint("🔍 Owner API type: ${ownerResponse.runtimeType}");

      // Normalize master data safely
      Map<String, dynamic> masterData = {};
      if (response is Map<String, dynamic>) {
        masterData = Map<String, dynamic>.from(response);
      } else if (response is Map<String, List>) {
        masterData = Map<String, dynamic>.from(response);
      }

      // Extract lists safely
      final accountTypeData =
          (masterData["AccountType"] ?? masterData["Account Type"]) is List
          ? List.from(
              masterData["AccountType"] ?? masterData["Account Type"] ?? [],
            )
          : [];

      final industryData = masterData["Industry"] is List
          ? List.from(masterData["Industry"])
          : [];

      final ownersData = (ownerResponse is List)
          ? List.from(ownerResponse)
          : [];

      setState(() {
        // --- Account Type ---
        vendorList = accountTypeData
            .whereType<Map>()
            .map<Map<String, dynamic>>(
              (e) => {
                "id": e["id"] ?? e["accountTypeId"] ?? e["value"] ?? "",
                "name":
                    e["name"]?.toString() ??
                    e["display_name"]?.toString() ??
                    e["displayName"]?.toString() ??
                    "",
              },
            )
            .where(
              (item) =>
                  item["id"].toString().isNotEmpty &&
                  item["name"].toString().isNotEmpty,
            )
            .toList();

        // --- Industry ---
        industryList = industryData
            .whereType<Map>()
            .map<Map<String, dynamic>>(
              (e) => {
                "id": e["id"] ?? e["industryId"] ?? e["value"] ?? "",
                "name":
                    e["name"]?.toString() ?? e["displayName"]?.toString() ?? "",
              },
            )
            .where(
              (item) =>
                  item["id"].toString().isNotEmpty &&
                  item["name"].toString().isNotEmpty,
            )
            .toList();

        // --- Owners ---
        ownerList = ownersData
            .whereType<Map>()
            .map<Map<String, dynamic>>(
              (e) => {
                "id": e["id"] ?? e["userId"] ?? "",
                "name":
                    e["display_name"]?.toString() ??
                    e["fullName"]?.toString() ??
                    e["name"]?.toString() ??
                    "",
              },
            )
            .where(
              (item) =>
                  item["id"].toString().isNotEmpty &&
                  item["name"].toString().isNotEmpty,
            )
            .toList();

        // ✅ Match by ID
        selectedOwner = ownerList.firstWhere(
          (item) => item["id"] == updatedAccount["ownerId"],
          orElse: () =>
              ownerList.isNotEmpty ? ownerList.first : {"id": "", "name": ""},
        );

        selectedVendor = vendorList.firstWhere(
          (item) => item["id"] == updatedAccount["accountTypeId"],
          orElse: () =>
              vendorList.isNotEmpty ? vendorList.first : {"id": "", "name": ""},
        );

        selectedIndustry = industryList.firstWhere(
          (item) => item["id"] == updatedAccount["industryId"],
          orElse: () => industryList.isNotEmpty
              ? industryList.first
              : {"id": "", "name": ""},
        );
      });
    } catch (e, st) {
      debugPrint("❌ Error fetching dropdown data: $e");
      debugPrintStack(stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load dropdown data: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ✅ Save logic
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => autoValidate = true);
      return;
    }

    setState(() => isSaving = true);

    updatedAccount["ownerId"] = selectedOwner?["id"];
    updatedAccount["accountTypeId"] = selectedVendor?["id"];
    updatedAccount["industryId"] = selectedIndustry?["id"];
    updatedAccount["website"] = websiteController.text.trim();
    updatedAccount["phone"] = phoneController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    updatedAccount["employees"] =
        int.tryParse(employeesController.text.trim()) ?? 0;
    updatedAccount["annualRevenue"] =
        double.tryParse(revenueController.text.trim()) ?? 0.0;

    try {
      final success = await _apiService.updateAccount(updatedAccount);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Account updated successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, updatedAccount);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to update account: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5733C7), Color(0xFF9A24C3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Edit Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isSaving
                      ? const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: _onSave,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: autoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account Image",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.purple[50],
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          updatedAccount["name"] ?? "Account Name",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Account Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Dynamic Dropdowns (now map-based)
                    _buildDropdownField(
                      "Account Owner",
                      selectedOwner,
                      ownerList,
                      (v) => setState(() => selectedOwner = v),
                    ),
                    _buildDropdownField(
                      "Account Type",
                      selectedVendor,
                      vendorList,
                      (v) => setState(() => selectedVendor = v),
                    ),
                    _buildDropdownField(
                      "Industry",
                      selectedIndustry,
                      industryList,
                      (v) => setState(() => selectedIndustry = v),
                    ),

                    _buildEditableField(
                      "Website",
                      websiteController,
                      isWebsite: true,
                    ),
                    _buildEditableField(
                      "Phone",
                      phoneController,
                      isPhone: true,
                    ),
                    _buildEditableField("Employees", employeesController),
                    _buildEditableField("Annual Revenue", revenueController),
                  ],
                ),
              ),
            ),
    );
  }

  // ✅ Dropdown builder (now supports id–name maps)
  Widget _buildDropdownField(
    String label,
    Map<String, dynamic>? selectedValue,
    List<Map<String, dynamic>> items,
    ValueChanged<Map<String, dynamic>?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          border: const UnderlineInputBorder(),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<Map<String, dynamic>>(
                value: item,
                child: Text(item["name"] ?? ""),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (v) => (v == null || (v["id"] ?? "").isEmpty)
            ? "Please select $label"
            : null,
      ),
    );
  }

  // ✅ Text fields
  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool isPhone = false,
    bool isWebsite = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.number : TextInputType.text,
        inputFormatters: isPhone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                PhoneNumberFormatter(),
              ]
            : [],
        validator: (value) {
          if (isPhone) {
            final digits = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
            if (digits.isEmpty) return "Phone number is required";
            if (digits.length != 10) return "Enter a valid 10-digit number";
          } else if (isWebsite) {
            final website = value?.trim() ?? '';
            final regex = RegExp(
              r'^(https?:\/\/)?([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(\/\S*)?$',
            );
            if (website.isEmpty) return "Website is required";
            if (!regex.hasMatch(website)) return "Enter a valid website URL";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
