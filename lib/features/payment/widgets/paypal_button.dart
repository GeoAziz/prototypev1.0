import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayPalButton extends StatefulWidget {
  final double amount;
  final Function(bool success) onPaymentComplete;

  const PayPalButton({
    super.key,
    required this.amount,
    required this.onPaymentComplete,
  });

  @override
  State<PayPalButton> createState() => _PayPalButtonState();
}

class _PayPalButtonState extends State<PayPalButton> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePayPal();
  }

  Future<void> _initializePayPal() async {
    final clientId = dotenv.env['PAYPAL_CLIENT_ID'];
    if (clientId == null) {
      widget.onPaymentComplete(false);
      return;
    }

    final returnUrl =
        dotenv.env['PAYPAL_CALLBACK_URL'] ??
        'http://localhost:5000/api/payments/paypal/callback';
    final sandbox = dotenv.env['PAYPAL_MODE'] == 'sandbox';

    final baseUrl = sandbox ? 'sandbox.paypal.com' : 'www.paypal.com';
    final paypalUrl =
        'https://$baseUrl/sdk/js?client-id=$clientId&currency=USD';

    try {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              debugPrint('[PayPal] Loading: $url');
              setState(() => isLoading = true);

              if (url.startsWith(returnUrl)) {
                final uri = Uri.parse(url);
                final success = uri.queryParameters['success'] == 'true';
                widget.onPaymentComplete(success);
              }
            },
            onPageFinished: (url) {
              debugPrint('[PayPal] Loaded: $url');
              setState(() => isLoading = false);
            },
            onNavigationRequest: (request) {
              final url = request.url;
              debugPrint('[PayPal] Navigation request: $url');

              if (url.contains('paypal.com') || url.startsWith(returnUrl)) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        )
        ..loadHtmlString('''
          <!DOCTYPE html>
          <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <script src="$paypalUrl"></script>
              <style>
                body { margin: 0; padding: 20px; background: #f7f7f7; }
                #paypal-button-container { 
                  max-width: 400px; 
                  margin: 0 auto;
                  background: white;
                  padding: 20px;
                  border-radius: 8px;
                  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }
              </style>
            </head>
            <body>
              <div id="paypal-button-container"></div>
              <script>
                paypal.Buttons({
                  style: {
                    layout: 'vertical',
                    color:  'gold',
                    shape:  'rect',
                    label:  'paypal'
                  },
                  createOrder: function() {
                    return paypal.rest.payment.create({
                      intent: "sale",
                      payer: {
                        payment_method: "paypal"
                      },
                      transactions: [{
                        amount: {
                          total: "${widget.amount.toStringAsFixed(2)}",
                          currency: "USD"
                        }
                      }]
                    });
                  },
                  onApprove: function(data, actions) {
                    return actions.order.capture().then(function() {
                      window.location.href = '$returnUrl?success=true';
                    });
                  },
                  onCancel: function() {
                    window.location.href = '$returnUrl?success=false';
                  },
                  onError: function(err) {
                    console.error('PayPal error:', err);
                    window.location.href = '$returnUrl?success=false';
                  }
                }).render('#paypal-button-container');
              </script>
            </body>
          </html>
        ''');
    } catch (e) {
      debugPrint('[PayPal] Error initializing button: $e');
      widget.onPaymentComplete(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isLoading)
          SizedBox(height: 300, child: WebViewWidget(controller: controller)),
        if (isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
