import 'package:flutter/material.dart';
import 'package:white_label_customer_flutter/components/cart/cart_app_bar.dart';
import 'package:white_label_customer_flutter/components/cart/cart_view.dart';
import 'package:white_label_customer_flutter/components/cart/checkout_view.dart';
import 'package:white_label_customer_flutter/components/cart/footer.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final PageController _pageController = PageController();
  int _currentStep = 2;
  String _currentTitle = 'Cart';
  String _footerButtonText = 'Continue to Checkout';
  final CheckoutView _checkoutView = CheckoutView();

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

  void _pay() {
    _checkoutView.pay(context);
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
              physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
              children: [
                CartView(onProceedToCheckout: _proceedToCheckout),
                _checkoutView,
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
