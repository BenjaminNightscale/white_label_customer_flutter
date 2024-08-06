import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:white_label_customer_flutter/components/cart/cart.dart';
import 'package:white_label_customer_flutter/components/cart/tip_section.dart';
import 'package:white_label_customer_flutter/components/summary_area.dart';
import 'package:white_label_customer_flutter/services/payment/payment_service.dart';

class CheckoutView extends StatefulWidget {
  @override
  _CheckoutViewState createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final PaymentService _paymentService = PaymentService();
  String _paymentMethod = '';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('Quantity: ${item.quantity}'),
                        trailing: Text('€${item.price.toStringAsFixed(2)}'),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _paymentMethod = 'apple_pay';
                      });
                    },
                    child: Text('Mit Apple Pay bezahlen'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _paymentMethod = 'google_pay';
                      });
                    },
                    child: Text('Mit Google Pay bezahlen'),
                  ),
                  // Weitere Zahlungsmethoden könnten hier hinzugefügt werden
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _paymentMethod.isEmpty ? null : () => pay(context),
              child: Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pay(BuildContext context) async {
    final cart = Provider.of<Cart>(context, listen: false);
    final int amount = (cart.totalPrice * 100).toInt(); // Gesamtbetrag in Cent
    const String currency = 'eur';

    try {
      final String clientSecret = await _paymentService.createPaymentIntent(
        amount,
        currency,
      );

      if (_paymentMethod == 'apple_pay') {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Your Merchant Name',
            applePay: const PaymentSheetApplePay(
              merchantCountryCode: 'DE',
            ),
            style: ThemeMode.system,
            allowsDelayedPaymentMethods: false,
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed!')),
        );
      } else if (_paymentMethod == 'google_pay') {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Your Merchant Name',
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: 'AT',
              testEnv:
                  true, // Setzen Sie dies auf false, wenn Sie in Produktion sind
            ),
            style: ThemeMode.system,
            allowsDelayedPaymentMethods: false,
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed!')),
        );
      }
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
