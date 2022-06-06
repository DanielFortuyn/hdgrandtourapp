import 'package:flutter/material.dart';

class SnackModel extends ChangeNotifier {
  void add() {
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
