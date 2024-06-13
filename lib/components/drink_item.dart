import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:white_label_customer_flutter/services/database/drink.dart';
import 'package:white_label_customer_flutter/components/cart/cart.dart';

class DrinkItem extends StatelessWidget {
  final Drink drink;

  const DrinkItem({required this.drink, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<Cart>(context, listen: false).addItem(drink);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.name,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      drink.ingredients.join(' + '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${drink.price.toStringAsFixed(2)} €',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  size: 25,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false).addItem(drink);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
