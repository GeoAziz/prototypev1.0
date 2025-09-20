import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:poafix/core/payment/paypal_service.dart';

class PayPalPaymentButton extends StatefulWidget {
  final double amount;
  final String serviceId;
  final Function(bool success) onPaymentComplete;
  final bool showLoadingAnimation;

  const PayPalPaymentButton({
    Key? key,
    required this.amount,
    required this.serviceId,
    required this.onPaymentComplete,
    this.showLoadingAnimation = true,
  }) : super(key: key);

  @override
  State<PayPalPaymentButton> createState() => _PayPalPaymentButtonState();
}

class _PayPalPaymentButtonState extends State<PayPalPaymentButton> {
  bool _isProcessing = false;
  String? _error;
  WebViewController? _controller; // Make nullable
  final _paypalService = PayPalService();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      final config = await _paypalService.processPayment(
        amount: widget.amount,
        serviceId: widget.serviceId,
        onComplete: (success, error) {
          setState(() => _isProcessing = false);
          if (mounted) {
            widget.onPaymentComplete(success);
          }
        },
      );

      setState(() {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                debugPrint('[PayPal] Loading: $url');
                if (url.startsWith(config['returnUrl'])) {
                  final uri = Uri.parse(url);
                  final success = uri.queryParameters['success'] == 'true';
                  final transactionId = uri.queryParameters['transaction_id'];
                  _paypalService.updatePaymentStatus(
                    paymentId: config['paymentId'],
                    success: success,
                    transactionId: transactionId,
                    error: success ? null : 'Payment not completed',
                  );
                  widget.onPaymentComplete(success);
                }
              },
              onPageFinished: (String url) {
                debugPrint('[PayPal] Loaded: $url');
                if (mounted) {
                  setState(() => _isProcessing = false);
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                final url = request.url;
                if (url.contains('paypal.com') ||
                    url.startsWith(config['returnUrl'])) {
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
              <script src="https://${config['sandbox'] ? 'sandbox.' : ''}paypal.com/sdk/js?client-id=${config['clientId']}&currency=USD"></script>
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
                          total: "${config['amount']}",
                          currency: "USD"
                        }
                      }]
                    });
                  },
                  onApprove: function(data, actions) {
                    return actions.order.capture().then(function(details) {
                      window.location.href = '${config['returnUrl']}?success=true&transaction_id=' + details.id;
                    });
                  },
                  onCancel: function() {
                    window.location.href = '${config['returnUrl']}?success=false';
                  },
                  onError: function(err) {
                    console.error('PayPal error:', err);
                    window.location.href = '${config['returnUrl']}?success=false&error=' + encodeURIComponent(err);
                  }
                }).render('#paypal-button-container');
              </script>
            </body>
          </html>
        ''');
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
      widget.onPaymentComplete(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Payment Error: $_error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = null;
                _isProcessing = true;
              });
              _initializeWebView();
            },
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    if (_isProcessing && widget.showLoadingAnimation) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/payment-processing.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text('Initializing PayPal...', style: TextStyle(fontSize: 16)),
        ],
      );
    }

    if (_controller == null) {
      return Center(child: CircularProgressIndicator());
    }
    return SizedBox(
      height: 300,
      child: WebViewWidget(controller: _controller!),
    );
  }
}
