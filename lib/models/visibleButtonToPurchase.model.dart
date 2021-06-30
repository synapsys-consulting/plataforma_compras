import 'package:flutter/foundation.dart';

class VisibleButtonToPurchase with ChangeNotifier {
  final List<bool> _items = [];

  List<bool> get items => _items;

  void add (bool item) {
    this._items.add(item);
    notifyListeners();
  }
  void remove (bool item){
    this._items.remove(item);
    notifyListeners();
  }
  bool getItem (int index) {
    return _items[index];
  }
  void clearVisibleButtonToPurchase () {
    for (var i = 0; i < this._items.length; i++) {
      this._items[i] = true;
      notifyListeners();
    }
  }
  int get numItems => this._items.length;
  void setItem (int index, bool value) {
    this._items[index] = value;
    notifyListeners();
  }
}