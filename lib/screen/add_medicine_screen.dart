// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _milligramController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Medicine'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(  // Make the body scrollable to prevent overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Medicine Name TextField
            TextField(
              controller: _medicineNameController,
              decoration: const InputDecoration(labelText: 'Medicine Name'),
            ),
            const SizedBox(height: 12),

            // Brand Name TextField
            TextField(
              controller: _brandNameController,
              decoration: const InputDecoration(labelText: 'Brand Name'),
            ),
            const SizedBox(height: 12),

            // Milligrams TextField
            TextField(
              controller: _milligramController,
              decoration: const InputDecoration(labelText: 'Milligrams'),
            ),
            const SizedBox(height: 12),

            // Quantity TextField
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 12),

            // Expiration Date TextField
            TextField(
              controller: _expirationDateController,
              decoration: const InputDecoration(labelText: 'Expiration Date'),
            ),
            const SizedBox(height: 20),

            // Add Medicine Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newMedicine = {
                    'Medicine Name': _medicineNameController.text,
                    'Brand Name': _brandNameController.text,
                    'Milligram': _milligramController.text,
                    'Quantity': _quantityController.text,
                    'Expiration Date': _expirationDateController.text,
                  };

                  Navigator.pop(context, newMedicine);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue color for the button
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Add Medicine',
                  style: TextStyle(
                    color: Colors.white, // White font color
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
