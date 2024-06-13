import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:white_label_customer_flutter/services/payment/payment_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CheckoutView extends StatelessWidget {
  final PaymentService _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('Checkout Page Content Here'),
            ),
          ),
          CardFormField(
            controller: CardFormEditController(),
            style: CardFormStyle(
              borderColor: Colors.blue,
              backgroundColor: Colors.white,
              textColor: Colors.black,
            ),
            onCardChanged: (card) {
              print(card);
            },
          ),
        ],
      ),
    );
  }

  Future<void> pay(BuildContext context) async {
    const int amount = 6900; // Beispielbetrag in Cent
    const String currency = 'eur';

    try {
      // Überprüfe den Stripe-Schlüssel
      final String? stripeKey = await checkStripeKey();
      if (stripeKey == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stripe key is not set or invalid.')),
        );
        return;
      }

      final String clientSecret = await _paymentService
          .createPaymentIntent(amount, currency);

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        style: ThemeMode.light,
        merchantDisplayName: 'Your Merchant Name',
      ));

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed!')));
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')));
    }
  }

  Future<String?> checkStripeKey() async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('checkStripeKey');
    try {
      final response = await callable.call();
      print('Stripe Key: ${response.data['stripeSecret']}');
      return response.data['stripeSecret'];
    } catch (e) {
      print('Error checking Stripe key: $e');
      return null;
    }
  }
}
