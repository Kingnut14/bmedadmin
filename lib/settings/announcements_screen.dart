import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnounceScreen extends StatefulWidget {
  const AnnounceScreen({super.key});

  @override
  State<AnnounceScreen> createState() => _AnnounceScreenState();
}

class _AnnounceScreenState extends State<AnnounceScreen> {
  List<String> _selectedParticipants = [];
  final List<Map<String, String>> _allUsers = [
    {'id': '1', 'username': 'Juan Dela Cruz'},
    {'id': '2', 'username': 'Maria Santos'},
    {'id': '3', 'username': 'Pedro Sanchez'},
    {'id': '4', 'username': 'Elena Smith'},
    {'id': '5', 'username': 'Ricardo Tolentino'},
    {'id': '6', 'username': 'Anna Stone'},
    {'id': '7', 'username': 'Alex Smith'},
    {'id': '8', 'username': 'Jose Rizal'},
    {'id': '9', 'username': 'Andres Bonifacio'},
    {'id': '10', 'username': 'Apolinario Mabini'},
    {'id': '11', 'username': 'Emilio Aguinaldo'},
    {'id': '12', 'username': 'Gregorio del Pilar'},
    {'id': '13', 'username': 'Melchora Aquino'},
    {'id': '14', 'username': 'Gabriela Silang'},
    {'id': '15', 'username': 'Diego Silang'},
    {'id': '16', 'username': 'Lapu-Lapu'},
    {'id': '17', 'username': 'Magellan'},
    {'id': '18', 'username': 'Christopher Columbus'},
    {'id': '19', 'username': 'Isaac Newton'},
    {'id': '20', 'username': 'Albert Einstein'},
  ];

  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _announcements = [];

  bool _selectAll = false;

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredUsers = _allUsers.where((user) {
      return user['username']!.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !_selectedParticipants.contains(user['username']!);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        elevation: 1,
        title: Text(
          'Create Announcement',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel("Title"),
            _modernTextField(
              controller: _titleController,
              hintText: "Enter announcement title",
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _sectionLabel("Description"),
            _modernTextField(
              controller: _descriptionController,
              hintText: "Enter announcement description",
              maxLines: 4,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _sectionLabel("Participants"),
            const SizedBox(height: 6),
            _buildSelectedParticipants(), // Extract selected participants UI
            const SizedBox(height: 16),
            _modernTextField(
              controller: _searchController,
              hintText: "Search participants...",
              prefixIcon: const Icon(Icons.search),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildSearchList(filteredUsers), // Extract search list
            const SizedBox(height: 30),
            _buildSelectAll(), // Extract select all
            const SizedBox(height: 30),
            _buildAnnounceButton(context), // Extract announce button
            const SizedBox(height: 30),
            if (_announcements.isNotEmpty) _sectionLabel("Recent Announcements"),
            const SizedBox(height: 8),
            _buildAnnouncementsList(), // Extract announcements
          ],
        ),
      ),
    );
  }

  // Refactored Widgets

  Widget _buildSelectedParticipants() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_selectedParticipants.length} participants selected",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (_selectedParticipants.length <= 10)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _selectedParticipants.map((participant) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _selectedParticipantChip(participant),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchList(List<Map<String, String>> filteredUsers) {
    if (_searchQuery.isNotEmpty && filteredUsers.isNotEmpty) {
      return ListView.separated(
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return _customCard(user['username']!);
        },
      );
    } else if (_searchQuery.isNotEmpty) {
      return const Text("No users found.", style: TextStyle(color: Colors.grey));
    }
    return const SizedBox.shrink(); // return empty widget
  }

  Widget _buildSelectAll() {
    return Row(
      children: [
        Checkbox(
          value: _selectAll,
          onChanged: (value) {
            setState(() {
              _selectAll = value!;
              if (_selectAll) {
                _selectedParticipants =
                    _allUsers.map((user) => user['username']!).toList();
              } else {
                _selectedParticipants.clear();
              }
            });
          },
        ),
        const Text("Select All"),
      ],
    );
  }

  Widget _buildAnnounceButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.campaign_rounded, size: 22),
        label: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            "Announce",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          _handleAnnounce(context);
        },
      ),
    );
  }

  void _handleAnnounce(BuildContext context) {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.isEmpty || description.isEmpty || _selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please complete all fields and select participants.')),
      );
      return;
    }

    setState(() {
      _announcements.add({
        'title': title,
        'description': description,
        'participants': _selectedParticipants.length,
        'date': DateTime.now().toString(),
      });
      _titleController.clear();
      _descriptionController.clear();
      _selectedParticipants.clear();
      _searchQuery = '';
      _searchController.clear(); // Clear search field after announcement
      _selectAll = false; // Reset Select All checkbox
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Announcement created and added below!')),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_announcements.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];
          return _announcementCard(announcement);
        },
      );
    } else {
      return Center(
        child: Text(
          'No recent announcements yet.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
  }

  // Existing Widgets

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _modernTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    Widget? prefixIcon,
    void Function(String)? onChanged,
    bool isDark = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _customCard(String username) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.grey[800] : Colors.grey[100],
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            if (!_selectAll) {
              _selectedParticipants.add(username);
              _searchController.clear();
              _searchQuery = "";
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!_selectAll)
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                )
              else
                const Text(
                  "Selected",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              const Icon(Icons.person_add_alt_1_rounded,
                  color: Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectedParticipantChip(String participant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showName = _selectedParticipants.length <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showName)
            Text(
              participant,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          if (!showName)
            Text(
              '#${_selectedParticipants.indexOf(participant) + 1}',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedParticipants.remove(participant);
                if (_selectAll) {
                  _selectAll = false;
                }
              });
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _announcementCard(Map<String, dynamic> announcement) {
    final DateFormat dateFormat = DateFormat('MMM dd, hh:mm a'); // Corrected
    final formattedDate = announcement['date'] != null
        ? dateFormat.format(DateTime.parse(announcement['date']))
        : '';
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              announcement['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Participants: ${announcement['participants']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

