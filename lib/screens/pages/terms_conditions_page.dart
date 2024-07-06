import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: blue,
          title: TextWidget(
            text: 'Terms and Conditions',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '''
Terms and Conditions\n
Welcome to our Affiliate Program. By participating, you agree to comply with and be bound by the
following terms and conditions:\n
1. Compliance with Discounting and Pricing Policies
Affiliates must adhere to the company's discounting and pricing policies for all company
merchandise. Any deviation from these policies may result in immediate termination of the
affiliate agreement.\n
2. Exchange Rate of Reward Points and Cash Wallets
Affiliates must honor the exchange rate of reward points and cash wallets as determined by the
company. Any changes to these rates will be communicated to affiliates in advance.\n
3. Extension of Reward Points to Customers
Affiliates are required to extend reward points to all customers using the company platform. This
ensures a consistent and fair experience for all customers, regardless of the affiliate through
whom they are purchasing.\n
4. Right to Terminate or Decline Subscription
The company reserves the right to stop and/or decline any affiliate's subscription at any time,
with or without cause. This includes, but is not limited to, violations of these terms and
conditions or any actions deemed harmful to the company’s reputation or operations.\n
5. Use of Marketing Materials
Affiliates must use approved marketing materials provided by the company. Any modifications or
the use of unapproved materials must receive prior written consent from the company.\n
6. Data Privacy and Security
Affiliates must ensure that all customer data collected through the platform is handled in
accordance with applicable data protection laws and the company's privacy policies. Any data
breaches must be reported to the company immediately.\n
7. Prohibited Conduct
Affiliates are prohibited from engaging in fraudulent activities, misleading advertising, or any
practices that could harm the company’s reputation. Violations will result in immediate
termination of the affiliate agreement.\n
8. Modification of Terms
The company reserves the right to modify these terms and conditions at any time. Affiliates will
be notified of any changes, and continued participation in the program will constitute
acceptance of the new terms.\n
9. Indemnification
Affiliates agree to indemnify and hold the company harmless from any claims, damages, losses,
or expenses arising out of or related to the affiliate’s activities, including but not limited to
violations of these terms.\n
10. Intellectual Property Rights
All intellectual property rights, including trademarks, service marks, and copyrights related to
the company's brand and materials, remain the property of the company. Affiliates are granted a
limited license to use these materials for the sole purpose of promoting the company's platform,
subject to these terms and conditions.\n
By clicking "AGREE," you acknowledge that you have read, understood, and agree to be bound by these
terms and conditions. If you do not agree to these terms, please decline participation in the Affiliate
Program
                  ''',
                  style: TextStyle(fontSize: 14.0, fontFamily: 'Regular'),
                ),
              ],
            ),
          ),
        ));
  }
}
