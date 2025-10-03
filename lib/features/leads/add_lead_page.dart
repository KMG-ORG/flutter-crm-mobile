import 'package:flutter/material.dart';

class AddLeadPage extends StatefulWidget {
  const AddLeadPage({Key? key}) : super(key: key);

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController faxController = TextEditingController();

  String salutation = "-None-";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Lead", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Save logic here
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader("Lead Image"),
            _buildImageCard(),
            const SizedBox(height: 20),
            _buildSectionHeader("Lead Information"),
            _buildInfoRow("Lead Owner", trailing: "Rahul Mondal"),
            const SizedBox(height: 8),
            _buildTextField("Company", controller: companyController, isRequired: true, icon: Icons.business),
            _buildDropdownField("Salutation", value: salutation, options: ["-None-", "Mr.", "Ms.", "Dr."], icon: Icons.person),
            _buildTextField("First Name", controller: firstNameController, icon: Icons.person),
            _buildTextField("Last Name", controller: lastNameController, isRequired: true, icon: Icons.person_outline),
            _buildTextField("Title", controller: titleController, icon: Icons.title),
            _buildTextField("Email", controller: emailController, keyboardType: TextInputType.emailAddress, icon: Icons.email),
            _buildTextField("Phone", controller: phoneController, keyboardType: TextInputType.phone, icon: Icons.phone),
            _buildTextField("Fax", controller: faxController, keyboardType: TextInputType.number, icon: Icons.print),
            const SizedBox(height: 30),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
      ),
    );
  }

  // Image Card
  Widget _buildImageCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.3),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, size: 50, color: Colors.blueGrey),
              SizedBox(height: 6),
              Text("Upload Photo", style: TextStyle(color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }

  // Info Row
  Widget _buildInfoRow(String title, {String? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: Text(trailing ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  // Text Field
  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: isRequired ? "$label *" : label,
            prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
            border: InputBorder.none,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return "$label is required";
            }
            return null;
          },
        ),
      ),
    );
  }

  // Dropdown Field
  Widget _buildDropdownField(String label,
      {required String value, required List<String> options, IconData? icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.blue) : null,
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
        onTap: () async {
          final result = await showModalBottomSheet<String>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return ListView(
                children: options.map((opt) {
                  return ListTile(
                    title: Text(opt),
                    onTap: () => Navigator.pop(context, opt),
                  );
                }).toList(),
              );
            },
          );
          if (result != null) {
            setState(() => salutation = result);
          }
        },
      ),
    );
  }

  // Save Button
  Widget _buildSaveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.blue.shade700,
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Save Lead action
        }
      },
      child: const Text(
        "Save Lead",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
