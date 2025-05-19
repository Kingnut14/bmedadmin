// import 'package:bmedv2/provider/font_size_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../provider/theme_provider.dart';
// import '../provider/unread_count_provider.dart';
// import '../widget/custom_app_bar.dart';

// class AcceptedScreen extends StatefulWidget {
//   final List<Map<String, String>> parsedRequests;

//   const AcceptedScreen({super.key, required this.parsedRequests});

//   @override
//   State<AcceptedScreen> createState() => _AcceptedScreenState();
// }

// class _AcceptedScreenState extends State<AcceptedScreen> {
//   String? selectedName;
//   late List<Map<String, String>> requests;
//   String searchQuery = "";
//   double scaledFontSize = 16.0;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     requests =
//         widget.parsedRequests.isNotEmpty
//             ? widget.parsedRequests
//             : [
//               {
//                 "name": "Juan Dela Cruz",
//                 "Medicine Name": "Paracetamol",
//                 "Dosage": "500mg",
//                 "Type": "Tablet",
//                 "Quantity": "20",
//                 "Notes": "Take after meal",
//               },
//               // Dummy requests for fallback
//             ];
//     _fetchRequests();
//   }

//   Future<void> _fetchRequests() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('http://127.0.0.1:5566/request/status/true'),
//       ); // Adjust the URL accordingly.

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['retCode'] == '200') {
//           List<dynamic> requestsData = data['data'];
//           setState(() {
//             requests =
//                 requestsData.map<Map<String, String>>((e) {
//                   final user = e['user'] ?? {};
//                   final firstName = user['first_name']?.toString() ?? "Unknown";
//                   final lastName = user['last_name']?.toString() ?? "Unknown";
//                   return {
//                     "Name":
//                         '$firstName $lastName', // Combine first name and last name
//                     "Medicine Code":
//                         e['medicine_code']?.toString() ?? "Unknown",
//                     "Batch Code": e['batch_code']?.toString() ?? "Unknown",
//                     "Scan Date": e['scan_date']?.toString() ?? "Unknown",
//                     "Quantity": e['quantity']?.toString() ?? "0",
//                     "Request Date": e['request_date']?.toString() ?? "Unknown",
//                     "Status": (e['status'] == true) ? "Approved" : "Pending",
//                   };
//                 }).toList();
//           });
//         } else {
//           // Handle error response
//           setState(() {
//             requests = [];
//           });
//         }
//       } else {
//         setState(() {
//           requests = [];
//         });
//       }
//     } catch (error) {
//       setState(() {
//         requests = [];
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final unreadCount = Provider.of<UnreadCountProvider>(context).unreadCount;
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

//     final groupedRequests = <String, List<Map<String, String>>>{};
//     for (var request in requests) {
//       final name = request['Name'] ?? "Unknown";
//       groupedRequests.putIfAbsent(name, () => []).add(request);
//     }

//     final filteredNames =
//         groupedRequests.keys
//             .where(
//               (name) => name.toLowerCase().contains(searchQuery.toLowerCase()),
//             )
//             .toList();

//     return Scaffold(
//       appBar: CustomAppBar(
//         title: "Request Management",
//         fontSize: fontSize + 2,
//         isDarkMode: themeProvider.isDarkMode,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 if (selectedName != null) {
//                   setState(() => selectedName = null);
//                 } else {
//                   Navigator.pop(context);
//                 }
//               },
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.arrow_back_ios_new,
//                     color: Theme.of(context).iconTheme.color,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     "",
//                     style: TextStyle(
//                       color: Theme.of(context).textTheme.bodyLarge?.color,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             TextField(
//               decoration: InputDecoration(
//                 hintText: "Search by name...",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value;
//                   selectedName = null;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),

//             if (isLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (filteredNames.isNotEmpty)
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: filteredNames.length,
//                 itemBuilder: (context, index) {
//                   final name = filteredNames[index];
//                   final isSelected = selectedName == name;

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedName = isSelected ? null : name;
//                           });
//                         },
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           margin: const EdgeInsets.symmetric(vertical: 10),
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 12,
//                             horizontal: 16,
//                           ),
//                           decoration: BoxDecoration(
//                             color:
//                                 isSelected
//                                     ? (isDark
//                                         ? Colors.blue.shade700
//                                         : Colors.blue.shade200)
//                                     : (isDark
//                                         ? const Color(0xFF1A1A2E)
//                                         : const Color(0xFFFFFFFF)),
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color.fromARGB(255, 50, 96, 164),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 name,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: fontSize,
//                                   color:
//                                       isSelected
//                                           ? (isDark
//                                               ? Colors.white
//                                               : Colors.blue.shade900)
//                                           : (isDark
//                                               ? Colors.grey[300]
//                                               : Colors.blue.shade700),
//                                 ),
//                               ),
//                               Icon(
//                                 isSelected
//                                     ? Icons.arrow_drop_up
//                                     : Icons.arrow_drop_down,
//                                 color:
//                                     isSelected
//                                         ? (isDark
//                                             ? Colors.white
//                                             : Colors.blue.shade900)
//                                         : (isDark
//                                             ? Colors.grey[300]
//                                             : Colors.blue.shade700),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // Show requests directly below the selected name
//                       if (isSelected)
//                         Container(
//                           decoration: BoxDecoration(
//                             color:
//                                 isDark ? const Color(0xFF1A1A2E) : Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 name,
//                                 style: TextStyle(
//                                   fontSize: fontSize + 6,
//                                   fontWeight: FontWeight.bold,
//                                   color: isDark ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                               const Divider(thickness: 1.2, height: 24),
//                               if (groupedRequests[name]!.isNotEmpty)
//                                 ...groupedRequests[name]!.asMap().entries.map((
//                                   entry,
//                                 ) {
//                                   final requestIndex = entry.key + 1;
//                                   final request = entry.value;

//                                   return Padding(
//                                     padding: const EdgeInsets.only(
//                                       bottom: 16.0,
//                                     ),
//                                     child: Card(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       elevation: 4,
//                                       color:
//                                           isDark
//                                               ? const Color(0xFF1A1A2E)
//                                               : Colors.white,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(12.0),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "Request #$requestIndex",
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: fontSize,
//                                                 color:
//                                                     isDark
//                                                         ? Colors.white
//                                                         : Colors.blue,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 8),
//                                             ...request.entries
//                                                 .where(
//                                                   (e) =>
//                                                       e.key != "name" &&
//                                                       e.value.trim().isNotEmpty,
//                                                 )
//                                                 .map(
//                                                   (e) => Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                           bottom: 8.0,
//                                                         ),
//                                                     child: Row(
//                                                       children: [
//                                                         Icon(
//                                                           Icons.info_outline,
//                                                           size: 20,
//                                                           color:
//                                                               isDark
//                                                                   ? Colors.white
//                                                                   : Colors.blue,
//                                                         ),
//                                                         const SizedBox(
//                                                           width: 8,
//                                                         ),
//                                                         Expanded(
//                                                           child: Text(
//                                                             "${e.key}: ${e.value}",
//                                                             style: TextStyle(
//                                                               fontSize: fontSize - 2,
//                                                               color:
//                                                                   isDark
//                                                                       ? Colors
//                                                                           .grey[300]
//                                                                       : Colors
//                                                                           .black,
//                                                             ),
//                                                             maxLines: 2,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 )
//                                                 .toList(),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 })
//                               else
//                                 Text(
//                                   "No requests available for $name.",
//                                   style: TextStyle(
//                                     color: colors.onSurfaceVariant,
//                                     fontSize: fontSize,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               )
//             else
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 40.0),
//                   child: Text(
//                     "No matching names found.",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
