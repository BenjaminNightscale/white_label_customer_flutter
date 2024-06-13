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
              Text('Tip 10%'),
              Text('${(cart.subtotal * 0.1).toStringAsFixed(2)} €'),
            ],
          ),
        ],
      ),
    );
  }
}
