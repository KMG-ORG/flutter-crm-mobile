import 'package:crm_mobile/services/api_service.dart';
import 'package:flutter/material.dart';

class AccountsPage extends StatefulWidget {
  final VoidCallback onClose;
  const AccountsPage({super.key, required this.onClose});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Map<String, dynamic>> accounts = [];
  bool isLoading = true;
  String? errorMessage;
  //const AccountsPage({super.key});
  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    try {
      final apiService = ApiService();
      final data = await apiService.getAccounts();
      setState(() {
        accounts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Accounts",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        //leading: const Icon(Icons.arrow_back),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onClose,
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add_circle_outline),
        //     onPressed: () {},
        //   ),
        // ],
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              //colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              colors: [Color(0xFF5733C7), Color(0xFF9A24C3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // All Contacts Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "All Accounts",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                //Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              ],
            ),
          ),

          // Contacts List
          // Expanded(
          //   child: ListView(
          //     children: [
          //       contactCard(
          //         name: "WebHub",
          //         category: "P&C Insurance",
          //         website: "www.webhub.io",
          //         type: "Customer",
          //         phone: "123-545-7888",
          //         email: "",
          //         amount: "\$500,000.00",
          //       ),
          //       contactCard(
          //         name: "FutureSoft",
          //         category: "",
          //         website: "www.futuresoft.co",
          //         type: "Customer",
          //         phone: "3690414243",
          //         email: "christopher-maclead@noemail.invalid",
          //         amount: "\$500,000.00",
          //       ),
          //       contactCard(
          //         name: "GreenWave",
          //         category: "",
          //         website: "www.greenwave.in",
          //         type: "Vendor",
          //         phone: "8974564564",
          //         email: "christopher-maclead@noemail.invalid",
          //         amount: "\$120,000.00",
          //       ),
          //       contactCard(
          //         name: "BrightTech Pvt Ltd",
          //         category: "",
          //         website: "www.brighttech.com",
          //         type: "Customer",
          //         phone: "9845646464",
          //         email: "christopher-maclead@noemail.invalid",
          //         amount: "\$270,000.00",
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text("Error: $errorMessage"))
                : RefreshIndicator(
                    onRefresh: fetchAccounts, // 👈 call accounts fetch method
                    child: ListView.builder(
                      itemCount: accounts.length, // 👈 use accounts list
                      itemBuilder: (context, index) {
                        final account = accounts[index]; // 👈 each account
                        return InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => AccountViewPage( // 👈 open details page
                            //       accountData: account,
                            //     ),
                            //   ),
                            // );
                          },
                          child: contactCard(
                            // 👈 your custom card
                            name: account["name"] ?? "Unknown",
                            category: account["industry"] ?? "N/A",
                            website: account["website"] ?? "N/A",
                            phone: account["phone"] ?? "N/A",
                            email: account["createdBy"] ?? "N/A",
                            type: account["accountType"] ?? "N/A",
                            amount: (account["annualRevenue"] ?? "0")
                                .toString(),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget contactCard({
    required String name,
    required String category,
    required String website,
    required String type,
    required String phone,
    required String email,
    required dynamic amount,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            // Main body column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Category
                if (category.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.apartment_outlined,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    const Icon(Icons.language, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        website,
                        style: const TextStyle(color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Person/Type (new separate row)
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(type, style: const TextStyle(color: Colors.black54)),
                  ],
                ),

                // Email
                if (email.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.purple),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                // Phone text only (button moved to Stack)
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(phone),
                  ],
                ),

                // Amount
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      amount,
                      style: const TextStyle(
                        //fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Phone icon floating on right
            Positioned(
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.blue),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
