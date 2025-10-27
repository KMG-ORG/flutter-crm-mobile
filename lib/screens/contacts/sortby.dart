import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crm_mobile/services/api_service.dart';
import 'contact_page.dart';

class SortByScreen extends StatefulWidget {
  const SortByScreen({super.key});

  @override
  State<SortByScreen> createState() => _SortByScreenState();
}

class _SortByScreenState extends State<SortByScreen> {
  // Field labels shown in dropdown (Title Case) → backend keys (lowercase)
  final Map<String, String> fieldMap = {
    'Full Name': 'fullName',
    'Account': 'account',
    'Email': 'email',
    'Phone': 'phone',
  };

  // Filter fields mapping
  final Map<String, String> filterFieldMap = {
    'Full Name': 'fullName',
    'Account': 'account',
    'Email': 'email',
    'Phone': 'phone',
  };

  // State variables
  String selectedFieldLabel = 'Full Name';
  String selectedFilterLabel = 'Full Name';
  String sortOrder = 'desc';
  String selectedOperator = 'contains';
  String pageNumber = '1';
  String pageSize = '50';
  bool isLoading = false;
  String filterValue = '';

  final TextEditingController filterValueController = TextEditingController();
  final ApiService apiService = ApiService();

  final List<String> operators = ['contains', 'equals', 'notEquals'];
  final List<String> pageNumbers = ['1', '2', '3'];
  final List<String> pageSizes = ['10', '25', '50', '100'];

  // === Apply filter and call API ===
  Future<void> _applyFilters() async {
    setState(() => isLoading = true);

    try {
      // Convert label to actual backend key
      final filterField = filterFieldMap[selectedFilterLabel]!;
      final columnName = fieldMap[selectedFieldLabel]!;

      final Map<String, dynamic> filterJsonMap = {
        filterField: {
          "filterType": "text",
          "type": selectedOperator.toLowerCase(),
          "filter": filterValueController.text.trim(),
        },
      };

      final payload = {
        "pageSize": int.parse(pageSize),
        "pageNumber": int.parse(pageNumber),
        "columnName": columnName,
        "orderType": sortOrder.toLowerCase(),
        "filterJson": jsonEncode(filterJsonMap),
        "searchText": null,
      };

      print("Final Payload Sent to API → $payload");

      final response = await apiService.getContacts(payload);

      if (response != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ContactsPage(
              onClose: () => Navigator.pop(context),
              filteredContacts: response['data'],
            ),
          ),
        );
      }
    } catch (e) {
      print("Error during filter apply: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to fetch data")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // === Dropdown builder ===
  Widget _buildDropdown(
    List<String> items,
    String selected,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButton<String>(
        value: selected,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
      ),
    );
  }

  // === UI ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Sort & Filter",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // === Sort By ===
                          const Text(
                            "Sort By Field",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            fieldMap.keys.toList(),
                            selectedFieldLabel,
                            (v) => setState(() => selectedFieldLabel = v!),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Radio<String>(
                                value: 'asc',
                                groupValue: sortOrder,
                                onChanged: (v) =>
                                    setState(() => sortOrder = v!),
                                activeColor: const Color(0xFF7F00FF),
                              ),
                              const Text("Ascending"),
                              const SizedBox(width: 20),
                              Radio<String>(
                                value: 'desc',
                                groupValue: sortOrder,
                                onChanged: (v) =>
                                    setState(() => sortOrder = v!),
                                activeColor: const Color(0xFF7F00FF),
                              ),
                              const Text("Descending"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // === Advance Filter ===
                          const Text(
                            "Advance Filter",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text("Select Field"),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            filterFieldMap.keys.toList(),
                            selectedFilterLabel,
                            (v) => setState(() => selectedFilterLabel = v!),
                          ),

                          const SizedBox(height: 16),
                          const Text("Operator"),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            operators,
                            selectedOperator,
                            (v) => setState(() => selectedOperator = v!),
                          ),

                          const SizedBox(height: 16),
                          const Text("Value"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: filterValueController,
                            decoration: InputDecoration(
                              hintText: "Enter filter value",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (v) => filterValue = v,
                          ),

                          const SizedBox(height: 16),
                          const Text("Page Number"),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            pageNumbers,
                            pageNumber,
                            (v) => setState(() => pageNumber = v!),
                          ),

                          const SizedBox(height: 16),
                          const Text("Page Size"),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            pageSizes,
                            pageSize,
                            (v) => setState(() => pageSize = v!),
                          ),

                          const SizedBox(height: 30),

                          // === Buttons ===
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _applyFilters,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7F00FF),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Apply",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.grey),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
