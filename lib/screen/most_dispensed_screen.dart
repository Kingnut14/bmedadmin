import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pw;
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
  int selectedMonth = DateTime.now().month; // sets to current month (1-12)
  int selectedYear = DateTime.now().year; // current year
  bool _isExporting = false;
  bool _showFilter = false;

  Map<String, double> dataMap = {};

  final List<int> years = List.generate(
    10,
    (index) => DateTime.now().year - index,
  ); // last 10 years
  final List<String> months = List.generate(
    12,
    (index) => DateFormat('MMMM').format(DateTime(0, index + 1)),
  );

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
    Colors.teal,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.brown,
    Colors.yellow,
    Colors.blueGrey,
    Colors.redAccent,
  ];

  ScreenshotController screenshotController = ScreenshotController();

  Future<void> fetchMostDispensedMedicines() async {
    // build base URL
    String urlString = 'http://127.0.0.1:5566/dashboard/most-dispense-medicine';
    // only append filter if the panel is showing
    if (_showFilter) {
      final monthYear = DateFormat(
        'yyyy-MM',
      ).format(DateTime(selectedYear, selectedMonth));
      urlString += '?monthYear=$monthYear';
    }

    final url = Uri.parse(urlString);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['retCode'] == "200") {
        final data = jsonData['data'];

        if (data is List) {
          setState(() {
            dataMap.clear(); // Reset data
            for (var item in data) {
              final String name = item['medicine_name'];
              final double quantity =
                  (item['total_quantity'] as num).toDouble();
              dataMap[name] = quantity;
            }
          });
        } else if (data == null) {
          setState(() {
            dataMap.clear();
          });
          print("No data found for this month/year.");
        } else {
          print("Error: 'data' is not a list or is null.");
        }
      } else {
        print("Backend error: ${jsonData['Message']}");
      }
    } else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMostDispensedMedicines();
  }

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
    setState(() {
      _isExporting = true;
    });
    final pdf = pw.Document();
    final total = dataMap.values.reduce((a, b) => a + b);
    final sortedData =
        dataMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    //final bool isFilterActive = selectedMonth > 0 && selectedYear > 0;

    String dateLabel =
        (_showFilter && selectedMonth > 0 && selectedYear > 0)
            ? 'Date: ${months[selectedMonth - 1]} $selectedYear'
            : 'Overall data';

    // Use dateLabel when building your PDF

    try {
      // Capture pie chart offscreen as image
      final Uint8List? pieChartImageBytes = await screenshotController
          .captureFromWidget(
            MediaQuery(
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
              child: SizedBox(
                width: 400, // Increase width
                height: 400, // Increase height
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50, // Slightly bigger hole
                    sections: generateChartData(context, dataMap),
                  ),
                ),
              ),
            ),
            pixelRatio: 3,
          );

      pw.PdfColor convertColor(Color color) {
        return PdfColor.fromInt(color.value);
      }

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
                pw.Text(dateLabel, style: pw.TextStyle(fontSize: 12)),

                // Pie chart image in PDF
                pw.Center(
                  child: pw.SizedBox(
                    width: 250,
                    height: 250,
                    child: pw.Transform.scale(
                      scale: 1.7,
                      child: pw.Image(pieChartImage, fit: pw.BoxFit.contain),
                    ),
                  ),
                ),

                pw.SizedBox(height: -10),

                pw.Center(
                  child: pw.Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children:
                        sortedData.map((entry) {
                          final index =
                              dataMap.keys.toList().indexOf(entry.key) %
                              colorList.length;
                          final color = convertColor(colorList[index]);

                          return pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(4),
                              border: pw.Border.all(color: PdfColors.grey300),
                            ),
                            child: pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.Container(
                                  width: 12,
                                  height: 12,
                                  decoration: pw.BoxDecoration(
                                    color: color,
                                    shape: pw.BoxShape.circle,
                                  ),
                                ),
                                pw.SizedBox(width: 6),
                                pw.Text(
                                  entry.key,
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),

                // Remove or reduce this SizedBox height or make it smaller
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
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            (_showFilter &&
                                    selectedMonth > 0 &&
                                    selectedYear > 0)
                                ? 'Date: ${months[selectedMonth - 1]} $selectedYear'
                                : 'Overall data',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 4),
                          // Filter icon + conditional dropdown filter section
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.filter_alt_outlined,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showFilter = !_showFilter;
                                });
                                // always refresh after toggling
                                fetchMostDispensedMedicines();
                              },
                            ),
                          ),
                          if (_showFilter)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DropdownButton<int>(
                                    value: selectedMonth,
                                    items: List.generate(12, (index) {
                                      final monthNumber = index + 1;
                                      return DropdownMenuItem(
                                        value: monthNumber,
                                        child: Text(months[index]),
                                      );
                                    }),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedMonth = value;
                                        });
                                        fetchMostDispensedMedicines();
                                      }
                                    },
                                  ),

                                  const SizedBox(width: 20),
                                  DropdownButton<int>(
                                    value: selectedYear,
                                    items:
                                        years
                                            .map(
                                              (y) => DropdownMenuItem<int>(
                                                value: y,
                                                child: Text('$y'),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (y) {
                                      if (y != null) {
                                        setState(() {
                                          selectedYear = y;
                                        });
                                        fetchMostDispensedMedicines();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                          //const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),

                  // Show no data message if empty, else show the chart & table cards
                  dataMap.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            "No data found for this month/year.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      )
                      : Card(
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
                                    sections: generateChartData(
                                      context,
                                      dataMap,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 16,
                                  runSpacing: 12,
                                  children:
                                      dataMap.entries.map((entry) {
                                        final index =
                                            dataMap.keys.toList().indexOf(
                                              entry.key,
                                            ) %
                                            colorList.length;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
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
                                              Text(
                                                entry.key,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
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
                                    dataTextStyle: const TextStyle(
                                      fontSize: 12,
                                    ),
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
                                  onPressed:
                                      (_isExporting || dataMap.isEmpty)
                                          ? null
                                          : _exportAsPDF,
                                  icon:
                                      _isExporting
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Icon(
                                            Icons.picture_as_pdf,
                                            size: 20,
                                          ),
                                  label:
                                      _isExporting
                                          ? const Text('Exporting...')
                                          : const Text('Export as PDF'),
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
    final total = dataMap.values.fold(0.0, (a, b) => a + b);
    return dataMap.entries.map((entry) {
      final index = dataMap.keys.toList().indexOf(entry.key) % colorList.length;
      final percentage = (entry.value / total) * 100;

      return PieChartSectionData(
        color: colorList[index],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
