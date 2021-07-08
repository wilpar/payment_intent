import 'package:flutter/material.dart';

class PayConnectedAccount extends StatefulWidget {
  const PayConnectedAccount({Key? key}) : super(key: key);

  @override
  _PayConnectedAccountState createState() => _PayConnectedAccountState();
}

class _PayConnectedAccountState extends State<PayConnectedAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay a Connected Account')),
      body: Container(),
    );
  }
}
