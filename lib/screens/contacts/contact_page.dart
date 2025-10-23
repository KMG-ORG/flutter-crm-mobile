import 'package:crmMobileUi/screens/contacts/contact_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:crmMobileUi/services/api_service.dart';

class ContactsPage extends StatefulWidget {
  final VoidCallback onClose;
  const ContactsPage({super.key, required this.onClose});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Map<String, dynamic>> contacts = [];
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
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    fetchContacts(pageNumber);
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
      fetchContacts(pageNumber);
    }
  }

  Future<void> fetchContacts(int page, [String? search]) async {
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
          await apiService.getContacts(payload) as Map<String, dynamic>;

      final List<Map<String, dynamic>> newContacts =
          (response['data'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      totalCount =
          int.tryParse(response['totalCount']?.toString() ?? '') ?? totalCount;

      setState(() {
        if (page == 1) {
          contacts = newContacts;
        } else {
          contacts.addAll(newContacts);
        }

        hasMore = contacts.length < totalCount;
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

  void onSearchPressed() {
    if (showSearchBar) {
      fetchContacts(1, _searchController.text.trim());
    } else {
      setState(() => showSearchBar = true);
    }
  }

  void onCancelSearch() {
    setState(() {
      showSearchBar = false;
      _searchController.clear();
    });
    fetchContacts(1);
  }

  Future<void> _refreshContacts() async {
    pageNumber = 1;
    hasMore = true;
    await fetchContacts(pageNumber);
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
                decoration: const InputDecoration(
                  hintText: "Search contacts...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) => fetchContacts(1, value),
              )
            : const Text(
                "Contacts",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Contacts",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2E9FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        offset: const Offset(0, 30),
                        onSelected: (value) =>
                            setState(() => selectedOption = value),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: "Manage Tags",
                            child: Text(
                              "Manage Tags",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          PopupMenuItem(
                            value: "Mass Email",
                            child: Text(
                              "Mass Email",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          PopupMenuItem(
                            value: "Export Contacts",
                            child: Text(
                              "Export Contacts",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        child: Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Options",
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2E9FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: GestureDetector(
                        onTap: () {
                          // Open filter
                        },
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text("Error: $errorMessage"))
                : contacts.isEmpty
                ? const Center(child: Text("No contacts found"))
                : RefreshIndicator(
                    onRefresh: _refreshContacts,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: contacts.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < contacts.length) {
                          final contact = contacts[index];
                          return contactCard(
                            name: contact['fullName'] ?? "Unknown",
                            category: contact['account'] ?? "N/A",
                            email: contact['email'] ?? "N/A",
                            phone: contact['phone'] ?? "N/A",
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
          child: const Icon(Icons.add, color: Colors.white),
          activeChild: const Icon(Icons.close, color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.person),
              label: 'Create Accounts',
              onTap: () {},
            ),
            SpeedDialChild(
              child: const Icon(Icons.download),
              label: 'Import Accounts',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget contactCard({
    required String name,
    required String category,
    required String email,
    required String phone,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContactDetailsPage(
              // name: name,
              // email: email,
              // phone: phone,
              // category: category,
            ),
          ),
        );
      },
      child: Card(
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
      ),
    );
  }
}
