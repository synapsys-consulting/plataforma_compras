import 'package:flutter/foundation.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';

class Cart with ChangeNotifier{
  /// Internal, private state of the cart. Stores the ids of each item.
  final List<ProductAvail> _items = [];
  double totalPrice= 0;

  List<ProductAvail> get items => _items;

  void add (ProductAvail item){
    bool founded = false;
    debugPrint('The value of founded is: ' + founded.toString());
    debugPrint('The number of elements is: ' + this._items.length.toString());
    this._items.forEach((element) {debugPrint('The element is: ' + element.product_id.toString());});
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.product_id == item.product_id) {
          element.avail += 1;
          founded = true;
        }
      });
    }
    debugPrint('The value of founded after of the for: ' + founded.toString());
    if (!founded) {
      item.avail = 1;
      _items.add(item);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.product_price * current.avail));
    notifyListeners();
  }
  void remove (ProductAvail item){
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) { if (element.product_id == item.product_id) (element.avail == 1) ? founded = true : element.avail -= 1;});
    }
    if (founded) this._items.remove(item);
    totalPrice = _items.fold(0, (total, current) => total + (current.product_price * current.avail));
    notifyListeners();
  }
  void incrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.product_id == item.product_id) element.avail += 1;});
    totalPrice = _items.fold(0, (total, current) => total + (current.product_price * current.avail));
    notifyListeners();
  }
  void decrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.product_id == item.product_id) element.avail -= 1;});
    totalPrice = _items.fold(0, (total, current) => total + (current.product_price * current.avail));
    notifyListeners();
  }

  ProductAvail  getItem (int index) {
    return _items[index];
  }

  int get numItems => this._items.length;
}