import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a service?',
      'answer':
          'To book a service, open the app and tap on the service you want to book. Select your preferred date and time, add any special instructions, and confirm your booking. You\'ll receive a confirmation notification once your booking is confirmed.',
    },
    {
      'question': 'How do I cancel a booking?',
      'answer':
          'To cancel a booking, go to "My Bookings" in the app menu, select the booking you want to cancel, and tap the "Cancel Booking" button. Please note that cancellation policies may apply depending on how close to the service time you cancel.',
    },
    {
      'question': 'How do I add a payment method?',
      'answer':
          'To add a payment method, go to "Settings" > "Payment Methods" > "Add Payment Method". You can add credit/debit cards or connect your PayPal account. All payment information is securely stored and processed.',
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'You can contact our support team through several channels:\n\n1. Live Chat: Available 24/7 in the Help & Support section\n2. Support Tickets: Submit detailed inquiries for complex issues\n3. Email: support@poafix.com\n4. Phone: 1-800-POAFIX',
    },
    {
      'question': 'How do I change my address?',
      'answer':
          'To update your address, go to "Settings" > "Profile" > "Addresses". Here you can edit existing addresses or add new ones. Make sure to tap "Save" after making any changes.',
    },
    {
      'question': 'What happens if I\'m not satisfied with the service?',
      'answer':
          'Your satisfaction is our priority. If you\'re not happy with a service, please contact our support team within 24 hours of service completion. We\'ll work to resolve the issue or provide a refund according to our satisfaction guarantee policy.',
    },
    {
      'question': 'How do I become a service provider?',
      'answer':
          'To become a service provider, tap "Become a Provider" in the app menu. You\'ll need to complete an application, provide required documentation, and pass our verification process. Our team will review your application and contact you within 2-3 business days.',
    },
    {
      'question': 'Is my personal information secure?',
      'answer':
          'Yes, we take data security seriously. All personal information is encrypted and stored securely. We never share your data with third parties without your consent. You can review our privacy policy in the app settings.',
    },
  ];

  FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frequently Asked Questions')),
      body: ListView.builder(
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    faq['answer']!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
