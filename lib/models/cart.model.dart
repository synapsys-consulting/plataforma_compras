import 'package:flutter/foundation.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';

class Cart with ChangeNotifier{
  /// Internal, private state of the cart. Stores the ids of each item.
  final List<ProductAvail> _items = [];
  double totalPrice= 0;

  List<ProductAvail> get items => _items;

  void add (ProductAvail item){
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) {
          element.purchased += 1;
          founded = true;
        }
      });
    }
    if (!founded) {
      item.purchased = 1;
      _items.add(item);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    notifyListeners();
  }
  void remove (ProductAvail item){
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) { if (element.productId == item.productId) (element.purchased == 1) ? founded = true : element.purchased -= 1;});
    }
    if (founded) this._items.remove(item);
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    notifyListeners();
  }
  void incrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased += 1;});
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    notifyListeners();
  }
  void decrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased -= 1;});
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    notifyListeners();
  }

  ProductAvail  getItem (int index) {
    return _items[index];
  }

  void clearCart () {
    this._items.clear();
    notifyListeners();
  }

  int get numItems => this._items.length;
}