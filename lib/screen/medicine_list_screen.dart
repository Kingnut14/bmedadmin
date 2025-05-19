import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MedicineListScreen extends StatefulWidget {
  final List<Map<String, String>>? medicineList;

  const MedicineListScreen({super.key, this.medicineList});

  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  List<Map<String, String>> medicineList = [];
  List<Map<String, String>> _filteredMedicineList = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  Future<void> _updateMedicineImage(int medicineId, String imagePath) async {
    final uri = Uri.parse('http://127.0.0.1:5566/medicines/$medicineId/image');

    try {
      final request = http.MultipartRequest('PUT', uri);

      // Read image bytes
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Add the file as multipart
      request.files.add(
        http.MultipartFile.fromBytes(
          'picture',
          imageBytes,
          filename: imagePath.split(RegExp(r'[\/\\]')).last,
          // import 'package:path/path.dart' as path;
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // Add this method to show the success message with animation
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: AnimatedContainer(
            duration: const Duration(seconds: 2),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2), // Show for 2 seconds
      ),
    );
  }

  Future<List<Map<String, String>>> _fetchMedicineListFromBackend() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5566/medicine'),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body['retCode'] == '200' && body['data'] != null) {
        final List medicines = body['data'];
        return medicines
            .map<Map<String, String>>(
              (med) => {
                'ID': med['ID'].toString(),
                'Medicine Name': med['medicine_name'] ?? '',
                'Brand Name': med['brand_name'] ?? '',
                'Generic Name': med['generic_name'] ?? '',
                'Dosage': med['milligram'] ?? '',
                'Category': med['category'] ?? '',
                'Type of Medicine': med['type_of_drug'] ?? '',
                'Stocks': med['stock'].toString(),
                'Expiration Date': med['expiration_date'] ?? '',
                'Picture': med['picture'] ?? '',
              },
            )
            .toList();
      } else {
        throw Exception('Invalid response: ${body['message']}');
      }
    } else {
      throw Exception(
        'Failed to load medicines (status code ${response.statusCode})',
      );
    }
  }

  final List<String> medicineCategories = [
    'All',
    'Allergy Care',
    'Body & Muscle Pain',
    'Children\'s Health',
    'Headache, Fever & Flu',
    'Vitamins & Supplements',
  ];

  Future<void> _loadMedicines() async {
    try {
      medicineList = await _fetchMedicineListFromBackend();
      _filterMedicines();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading medicine list')),
      );
      medicineList = [];
      _filteredMedicineList = [];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _searchController.addListener(_filterMedicines);
    _filterMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getValue(String? value) {
    return (value != null && value.isNotEmpty) ? value : 'Not Available';
  }

  void _filterMedicines() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedicineList =
          medicineList.where((medicine) {
            final name = medicine['Medicine Name']?.toLowerCase() ?? '';
            final brand = medicine['Brand Name']?.toLowerCase() ?? '';
            final category = medicine['Category']?.toLowerCase() ?? '';
            final matchesSearch = name.contains(query) || brand.contains(query);
            final matchesCategory =
                _selectedCategory == 'All' ||
                category.contains(_selectedCategory.toLowerCase());
            return matchesSearch && matchesCategory;
          }).toList();
    });
  }

  Future<void> _updateMedicineOnServer(
    Map<String, String> medicineData,
    String imagePath,
  ) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://127.0.0.1:5566/medicine/edit/${medicineData['ID']}'),
    );

    // Append form fields
    request.fields['medicine_name'] = medicineData['Medicine Name'] ?? '';
    request.fields['brand_name'] = medicineData['Brand Name'] ?? '';
    request.fields['generic_name'] = medicineData['Generic Name'] ?? '';
    request.fields['milligram'] = medicineData['Dosage'] ?? '';
    request.fields['type_of_drug'] = medicineData['Type of Medicine'] ?? '';
    request.fields['stock'] = medicineData['Stocks'] ?? '';
    request.fields['category'] = medicineData['Category'] ?? '';
    request.fields['expiration_date'] = medicineData['Expiration Date'] ?? '';

    // If the image is a local file, send it as a multipart file
    if (imagePath.isNotEmpty) {
      try {
        final imageBytes = base64Decode(imagePath);
        final multipartFile = http.MultipartFile.fromBytes(
          'picture',
          imageBytes,
          filename:
              'image_${DateTime.now().millisecondsSinceEpoch}.png', // or any name your server expects
        );
        request.files.add(multipartFile);
      } catch (e) {
        print('Error adding image file from base64: $e');
      }
    } else {
      print('No image to upload');
    }

    // Send the request
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        _showSuccessMessage('Medicine updated successfully');
        print('Medicine updated successfully');
      } else {
        print('Failed to update medicine: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during update: $e');
    }
  }

  void _editMedicine(int index) {
    final medicine = medicineList[index];

    final nameController = TextEditingController(
      text: medicine['Medicine Name'] ?? '',
    );
    final brandController = TextEditingController(
      text: medicine['Brand Name'] ?? '',
    );
    final genericNameController = TextEditingController(
      text: medicine['Generic Name'] ?? '',
    );

    final dosageController = TextEditingController(
      text: medicine['Dosage'] ?? '',
    );
    final typeController = TextEditingController(
      text: medicine['Type of Medicine'] ?? '',
    );
    final stocksController = TextEditingController(
      text: medicine['Stocks'] ?? '',
    );
    final expDateController = TextEditingController(
      text: medicine['Expiration Date'] ?? '',
    );
    String category =
        medicineCategories.contains(medicine['Category'])
            ? medicine['Category']!
            : 'All';

    String imagePath = medicine['Picture'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget imageWidget;

            // Determine how to display the image:
            // If imagePath is a local file path (starts with / or has a file extension), use Image.file
            // Otherwise, assume base64 string and decode to Image.memory
            if (imagePath.isNotEmpty) {
              try {
                imageWidget = Image.memory(
                  base64Decode(imagePath),
                  height: 150,
                  fit: BoxFit.contain,
                );
              } catch (e) {
                imageWidget = const SizedBox(
                  height: 150,
                  child: Center(child: Text('Invalid image')),
                );
              }
            } else {
              imageWidget = const SizedBox(
                height: 150,
                child: Center(child: Text('No image available')),
              );
            }

            return AlertDialog(
              title: const Text('Edit Medicine'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    imageWidget,
                    const SizedBox(height: 12),
                    _buildTextField(
                      nameController,
                      'Medicine Name',
                      controller: nameController,
                      hintText: '',
                      label: '',
                    ),
                    _buildTextField(
                      brandController,
                      'Brand Name',
                      controller: brandController,
                      hintText: '',
                      label: '',
                    ),
                    _buildTextField(
                      genericNameController,
                      'Generic Name',
                      controller: genericNameController,
                      hintText: '',
                      label: '',
                    ),

                    _buildTextField(
                      dosageController,
                      'Dosage',
                      controller: dosageController,
                      hintText: '',
                      label: '',
                    ),
                    _buildTextField(
                      typeController,
                      'Type of Medicine',
                      controller: typeController,
                      hintText: '',
                      label: '',
                    ),
                    _buildTextField(
                      stocksController,
                      'Stocks',
                      controller: stocksController,
                      hintText: '',
                      label: '',
                    ),

                    TextField(
                      controller: expDateController,
                      readOnly: false, // Allow user to type
                      decoration: InputDecoration(
                        labelText: 'Expiration Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: category,
                      items:
                          medicineCategories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => category = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Change Image'),
                      onPressed: () async {
                        final picked = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          final bytes = await picked.readAsBytes();
                          setState(() => imagePath = base64Encode(bytes));
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 20),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    bool confirmSave = await _showConfirmationDialog(context);

                    if (confirmSave) {
                      final updatedMedicine = {
                        'ID': (medicine['ID'] ?? '').toString(),
                        'Medicine Name': nameController.text,
                        'Brand Name': brandController.text,
                        'Generic Name': genericNameController.text,
                        'Dosage': dosageController.text,
                        'Type of Medicine': typeController.text,
                        'Stocks': stocksController.text,
                        'Expiration Date': expDateController.text,
                        'Category': category.toString(),
                        'Image Path': imagePath.toString(),
                      };

                      try {
                        await _updateMedicineOnServer(
                          updatedMedicine,
                          imagePath,
                        );

                        await _loadMedicines();
                        _filterMedicines();

                        setState(() {});

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating medicine: $e'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final medicineId = int.parse(medicineList[index]['ID'] ?? '0');

        // Read image bytes directly from pickedFile (Flutter Web compatible)
        final imageBytes = await pickedFile.readAsBytes();

        final uri = Uri.parse(
          'http://127.0.0.1:5566/medicines/$medicineId/image',
        );
        final request = http.MultipartRequest('PUT', uri);

        request.files.add(
          http.MultipartFile.fromBytes(
            'picture',
            imageBytes,
            filename: pickedFile.name,
          ),
        );

        final response = await request.send();

        if (response.statusCode == 200) {
          print('Image uploaded successfully');
          setState(() {
            final base64Image = base64Encode(imageBytes);
            medicineList[index]['Picture'] = base64Image;
          });
        } else {
          print('Failed to upload image. Status code: ${response.statusCode}');
        }
      }
    } catch (e, stack) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
      print('Exception: $e');
      print(stack);
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Save'),
              content: const Text('Are you sure you want to save the changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _deleteMedicine(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Medicine"),
            content: const Text(
              "Are you sure you want to delete this medicine?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    medicineList.removeAt(index);
                    _filterMedicines();
                  });
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController primaryController,
    String s, {
    required TextEditingController controller,
    required String label,
    required String hintText,
    IconData? prefixIcon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black12,
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            labelText: label.isNotEmpty ? label : s,
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBDEFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBBDEFB),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Medicine List',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search medicines...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt, color: Colors.white),
                    onPressed: () async {
                      final selected = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(1000, 80, 0, 0),
                        items:
                            medicineCategories
                                .map(
                                  (cat) => PopupMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                      );
                      if (selected != null) {
                        setState(() {
                          _selectedCategory = selected;
                          _filterMedicines();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMedicines,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _filteredMedicineList.length,
                  itemBuilder: (context, index) {
                    final medicine = _filteredMedicineList[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final imageHeight = screenWidth * 0.3;
                        final fontSizeTitle = screenWidth * 0.035;
                        final fontSizeText = screenWidth * 0.03;
                        final iconSize = screenWidth * 0.05;
                        final iconContainerSize = screenWidth * 0.1;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black12,
                          color: Colors.white,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap:
                                        (medicine['Picture']?.isEmpty ?? true)
                                            ? () => _pickImage(index)
                                            : null,
                                    child: Container(
                                      height: constraints.maxHeight * 0.50,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                        image:
                                            (medicine['Picture']?.isEmpty ??
                                                    true)
                                                ? null
                                                : DecorationImage(
                                                  image: MemoryImage(
                                                    base64Decode(
                                                      medicine['Picture'] ?? '',
                                                    ),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                      child:
                                          (medicine['Picture']?.isEmpty ?? true)
                                              ? Icon(
                                                Icons.image_outlined,
                                                size:
                                                    constraints.maxHeight *
                                                    0.12,
                                                color: Colors.blue,
                                              )
                                              : null,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 6,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          medicine['Medicine Name'] ??
                                              'Unknown',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                constraints.maxWidth * 0.07,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          medicine['Brand Name'] ??
                                              'Unknown Brand',
                                          style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.055,
                                            color: Colors.grey[700],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Dosage: ${medicine['Dosage'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.05,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Stocks: ${medicine['Stocks'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.05,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed:
                                                  () => _editMedicine(index),
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                              ),
                                              label: const Text("Edit"),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      constraints.maxWidth *
                                                      0.045,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton.icon(
                                              onPressed:
                                                  () => _deleteMedicine(index),
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                              label: const Text("Delete"),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      constraints.maxWidth *
                                                      0.045,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    );
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
