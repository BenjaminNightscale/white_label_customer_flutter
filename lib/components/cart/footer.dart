import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:white_label_customer_flutter/components/cart/cart.dart';

class Footer extends StatelessWidget {
  final String buttonText;
  final String? link;
  final VoidCallback? onPress;

  Footer({required this.buttonText, this.link, this.onPress});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    void _navigate() {
      if (link != null) {
        Navigator.pushNamed(context, link!);
      } else if (onPress != null) {
        onPress!();
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '(incl Ust.)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Text(
                '${cart.totalPrice.toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          SafeArea(
            child: GestureDetector(
              onTap: _navigate,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(child: child, opacity: animation);
                  },
                  child: Text(
                    buttonText,
                    key: ValueKey<String>(buttonText),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
