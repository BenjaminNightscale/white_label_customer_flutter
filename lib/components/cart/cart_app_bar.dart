import 'package:flutter/material.dart';

class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int step;
  final String title;
  final VoidCallback onBackPressed;

  const CartAppBar({
    super.key,
    required this.step,
    required this.title,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;

    // Set the progress value based on the step
    switch (step) {
      case 2:
        progress = 0.5; // 50% loaded
        break;
      case 3:
        progress = 0.80; // 75% loaded
        break;
      default:
        progress = 0.0; // Default to 0% loaded
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          automaticallyImplyLeading: false, // Remove the default back arrow
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    "5min - Nightscale",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        Container(
          height: 3.0,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.secondary,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 1000), // Animation duration
                curve: Curves.easeInOut, // Animation curve
                width: MediaQuery.of(context).size.width * progress, // Animate the width
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}