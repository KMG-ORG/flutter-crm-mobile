import 'package:flutter/material.dart';
import 'package:crm_mobile/services/api_service.dart';
import 'package:intl/intl.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  List<Map<String, dynamic>> tickets = [];
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
    fetchTickets(pageNumber);
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
      fetchTickets(pageNumber);
    }
  }

  Future<void> fetchTickets(int page, [String? search]) async {
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
          await apiService.getTickets(payload) as Map<String, dynamic>;

      final List<Map<String, dynamic>> newTickets =
          (response['data'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      totalCount =
          int.tryParse(response['totalCount']?.toString() ?? '') ?? totalCount;

      setState(() {
        if (page == 1) {
          tickets = newTickets;
        } else {
          tickets.addAll(newTickets);
        }
        hasMore = tickets.length < totalCount;
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

  Future<void> _refreshTickets() async {
    pageNumber = 1;
    hasMore = true;
    await fetchTickets(pageNumber);
  }

  void onSearchPressed() {
    if (showSearchBar) {
      // when already visible → perform search
      fetchTickets(1, _searchController.text.trim());
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
    fetchTickets(1); // reload all data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        //title: const Text("Tickets", style: TextStyle(color: Colors.white)),
        title: showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search Tickets...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) => fetchTickets(1, value),
              )
            : const Text(
                "Tickets",
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
            // icon: const Icon(Icons.search, color: Colors.white),
            icon: Icon(
              showSearchBar ? Icons.check : Icons.search,
              color: Colors.white,
            ),
            //onPressed: () {},
            onPressed: onSearchPressed,
          ),

          // IconButton(
          //   icon: const Icon(Icons.add, color: Colors.white),
          //   onPressed: () {},
          // ),
          if (showSearchBar)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onCancelSearch,
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
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
                'All Tickets',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tickets.isEmpty
                  ? const Center(child: Text("No tickets found"))
                  : RefreshIndicator(
                      onRefresh: _refreshTickets,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: tickets.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < tickets.length) {
                            final ticket = tickets[index];
                            return TicketCard(
                              title: ticket['subject'] ?? 'No Subject',
                              description: ticket['description'] ?? 'N/A',
                              company: ticket['leadName'] ?? 'N/A',
                              date: ticket['dueDate'] ?? 'N/A',
                              owner: ticket['owner'] ?? 'N/A',
                              priority: ticket['priority'] ?? 'Low',
                              priorityColor: _getPriorityColor(
                                ticket['priority'],
                              ),
                              status: ticket['status'] ?? 'Open',
                              statusColor: _getStatusColor(ticket['status']),
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

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'deferred':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class TicketCard extends StatelessWidget {
  final String title;
  final String description;
  final String company;
  final String date;
  final String owner;
  final String priority;
  final Color priorityColor;
  final String status;
  final Color statusColor;

  const TicketCard({
    super.key,
    required this.title,
    required this.description,
    required this.company,
    required this.date,
    required this.owner,
    required this.priority,
    required this.priorityColor,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    // final formattedDate = (date != null && date.isNotEmpty)
    //     ? DateFormat('dd/MM/yyyy').format(DateTime.parse(date))
    //     : 'N/A';
    final parsedDate = DateTime.tryParse(date ?? '');
    final formattedDate = parsedDate != null
        ? DateFormat('dd/MM/yyyy').format(parsedDate)
        : 'N/A';
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
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(height: 8),

                // Company row
                Row(
                  children: [
                    const Icon(
                      Icons.business_outlined,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        company,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Calendar row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate, // safe formatted value
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Person row
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
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

                // Chips row
                Row(
                  children: [
                    _buildChip(priority, priorityColor),
                    const SizedBox(width: 6),
                    _buildChip(status, statusColor),
                  ],
                ),
              ],
            ),

            // More button
            Positioned(
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.blue),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: TextStyle(
          color: bgColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
