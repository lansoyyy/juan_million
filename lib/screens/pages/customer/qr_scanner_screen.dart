import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _manualCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () async {
                await controller?.toggleFlash();
              },
            ),
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _pickImageFromGallery,
              tooltip: 'Upload QR Code Image',
            ),
        ],
      ),
      body: kIsWeb ? _buildWebFallback() : _buildMobileScanner(),
    );
  }

  Widget _buildMobileScanner() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: primary,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 250,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              'Scan a QR code to earn points',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildWebFallback() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'QR camera scanning may not work reliably on desktop web.\nYou can still continue by entering the code manually or uploading an image.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _manualCodeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Paste / type QR code value',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary.withOpacity(0.8)),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final code = _manualCodeController.text.trim();
                    if (code.isEmpty) return;
                    Navigator.pop(context, code);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text(
                    'Upload QR Code Image',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.25)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        _showManualInputDialog();
      }
    } catch (e) {
      _showErrorDialog('Failed to process image: $e');
    }
  }

  void _showManualInputDialog() {
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter QR Code Manually'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter QR code value',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.pop(context);
                Navigator.pop(context, textController.text);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning && scanData.code != null) {
        isScanning = false;
        if (!kIsWeb) {
          controller.pauseCamera();
        }
        Navigator.pop(context, scanData.code);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }
}
