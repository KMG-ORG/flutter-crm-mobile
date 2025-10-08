import 'package:crm_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class AccountsPage extends StatefulWidget {
  final VoidCallback onClose;
  const AccountsPage({super.key, required this.onClose});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Map<String, dynamic>> accounts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool showSearchBar = false;
  int pageNumber = 1;
  final int pageSize = 200;
  int totalCount = 0;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAccounts(pageNumber);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger only if near bottom, not already loading, and more data exists
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      pageNumber++;
      fetchAccounts(pageNumber);
    }
  }

  Future<void> fetchAccounts(int page, [String? search]) async {
    try {
      if (page == 1) {
        setState(() {
          isLoading = true;
        });
      } else {
        setState(() {
          isLoadingMore = true;
        });
      }

      final apiService = ApiService();

      final payload = {
        'pageSize': pageSize,
        'pageNumber': page,
        'columnName': 'UpdatedDateTime',
        'orderType': 'desc',
        'filterJson': null,
        'searchText': (search != null && search.trim().isNotEmpty)
            ? search.trim()
            : null,
      };

      // final response = await apiService.getAccounts(
      //   payload,
      // ); // 🔹 Adjust API call
      final response =
          await apiService.getAccounts(payload) as Map<String, dynamic>;

      final List<Map<String, dynamic>> newAccounts =
          (response['data'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      totalCount =
          int.tryParse(response['totalCount']?.toString() ?? '') ?? totalCount;
      setState(() {
        if (page == 1) {
          accounts = newAccounts;
        } else {
          accounts.addAll(newAccounts);
        }

        hasMore = accounts.length < totalCount;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void onSearchPressed() {
    if (showSearchBar) {
      // when already visible → perform search
      fetchAccounts(1, _searchController.text.trim());
    } else {
      // show the search bar
      setState(() {
        showSearchBar = true;
      });
    }
  }

  void onCancelSearch() {
    setState(() {
      showSearchBar = false;
      _searchController.clear();
    });
    fetchAccounts(1); // reload all data
  }

  Future<void> _refreshAccounts() async {
    pageNumber = 1;
    hasMore = true;
    await fetchAccounts(pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search Accounts...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) => fetchAccounts(1, value),
              )
            : const Text(
                "Accounts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onClose,
        ),
        actions: [
          IconButton(
            icon: Icon(
              showSearchBar ? Icons.check : Icons.search,
              color: Colors.white,
            ),
            onPressed: onSearchPressed,
          ),
          if (showSearchBar)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onCancelSearch,
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              // child: IconButton(
              //   icon: const Icon(Icons.add, color: Colors.white),
              //   onPressed: () {},
              // ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
          ? const Center(child: Text("No accounts found"))
          : RefreshIndicator(
              onRefresh: _refreshAccounts,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: accounts.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < accounts.length) {
                    final account = accounts[index];
                    return contactCard(
                      name: account["name"] ?? "Unknown",
                      category: account["industry"] ?? "N/A",
                      website: account["website"] ?? "N/A",
                      phone: account["phone"] ?? "N/A",
                      email: account["createdBy"] ?? "N/A",
                      type: account["accountType"] ?? "N/A",
                      amount: (account["annualRevenue"] ?? "0").toString(),
                    );
                  } else {
                    // Loading indicator at bottom
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF5733C7), Color(0xFF9A24C3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SpeedDial(
          //icon: Icons.add,
          child: const Icon(Icons.add, color: Colors.white),
          activeChild: const Icon(Icons.close, color: Colors.white),
          activeIcon: Icons.close,
          backgroundColor: Colors.transparent, // Let gradient show
          elevation: 0, // remove shadow for clean gradient

          children: [
            SpeedDialChild(
              child: const Icon(Icons.person),
              label: 'Create Accounts',
              onTap: () {
                // Your create accounts logic
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.download),
              label: 'Import Accounts',
              onTap: () {
                // Your import accounts logic
              },
            ),
          ],
        ),
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
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
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
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(type, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
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
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(phone),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(amount, style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ],
            ),
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
