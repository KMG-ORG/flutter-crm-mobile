import 'package:flutter/material.dart';

// class AddEditContactScreen extends StatefulWidget {
//   const AddEditContactScreen({super.key});

//   @override
//   State<AddEditContactScreen> createState() => _AddEditContactScreenState();
// }

class AddEditContactScreen extends StatefulWidget {
  final Map<String, String>? contact; // null = Add mode, not null = Edit mode

  const AddEditContactScreen({Key? key, this.contact}) : super(key: key);

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController skypeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController technologyStackController =
      TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  // Dropdown values
  String? selectedSalutation;
  String? selectedContactOwner;
  String? selectedLeadSource;

  // Sample dropdown options
  final List<String> salutations = ["Mr.", "Mrs.", "Ms.", "Dr."];
  final List<String> contactOwners = ["John Doe", "Jane Smith", "Alice"];
  final List<String> leadSources = ["Referral", "Website", "Advertisement"];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.contact != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Contact" : "Create New Contact"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // Contact Information
              // =========================
              const Text(
                "Contact Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Salutation Dropdown
              DropdownButtonFormField<String>(
                value: selectedSalutation,
                decoration: const InputDecoration(
                  labelText: "Salutation",
                  border: OutlineInputBorder(),
                ),
                items: salutations
                    .map(
                      (salutation) => DropdownMenuItem(
                        value: salutation,
                        child: Text(salutation),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSalutation = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select salutation" : null,
              ),
              const SizedBox(height: 10),

              // First Name
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter first name" : null,
              ),
              const SizedBox(height: 10),

              // Last Name
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter last name" : null,
              ),
              const SizedBox(height: 20),

              // =========================
              // General Information
              // =========================
              const Text(
                "General Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Contact Owner Dropdown
              DropdownButtonFormField<String>(
                value: selectedContactOwner,
                decoration: const InputDecoration(
                  labelText: "Contact Owner",
                  border: OutlineInputBorder(),
                ),
                items: contactOwners
                    .map(
                      (owner) =>
                          DropdownMenuItem(value: owner, child: Text(owner)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedContactOwner = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select contact owner" : null,
              ),
              const SizedBox(height: 10),

              // Lead Source Dropdown
              DropdownButtonFormField<String>(
                value: selectedLeadSource,
                decoration: const InputDecoration(
                  labelText: "Lead Source",
                  border: OutlineInputBorder(),
                ),
                items: leadSources
                    .map(
                      (source) =>
                          DropdownMenuItem(value: source, child: Text(source)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLeadSource = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select lead source" : null,
              ),
              const SizedBox(height: 20),

              // =========================
              // Social Media
              // =========================
              const Text(
                "Social Media",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // LinkedIn
              TextFormField(
                controller: linkedinController,
                decoration: const InputDecoration(
                  labelText: "LinkedIn",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Twitter
              TextFormField(
                controller: twitterController,
                decoration: const InputDecoration(
                  labelText: "Twitter",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Facebook
              TextFormField(
                controller: facebookController,
                decoration: const InputDecoration(
                  labelText: "Facebook",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Skype ID
              TextFormField(
                controller: skypeController,
                decoration: const InputDecoration(
                  labelText: "Skype ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // =========================
              // Address Information
              // =========================
              const Text(
                "Address Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Street
              TextFormField(
                controller: streetController,
                decoration: const InputDecoration(
                  labelText: "Street",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // City
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: "Enter City",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // State
              TextFormField(
                controller: stateController,
                decoration: const InputDecoration(
                  labelText: "Enter State",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Country
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: "Enter Country",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Zip Code
              TextFormField(
                controller: zipCodeController,
                decoration: const InputDecoration(
                  labelText: "Enter Zip Code",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // =========================
              // Notes & Tech Details
              // =========================
              const Text(
                "Notes & Tech Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Tecnology Stack
              TextFormField(
                controller: technologyStackController,
                decoration: const InputDecoration(
                  labelText: "Technology Stack",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  // Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null // disable button while loading
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                // Simulate a network call or save delay
                                await Future.delayed(
                                  const Duration(seconds: 2),
                                );

                                setState(() {
                                  isLoading = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Contact Saved"),
                                  ),
                                );

                                Navigator.pop(
                                  context,
                                ); // optional: go back after saving
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEditMode ? "Update" : "Add",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10), // space between buttons
                  // Cancel Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pop(context); // cancel action
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
