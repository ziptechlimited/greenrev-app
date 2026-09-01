import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  Text('PRIVACY POLICY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                  SizedBox(height: 4),
                  Text('Operated by GreenCrest Ltd', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  Text('Effective date: 31 August 2026', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  Text('support@greenrevs.com', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  SizedBox(height: 24),
                ],
              ),
            ),
            
            Text(
              "This Privacy Policy explains GreenRev's personal-data practices in a layered, user-facing format designed around Nigerian requirements and widely used international privacy-notice principles.",
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),

            _SectionHeading('1. Who We Are and Scope'),
            _BodyText('This Privacy Policy explains how GreenCrest Ltd, operator of GreenRev, collects, uses, shares, retains and protects personal data through the GreenRev website, applications, dashboards, marketplace and related services.'),
            _BodyText('Where GreenCrest Ltd determines the purposes and means of processing, it acts as the data controller. Independent sellers, payment providers, lenders, logistics providers and other partners may separately act as controllers for their own processing.'),
            SizedBox(height: 24),

            _SectionHeading('2. Information We Collect'),
            _SubHeading('Account and identity data'),
            _BodyText('Name, username, email, phone number, account credentials in protected form, profile information, date of birth where required, identity documents and verification results where necessary.'),
            _SubHeading('Business and dealer data'),
            _BodyText('Business/dealership name, registration details, business contact information, authorised representatives, verification documents, subscription information and related account data.'),
            _SubHeading('Vehicle, listing and ownership data'),
            _BodyText('Listings, photographs, VIN/chassis information, registration information, mileage, service or inspection records, ownership documents and information about vehicles, parts or services.'),
            _SubHeading('Transaction and communications data'),
            _BodyText('Enquiries, deal/order IDs, transaction status, prices, commissions, delivery confirmations, refunds, complaints, disputes, reviews, messages and support records.'),
            _SubHeading('Payment data'),
            _BodyText('Payment-provider references, amounts, status, masked payment details and settlement information. Complete card credentials may be collected directly by payment providers rather than GreenRev.'),
            _SubHeading('Finance-referral data'),
            _BodyText('Information you submit for finance or BNPL referral or preliminary eligibility, plus related referral status. Finance providers may collect additional information directly.'),
            _SubHeading('Location data'),
            _BodyText('Approximate location and, with permission or when needed for a feature, precise device location.'),
            _SubHeading('Technical and usage data'),
            _BodyText('IP address, device identifiers, browser/app version, operating system, timestamps, searches, clicks, viewed screens/pages, crash, diagnostic and security information.'),
            _SubHeading('Cookies and similar technology data'),
            _BodyText('Identifiers and usage data collected through cookies, SDKs and similar technologies, subject to applicable consent requirements.'),
            SizedBox(height: 24),

            _SectionHeading('3. Sources of Personal Data'),
            _BodyText('We collect data directly from you when you register, list or enquire about an item, transact, request a service or finance referral, communicate with another user, contact support or otherwise use GreenRev.'),
            _BodyText('We may receive data from other marketplace users, dealers, payment providers, logistics partners, verification providers, finance partners, analytics/security providers and lawful public sources.'),
            _BodyText('Where information is obtained from another source, we use it only where we have an appropriate lawful basis and provide information required by applicable law.'),
            SizedBox(height: 24),

            _SectionHeading('4. Purposes and Lawful Bases'),
            _BodyText('GreenRev processes personal data only for defined purposes and on an appropriate lawful basis.'),
            _BodyText('• Account creation, authentication and requested services: contract or steps requested before contract.'),
            _BodyText('• Listings, enquiries, transactions, delivery and support: contract and legitimate interests in operating the marketplace.'),
            _BodyText('• Payments, refunds, accounting and transaction records: contract, legal obligations and legitimate interests.'),
            _BodyText('• Finance/BNPL referrals: steps requested by you before a potential contract, consent where appropriate, and applicable legal obligations.'),
            _BodyText('• Identity verification, security and fraud prevention: legitimate interests and legal obligations where applicable.'),
            _BodyText('• Location-based features: consent where device permission/consent is required, or contract where necessary for a requested service.'),
            _BodyText('• Service analytics and product improvement: legitimate interests, with consent for non-essential tracking where required.'),
            _BodyText('• Direct marketing: consent or another lawful basis permitted by applicable law, with opt-out rights.'),
            _BodyText('• Legal claims, regulatory requests and compliance: legal obligations and legitimate interests in protecting legal rights.'),
            SizedBox(height: 24),

            _SectionHeading('5. Sensitive Personal Data'),
            _BodyText('We seek to minimise collection of sensitive personal data. Where sensitive data is necessary, we will rely on an appropriate legal condition and apply enhanced safeguards.'),
            SizedBox(height: 24),

            _SectionHeading('6. Payments'),
            _BodyText('Independent payment providers may process payment credentials and apply their own privacy notices. We do not intend to store complete card credentials.'),
            SizedBox(height: 24),

            _SectionHeading('7. Finance and BNPL Referrals'),
            _BodyText('If you ask us to connect you with a finance provider, we may transmit the information reasonably necessary for that referral.'),
            SizedBox(height: 24),

            _SectionHeading('8. Location Data'),
            _BodyText('With appropriate permission, precise location may be used for nearby vehicles, dealers, mechanics, rentals, logistics or other location-based features.'),
            SizedBox(height: 24),

            _SectionHeading('9. Cookies and Similar Technologies'),
            _BodyText('GreenRev may use strictly necessary technologies for authentication, security, preferences and core functionality.'),
            SizedBox(height: 24),

            _SectionHeading('10. Who We Share Data With'),
            _BodyText('We may share personal data with relevant marketplace counterparties; payment processors; logistics, mechanic, inspection and rental providers; finance providers and competent authorities.'),
            SizedBox(height: 24),

            _SectionHeading('11. International Transfers'),
            _BodyText('Some service providers may process information outside Nigeria with required safeguards.'),
            SizedBox(height: 24),

            _SectionHeading('12. Retention'),
            _BodyText('We keep personal data only for as long as necessary for the relevant purpose and applicable legal requirements.'),
            SizedBox(height: 24),

            _SectionHeading('13. Security'),
            _BodyText('We use technical and organisational measures appropriate to risk. No system is completely secure.'),
            SizedBox(height: 24),
            
            _SectionHeading('14. Personal Data Breaches'),
            _BodyText('Report suspected compromise to support@greenrevs.com.'),
            SizedBox(height: 24),

            _SectionHeading('15. Your Privacy Rights'),
            _BodyText('Subject to applicable law, you may have rights to access, correction, deletion, restriction, objection and data portability.'),
            SizedBox(height: 24),

            _SectionHeading('24. Contact and Complaints'),
            _BodyText('GreenRev\nOperated by GreenCrest Ltd\nWebsite: www.greenrevs.com\nPrivacy and support email: support@greenrevs.com'),
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

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w600,
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
