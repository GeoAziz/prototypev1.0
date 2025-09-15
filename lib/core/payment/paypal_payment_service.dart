import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_service.dart';

class PayPalPaymentService implements PaymentProvider {
  Future<Map<String, String>> _createOrder({
    required String accessToken,
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> metadata,
  }) async {
    debugPrint(
      '[PayPal] _createOrder called with: amount=[32m$amount[0m, currency=$currency, serviceId=$serviceId, metadata=$metadata',
    );
    final response = await http.post(
      Uri.parse('$_baseUrl/v2/checkout/orders'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: () {
        final orderPayload = {
          'intent': 'CAPTURE',
          'purchase_units': [
            {
              'amount': {
                'currency_code': currency,
                'value': amount.toStringAsFixed(2),
              },
              'custom_id': serviceId,
              'description': metadata['description'] ?? 'Home Service Payment',
            },
          ],
          'application_context': {
            'return_url': 'https://success.poafix.com',
            'cancel_url': 'https://cancel.poafix.com',
            'brand_name': 'PoaFix Home Services',
            'landing_page': 'LOGIN',
            'user_action': 'PAY_NOW',
          },
        };
        debugPrint('\n[PayPal] 📤 Sending order request to PayPal:');
        debugPrint(JsonEncoder.withIndent('  ').convert(orderPayload));
        return jsonEncode(orderPayload);
      }(),
    );
    debugPrint(
      '[PayPal] _createOrder response: status=${response.statusCode}, body=${response.body}',
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      debugPrint('[PayPal] _createOrder success: $data');
      final approvalUrl = data['links']
          .firstWhere((link) => link['rel'] == 'approve')['href']
          .toString();
      return {'orderId': data['id'], 'approvalUrl': approvalUrl};
    }
    debugPrint('[PayPal] _createOrder failed: ${response.body}');
    throw Exception('Failed to create PayPal order');
  }

  Future<bool> _showPayPalCheckout({
    required BuildContext context,
    required String approvalUrl,
  }) async {
    debugPrint('\n[PayPal] 🌐 Opening WebView Checkout');
    debugPrint('[PayPal] • Initial URL: $approvalUrl');

    bool paymentSuccess = false;
    bool isLoading = true;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Enhanced security headers
      ..setUserAgent('PoaFix-PayPal-Checkout')
      // Set security and privacy headers
      ..loadRequest(
        Uri.parse(approvalUrl),
        headers: {
          'X-Frame-Options': 'DENY',
          'X-Content-Type-Options': 'nosniff',
          'Referrer-Policy': 'strict-origin-when-cross-origin',
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('\n[PayPal] 🔄 WebView Navigation');
            debugPrint('[PayPal] • Navigating to: ${request.url}');

            // Enhanced URL validation
            final Uri? uri = Uri.tryParse(request.url);
            if (uri == null) {
              debugPrint('[PayPal] ❌ Invalid URL format');
              return NavigationDecision.prevent;
            }

            // Whitelist of allowed domains
            final allowedDomains = [
              'www.sandbox.paypal.com',
              'www.paypal.com',
              'success.poafix.com',
              'cancel.poafix.com',
            ];

            if (!allowedDomains.contains(uri.host)) {
              debugPrint('[PayPal] ❌ Blocked navigation to untrusted domain: ${uri.host}');
              return NavigationDecision.prevent;
            }

            if (request.url.startsWith('https://success.poafix.com')) {
              debugPrint('[PayPal] ✅ Payment Approved');
              paymentSuccess = true;
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }

            if (request.url.startsWith('https://cancel.poafix.com')) {
              debugPrint('[PayPal] ❌ Payment Cancelled by User');
              paymentSuccess = false;
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }

            debugPrint('[PayPal] ➡️ Allowing navigation to trusted domain');
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            // Improved error handling
            if (error.description.toLowerCase().contains('cors')) {
              // Ignore CORS errors in sandbox
              return;
            }

            debugPrint('\n[PayPal] ❌ WebView Error:');
            debugPrint('[PayPal] • Error Code: ${error.errorCode}');
            debugPrint('[PayPal] • Description: ${error.description}');

            // Handle critical errors
            if (error.errorType == WebResourceErrorType.authentication ||
                error.errorType == WebResourceErrorType.badUrl ||
                error.errorType == WebResourceErrorType.connect) {
              debugPrint('[PayPal] ⚠️ Critical WebView Error');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connection issue. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          onPageFinished: (String url) {
            debugPrint('\n[PayPal] 📱 Page Loaded: $url');
          },
        ),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loading payment page...'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          onPageFinished: (url) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ready for payment'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(approvalUrl));

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Payment?'),
                        content: const Text('Are you sure you want to cancel this payment?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No, Continue'),
                          ),
                          TextButton(
                            onPressed: () {
                              paymentSuccess = false;
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close WebView
                            },
                            child: const Text('Yes, Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                title: const Text('PayPal Checkout'),
                centerTitle: true,
              ),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: controller),
                    StatefulBuilder(
                      builder: (context, setState) {
                        controller.setNavigationDelegate(
                          NavigationDelegate(
                            onPageStarted: (_) => setState(() => isLoading = true),
                            onPageFinished: (_) => setState(() => isLoading = false),
                          ),
                        );
                        
                        return isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('[PayPal] ❌ Error in payment dialog: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      paymentSuccess = false;
    }
    return paymentSuccess;
  }

  Future<bool> _capturePayPalPayment(String accessToken, String orderId) async {
    debugPrint('\n[PayPal] 💳 Capturing Payment');
    debugPrint('[PayPal] • Order ID: $orderId');
    debugPrint(
      '[PayPal] • Using Access Token: ${accessToken.substring(0, 10)}...',
    );

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v2/checkout/orders/$orderId/capture'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('\n[PayPal] 📥 Capture Response:');
      debugPrint('[PayPal] • Status Code: ${response.statusCode}');
      debugPrint('[PayPal] • Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final isCompleted = data['status'] == 'COMPLETED';

        if (isCompleted) {
          debugPrint('[PayPal] ✅ Payment Capture Successful');
          debugPrint('[PayPal] • Status: ${data['status']}');
          debugPrint(
            '[PayPal] • Transaction ID: ${data['purchase_units']?[0]?['payments']?['captures']?[0]?['id']}',
          );
        } else {
          debugPrint('[PayPal] ⚠️ Payment Not Completed');
          debugPrint('[PayPal] • Status: ${data['status']}');
        }

        return isCompleted;
      } else {
        debugPrint('[PayPal] ❌ Capture Failed');
        debugPrint('[PayPal] • Error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('[PayPal] ❌ Capture Error');
      debugPrint('[PayPal] • Exception: $e');
      return false;
    }
  }

  static final String _clientId = dotenv.env['PAYPAL_CLIENT_ID'] ?? '';
  static final String _clientSecret = dotenv.env['PAYPAL_CLIENT_SECRET'] ?? '';
  static final bool _isSandbox = dotenv.env['PAYPAL_MODE'] == 'sandbox';
  static final String _baseUrl = _isSandbox
      ? 'https://api-m.sandbox.paypal.com'
      : 'https://api-m.paypal.com';

  Future<String> _getAccessToken() async {
    debugPrint('[PayPal] _getAccessToken called');
    debugPrint('[PayPal] Requesting access token');
    final basicAuth = base64.encode(utf8.encode('$_clientId:$_clientSecret'));
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/oauth2/token'),
      headers: {
        'Authorization': 'Basic $basicAuth',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );
    debugPrint(
      '[PayPal] _getAccessToken response: status=${response.statusCode}, body=${response.body}',
    );
    if (response.statusCode == 200) {
      debugPrint('[PayPal] Access token received');
      return jsonDecode(response.body)['access_token'];
    }
    debugPrint('[PayPal] Failed to get access token: ${response.body}');
    throw Exception('Failed to get PayPal access token');
  }

  @override
  Future<PaymentResult> pay({
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Input validation with detailed logging
      debugPrint('\n[PayPal] 🔵 Payment Flow Started');
      debugPrint('[PayPal] 📝 Input Parameters:');
      debugPrint('  • Amount: $amount (${amount.runtimeType})');
      debugPrint('  • Currency: $currency');
      debugPrint('  • Service ID: $serviceId');
      debugPrint('  • User Data: $userData');

      // Validate amount
      if (amount <= 0) {
        debugPrint('[PayPal] ❌ Invalid amount: $amount');
        return PaymentResult(
          success: false,
          errorMessage: 'Invalid payment amount: Amount must be greater than 0',
        );
      }

      // Validate currency
      if (currency.isEmpty) {
        debugPrint('[PayPal] ❌ Invalid currency: Empty currency code');
        return PaymentResult(
          success: false,
          errorMessage: 'Invalid currency code',
        );
      }

      // Validate service ID
      if (serviceId.isEmpty) {
        debugPrint('[PayPal] ❌ Invalid serviceId: Empty service ID');
        return PaymentResult(
          success: false,
          errorMessage: 'Invalid service ID',
        );
      }

      // Check build context
      final context = userData['context'] as BuildContext?;
      if (context == null) {
        debugPrint('[PayPal] ❌ Missing BuildContext in userData');
        return PaymentResult(
          success: false,
          errorMessage: 'BuildContext not provided in userData',
        );
      }

      debugPrint('[PayPal] ✅ Input validation passed');
      // Start the PayPal payment flow
      debugPrint('[PayPal] Getting access token...');
      final accessToken = await _getAccessToken();
      debugPrint('[PayPal] Creating PayPal order...');
      final orderData = await _createOrder(
        accessToken: accessToken,
        amount: amount,
        currency: currency,
        serviceId: serviceId,
        metadata: userData,
      );
      debugPrint('[PayPal] Order created: $orderData');
      final approvalUrl = orderData['approvalUrl'] ?? '';
      final orderId = orderData['orderId'] ?? '';
      if (approvalUrl.isEmpty || orderId.isEmpty) {
        debugPrint('[PayPal] Invalid order data: $orderData');
        return PaymentResult(
          success: false,
          errorMessage: 'Invalid PayPal order',
        );
      }
      final success = await _showPayPalCheckout(
        context: context,
        approvalUrl: approvalUrl,
      );
      debugPrint('[PayPal] Checkout completed: success=$success');
      if (success) {
        debugPrint('[PayPal] Capturing payment for orderId=$orderId');
        final captureSuccess = await _capturePayPalPayment(
          accessToken,
          orderId,
        );
        debugPrint('[PayPal] Capture result: $captureSuccess');
        if (captureSuccess) {
          return PaymentResult(success: true, transactionId: orderId);
        }
      }
      return PaymentResult(
        success: false,
        errorMessage: success ? 'Payment capture failed' : 'Payment cancelled',
      );
    } catch (e) {
      debugPrint('[PayPal] Payment error: $e');
      return PaymentResult(success: false, errorMessage: e.toString());
    }
  }
}
