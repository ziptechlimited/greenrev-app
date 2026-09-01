import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Terms of Use', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text('GREENREV', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 12)),
                  SizedBox(height: 8),
                  Text('TERMS OF USE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                  SizedBox(height: 4),
                  Text('Operated by GreenCrest Ltd', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  Text('Effective date: 31 August 2026', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  Text('support@greenrevs.com', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  SizedBox(height: 24),
                ],
              ),
            ),
            
            Text(
              "These Terms set out the public rules for using GreenRev and are written for GreenRev's multi-sided automotive marketplace, digital services and planned mobile applications.",
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            _SectionHeading('1. Agreement and Definitions'),
            _BodyText('These Terms of Use (Terms) govern access to and use of GreenRev\'s website, mobile applications, dashboards, marketplace tools, communications and related services (the Platform).'),
            _BodyText('By accessing or using the Platform, you agree to these Terms and any service-specific terms presented to you. If you do not agree, do not use the Platform.'),
            SizedBox(height: 24),

            _SectionHeading('2. GreenRev\'s Marketplace Role'),
            _BodyText('GreenRev is a technology-enabled automotive marketplace and services platform. It may connect users with independent vehicle sellers, dealers, parts vendors, mechanics, inspectors, rental providers, logistics providers, finance providers and other third parties.'),
            SizedBox(height: 24),

            _SectionHeading('3. Eligibility, Registration and Account Security'),
            _BodyText('You must have legal capacity to enter binding agreements. You must provide accurate, current and complete information.'),
            SizedBox(height: 24),

            _SectionHeading('4. App Licence'),
            _BodyText('If you download a GreenRev mobile application, GreenCrest Ltd grants you a limited, personal, non-exclusive, non-transferable, revocable licence to install and use the application on devices you own or control.'),
            SizedBox(height: 24),

            _SectionHeading('5. Listings and Seller Obligations'),
            _BodyText('Sellers must have legal authority to offer the relevant vehicle, part or service and must provide accurate, current and non-misleading information.'),
            SizedBox(height: 24),

            _SectionHeading('13. User Content and Reviews'),
            _BodyText('You retain ownership of content you submit. You grant GreenRev a non-exclusive, worldwide, royalty-free licence to host, store, reproduce, format, display, distribute and use that content.'),
            SizedBox(height: 24),

            _SectionHeading('15. Prohibited Conduct'),
            _BodyText('• Hacking, phishing, malware, denial-of-service activity or unauthorised access.\n• Scraping or harvesting Platform data without permission.\n• Impersonation, fake accounts, manipulated reviews.\n• Spam, harassment, threats, discriminatory abuse.\n• Fraudulent listings, stolen or counterfeit goods.'),
            SizedBox(height: 24),
            
            _SectionHeading('20. Liability'),
            _BodyText('To the maximum extent permitted by applicable law, GreenRev is not liable for indirect or consequential losses arising solely from independent third-party conduct or services outside GreenRev\'s reasonable control.'),
            SizedBox(height: 24),

            _SectionHeading('23. Governing Law'),
            _BodyText('These Terms are governed by the laws of the Federal Republic of Nigeria.'),
            SizedBox(height: 24),

            _SectionHeading('26. Contact'),
            _BodyText('GreenRev\nOperated by GreenCrest Ltd\nWebsite: www.greenrevs.com\nEmail: support@greenrevs.com'),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
