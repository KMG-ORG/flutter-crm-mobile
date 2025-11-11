import 'package:crmMobileUi/screens/opportunity/edit_opportunity_page.dart';
import 'package:flutter/material.dart';
import 'package:crmMobileUi/services/api_service.dart';
import 'package:intl/intl.dart';

class OpportunityPage extends StatefulWidget {
  //final VoidCallback onClose;
  const OpportunityPage({super.key});

  @override
  State<OpportunityPage> createState() => _OpportunityPageState();
}

class _OpportunityPageState extends State<OpportunityPage> {
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool showSearchBar = false;
  int pageNumber = 1;
  final int pageSize = 100;
  int totalCount = 0;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> opportunities = [];

  @override
  void initState() {
    super.initState();
    fetchOpportutnity(pageNumber);
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
      fetchOpportutnity(pageNumber);
    }
  }

  void onSearchPressed() {
    if (showSearchBar) {
      fetchOpportutnity(1, _searchController.text.trim());
    } else {
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
    fetchOpportutnity(1);
  }

  Future<void> fetchOpportutnity(int page, [String? search]) async {
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

      final response =
          await apiService.getOpportunity(payload) as Map<String, dynamic>;

      final List<Map<String, dynamic>> newOpportunity =
          (response['data'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      totalCount =
          int.tryParse(response['totalCount']?.toString() ?? '') ?? totalCount;
      setState(() {
        if (page == 1) {
          opportunities = newOpportunity;
        } else {
          opportunities.addAll(newOpportunity);
        }

        hasMore = opportunities.length < totalCount;
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

  Future<void> _refreshOpportutnity() async {
    pageNumber = 1;
    hasMore = true;
    await fetchOpportutnity(pageNumber);
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      final parsedDate = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return "N/A"; // in case of invalid format
    }
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
                  hintText: "Search Opportunity",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) => fetchOpportutnity(1, value),
              )
            : const Text(
                "Opportunity",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          //onPressed: widget.onClose,
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
            )
          else
            // Container(
            //   margin: const EdgeInsets.only(right: 12),
            //   decoration: BoxDecoration(
            //     color: Colors.white.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   // child: IconButton(
            //   //   icon: const Icon(Icons.add, color: Colors.white),
            //   //   onPressed: () {},
            //   // ),
            // ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () {},
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "All Opportunity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),
            const SizedBox(height: 10),

            // List of opportunities
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : opportunities.isEmpty
                  ? const Center(child: Text("No opportunities found"))
                  : RefreshIndicator(
                      onRefresh: _refreshOpportutnity,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            opportunities.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < opportunities.length) {
                            final opp = opportunities[index];
                            // return OpportunityCard(
                            //   name: opp['name'] ?? "N/A",
                            //   stage: opp['stage'] ?? "N/A",
                            //   //amount: opp['amount']!,
                            //   amount: (opp['amount'] ?? "0").toString(),
                            //   //date: opp['closingDate'] ?? "N/A",
                            //   date: _formatDate(opp['closingDate']),
                            //   owner: opp['owner'] ?? "N/A",
                            // );
                            return GestureDetector(
                              onTap: () async {
                                // Navigate to EditOpportunityPage
                                final updatedOpportunity = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditOpportunityPage(opportunity: opp),
                                  ),
                                );

                                // ✅ Optional: refresh list if user saved changes
                                // if (updatedOpportunity != null) {
                                //   setState(() {
                                //     final index = opportunities.indexWhere(
                                //       (item) =>
                                //           item['id'] ==
                                //           updatedOpportunity['id'],
                                //     );
                                //     if (index != -1) {
                                //       opportunities[index] = updatedOpportunity;
                                //     }
                                //   });
                                // }
                                if (updatedOpportunity != null) {
                                  await _refreshOpportutnity(); // refresh list from API
                                }
                              },
                              child: OpportunityCard(
                                name: opp['name'] ?? "N/A",
                                stage: opp['stage'] ?? "N/A",
                                amount: (opp['amount'] ?? "0").toString(),
                                date: _formatDate(opp['closingDate']),
                                owner: opp['owner'] ?? "N/A",
                              ),
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
}

class OpportunityCard extends StatelessWidget {
  final String name;
  final String stage;
  final String amount;
  final String date;
  final String owner;

  const OpportunityCard({
    Key? key,
    required this.name,
    required this.stage,
    required this.amount,
    required this.date,
    required this.owner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF7B61FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.assignment, color: purpleColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      stage,
                      style: const TextStyle(
                        color: purpleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: purpleColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      amount,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: purpleColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(date),
                    // const SizedBox(width: 10),
                    // const Icon(Icons.person, color: purpleColor, size: 16),
                    // const SizedBox(width: 4),
                    // Text(owner),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person, color: purpleColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      owner,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right side icon
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAFF),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.list_alt, color: purpleColor),
          ),
        ],
      ),
    );
  }
}
