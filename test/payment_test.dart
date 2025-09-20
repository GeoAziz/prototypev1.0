import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fresh_flutter_project/core/models/payment.dart';
import 'package:fresh_flutter_project/core/services/payment_service.dart';
import 'package:fresh_flutter_project/core/payment/mpesa_service.dart';
import 'package:fresh_flutter_project/core/payment/stripe_service.dart';
import 'package:fresh_flutter_project/core/payment/widgets/mpesa_payment_widget.dart';
import 'package:fresh_flutter_project/core/payment/widgets/card_payment_widget.dart';
import 'package:fresh_flutter_project/core/payment/widgets/bank_transfer_widget.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks using mockito's build_runner
@GenerateMocks([PaymentService, MpesaService, StripeService])
void main() {
  group('Payment Model Tests', () {
    test('creates Payment from JSON', () {
      final json = {
        'id': 'test_id',
        'amount': 1000.0,
        'method': 'mpesa',
        'status': 'pending',
        'message': 'Processing payment',
        'createdAt': '2024-01-22T10:00:00.000Z',
        'updatedAt': '2024-01-22T10:00:00.000Z',
      };

      final payment = Payment.fromJson(json);

      expect(payment.id, 'test_id');
      expect(payment.amount, 1000.0);
      expect(payment.method, 'mpesa');
      expect(payment.status, 'pending');
      expect(payment.message, 'Processing payment');
      expect(payment.createdAt.toIso8601String(), '2024-01-22T10:00:00.000Z');
      expect(payment.updatedAt.toIso8601String(), '2024-01-22T10:00:00.000Z');
    });

    test('converts Payment to JSON', () {
      final payment = Payment(
        id: 'test_id',
        amount: 1000.0,
        method: 'mpesa',
        status: 'pending',
        message: 'Processing payment',
        createdAt: DateTime.parse('2024-01-22T10:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-22T10:00:00.000Z'),
      );

      final json = payment.toJson();

      expect(json['id'], 'test_id');
      expect(json['amount'], 1000.0);
      expect(json['method'], 'mpesa');
      expect(json['status'], 'pending');
      expect(json['message'], 'Processing payment');
      expect(json['createdAt'], '2024-01-22T10:00:00.000Z');
      expect(json['updatedAt'], '2024-01-22T10:00:00.000Z');
    });
  });

  group('M-Pesa Payment Widget Tests', () {
    late MockPaymentService mockPaymentService;
    late MockMpesaService mockMpesaService;

    setUp(() {
      mockPaymentService = MockPaymentService();
      mockMpesaService = MockMpesaService();
    });

    testWidgets('shows phone number input field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MpesaPaymentWidget(
              bookingId: 'test_booking',
              amount: 1000.0,
              onPaymentComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('validates phone number input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MpesaPaymentWidget(
              bookingId: 'test_booking',
              amount: 1000.0,
              onPaymentComplete: (_) {},
            ),
          ),
        ),
      );

      // Try submitting without entering a phone number
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your phone number'), findsOneWidget);

      // Enter an invalid phone number
      await tester.enterText(find.byType(TextFormField), '1234');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(
        find.text('Please enter a valid 9-digit phone number'),
        findsOneWidget,
      );
    });
  });

  group('Card Payment Widget Tests', () {
    late MockPaymentService mockPaymentService;
    late MockStripeService mockStripeService;

    setUp(() {
      mockPaymentService = MockPaymentService();
      mockStripeService = MockStripeService();
    });

    testWidgets('shows card input field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardPaymentWidget(
              bookingId: 'test_booking',
              amount: 1000.0,
              onPaymentComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CardField), findsOneWidget);
    });
  });

  group('Bank Transfer Widget Tests', () {
    late MockPaymentService mockPaymentService;

    setUp(() {
      mockPaymentService = MockPaymentService();
    });

    testWidgets('shows bank transfer details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BankTransferWidget(
              bookingId: 'test_booking',
              amount: 1000.0,
              onPaymentComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Bank Transfer Details'), findsOneWidget);
      expect(find.text('Instructions'), findsOneWidget);
    });

    testWidgets('shows copy button for reference', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BankTransferWidget(
              bookingId: 'test_booking',
              amount: 1000.0,
              onPaymentComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });
  });
}
