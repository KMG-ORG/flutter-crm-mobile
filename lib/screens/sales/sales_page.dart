import 'package:crmMobileUi/services/api_service.dart';
import 'package:flutter/material.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Map<String, dynamic>> sales = [];
  bool isLoading = true;
  String? errorMessage;
  bool isLoadingMore = false;
  bool hasMore = true;
  int pageNumber = 1;
  final int pageSize = 20;
  int totalCount = 0;

  final ScrollController _scrollController = ScrollController();

  bool showSearchBar = false; // 🔍 search bar toggle
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSales(pageNumber);
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
      fetchSales(pageNumber);
    }
  }

  Future<void> fetchSales(int page, [String? search]) async {
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
          await apiService.getSales(payload) as Map<String, dynamic>;

      final List<Map<String, dynamic>> newAccounts =
          (response['data'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      totalCount =
          int.tryParse(response['totalCount']?.toString() ?? '') ?? totalCount;
      setState(() {
        if (page == 1) {
          sales = newAccounts;
        } else {
          sales.addAll(newAccounts);
        }

        hasMore = sales.length < totalCount;
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

  // final List<Map<String, dynamic>> sales = [
  //   {
  //     'name': 'James Merced',
  //     'id': 'SO-2025-00033',
  //     'amount': '\$370,000.00',
  //     'date': '25/09/2025 20:40:00',
  //     'owner': 'John Doe',
  //     'status': 'Cancelled',
  //     'statusColor': Colors.orange.shade100,
  //     'textColor': Colors.orange.shade700,
  //   },
  //   {
  //     'name': 'Social Media Blast',
  //     'id': 'SO-2025-00041',
  //     'amount': '\$500,000.00',
  //     'date': '25/09/2025 17:11:20',
  //     'owner': 'John Doe',
  //     'status': 'Approved',
  //     'statusColor': Colors.green.shade100,
  //     'textColor': Colors.green.shade700,
  //   },
  //   {
  //     'name': 'Email Drip Campaign',
  //     'id': 'SO-2025-00033',
  //     'amount': '\$120,000.00',
  //     'date': '25/09/2025 16:23:00',
  //     'owner': 'John Doe',
  //     'status': 'Back ordered',
  //     'statusColor': Colors.blue.shade100,
  //     'textColor': Colors.blue.shade700,
  //   },
  //   {
  //     'name': 'Product Launch X',
  //     'id': 'SO-2025-00033',
  //     'amount': '\$270,000.00',
  //     'date': '25/09/2025 11:12:00',
  //     'owner': 'John Doe',
  //     'status': 'Cancelled',
  //     'statusColor': Colors.orange.shade100,
  //     'textColor': Colors.orange.shade700,
  //   },
  // ];

  void onSearchPressed() {
    if (showSearchBar) {
      // when already visible → perform search
      fetchSales(1, _searchController.text.trim());
    } else {
      // show the search bar
      setState(() {
        showSearchBar = true;
      });
    }
  }

  Future<void> _refreshSales() async {
    pageNumber = 1;
    hasMore = true;
    await fetchSales(pageNumber);
  }

  void onCancelSearch() {
    setState(() {
      showSearchBar = false;
      _searchController.clear();
    });
    fetchSales(1); // reload all data
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
                  hintText: "Search Sales...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) => fetchSales(1, value),
              )
            : const Text(
                'Sales',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10, left: 4),
              child: Text(
                'All Sales',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(child: Text("Error: $errorMessage"))
                  : sales.isEmpty
                  ? const Center(child: Text("No Sales found"))
                  : RefreshIndicator(
                      onRefresh: _refreshSales,
                      child: ListView.builder(
                        itemCount: sales.length + (isLoadingMore ? 1 : 0),
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          if (index < sales.length) {
                            final sale = sales[index];
                            return saleCard(
                              name: sale['subject'] ?? "Unknown",
                              code: sale['code'] ?? "N/A",
                              amount: (sale['price'] ?? "N/A").toString(),
                              owner: sale['salesOwner'] ?? "N/A",
                              status: (sale['status'] ?? "N/A").toString(),
                              date: sale['dueDate'].toString().split('T')[0],
                              accountOwner: sale['accountName'] ?? "N/A",
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget saleCard({
    required String name,
    required String code,
    required String amount,
    required String owner,
    required String status,
    required String date,
    required String accountOwner,
  }) {
    Color statusColor;
    Color textColor;

    if (status.toLowerCase() == "approved") {
      statusColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
    } else if (status.toLowerCase() == "cancelled") {
      statusColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
    } else {
      statusColor = Colors.blue.shade100;
      textColor = Colors.blue.shade700;
    }
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Stack(
          alignment: Alignment.centerRight,
          // crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(code),
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
                    Text(amount),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(date),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(owner),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.man, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(accountOwner),
                  ],
                ),

                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  icon: const Icon(Icons.checklist, color: Colors.blue),
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
