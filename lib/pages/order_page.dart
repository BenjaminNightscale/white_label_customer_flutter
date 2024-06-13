import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:white_label_customer_flutter/components/bottom_cart_popup.dart';
import 'package:white_label_customer_flutter/components/cart/cart.dart';
import 'package:white_label_customer_flutter/components/drink_item.dart';
import 'package:white_label_customer_flutter/components/order_app_bar.dart';
import 'package:white_label_customer_flutter/services/database/drink.dart';
import 'package:white_label_customer_flutter/services/database/firestore.dart';


class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OrderAppBar(),
      body: const DrinkMenu(),
      bottomSheet: _buildBottomCartPopup(context),
    );
  }

  Widget _buildBottomCartPopup(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        return cart.items.isNotEmpty ? BottomCartPopup() : SizedBox.shrink();
      },
    );
  }
}

class DrinkMenu extends StatefulWidget {
  const DrinkMenu({super.key});

  @override
  _DrinkMenuState createState() => _DrinkMenuState();
}

class _DrinkMenuState extends State<DrinkMenu> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController categoryScrollController = ItemScrollController();

  late Map<String, List<Drink>> categorizedDrinks;
  late List<String> categories;
  late List<Widget> listWidgets;
  late Map<String, int> categoryIndexMap;
  String? selectedCategory;

  bool isLoading = true;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    loadDrinksFromFirestore();
  }

  void loadDrinksFromFirestore() {
    setState(() {
      isLoading = true;
    });

    _firestoreService.streamDrinks().listen((drinks) {
      setState(() {
        _categorizeDrinks(drinks);
        buildListWidgets();
        itemPositionsListener.itemPositions.addListener(updateVisibleCategory);
        isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      print('Error loading drinks: $error');
    });
  }

  void _categorizeDrinks(List<Drink> drinks) {
    categorizedDrinks = {};
    for (var drink in drinks) {
      categorizedDrinks.putIfAbsent(drink.category, () => []).add(drink);
    }
    categories = categorizedDrinks.keys.toList();
    categoryIndexMap = {};
  }

  void buildListWidgets() {
    int index = 0;
    listWidgets = [];

    for (var category in categories) {
      categoryIndexMap[category] = index;

      // Apply different padding for the first category
      EdgeInsets categoryPadding = index == 0
          ? const EdgeInsets.only(
              top: 5.0, bottom: 15.0, left: 15.0, right: 15.0)
          : const EdgeInsets.only(
              top: 40.0, bottom: 15.0, left: 15.0, right: 15.0);

      listWidgets.add(
        Padding(
          padding: categoryPadding,
          child: Text(
            category,
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
      );
      index++;
      for (var drink in categorizedDrinks[category]!) {
        listWidgets.add(DrinkItem(drink: drink));
        index++;
      }
    }
  }

  void scrollToCategory(String category) {
    if (categoryIndexMap.containsKey(category)) {
      double customAlignment = (categoryIndexMap[category] == 0) ? 0.0 : -0.1;
      itemScrollController.scrollTo(
        index: categoryIndexMap[category]!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: customAlignment,
      );
      categoryScrollController.scrollTo(
        index: categories.indexOf(category),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  void updateVisibleCategory() {
    var visiblePositions = itemPositionsListener.itemPositions.value;
    if (visiblePositions.isNotEmpty) {
      int firstVisibleIndex = visiblePositions
          .where((position) =>
              position.itemLeadingEdge <= 0 && position.itemTrailingEdge > 0)
          .reduce((min, position) =>
              position.itemLeadingEdge > min.itemLeadingEdge ? position : min)
          .index;
      String? newCategory;
      Widget firstVisibleWidget = listWidgets[firstVisibleIndex];
      if (firstVisibleWidget is Padding) {
        Text? textWidget = firstVisibleWidget.child as Text?;
        if (textWidget != null) {
          newCategory = textWidget.data;
        }
      }
      if (newCategory != null && selectedCategory != newCategory) {
        setState(() {
          selectedCategory = newCategory;
        });
        categoryScrollController.scrollTo(
          index: categories.indexOf(newCategory),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        _buildCategorySelector(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemCount: listWidgets.length,
              itemBuilder: (context, index) => listWidgets[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
      ),
      child: ScrollablePositionedList.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemScrollController: categoryScrollController,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];
          return Stack(
            children: [
              InkWell(
                onTap: () {
                  scrollToCategory(categories[index]);
                  setState(() => selectedCategory = categories[index]);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    categories[index],
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
