import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:stripe_payment/stripe_payment.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScrollController _controller = ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var _errorString = '';
  PaymentMethod _paymentMethod;
  String _paymentIntentClientSecret;
  PaymentIntentResult _paymentIntent;
  bool _error = false;
  String _pubKey;

  getPubKey() async {
    try {
      final keyUrl =
          "https://us-central1-paymentintent.cloudfunctions.net/pub_key";
      final http.Response response = await http.post(
        Uri.parse(keyUrl),
      );
      final responseData = jsonDecode(response.body);
      final String pubKey = responseData['publishable_key'];
      setState(() {
        _pubKey = pubKey;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
    StripePayment.setOptions(
      StripeOptions(publishableKey: _pubKey),
    );
  }

  @override
  void initState() {
    super.initState();
    getPubKey();
  }

  void setError(dynamic errorString) {
    print(errorString);
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(errorString.toString())));
    setState(() {
      _errorString = errorString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Stripe Payment Intent'),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _paymentIntent = null;
                  _paymentMethod = null;
                  _paymentIntentClientSecret = null;
                });
              },
            ),
          ],
        ),
        body: ListView(
          controller: _controller,
          padding: EdgeInsets.all(20),
          children: [
            ElevatedButton(
              child: Text('Step 1 - Payment Method'),
              onPressed: () {
                StripePayment.paymentRequestWithCardForm(
                  CardFormPaymentRequest(),
                ).then(
                  (paymentMethod) {
                    // _scaffoldKey.currentState.showSnackBar(
                    //   SnackBar(
                    //     content: Text('Received ${paymentMethod.id}'),
                    //   ),
                    // );
                    setState(() {
                      _paymentMethod = paymentMethod;
                    });
                  },
                ).catchError(setError);
              },
            ),
            ElevatedButton(
              child: Text('Step 2 - Payment Intent'),
              onPressed: () async {
                final String cpiUrl =
                    'https://us-central1-paymentintent.cloudfunctions.net/create_payment_intent';
                final int amount = 7777;
                final String currency = "cad";
                final String finalUrl =
                    '$cpiUrl?amount=$amount&currency=$currency';
                final http.Response response = await http.post(
                  Uri.parse(finalUrl),
                );
                final responseData = jsonDecode(response.body);
                final String pics = responseData['clientSecret'];
                setState(() {
                  _paymentIntentClientSecret = pics;
                });
              },
            ),
            ElevatedButton(
              child: Text('Step 3 - Confirm Payment Intent'),
              onPressed: () {
                StripePayment.confirmPaymentIntent(PaymentIntent(
                        clientSecret: _paymentIntentClientSecret,
                        paymentMethodId: _paymentMethod.id))
                    .then((paymentIntent) {
                  setState(() {
                    _paymentIntent = paymentIntent;
                  });
                }).catchError(setError);
              },
            ),
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            Divider(),
            Text('Pubkey:'),
            Text(
              _pubKey ?? '',
              style: TextStyle(fontFamily: "Monospace"),
            ),
            Divider(),
            Text('Current payment method:'),
            Text(
              JsonEncoder.withIndent('  ')
                  .convert(_paymentMethod?.toJson() ?? {}),
              style: TextStyle(fontFamily: "Monospace"),
            ),
            Divider(),
            Text('Current PICS:'),
            Text(
              _paymentIntentClientSecret ?? '',
              style: TextStyle(fontFamily: "Monospace"),
            ),
            Divider(),
            Text('Current payment intent:'),
            Text(
              JsonEncoder.withIndent('  ')
                  .convert(_paymentIntent?.toJson() ?? {}),
              style: TextStyle(fontFamily: "Monospace"),
            ),
            Divider(),
            Text('Current error: $_error'),
          ],
        ),
      ),
    );
  }
}
