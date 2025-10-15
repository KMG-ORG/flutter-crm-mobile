import 'package:crmMobileUi/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  List<Map<String, dynamic>> campaigns = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int pageNumber = 1;
  final int pageSize = 20;
  bool showSearchBar = false;
  int totalCount = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCampaigns(pageNumber);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      pageNumber++;
      fetchCampaigns(pageNumber);
    }
  }

  Future<void> fetchCampaigns(int page, [String? search]) async {
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
        'columnName': 'CreatedDate',
        'orderType': 'desc',
        'filterJson': null,
        'searchText': (search != null && search.trim().isNotEmpty)
            ? search.trim()
            : null,
      };

      final response =
          await apiService.getCampaigns(payload) as Map<String, dynamic>;

      final List<Map<String, dynamic>> newCampaigns =
          (response['data'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      totalCount =
          int.tryParse(response['totalCount']?.toString() ?? '') ?? totalCount;

      setState(() {
        if (page == 1) {
          campaigns = newCampaigns;
        } else {
          campaigns.addAll(newCampaigns);
        }
        hasMore = campaigns.length < totalCount;
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

  Future<void> _refreshCampaigns() async {
    pageNumber = 1;
    hasMore = true;
    await fetchCampaigns(pageNumber);
  }

  void onSearchPressed() {
    if (showSearchBar) {
      // when already visible → perform search
      fetchCampaigns(1, _searchController.text.trim());
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
    fetchCampaigns(1); // reload all data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search Campaigns...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                //onSubmitted: (value) => fetchCampaigns(1, value),
              )
            : const Text(
                "Campaigns",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
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
            //onPressed: () {},
          ),
          if (showSearchBar)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onCancelSearch,
              //onPressed: () {},
            )
          else
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () {},
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Campaigns",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : campaigns.isEmpty
                  ? const Center(child: Text("No campaigns found"))
                  : RefreshIndicator(
                      onRefresh: _refreshCampaigns,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: campaigns.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < campaigns.length) {
                            final campaign = campaigns[index];
                            return CampaignCard(
                              campaign: {
                                'title':
                                    campaign['campaignName'] ??
                                    'Untitled Campaign',
                                'type': campaign['campaignType'] ?? 'N/A',
                                'budget': campaign['budget'] ?? 0,
                                'date':
                                    campaign['date'] ??
                                    DateTime.now().toString(),
                                'owner': campaign['owner'] ?? 'Unknown',
                                'status': campaign['campaignStatus'] ?? 'N/A',
                              },
                            );
                          } else {
                            // Loader for pagination (infinite scroll)
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
}

class CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;

  const CampaignCard({super.key, required this.campaign});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return const Color.fromARGB(255, 135, 205, 138);
      case 'inactive':
        return Colors.orange.shade100;
      case 'planning':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return Colors.white;
      case 'inactive':
        return Colors.orange;
      case 'planning':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = campaign['title']?.toString().trim() ?? 'N/A';
    final type = campaign['type']?.toString().trim() ?? 'N/A';
    final owner = campaign['owner']?.toString().trim() ?? 'Unknown';
    final status = campaign['status']?.toString().trim() ?? 'Unknown';

    final budget = (campaign['budget'] != null)
        ? NumberFormat.currency(
            symbol: "\$",
            decimalDigits: 2,
          ).format(double.tryParse(campaign['budget'].toString()) ?? 0)
        : "\$0.00";

    // Handle invalid or missing date safely
    String formattedDate = 'N/A';
    if (campaign['date'] != null && campaign['date'].toString().isNotEmpty) {
      try {
        final date = DateTime.parse(campaign['date']);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
      } catch (_) {
        formattedDate = 'Invalid Date';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Type
                  Row(
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type,
                        style: const TextStyle(
                          //color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Budget
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.purple,
                      ),
                      Text(budget, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Owner
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        owner,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusTextColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Icon container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.task_alt_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
