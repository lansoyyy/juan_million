import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:juan_million/widgets/toast_widget.dart';

Future<void> downloadQrAsPng(
  BuildContext context, {
  required String data,
  required String fileName,
}) async {
  if (!kIsWeb) {
    showToast('QR download is currently available on web.', context: context);
    return;
  }

  final painter = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: true,
    color: Colors.black,
    emptyColor: Colors.white,
  );

  final imageData = await painter.toImageData(1024, format: ImageByteFormat.png);
  if (imageData == null) {
    showToast('Failed to generate QR image.', context: context, type: ToastType.error);
    return;
  }

  final bytes = imageData.buffer.asUint8List();
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', '$fileName.png')
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  showToast('QR code downloaded.', context: context);
}
