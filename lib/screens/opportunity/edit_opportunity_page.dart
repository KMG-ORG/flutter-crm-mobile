import 'package:flutter/material.dart';
import 'package:crmMobileUi/services/api_service.dart';

class EditOpportunityPage extends StatefulWidget {
  final Map<String, dynamic> opportunity;

  const EditOpportunityPage({super.key, required this.opportunity});

  @override
  State<EditOpportunityPage> createState() => _EditOpportunityPageState();
}

class _EditOpportunityPageState extends State<EditOpportunityPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> updatedOpportunity;

  // ✅ Controllers (each field is now independent)
  //late TextEditingController contactNameController;
  late TextEditingController sourceNameController;
  late TextEditingController opportunityNameController;
  late TextEditingController nextStepController;

  // ✅ Dropdown lists
  List<Map<String, dynamic>> accountList = [];
  List<Map<String, dynamic>> contactList = [];
  List<Map<String, dynamic>> stageList = [];
  List<Map<String, dynamic>> industryList = [];
  List<Map<String, dynamic>> leadSourceList = [];
  List<Map<String, dynamic>> sourceNameList = [];

  // ✅ Selected values
  Map<String, dynamic>? selectedAccount;
  Map<String, dynamic>? selectedContact;
  Map<String, dynamic>? selectedStage;
  Map<String, dynamic>? selectedIndustry;
  Map<String, dynamic>? selectedLeadSource;
  Map<String, dynamic>? selectedSourceName;

  bool isSaving = false;
  bool isLoading = false;
  bool autoValidate = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    updatedOpportunity = Map<String, dynamic>.from(widget.opportunity);

    // ✅ Initialize controllers with safe null checks
    // contactNameController = TextEditingController(
    //   text: updatedOpportunity["contact"] ?? "",
    // );

    sourceNameController = TextEditingController(
      text: updatedOpportunity["sourceName"] ?? "",
    );

    opportunityNameController = TextEditingController(
      text: updatedOpportunity["name"] ?? "",
    );

    nextStepController = TextEditingController(
      text: updatedOpportunity["nextStep"] ?? "",
    );

    _fetchMasterDropdownData();
  }

  @override
  void dispose() {
    //contactNameController.dispose();
    sourceNameController.dispose();
    opportunityNameController.dispose();
    nextStepController.dispose();
    super.dispose();
  }

  // ✅ Fetch dropdown data
  Future<void> _fetchMasterDropdownData() async {
    try {
      setState(() => isLoading = true);

      final accountPayload = {
        "searchText": "",
        "pageNumber": 1,
        "pageSize": 50,
      };

      // ✅ Fetch dropdown data in parallel
      final results = await Future.wait([
        _apiService.getFilteredMasterData(), // For Industry, Stage, LeadSource
        _apiService.getAccountNamesList(accountPayload),
      ]);

      final masterResponse = results[0];
      final accountResponse = results[1]; // This is List<Map<String, dynamic>>

      debugPrint("🔍 Master API type: ${masterResponse.runtimeType}");
      debugPrint("🔍 Account API type: ${accountResponse.runtimeType}");

      Map<String, dynamic> masterData = {};
      if (masterResponse is Map<String, dynamic>) {
        masterData = Map<String, dynamic>.from(masterResponse);
      } else if (masterResponse is Map<String, List>) {
        masterData = Map<String, dynamic>.from(masterResponse);
      }

      final stageData =
          (masterData["Stage"] ?? masterData["OpportunityStage"]) is List
          ? List.from(
              masterData["Stage"] ?? masterData["OpportunityStage"] ?? [],
            )
          : [];

      final industryData = masterData["Industry"] is List
          ? List.from(masterData["Industry"])
          : [];

      final leadSourceData = masterData["LeadSource"] is List
          ? List.from(masterData["LeadSource"])
          : [];

      setState(() {
        // --- Account Dropdown ---
        accountList = (accountResponse as List<Map<String, dynamic>>)
            .where(
              (e) =>
                  (e["id"] ?? e["accountId"] ?? "").toString().isNotEmpty &&
                  (e["name"] ?? e["accountName"] ?? "").toString().isNotEmpty,
            )
            .map<Map<String, dynamic>>(
              (e) => {
                "id": e["id"] ?? e["accountId"] ?? "",
                "name":
                    e["name"]?.toString() ?? e["accountName"]?.toString() ?? "",
              },
            )
            .toList();

        // --- Stage Dropdown ---
        stageList = stageData
            .whereType<Map>()
            .map<Map<String, dynamic>>(
              (e) => {
                "id": e["id"] ?? e["stageId"] ?? e["value"] ?? "",
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

        // --- Industry Dropdown ---
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

        // --- Lead Source Dropdown ---
        leadSourceList = leadSourceData
            .whereType<Map>()
            .map<Map<String, dynamic>>(
              (e) => {
                "id": e["id"] ?? e["leadSourceId"] ?? e["value"] ?? "",
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

        // ✅ Preselect previously saved values
        selectedAccount = _findSelected(
          accountList,
          updatedOpportunity["accountId"],
        );
        selectedStage = _findSelected(stageList, updatedOpportunity["stageId"]);
        selectedIndustry = _findSelected(
          industryList,
          updatedOpportunity["industryId"],
        );
        selectedLeadSource = _findSelected(
          leadSourceList,
          updatedOpportunity["leadSourceId"],
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

  // ✅ Find selected item by ID
  Map<String, dynamic>? _findSelected(
    List<Map<String, dynamic>> list,
    dynamic id,
  ) {
    return list.firstWhere(
      (e) => e["id"].toString() == (id?.toString() ?? ""),
      orElse: () => list.isNotEmpty ? list.first : {"id": "", "name": ""},
    );
  }

  // ✅ Save logic
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => autoValidate = true);
      return;
    }

    setState(() => isSaving = true);

    final Map<String, dynamic> payload = Map<String, dynamic>.from(
      updatedOpportunity,
    );

    // ✅ Update values only if changed
    if (opportunityNameController.text.trim() !=
        (updatedOpportunity["name"] ?? "")) {
      payload["name"] = opportunityNameController.text.trim();
    }

    if (nextStepController.text.trim() !=
        (updatedOpportunity["nextStep"] ?? "")) {
      payload["nextStep"] = nextStepController.text.trim();
    }

    // if (contactNameController.text.trim() !=
    //     (updatedOpportunity["contact"] ?? "")) {
    //   payload["contact"] = contactNameController.text.trim();
    // }

    if (sourceNameController.text.trim() !=
        (updatedOpportunity["sourceName"] ?? "")) {
      payload["sourceName"] = sourceNameController.text.trim();
    }

    if (selectedAccount?["id"] != updatedOpportunity["accountId"]) {
      payload["accountId"] = selectedAccount?["id"];
    }

    if (selectedStage?["id"] != updatedOpportunity["stageId"]) {
      payload["stageId"] = selectedStage?["id"];
    }

    if (selectedIndustry?["id"] != updatedOpportunity["industryId"]) {
      payload["industryId"] = selectedIndustry?["id"];
    }

    if (selectedLeadSource?["id"] != updatedOpportunity["leadSourceId"]) {
      payload["leadSourceId"] = selectedLeadSource?["id"];
    }

    try {
      final success = await _apiService.updateOpportunity(payload);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Opportunity updated successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, payload);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to update opportunity: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                    "Edit Opportunity",
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
                      "Opportunity Overview",
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
                            Icons.business_center,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          updatedOpportunity["name"] ?? "Opportunity Name",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Opportunity Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildDropdownField(
                      "Account Name",
                      selectedAccount,
                      accountList,
                      (v) => setState(() => selectedAccount = v),
                    ),
                    //_buildEditableField("Contact Name", contactNameController),
                    _buildDropdownField(
                      "Stage",
                      selectedStage,
                      stageList,
                      (v) => setState(() => selectedStage = v),
                    ),
                    _buildDropdownField(
                      "Industry",
                      selectedIndustry,
                      industryList,
                      (v) => setState(() => selectedIndustry = v),
                    ),
                    _buildDropdownField(
                      "Lead Source",
                      selectedLeadSource,
                      leadSourceList,
                      (v) => setState(() => selectedLeadSource = v),
                    ),
                    _buildEditableField("Source Name", sourceNameController),
                    _buildEditableField(
                      "Opportunity Name",
                      opportunityNameController,
                    ),
                    _buildEditableField("Next Step", nextStepController),
                  ],
                ),
              ),
            ),
    );
  }

  // ✅ Dropdown builder
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

  // ✅ Text field builder
  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
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
