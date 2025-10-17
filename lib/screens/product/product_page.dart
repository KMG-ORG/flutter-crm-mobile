import 'package:crm_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? errorMessage;
  bool isLoadingMore = false;
  bool hasMore = true;
  int pageNumber = 1;
  final int pageSize = 20;
  int totalCount = 0;
  final ScrollController _scrollController = ScrollController();

  bool showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts(pageNumber);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      pageNumber++;
      fetchProducts(pageNumber);
    }
  }

  /// 🔹 Fetch Products from API
  Future<void> fetchProducts(int page, [String? search]) async {
    try {
      if (page == 1) {
        setState(() => isLoading = true);
      } else {
        setState(() => isLoadingMore = true);
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

      final response =
          await apiService.getProducts(payload) as Map<String, dynamic>;

      final List<Map<String, dynamic>> newProducts =
          (response['data'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      totalCount =
          int.tryParse(response['totalCount']?.toString() ?? '') ?? totalCount;

      setState(() {
        if (page == 1) {
          products = newProducts;
        } else {
          products.addAll(newProducts);
        }

        hasMore = products.length < totalCount;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
        errorMessage = e.toString();
      });
    }
  }

  /// 🔹 Search Handling
  void onSearchPressed() {
    if (showSearchBar) {
      fetchProducts(1, _searchController.text.trim());
    } else {
      setState(() => showSearchBar = true);
    }
  }

  void onCancelSearch() {
    setState(() {
      showSearchBar = false;
      _searchController.clear();
    });
    fetchProducts(1);
  }

  Future<void> _refreshProducts() async {
    pageNumber = 1;
    hasMore = true;
    await fetchProducts(pageNumber);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade100;
      case 'inactive':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔹 Updated App Bar with Search Integration
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B2FF7), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search products...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) => fetchProducts(1, value.trim()),
              )
            : const Text(
                "Products",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
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
      ),

      /// 🔹 Body Section
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshProducts,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "All Products",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.filter_list, color: Colors.grey),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount:
                          products.length +
                          (isLoadingMore ? 1 : 0), // loader at bottom
                      itemBuilder: (context, index) {
                        if (index == products.length) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = products[index];

                        final name =
                            item['productName'] ??
                            item['name'] ??
                            'Unnamed Product';
                        final id = item['productCode'] ?? item['id'] ?? 'N/A';
                        final company =
                            item['companyName'] ??
                            item['company'] ??
                            'Unknown Company';
                        final date = formatDate(
                          item['salesStartDate'] ?? item['date'],
                        );

                        // ✅ Unified status logic
                        final bool isActive =
                            item['productActive'] == true ||
                            item['isActive'] == true ||
                            (item['status']?.toString().toLowerCase() ==
                                'active');
                        final String status = isActive ? 'Active' : 'Inactive';

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Title + Menu
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.more_vert,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Product ID
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.badge_outlined,
                                      color: Colors.deepPurple,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      id,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Company Name
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.business_outlined,
                                      color: Colors.deepPurple,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      company,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Date + User
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      color: Colors.deepPurple,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.person_outline,
                                      color: Colors.deepPurple,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      (item['productOwner'] ?? 'Unknown User')
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Status Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: getStatusTextColor(status),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

      /// 🔹 Floating Action Button
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: const Color(0xFF7B2FF7),
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF7B2FF7), Color(0xFF9C27B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SpeedDial(
          child: const Icon(Icons.add, color: Colors.white),
          activeChild: const Icon(Icons.close, color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.shopping_bag),
              label: 'Create Product',
              onTap: () {
                // TODO: Navigate to Add Product Page
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.download),
              label: 'Import Products',
              onTap: () {
                // TODO: Handle Import
              },
            ),
          ],
        ),
      ),
    );
  }
}
