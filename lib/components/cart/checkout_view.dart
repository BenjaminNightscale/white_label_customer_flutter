import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:white_label_customer_flutter/components/cart/tip_section.dart';
import 'package:white_label_customer_flutter/components/summary_area.dart';
import 'package:white_label_customer_flutter/services/payment/payment_service.dart';
import 'package:provider/provider.dart';
import 'package:white_label_customer_flutter/components/cart/cart.dart';

class CheckoutView extends StatelessWidget {
  final PaymentService _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0), // Padding around the main content
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true, // Ensure it takes only as much space as needed
                    physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('Quantity: ${item.quantity}'),
                        trailing: Text('€${item.price.toStringAsFixed(2)}'),
                        textColor: Theme.of(context).colorScheme.onBackground,
                      );
                    },
                  ),
                  TipSection(),
                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.outline),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SummaryArea(),
            ),
            Divider(color: Theme.of(context).colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Future<void> pay(BuildContext context) async {
    final cart = Provider.of<Cart>(context, listen: false);
    final int amount = (cart.totalPrice * 100).toInt(); // Total amount in cents
    const String currency = 'eur';

    try {
      // Create Payment Intent on the backend
      final String clientSecret = await _paymentService.createPaymentIntent(
        amount,
        currency,
      );

      // Display the Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        style: ThemeMode.system,
        merchantDisplayName: 'Your Merchant Name',
      ));

      await Stripe.instance.presentPaymentSheet();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed!')),
      );
    } catch (e) {
      if (e is StripeException) {
        print('Error from Stripe: ${e.error.localizedMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment failed: ${e.error.localizedMessage}')),
        );
      } else {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    }
  }
}
