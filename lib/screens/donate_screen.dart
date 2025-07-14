import 'package:flutter/material.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    double responsiveFont(double base) => screenWidth * base;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Support Our Cause',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: responsiveFont(0.05),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner image
            Container(
              height: screenWidth * 0.5,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/donation_banner.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black26,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Make a Difference Today',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveFont(0.06),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        'Your contribution helps us protect and empower women',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: responsiveFont(0.04),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Scan to Donate',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveFont(0.05),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.04),

                  // QR Code
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/donation_qr.png',
                          height: screenWidth * 0.5,
                          width: screenWidth * 0.5,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        Text(
                          "Scan with any UPI app",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontSize: responsiveFont(0.04),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.08),

                  Text(
                    'Bank Transfer Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveFont(0.05),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.04),

                  // Bank details card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.tertiary.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      children: [
                        _buildBankDetailRow(context, "Account Name", "Women Safety Foundation"),
                        _buildDivider(),
                        _buildBankDetailRow(context, "Account Number", "6754 3210 9876 5432"),
                        _buildDivider(),
                        _buildBankDetailRow(context, "IFSC Code", "WSFT0001234"),
                        _buildDivider(),
                        _buildBankDetailRow(context, "Bank Name", "National City Bank"),
                        _buildDivider(),
                        _buildBankDetailRow(context, "Branch", "Main Branch, New Delhi"),
                      ],
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.08),

                  // Custom amount button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Custom donation dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.04,
                        ),
                      ),
                      child: Text(
                        "Enter Custom Amount",
                        style: TextStyle(
                          fontSize: responsiveFont(0.045),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.04),

                  // Donation chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDonationChip(context, "₹100"),
                      _buildDonationChip(context, "₹500"),
                      _buildDonationChip(context, "₹1000"),
                    ],
                  ),

                  SizedBox(height: screenWidth * 0.08),

                  Text(
                    "100% of your donation goes directly to supporting women's safety initiatives",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: responsiveFont(0.035),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 24,
      thickness: 1,
    );
  }

  Widget _buildBankDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: screenWidth * 0.035,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.04,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDonationChip(BuildContext context, String amount) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        // TODO: Handle donation
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenWidth * 0.03,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.colorScheme.tertiary,
          ),
        ),
        child: Text(
          amount,
          style: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        ),
      ),
    );
  }
}
// This code defines a donation screen for a Flutter application, featuring a banner, QR code for donations, bank transfer details, and options for custom and preset donation amounts. The layout is responsive to screen size changes.