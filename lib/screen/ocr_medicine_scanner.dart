import 'dart:io';
import 'package:bmedv2/screen/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider/unread_count_provider.dart';
import 'medicine_list_screen.dart';
import '../widget/custom_app_bar.dart';
// import '../widget/custom_nav_bar.dart';

class OcrMedicineScanner extends StatefulWidget {
  final Function(int) onTabSelected;
  const OcrMedicineScanner({super.key, required this.onTabSelected});

  @override
  _OcrMedicineScannerState createState() => _OcrMedicineScannerState();
}

class _OcrMedicineScannerState extends State<OcrMedicineScanner> {
  File? _image;
  Map<String, TextEditingController> extractedDataControllers = {};
  bool isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer textRecognizer = TextRecognizer();
  bool _isEditingEnabled = false;
  bool _hasImage = false; // Track if an image has been picked

  List<String> medicineNames = const [
    "Paracetamol",
    "Ibuprofen",
    "Amoxicillin",
    "Cetirizine",
    "Loperamide",
    "Mefenamic Acid",
    "Losartan",
    "Metformin",
    "Salbutamol",
    "Omeprazole",
    "Aspirin",
    "Cotrimoxazole",
    "Dextromethorphan",
    "Diphenhydramine",
    "Domperidone",
    "Hydroxyzine",
    "Ciprofloxacin",
    "Doxycycline",
    "Carbocisteine",
    "Ambroxol",
    "Clarithromycin",
    "Ranitidine",
    "Simvastatin",
    "Amlodipine",
    "Metoprolol",
    "Hydrochlorothiazide",
    "Candesartan",
    "Glibenclamide",
    "GLIBENCLAMIDE",
    "Levothyroxine",
    "Prednisone",
    "Nighttime Cough DM",
    "PRETENDMED",
    "Pretenmed",
    "Fakelixir",
  ];

  List<String> brandNames = const [
    "Biogesic",
    "Medicol",
    "Flanax",
    "Neozep",
    "Tuseran",
    "Dolfenal",
    "Solmux",
    "Alaxan",
    "Ritemed",
    "Pharex",
    "Rovamycine",
    "Zinnat",
    "Augmentin",
    "Ponstan",
    "Robitussin",
    "Sarbena",
  ];

  Map<String, String> keywordMapping = const {
    "Exp:": "Expiration Date",
    "Exp Date": "Expiration Date",
    "Exp.": "Expiration Date",
    "Expiring": "Expiration Date",
    "Expires": "Expiration Date",
    "Valid Until": "Expiration Date",
    "Expiry": "Expiration Date",
    "Use by": "Expiration Date",
  };

  List<Map<String, String>> medicineList = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    extractedDataControllers["Medicine Name"] = TextEditingController();
    extractedDataControllers["Brand Name"] = TextEditingController();
    extractedDataControllers["Dosage"] = TextEditingController();
    extractedDataControllers["Type of Medicine"] = TextEditingController();
    extractedDataControllers["Stocks"] = TextEditingController();
    extractedDataControllers["Expiration Date"] = TextEditingController();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      setState(() {
        _image = File(pickedFile.path);
        isProcessing = true;
        _hasImage = true; // Set to true when an image is picked
        _isEditingEnabled = true;
        _clearControllers();
      });
      await _processImage();
    } catch (e) {
      debugPrint("Error picking image: $e");
      setState(() => isProcessing = false);
    }
  }

  void _clearControllers() {
    extractedDataControllers.forEach((_, controller) => controller.clear());
  }

  Future<void> _processImage() async {
    if (_image == null) return;
    try {
      setState(() {
        isProcessing = true;
      });

      File preprocessedImage = await _preprocessImage(_image!);

      final inputImage = InputImage.fromFile(preprocessedImage);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      Map<String, String> detectedData = {
        "Medicine Name": "",
        "Brand Name": "",
        "Dosage": "",
        "Expiration Date": "",
      };

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final lineText = line.text.trim().toLowerCase();

          for (String medicine in medicineNames) {
            if (lineText.contains(medicine.toLowerCase()) &&
                detectedData["Medicine Name"]!.isEmpty) {
              detectedData["Medicine Name"] = medicine;
              break;
            }
          }

          for (String brand in brandNames) {
            if (lineText.contains(brand.toLowerCase()) &&
                detectedData["Brand Name"]!.isEmpty) {
              detectedData["Brand Name"] = brand;
              break;
            }
          }

          RegExp dosageRegex = RegExp(
            r'(\d+(\.\d{1,2})?\s*(mg|mg\.|milligrams?|mgs?))',
          );
          Match? dosageMatch = dosageRegex.firstMatch(lineText);
          if (dosageMatch != null && detectedData["Dosage"]!.isEmpty) {
            detectedData["Dosage"] = dosageMatch.group(0) ?? "";
          }

          for (String keyword in keywordMapping.keys) {
            if (lineText.contains(keyword.toLowerCase()) &&
                detectedData["Expiration Date"]!.isEmpty) {
              RegExp expRegex = RegExp(
                r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}[/-]\d{1,2}[/-]\d{1,2}|\d{1,2}\s?[A-Za-z]{3,9}\s?\d{2,4})',
                caseSensitive: false,
              );
              Match? expMatch = expRegex.firstMatch(lineText);
              if (expMatch != null) {
                detectedData["Expiration Date"] = expMatch.group(0) ?? "";
              }
            }
          }
        }
      }

      // Ensure all controllers have a value, even if empty
      extractedDataControllers.forEach((key, controller) {
        if (!detectedData.containsKey(key)) {
          detectedData[key] = "";
        }
        controller.text = detectedData[key]!;
      });

      setState(() {
        isProcessing = false;
      });
    } catch (e) {
      debugPrint("Error processing image: $e");
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error processing the image. Please try again."),
        ),
      );
    }
  }

  Future<File> _preprocessImage(File image) async {
    return image;
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Confirm Add Medicine",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            content: const Text(
              "Are you sure you want to add this medicine to the list?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _acceptData();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: const Text("Yes"),
              ),
            ],
          ),
    );
  }

  void _acceptData() {
    Map<String, String> finalData = extractedDataControllers.map(
      (key, controller) => MapEntry(key, controller.text),
    );
    setState(() {
      if (finalData.isNotEmpty) {
        medicineList.add(finalData);
      }
      _clearControllers();
      _image = null;
      _hasImage = false;
      _isEditingEnabled = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineListScreen(medicineList: medicineList),
      ),
    );
  }

  void _rejectData() {
    setState(() {
      _clearControllers();
      _image = null;
      _hasImage = false;
      _isEditingEnabled = false;
    });
  }

  // void _toggleEdit() {
  //   setState(() {
  //     _isEditingEnabled = !_isEditingEnabled;
  //   });
  // }

  // void _clearImage() {
  //   setState(() {
  //     _image = null;
  //     _hasImage = false;
  //     _isEditingEnabled = false;
  //     _clearControllers();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryColor =
        Colors.blue.shade500; // Example primary color for BARMED
    final unreadCount = Provider.of<UnreadCountProvider>(context).unreadCount;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFBBDEFB), // Example colors
      appBar: CustomAppBar(
        title: 'Baramed OCR',
        fontSize: 15,
        isDarkMode: theme.brightness == Brightness.dark,
      ),
      drawer: const MenuScreen(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    _image!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (!_hasImage)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Upload Photo",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: Icon(
                              Icons.photo_library,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            label: Text(
                              "Gallery",
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  isDarkMode ? Colors.white : Colors.black87,
                              backgroundColor:
                                  isDarkMode ? Colors.grey[800] : primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: Icon(
                              Icons.camera_alt,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            label: Text(
                              "Camera",
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  isDarkMode ? Colors.white : Colors.black87,
                              backgroundColor:
                                  isDarkMode ? Colors.grey[800] : primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_hasImage)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        extractedDataControllers.entries.map((entry) {
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            child: ListTile(
                              title: Text(
                                entry.key,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: TextField(
                                controller: entry.value,
                                enabled: _isEditingEnabled,
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: primaryColor),
                                  ),
                                  hintText:
                                      _isEditingEnabled ? "Edit here" : null,
                                  hintStyle: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.grey,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  filled: _isEditingEnabled,
                                  fillColor:
                                      isDarkMode
                                          ? Colors.grey[700]
                                          : Colors.grey[100],
                                ),
                                keyboardType:
                                    entry.key == "Stocks"
                                        ? TextInputType.number
                                        : null,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            if (isProcessing) const CircularProgressIndicator(),
            if (_hasImage && extractedDataControllers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showConfirmationDialog,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _rejectData,
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text(
                        "Reject",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomNavBar(
      //   selectedIndex: 2,
      //   onItemTapped: (index) {
      //     // Handle navigation actions here
      //   },
      //   onScanPressed: () {
      //     // Implement scan action if needed
      //   },
      // ),
    );
  }
}
