import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class MpesaService {
  final String consumerKey;
  final String consumerSecret;
  final String shortcode;
  final bool isSandbox;
  final String _baseUrl;
  String? _accessToken;
  DateTime? _tokenExpiry;

  MpesaService({
    required this.consumerKey,
    required this.consumerSecret,
    required this.shortcode,
    this.isSandbox = true,
  }) : _baseUrl = isSandbox
           ? 'https://sandbox.safaricom.co.ke'
           : 'https://api.safaricom.co.ke';

  Future<String> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null) {
      if (_tokenExpiry!.isAfter(DateTime.now())) {
        return _accessToken!;
      }
    }

    final credentials = base64Encode(
      utf8.encode('$consumerKey:$consumerSecret'),
    );

    final response = await http.get(
      Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
      headers: {'Authorization': 'Basic $credentials'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get access token: ${response.body}');
    }

    final data = jsonDecode(response.body);
    _accessToken = data['access_token'];
    _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in']));

    return _accessToken!;
  }

  Future<Map<String, dynamic>> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String description,
  }) async {
    final token = await _getAccessToken();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[-:.]'), '')
        .substring(0, 14);
    final password = base64Encode(
      utf8.encode('$shortcode${AppConstants.mpesaPasskey}$timestamp'),
    );

    final response = await http.post(
      Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.round(),
        'PartyA': phoneNumber,
        'PartyB': shortcode,
        'PhoneNumber': phoneNumber,
        'CallBackURL': '${AppConstants.baseApiUrl}/mpesa/callback',
        'AccountReference': accountReference,
        'TransactionDesc': description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to initiate STK push: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> queryTransactionStatus(
    String checkoutRequestId,
  ) async {
    final token = await _getAccessToken();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[-:.]'), '')
        .substring(0, 14);
    final password = base64Encode(
      utf8.encode('$shortcode${AppConstants.mpesaPasskey}$timestamp'),
    );

    final response = await http.post(
      Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to query transaction status: ${response.body}');
    }

    return jsonDecode(response.body);
  }
}
