import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/stripe.dart';

class PayThePlatform extends StatefulWidget {
  @override
  _PayThePlatformState createState() => _PayThePlatformState();
}

class _PayThePlatformState extends State<PayThePlatform> {
  Map<String, dynamic>? _paymentSheetData;
  final StripeService _stripeService = StripeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay the Platform')),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: _paymentSheetData != null ? null : _initPaymentSheet,
            child: const Text('Init payment sheet'),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _paymentSheetData != null ? _displayPaymentSheet : null,
            child: const Text('Show payment sheet'),
          ),
        ],
      )),
    );
  }

  Future<Map<String, dynamic>> _createTestPaymentSheet() async {
    final String endpoint = "create_payment_intent";
    final http.Response response = await http.post(
      Uri.parse('$kApiUrl/$endpoint'),
    );
    // DEBUG
    // print(json.decode(response.body));
    //
    return json.decode(response.body);
  }

  Future<void> _initPaymentSheet() async {
    try {
      // 1. create payment intent on the server
      _paymentSheetData = await _createTestPaymentSheet();

      if (_paymentSheetData!['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error code: ${_paymentSheetData!['error']}')));
        return;
      }

      // 2. Set Variables
      Stripe.publishableKey = await _stripeService.getPubKey();
      Stripe.merchantIdentifier = "SET_FOR_APPLE_PAY";

      // 3. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          applePay: true,
          googlePay: true,
          // style: ThemeMode.dark,
          testEnv: true,
          merchantCountryCode: 'CA',
          merchantDisplayName: 'Founder @50',
          customerId: _paymentSheetData!['customer'],
          paymentIntentClientSecret: _paymentSheetData!['paymentIntent'],
          customerEphemeralKeySecret: _paymentSheetData!['ephemeralKey'],
        ),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _displayPaymentSheet() async {
    try {
      // 4. display the payment sheet.
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
        clientSecret: _paymentSheetData!['paymentIntent'],
        confirmPayment: true,
      ));

      // DO NOT REUSE PAYMENT INTENTS -F50
      setState(() {
        _paymentSheetData = null;
      });

      // DOES NOT CATCH CANCELLED PAYMENTSHEETS -F50
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment succesfully completed'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
        ),
      );
    }
  }
}
