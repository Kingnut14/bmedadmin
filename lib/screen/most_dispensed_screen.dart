import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MostDispensedScreen extends StatefulWidget {
  const MostDispensedScreen({super.key});

  @override
  State<MostDispensedScreen> createState() => _MostDispensedScreenState();
}

class _MostDispensedScreenState extends State<MostDispensedScreen> {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error saving report.')));
    }
  }

  Future<void> _exportAsPDF() async {
    final pdf = pw.Document();
    final total = dataMap.values.reduce((a, b) => a + b);
    final sortedData =
        dataMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    final endDate = now;

    try {
      // Capture pie chart offscreen as image
      final Uint8List? pieChartImageBytes = await screenshotController
          .captureFromWidget(
            MediaQuery(
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: generateChartData(context, dataMap),
                ),
              ),
            ),
            pixelRatio: 3,
          );

      final pieChartImage = pw.MemoryImage(pieChartImageBytes!);

      // Build PDF pages
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build:
              (pw.Context context) => [
                pw.Text(
                  'Most Dispensed Medicines Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Date Range: ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),

                // Pie chart image in PDF
                pw.Center(
                  child: pw.Image(pieChartImage, fit: pw.BoxFit.contain),
                ),

                pw.SizedBox(height: 20),
                pw.Text(
                  'Medicine Details:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Medicine', 'Quantity', 'Percentage'],
                  headerStyle: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.teal,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 12),
                  data:
                      sortedData.map((entry) {
                        final percentage = (entry.value / total) * 100;
                        return [
                          entry.key,
                          entry.value.toString(),
                          '${percentage.toStringAsFixed(1)}%',
                        ];
                      }).toList(),
                ),
              ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error exporting PDF: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to export PDF')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 30));
    final DateTime endDate = now;

    final List<MapEntry<String, double>> sortedData =
        dataMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFBBDEFB),
      appBar: AppBar(
        title: const Text(
          'Most Dispensed Medicines',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFBBDEFB),
        elevation: 0,
      ),
      body: Screenshot(
        controller: screenshotController,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Most Dispensed Report',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date Range: ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Dispensation Overview & Medicine Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: constraints.maxWidth * 0.55,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: generateChartData(context, dataMap),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 12,
                              children:
                                  dataMap.entries.map((entry) {
                                    final index =
                                        dataMap.keys.toList().indexOf(
                                          entry.key,
                                        ) %
                                        colorList.length;
                                    return SizedBox(
                                      width: 160,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorList[index],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              entry.key,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.teal.shade50,
                                ),
                                headingTextStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                dataTextStyle: const TextStyle(fontSize: 12),
                                columnSpacing: 24,
                                columns: const [
                                  DataColumn(label: Text('Medicine')),
                                  DataColumn(label: Text('Quantity')),
                                  DataColumn(label: Text('Percentage')),
                                ],
                                rows:
                                    sortedData.map((entry) {
                                      final total = dataMap.values.reduce(
                                        (a, b) => a + b,
                                      );
                                      final percentage =
                                          (entry.value / total) * 100;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(entry.key)),
                                          DataCell(
                                            Text(entry.value.toString()),
                                          ),
                                          DataCell(
                                            Text(
                                              '${percentage.toStringAsFixed(1)}%',
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _exportAsPDF,
                                  icon: const Icon(
                                    Icons.picture_as_pdf,
                                    size: 20,
                                  ),
                                  label: const Text('Export as PDF'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D47A1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _saveScreenshot,
                                  icon: const Icon(Icons.save_alt, size: 20),
                                  label: const Text('Save Screenshot'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D47A1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<PieChartSectionData> generateChartData(
    BuildContext context,
    Map<String, double> dataMap,
  ) {
    final List<PieChartSectionData> list = [];
    final total = dataMap.values.reduce((a, b) => a + b);
    final screenWidth = MediaQuery.of(context).size.width;
    final baseRadius = screenWidth * 0.25;
    final fontSize = screenWidth * 0.03;

    int i = 0;
    for (final entry in dataMap.entries) {
      final percentage = (entry.value / total) * 100;
      list.add(
        PieChartSectionData(
          color: colorList[i % colorList.length],
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: baseRadius.clamp(40, 60),
          titleStyle: TextStyle(
            fontSize: fontSize.clamp(8, 14),
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
