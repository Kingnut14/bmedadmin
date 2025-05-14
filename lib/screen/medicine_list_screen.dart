import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MedicineListScreen extends StatefulWidget {
  final List<Map<String, String>>? medicineList;

  const MedicineListScreen({super.key, this.medicineList});

  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late List<Map<String, String>> medicineList;
  List<Map<String, String>> _filteredMedicineList = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> medicineCategories = [
    'All',
    'Allergy Care',
    'Body & Muscle Pain',
    'Children\'s Health',
    'Headache, Fever & Flu',
    'Vitamins & Supplements',
  ];

  @override
  void initState() {
    super.initState();
    medicineList = widget.medicineList?.isNotEmpty == true
        ? widget.medicineList!
        : _defaultMedicineList();
    _searchController.addListener(_filterMedicines);
    _filterMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _defaultMedicineList() {
    return [
      {
        'Medicine Name': 'Paracetamol',
        'Brand Name': 'Panadol',
        'Dosage': '500mg',
        'Category': 'Headache, Fever & Flu',
        'Type of Medicine': 'Tablet',
        'Stocks': '150',
        'Expiration Date': '2025-12-15',
        'Image Path': '',
      },
      {
        'Medicine Name': 'Ibuprofen',
        'Brand Name': 'Advil',
        'Dosage': '200mg',
        'Category': 'Body & Muscle Pain',
        'Type of Medicine': 'Tablet',
        'Stocks': '120',
        'Expiration Date': '2026-03-10',
        'Image Path': '',
      },
      {
        'Medicine Name': 'Cetirizine',
        'Brand Name': 'Allerta',
        'Dosage': '10mg',
        'Category': 'Allergy Care',
        'Type of Medicine': 'Tablet',
        'Stocks': '80',
        'Expiration Date': '2025-08-01',
        'Image Path': '',
      },
      {
        'Medicine Name': 'Amoxicillin',
        'Brand Name': 'Biogesic',
        'Dosage': '500mg',
        'Category': 'Children\'s Health',
        'Type of Medicine': 'Capsule',
        'Stocks': '60',
        'Expiration Date': '2025-11-30',
        'Image Path': '',
      },
      {
        'Medicine Name': 'Salbutamol',
        'Brand Name': 'Ventolin',
        'Dosage': '2mg/5ml',
        'Category': 'Children\'s Health',
        'Type of Medicine': 'Syrup',
        'Stocks': '45',
        'Expiration Date': '2026-01-20',
        'Image Path': '',
      },
    ];
  }


  String getValue(String? value) {
    return (value != null && value.isNotEmpty) ? value : 'Not Available';
  }

  void _filterMedicines() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedicineList = medicineList.where((medicine) {
        final name = medicine['Medicine Name']?.toLowerCase() ?? '';
        final brand = medicine['Brand Name']?.toLowerCase() ?? '';
        final category = medicine['Category']?.toLowerCase() ?? '';
        final matchesSearch = name.contains(query) || brand.contains(query);
        final matchesCategory = _selectedCategory == 'All' ||
            category.contains(_selectedCategory.toLowerCase());
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          medicineList[index]['Image Path'] = pickedFile.path;
          _filterMedicines();
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _editMedicine(int index) {
    final medicine = medicineList[index];

    final nameController = TextEditingController(text: medicine['Medicine Name'] ?? '');
    final brandController = TextEditingController(text: medicine['Brand Name'] ?? '');
    final dosageController = TextEditingController(text: medicine['Dosage'] ?? '');
    final typeController = TextEditingController(text: medicine['Type of Medicine'] ?? '');
    final stocksController = TextEditingController(text: medicine['Stocks'] ?? '');
    final expDateController = TextEditingController(text: medicine['Expiration Date'] ?? '');
    String category = medicine['Category'] ?? 'All';
    String imagePath = medicine['Image Path'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Medicine'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(nameController, 'Medicine Name', controller: nameController, hintText: '', label: ''),
                    _buildTextField(brandController, 'Brand Name', controller: brandController, hintText: '', label: ''),
                    _buildTextField(dosageController, 'Dosage', controller: dosageController, hintText: '', label: ''),
                    _buildTextField(typeController, 'Type of Medicine', controller: typeController, hintText: '', label: ''),
                    _buildTextField(stocksController, 'Stocks', controller: stocksController, hintText: '', label: ''),

                    TextField(
                      controller: expDateController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          expDateController.text = picked.toIso8601String().split('T').first;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Expiration Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: medicineCategories.map((cat) {
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
                        final picked = await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() => imagePath = picked.path);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    setState(() {
                      medicineList[index] = {
                        'Medicine Name': nameController.text,
                        'Brand Name': brandController.text,
                        'Dosage': dosageController.text,
                        'Type of Medicine': typeController.text,
                        'Stocks': stocksController.text,
                        'Expiration Date': expDateController.text,
                        'Category': category,
                        'Image Path': imagePath,
                      };
                      _filterMedicines();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _deleteMedicine(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Medicine"),
        content: const Text("Are you sure you want to delete this medicine?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
  Widget _buildTextField(TextEditingController brandController, String s, {
    required TextEditingController controller,
    required String label,
    required String hintText,
    IconData? prefixIcon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine List'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt, color: Colors.white),
                    onPressed: () async {
                      final selected = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(1000, 80, 0, 0),
                        items: medicineCategories
                            .map((cat) => PopupMenuItem(value: cat, child: Text(cat)))
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
              child: GridView.builder(
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
                      final imageHeight = screenWidth * 0.3; // Adjust image height based on screen width
                      final fontSizeTitle = screenWidth * 0.035; // Responsive font size
                      final fontSizeText = screenWidth * 0.03;
                      final iconSize = screenWidth * 0.05;
                      final iconContainerSize = screenWidth * 0.1;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Medicine Image
                            GestureDetector(
                              onTap: () => _pickImage(index),
                              child: Container(
                                height: imageHeight,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  image: (medicine['Image Path']?.isEmpty ?? true)
                                      ? null
                                      : DecorationImage(
                                    image: FileImage(File(medicine['Image Path']!)),
                                    fit: BoxFit.cover,
                                  ),
                                  color: Colors.grey[200],
                                ),
                                child: (medicine['Image Path']?.isEmpty ?? true)
                                    ? Center(child: Icon(Icons.image, size: iconSize + 10, color: Colors.blue))
                                    : null,
                              ),
                            ),

                            // Medicine Details
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      medicine['Medicine Name'] ?? 'Unknown Medicine Name',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeTitle),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                    ),
                                    const SizedBox(height: 0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.business, size: 16, color: Colors.blue),
                                        const SizedBox(width: .0),
                                        Expanded(
                                          child: Text(
                                            medicine['Brand Name'] ?? 'Unknown Brand',
                                            style: TextStyle(fontSize: fontSizeText),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.local_hospital, size: 16, color: Colors.blue),
                                        const SizedBox(width: .1),
                                        Expanded(
                                          child: Text(
                                            'Dosage: ${medicine['Dosage'] ?? 'N/A'}',
                                            style: TextStyle(fontSize: fontSizeText),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Stocks: ${medicine['Stocks'] ?? 'N/A'}',
                                            style: TextStyle(fontSize: fontSizeText),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),


                            // Edit/Delete Buttons
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: iconContainerSize,
                                    height: iconContainerSize,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: iconSize,
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.green, // green na icon
                                      ),
                                      onPressed: () => _editMedicine(index),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: iconContainerSize,
                                    height: iconContainerSize,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: iconSize,
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red, // red na icon
                                      ),
                                      onPressed: () => _deleteMedicine(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}