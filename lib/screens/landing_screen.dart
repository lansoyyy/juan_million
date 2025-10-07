import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/auth/signup_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/utlis/dragonpay.dart';
import 'package:juan_million/widgets/dragonpay_screen.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/newbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Navigation Bar
                if (isWeb) _buildNavigationBar(context),

                // Hero Section
                _buildHeroSection(context, isWeb),

                // Statistics Section
                _buildStatisticsSection(context, isWeb),

                // Features Section
                if (isWeb) _buildFeaturesSection(context),

                // How It Works Section
                _buildHowItWorksSection(context, isWeb),

                // Account Selection Section
                _buildAccountSection(context, isWeb),

                // Benefits Section
                _buildBenefitsSection(context, isWeb),

                // Testimonials Section
                if (isWeb) _buildTestimonialsSection(context),

                // FAQ Section
                _buildFAQSection(context, isWeb),

                // Final CTA Section
                _buildFinalCTASection(context, isWeb),

                // Footer
                _buildFooter(context, isWeb),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/Juan4All 2.png',
                height: 50,
              ),
              const SizedBox(width: 15),
              TextWidget(
                text: 'Juan 4 All',
                fontSize: 24,
                fontFamily: 'Bold',
                color: Colors.white,
              ),
            ],
          ),
          Row(
            children: [
              _buildNavLink('Home', () {}),
              const SizedBox(width: 30),
              _buildNavLink('Features', () {}),
              const SizedBox(width: 30),
              _buildNavLink('About', () {}),
              const SizedBox(width: 30),
              _buildNavLink('Contact', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: TextWidget(
          text: text,
          fontSize: 16,
          fontFamily: 'Medium',
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 80 : 20,
        vertical: isWeb ? 100 : 60,
      ),
      child: Column(
        children: [
          // Logo
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            child: Image.asset(
              'assets/images/Juan4All 2.png',
              height: isWeb ? 180 : 150,
            ),
          ),
          const SizedBox(height: 30),

          // Main Heading
          TextWidget(
            text: 'Your All-in-One Payment Solution',
            fontSize: isWeb ? 48 : 32,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          // Subheading
          Container(
            constraints:
                BoxConstraints(maxWidth: isWeb ? 700 : double.infinity),
            child: TextWidget(
              text:
                  'Seamlessly manage your transactions with secure, fast, and reliable payment services for both personal and business needs.',
              fontSize: isWeb ? 20 : 16,
              fontFamily: 'Regular',
              color: Colors.white.withOpacity(0.9),
              align: TextAlign.center,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 40),

          // CTA Buttons
          if (isWeb)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCTAButton(
                  context,
                  'Get Started',
                  primary,
                  () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginScreen(inCustomer: true)));
                  },
                ),
                const SizedBox(width: 20),
                _buildCTAButton(
                  context,
                  'For Business',
                  secondary,
                  () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginScreen(inCustomer: false)));
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(
      BuildContext context, String text, Color color, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextWidget(
            text: text,
            fontSize: 18,
            fontFamily: 'Bold',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
      child: Column(
        children: [
          TextWidget(
            text: 'Why Choose Juan 4 All?',
            fontSize: 36,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureCard(
                Icons.security,
                'Secure',
                'Bank-level encryption to protect your transactions',
              ),
              _buildFeatureCard(
                Icons.flash_on,
                'Fast',
                'Lightning-fast processing for instant payments',
              ),
              _buildFeatureCard(
                Icons.verified_user,
                'Reliable',
                'Trusted by thousands of users and businesses',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          TextWidget(
            text: title,
            fontSize: 24,
            fontFamily: 'Bold',
            color: Colors.white,
          ),
          const SizedBox(height: 15),
          TextWidget(
            text: description,
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.white.withOpacity(0.8),
            align: TextAlign.center,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 80 : 20,
        vertical: isWeb ? 80 : 40,
      ),
      child: Column(
        children: [
          TextWidget(
            text: 'Choose Your Account Type',
            fontSize: isWeb ? 36 : 28,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextWidget(
            text: 'Select the account that best fits your needs',
            fontSize: isWeb ? 18 : 14,
            fontFamily: 'Regular',
            color: Colors.white.withOpacity(0.8),
            align: TextAlign.center,
          ),
          const SizedBox(height: 50),
          isWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAccountCard(
                      context,
                      Icons.account_circle_outlined,
                      'Customer Account',
                      'For personal transactions and payments',
                      primary,
                      true,
                    ),
                    const SizedBox(width: 40),
                    _buildAccountCard(
                      context,
                      Icons.business_center_outlined,
                      'Business Account',
                      'For merchants and business owners',
                      secondary,
                      false,
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildAccountCard(
                      context,
                      Icons.account_circle_outlined,
                      'Customer Account',
                      'For personal transactions and payments',
                      primary,
                      true,
                    ),
                    const SizedBox(height: 20),
                    _buildAccountCard(
                      context,
                      Icons.business_center_outlined,
                      'Business Account',
                      'For merchants and business owners',
                      secondary,
                      false,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, IconData icon, String title,
      String description, Color color, bool isCustomer) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => LoginScreen(inCustomer: isCustomer)));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 320,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                spreadRadius: 3,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 25),
              TextWidget(
                text: title,
                fontSize: 24,
                fontFamily: 'Bold',
                color: Colors.white,
                align: TextAlign.center,
              ),
              const SizedBox(height: 15),
              TextWidget(
                text: description,
                fontSize: 14,
                fontFamily: 'Regular',
                color: Colors.white.withOpacity(0.9),
                align: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(height: 25),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextWidget(
                  text: 'Get Started',
                  fontSize: 16,
                  fontFamily: 'Bold',
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 80 : 20,
        vertical: isWeb ? 60 : 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
      ),
      child: isWeb
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('1M+', 'Active Users'),
                _buildStatCard('₱500M+', 'Transactions'),
                _buildStatCard('99.9%', 'Uptime'),
                _buildStatCard('24/7', 'Support'),
              ],
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('1M+', 'Active Users'),
                    _buildStatCard('₱500M+', 'Transactions'),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('99.9%', 'Uptime'),
                    _buildStatCard('24/7', 'Support'),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Column(
      children: [
        TextWidget(
          text: number,
          fontSize: 36,
          fontFamily: 'Bold',
          color: primary,
        ),
        const SizedBox(height: 8),
        TextWidget(
          text: label,
          fontSize: 16,
          fontFamily: 'Medium',
          color: Colors.white.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 80 : 20,
        vertical: isWeb ? 80 : 50,
      ),
      child: Column(
        children: [
          TextWidget(
            text: 'How It Works',
            fontSize: isWeb ? 36 : 28,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextWidget(
            text: 'Get started in just 3 simple steps',
            fontSize: isWeb ? 18 : 14,
            fontFamily: 'Regular',
            color: Colors.white.withOpacity(0.8),
            align: TextAlign.center,
          ),
          const SizedBox(height: 50),
          isWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepCard(
                      '1',
                      'Create Account',
                      'Sign up with your email and verify your identity in minutes',
                      Icons.person_add,
                    ),
                    _buildStepCard(
                      '2',
                      'Add Payment Method',
                      'Link your bank account or card securely to your wallet',
                      Icons.credit_card,
                    ),
                    _buildStepCard(
                      '3',
                      'Start Transacting',
                      'Send, receive, and manage payments with ease',
                      Icons.payment,
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildStepCard(
                      '1',
                      'Create Account',
                      'Sign up with your email and verify your identity in minutes',
                      Icons.person_add,
                    ),
                    const SizedBox(height: 30),
                    _buildStepCard(
                      '2',
                      'Add Payment Method',
                      'Link your bank account or card securely to your wallet',
                      Icons.credit_card,
                    ),
                    const SizedBox(height: 30),
                    _buildStepCard(
                      '3',
                      'Start Transacting',
                      'Send, receive, and manage payments with ease',
                      Icons.payment,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
      String number, String title, String description, IconData icon) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: TextWidget(
                      text: number,
                      fontSize: 16,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextWidget(
            text: title,
            fontSize: 22,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextWidget(
            text: description,
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.white.withOpacity(0.8),
            align: TextAlign.center,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 80 : 20,
        vertical: isWeb ? 80 : 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        children: [
          TextWidget(
            text: 'More Than Just Payments',
            fontSize: isWeb ? 36 : 28,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
          ),
          const SizedBox(height: 50),
          isWeb
              ? Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildBenefitItem(
                        Icons.account_balance_wallet, 'Digital Wallet'),
                    _buildBenefitItem(Icons.qr_code_scanner, 'QR Payments'),
                    _buildBenefitItem(Icons.receipt_long, 'Bill Payments'),
                    _buildBenefitItem(Icons.phone_android, 'Mobile Load'),
                    _buildBenefitItem(Icons.send_to_mobile, 'Money Transfer'),
                    _buildBenefitItem(Icons.analytics, 'Transaction History'),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBenefitItem(
                            Icons.account_balance_wallet, 'Digital Wallet'),
                        _buildBenefitItem(Icons.qr_code_scanner, 'QR Payments'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBenefitItem(Icons.receipt_long, 'Bill Payments'),
                        _buildBenefitItem(Icons.phone_android, 'Mobile Load'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBenefitItem(
                            Icons.send_to_mobile, 'Money Transfer'),
                        _buildBenefitItem(
                            Icons.analytics, 'Transaction History'),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String label) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 40),
          const SizedBox(height: 12),
          TextWidget(
            text: label,
            fontSize: 14,
            fontFamily: 'Medium',
            color: Colors.white,
            align: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
      child: Column(
        children: [
          TextWidget(
            text: 'What Our Users Say',
            fontSize: 36,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTestimonialCard(
                'Maria Santos',
                'Small Business Owner',
                'Juan 4 All has transformed how I handle payments. My customers love the convenience!',
                '⭐⭐⭐⭐⭐',
              ),
              _buildTestimonialCard(
                'John Reyes',
                'Freelancer',
                'Fast, reliable, and secure. I receive payments from clients instantly.',
                '⭐⭐⭐⭐⭐',
              ),
              _buildTestimonialCard(
                'Anna Cruz',
                'Online Shopper',
                'The easiest way to pay bills and shop online. Highly recommended!',
                '⭐⭐⭐⭐⭐',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
      String name, String role, String testimonial, String rating) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: rating,
            fontSize: 20,
            fontFamily: 'Regular',
            color: Colors.amber,
          ),
          const SizedBox(height: 15),
          TextWidget(
            text: '"$testimonial"',
            fontSize: 15,
            fontFamily: 'Regular',
            color: Colors.white.withOpacity(0.9),
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: TextWidget(
                    text: name[0],
                    fontSize: 24,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: name,
                    fontSize: 16,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                  TextWidget(
                    text: role,
                    fontSize: 13,
                    fontFamily: 'Regular',
                    color: Colors.white.withOpacity(0.6),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 80 : 20,
        vertical: isWeb ? 80 : 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        children: [
          TextWidget(
            text: 'Frequently Asked Questions',
            fontSize: isWeb ? 36 : 28,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
          ),
          const SizedBox(height: 50),
          Container(
            constraints:
                BoxConstraints(maxWidth: isWeb ? 800 : double.infinity),
            child: Column(
              children: [
                _buildFAQItem(
                  'Is Juan 4 All secure?',
                  'Yes! We use bank-level encryption and comply with all security standards to protect your data and transactions.',
                ),
                const SizedBox(height: 20),
                _buildFAQItem(
                  'What are the transaction fees?',
                  'We offer competitive rates with transparent pricing. Personal transfers are free, while business transactions have minimal fees.',
                ),
                const SizedBox(height: 20),
                _buildFAQItem(
                  'How long does it take to process payments?',
                  'Most transactions are instant. Bank transfers may take 1-2 business days depending on your bank.',
                ),
                const SizedBox(height: 20),
                _buildFAQItem(
                  'Can I use Juan 4 All for my business?',
                  'Absolutely! Our Business Account offers features like invoicing, payment links, and detailed analytics.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: question,
                  fontSize: 18,
                  fontFamily: 'Bold',
                  color: Colors.white,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: TextWidget(
              text: answer,
              fontSize: 14,
              fontFamily: 'Regular',
              color: Colors.white.withOpacity(0.8),
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalCTASection(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 80 : 20,
        vertical: isWeb ? 100 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.3),
            secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        children: [
          TextWidget(
            text: 'Ready to Get Started?',
            fontSize: isWeb ? 42 : 32,
            fontFamily: 'Bold',
            color: Colors.white,
            align: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            constraints:
                BoxConstraints(maxWidth: isWeb ? 600 : double.infinity),
            child: TextWidget(
              text:
                  'Join millions of users who trust Juan 4 All for their payment needs. Sign up today and experience seamless transactions.',
              fontSize: isWeb ? 18 : 16,
              fontFamily: 'Regular',
              color: Colors.white.withOpacity(0.9),
              align: TextAlign.center,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 40),
          isWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCTAButton(
                      context,
                      'Create Account',
                      primary,
                      () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(inCustomer: true)));
                      },
                    ),
                    const SizedBox(width: 20),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: TextWidget(
                            text: 'Learn More',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildCTAButton(
                      context,
                      'Create Account',
                      primary,
                      () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(inCustomer: true)));
                      },
                    ),
                    const SizedBox(height: 15),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: TextWidget(
                            text: 'Learn More',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 80 : 20,
        vertical: isWeb ? 60 : 40,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        children: [
          if (isWeb)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/Juan4All 2.png',
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        TextWidget(
                          text: 'Juan 4 All',
                          fontSize: 20,
                          fontFamily: 'Bold',
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextWidget(
                      text: 'Your trusted payment partner',
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Product',
                      fontSize: 16,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildFooterLink('Features'),
                    _buildFooterLink('Pricing'),
                    _buildFooterLink('Security'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Company',
                      fontSize: 16,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildFooterLink('About Us'),
                    _buildFooterLink('Careers'),
                    _buildFooterLink('Contact'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Legal',
                      fontSize: 16,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                    const SizedBox(height: 15),
                    _buildFooterLink('Privacy Policy'),
                    _buildFooterLink('Terms of Service'),
                    _buildFooterLink('Cookie Policy'),
                  ],
                ),
              ],
            ),
          if (isWeb) const SizedBox(height: 40),
          if (isWeb) Divider(color: Colors.white.withOpacity(0.2)),
          if (isWeb) const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security,
                  color: Colors.white.withOpacity(0.7), size: 20),
              const SizedBox(width: 10),
              TextWidget(
                text: 'Secure',
                fontSize: 16,
                fontFamily: 'Medium',
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 30),
              Icon(Icons.flash_on,
                  color: Colors.white.withOpacity(0.7), size: 20),
              const SizedBox(width: 10),
              TextWidget(
                text: 'Fast',
                fontSize: 16,
                fontFamily: 'Medium',
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 30),
              Icon(Icons.verified_user,
                  color: Colors.white.withOpacity(0.7), size: 20),
              const SizedBox(width: 10),
              TextWidget(
                text: 'Reliable',
                fontSize: 16,
                fontFamily: 'Medium',
                color: Colors.white.withOpacity(0.7),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextWidget(
            text: '© 2025 Juan 4 All. All rights reserved.',
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.white.withOpacity(0.5),
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {},
          child: TextWidget(
            text: text,
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
