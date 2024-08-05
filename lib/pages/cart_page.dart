import 'package:flutter/material.dart';
import 'package:white_label_customer_flutter/components/cart/cart_app_bar.dart';
import 'package:white_label_customer_flutter/components/cart/cart_view.dart';
import 'package:white_label_customer_flutter/components/cart/checkout_view.dart';
import 'package:white_label_customer_flutter/components/cart/footer.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:white_label_customer_flutter/components/cart/cart.dart';
import 'package:white_label_customer_flutter/services/payment/payment_service.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final PageController _pageController = PageController();
  int _currentStep = 2;
  String _currentTitle = 'Cart';
  String _footerButtonText = 'Continue to Checkout';
  final PaymentService _paymentService = PaymentService();

  void _proceedToCheckout() {
    setState(() {
      _currentStep = 3;
      _currentTitle = 'Checkout';
      _footerButtonText = 'Pay';
    });
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_currentStep == 3) {
      setState(() {
        _currentStep = 2;
        _currentTitle = 'Cart';
        _footerButtonText = 'Continue to Checkout';
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pay() async {
    final cart = Provider.of<Cart>(context, listen: false);
    final int amount = (cart.totalPrice * 100).toInt(); // Total amount in cents
    const String currency = 'eur';

    try {
      final String clientSecret = await _paymentService.createPaymentIntent(
        amount,
        currency,
      );

      // Assuming _paymentMethod is set somewhere
      final String _paymentMethod = 'card'; // Replace with actual logic

      if (_paymentMethod == 'card') {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            style: ThemeMode.system,
            merchantDisplayName: 'Your Merchant Name',
          ),
        );

        await Stripe.instance.presentPaymentSheet();
      } else if (_paymentMethod == 'apple_pay') {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            style: ThemeMode.system,
            merchantDisplayName: 'Your Merchant Name',
            applePay: PaymentSheetApplePay(
              merchantCountryCode: 'DE',
            ),
          ),
        );

        await Stripe.instance.presentPaymentSheet();
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CartAppBar(
        step: _currentStep,
        title: _currentTitle,
        onBackPressed: _goBack,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics:
                  NeverScrollableScrollPhysics(), // Disable swipe navigation
              children: [
                CartView(onProceedToCheckout: _proceedToCheckout),
                CheckoutView(), // Update as needed
              ],
            ),
          ),
          Footer(
            buttonText: _footerButtonText,
            onPress: _currentStep == 2 ? _proceedToCheckout : _pay,
          ),
        ],
      ),
    );
  }
}
