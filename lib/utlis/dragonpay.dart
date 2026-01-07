import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

void launchDragonpayPayment() async {
  final merchantId = 'JUAN4ALL';
  final password = 'uEo3VuyhPB94BFF';
  final txnId =
      DateTime.now().millisecondsSinceEpoch.toString(); // UNIQUE txnId
  final amount = '100.00'; // Make sure always two decimal places
  final currency = 'PHP';
  final description = 'Payment for Zippy';
  final email = 'olanalans12345@gmail.com';

// Make sure there are no extra spaces in any of these
  final toSign =
      '$merchantId:$txnId:$amount:$currency:$description:$email:$password';
  final digest = sha1.convert(utf8.encode(toSign)).toString();

  final url = 'https://test.dragonpay.ph/Pay.aspx?merchantid=$merchantId'
      '&txnid=$txnId'
      '&amount=$amount'
      '&ccy=$currency'
      '&description=${Uri.encodeComponent(description)}'
      '&email=$email'
      '&digest=$digest';

  final uri = Uri.parse(url);

  try {
    final canLaunch = await canLaunchUrl(uri);
    print('canLaunchUrl: $canLaunch');
    if (!canLaunch) {
      print('Cannot launch URL: $url');
      throw Exception('Device cannot launch the URL');
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView, // Fallback for emulator
    );
    print('launchUrl success: $launched');

    if (!launched) {
      throw Exception('launchUrl returned false');
    }
  } catch (e, stackTrace) {
    print('Error launching Dragonpay URL: $e');
    print('StackTrace: $stackTrace');
    // You can also show a toast or dialog here if needed
  }
}
