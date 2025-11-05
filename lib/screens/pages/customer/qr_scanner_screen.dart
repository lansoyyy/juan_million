import 'dart:io';
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
          if (!kIsWeb && Platform.isAndroid || Platform.isIOS)
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
      body: kIsWeb ? _buildWebScanner() : _buildMobileScanner(),
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

  Widget _buildWebScanner() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 100,
              color: primary,
            ),
            const SizedBox(height: 30),
            Text(
              'QR Scanner for Web',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Click the button below to upload a QR code image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload QR Code Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _showManualInputDialog,
              icon: const Icon(Icons.keyboard),
              label: const Text('Enter Code Manually'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
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
        // For web, we'll show a dialog asking the user to enter the QR code manually
        // since direct QR code scanning from images is limited on web
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
        controller.pauseCamera();
        Navigator.pop(context, scanData.code);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
