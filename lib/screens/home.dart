import 'package:flutter/material.dart';

import 'pay_connected.dart';
import 'pay_platform.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Founder@50 Marketplace Demo'),
      ),
      body: Column(
        children: [
          ...ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: Text("Pay the Platform"),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayThePlatform(),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text("Pay Connected Account"),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayConnectedAccount(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
