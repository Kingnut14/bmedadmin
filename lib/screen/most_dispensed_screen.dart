// import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
// import 'package:path_provider/path_provider.dart'; // For getting temporary directory
import 'package:image_gallery_saver/image_gallery_saver.dart'; // To save to gallery

class MostDispensedScreen extends StatefulWidget {
  MostDispensedScreen({super.key});

  @override
  State<MostDispensedScreen> createState() => _MostDispensedScreenState();
}

class _MostDispensedScreenState extends State<MostDispensedScreen> {
  // Sample data - replace with your actual data
  final Map<String, double> dataMap = {
    "Cetirizine": 2,
    "Loperamide": 2,
    "Omeprazole": 2,
    "Amoxicillin": 2,
    "Hydroxyzine": 2,
    "Salbutamol": 1,
    "Clopidogrel": 1,
    "Ibuprofen": 1,
    "Paracetamol": 1,
    "Amlodipine": 1,
  };

  final List<Color> colorList = [
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.green,
    Colors.lime,
    Colors.cyan,
    Colors.purple,
    Colors.indigo,
    Colors.grey,
    Colors.pinkAccent,
  ];

  ScreenshotController screenshotController = ScreenshotController();

  Future<void> _saveScreenshot() async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        final result = await ImageGallerySaver.saveImage(imageBytes);
        if (result != null && result.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report saved to gallery!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save report to gallery.')),
          );
        }
      }
    } catch (e) {
      print('Error saving screenshot: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving report.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 30));
    final DateTime endDate = now;

    final List<MapEntry<String, double>> sortedData = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Most Dispensed Medicines'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveScreenshot,
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Most Dispensed Medicines Report',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Date Range: ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.width / 2.5, // Slightly smaller pie chart
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: MediaQuery.of(context).size.width / 7, // Adjusted center space
                    startDegreeOffset: 0,
                    sections: generateChartData(dataMap),
                  ),
                ),
              ),
              const SizedBox(height: 15), // Reduced spacing
              Wrap(
                spacing: 6, // Reduced spacing
                runSpacing: 3, // Reduced spacing
                children: dataMap.entries.map((entry) {
                  final index = dataMap.keys.toList().indexOf(entry.key) % colorList.length;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12, // Smaller color indicator
                        height: 12,
                        color: colorList[index],
                      ),
                      const SizedBox(width: 3),
                      Text(entry.key, style: const TextStyle(fontSize: 12)), // Smaller text
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20), // Reduced spacing before table
              Text(
                'Dispensed Medicines Details',
                style: TextStyle(
                  fontSize: 16, // Smaller title
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              DataTable(
                columnSpacing: 16, // Adjust column spacing if needed
                headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                dataTextStyle: const TextStyle(fontSize: 10),
                columns: const [
                  DataColumn(label: Text('Medicine', style: TextStyle(fontSize: 12))),
                  DataColumn(label: Text('Qty', style: TextStyle(fontSize: 12))),
                  DataColumn(label: Text('Pct (%)', style: TextStyle(fontSize: 12))),
                ],
                rows: sortedData.map((entry) {
                  final total = dataMap.values.reduce((a, b) => a + b);
                  final percentage = (entry.value / total) * 100;
                  return DataRow(cells: [
                    DataCell(Text(entry.key)),
                    DataCell(Text(entry.value.toString())),
                    DataCell(Text('${percentage.toStringAsFixed(2)}%')),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> generateChartData(Map<String, double> dataMap) {
    final List<PieChartSectionData> list = [];
    final total = dataMap.values.reduce((a, b) => a + b);
    final colorList = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.lime,
      Colors.cyan,
      Colors.purple,
      Colors.indigo,
      Colors.grey,
      Colors.pinkAccent,
    ];
    int i = 0;
    for (final entry in dataMap.entries) {
      final percentage = (entry.value / total) * 100;
      list.add(
        PieChartSectionData(
          color: colorList[i % colorList.length],
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50, // Slightly smaller radius
          titleStyle: const TextStyle(
            fontSize: 8, // Smaller title
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    }
    return list;
  }
}