import 'package:flutter/material.dart';
import 'package:white_label_customer_flutter/components/my_drawer.dart';
import 'package:white_label_customer_flutter/pages/order_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) =>  const OrderPage()),
            );
          },
          child: const Text('Order here'),
        ),
      ),
    );
  }
}
