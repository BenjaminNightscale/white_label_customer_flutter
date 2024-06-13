import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:white_label_customer_flutter/components/cart/cart.dart';

class SummaryArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<Cart>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal'),
              Text('${cart.subtotal.toStringAsFixed(2)} €'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tip ${cart.tipPercentage.toStringAsFixed(0)}%'),
              Text('${(cart.subtotal * cart.tipPercentage / 100).toStringAsFixed(2)} €'),
            ],
          ),
        ],
      ),
    );
  }
}
