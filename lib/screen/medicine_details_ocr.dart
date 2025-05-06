import 'package:flutter/material.dart';

class MedicineDetailsOcrScreen extends StatefulWidget {
  final Map<String, String> medicine;

  const MedicineDetailsOcrScreen({super.key, required this.medicine});

  @override
  _MedicineDetailsOcrScreenState createState() => _MedicineDetailsOcrScreenState();
}

class _MedicineDetailsOcrScreenState extends State<MedicineDetailsOcrScreen> {
  late TextEditingController medicineController;
  late TextEditingController brandController;
  late TextEditingController dosageController;
  late TextEditingController typeofmedicineController;
  late TextEditingController stocksController;
  late TextEditingController expirationController;

  @override
  void initState() {
    super.initState();
    medicineController = TextEditingController(text: widget.medicine['Medicine Name']);
    brandController = TextEditingController(text: widget.medicine['Brand Name']);
    dosageController = TextEditingController(text: widget.medicine['Dosage']);
    typeofmedicineController = TextEditingController(text: widget.medicine['Type of Medicine'] ?? '');
    stocksController = TextEditingController(text: widget.medicine['Stocks'] ?? '');
    expirationController = TextEditingController(text: widget.medicine['Expiration Date']);
  }

  @override
  void dispose() {
    medicineController.dispose();
    brandController.dispose();
    dosageController.dispose();
    typeofmedicineController.dispose();
    stocksController.dispose();
    expirationController.dispose();
    super.dispose();
  }

  bool validateForm() {
    return medicineController.text.isNotEmpty &&
        brandController.text.isNotEmpty &&
        dosageController.text.isNotEmpty &&
        typeofmedicineController.text.isNotEmpty &&
        stocksController.text.isNotEmpty &&
        expirationController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryColor = Colors.blueAccent.shade700;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine['Medicine Name'] ?? 'Medicine Details'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField("Medicine Name", medicineController, isDarkMode),
              const SizedBox(height: 12),
              buildTextField("Brand Name", brandController, isDarkMode),
              const SizedBox(height: 12),
              buildTextField("Dosage", dosageController, isDarkMode),
              const SizedBox(height: 12),
              buildTextField("Type of Medicine", typeofmedicineController, isDarkMode),
              const SizedBox(height: 12),
              buildTextField("Stocks", stocksController, isDarkMode),
              const SizedBox(height: 20),
              buildTextField("Expiration Date", expirationController, isDarkMode),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (validateForm()) {
                      Navigator.pop(context, {
                        'Medicine Name': medicineController.text,
                        'Brand Name': brandController.text,
                        'Dosage': dosageController.text,
                        'Type of Medicine': typeofmedicineController.text,
                        'Stocks': stocksController.text,
                        'Expiration Date': expirationController.text,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill out all fields.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, bool isDarkMode) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.blueGrey.shade900 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}