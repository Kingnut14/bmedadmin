import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ModernQRScanner extends StatefulWidget {
  const ModernQRScanner({super.key});

  @override
  State<ModernQRScanner> createState() => _ModernQRScannerState();
}

class _ModernQRScannerState extends State<ModernQRScanner> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isFlashOn = false;
  bool _isScanComplete = false;
  String? _scannedCode;
  List<Map<String, String>>? _parsedRequests;
  bool _isNavigated = false;

  void _processQRCode(String code) {
    final parsed = _parseMultipleRequests(code);
    if (!mounted) return;
    setState(() {
      _scannedCode = code;
      _parsedRequests = parsed;
      _isScanComplete = true;
      _isNavigated = false;
    });
    Feedback.forTap(context);
    _controller.stop();
  }

  List<Map<String, String>> _parseMultipleRequests(String code) {
    final requests = <Map<String, String>>[];


    final regex = RegExp(r'\{([^}]*)\}');
    final matches = regex.allMatches(code);

    for (var match in matches) {
      final rawEntry = match.group(1); // laman ng loob ng { ... }
      if (rawEntry == null) continue;

      final data = <String, String>{};

      final lines = rawEntry.split(RegExp(r'[\n,]'));

      for (var line in lines) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join(':').trim();
          data[key] = value;
        }
      }

      if (data.isNotEmpty) {
        requests.add(data);
      }
    }

    return requests;
  }




  void _navigateToAcceptedScreen() {
    if (_isNavigated) return;
    _isNavigated = true;

    Navigator.pushNamed(
      context,
      '/accepted',
      arguments: {
        'parsedRequests': _parsedRequests,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isScanComplete) return;
              if (capture.barcodes.isNotEmpty) {
                final barcode = capture.barcodes.first;
                final rawValue = barcode.rawValue;
                if (rawValue != null) {
                  _processQRCode(rawValue);
                }
              }
            },
          ),
          // Top Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 16,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset(
                  'assets/logo.png',
                  height: 100,
                  width: 100,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, color: Colors.white),
                ),
                IconButton(
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _controller.toggleTorch();
                    setState(() => _isFlashOn = !_isFlashOn);
                  },
                ),
              ],
            ),
          ),

          // Scan Result UI
          if (_isScanComplete && _scannedCode != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.medical_services, size: 48, color: Colors.blueAccent),
                          const SizedBox(height: 16),
                          Text(
                            _parsedRequests != null && _parsedRequests!.isNotEmpty
                                ? _parsedRequests![0]["name"] ?? "No Name Available"
                                : 'No Requests Found',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Show each request
                          if (_parsedRequests != null && _parsedRequests!.isNotEmpty) ...[
                            for (var request in _parsedRequests!) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Remove the "name" entry from the request before rendering
                                    for (var entry in request.entries)
                                      if (entry.key != 'name') _buildDetailRow(entry.key, entry.value),
                                    const Divider(color: Colors.white24),
                                  ],
                                ),
                              ),
                            ],
                          ]
                          else
                            const Text(
                              "No data available",
                              style: TextStyle(color: Colors.white70),
                            ),

                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                onPressed: () {
                                  _controller.start();
                                  setState(() {
                                    _isScanComplete = false;
                                    _scannedCode = null;
                                    _parsedRequests = null;
                                    _isNavigated = false;
                                  });
                                },
                                child: const Text('Reject'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('All requests accepted!')),
                                  );
                                  _navigateToAcceptedScreen();
                                },
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
