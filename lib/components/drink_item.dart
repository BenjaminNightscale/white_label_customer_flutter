import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:white_label_customer_flutter/services/database/drink.dart';
import 'package:white_label_customer_flutter/components/cart/cart.dart';

class DrinkItem extends StatelessWidget {
  final Drink drink;

  const DrinkItem({required this.drink, super.key});

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = drink.quantity <= 0;

    return InkWell(
      onTap: () {
        if (!isOutOfStock) {
          Provider.of<Cart>(context, listen: false).addItem(drink);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
              : Theme.of(context).colorScheme.surface,
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
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock
                                ? Colors.grey
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      drink.ingredients.join(' + '),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: isOutOfStock
                                ? Colors.grey
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      '${drink.price.toStringAsFixed(2)} €',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                            color: isOutOfStock
                                ? Colors.grey
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    if (isOutOfStock)
                      Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  size: 25,
                  color: isOutOfStock
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (!isOutOfStock) {
                    Provider.of<Cart>(context, listen: false).addItem(drink);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
