import 'package:flutter/foundation.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';

class Warehouse with ChangeNotifier {
  /// Internal, private state of the Warehouse. Stores the ids of each item.
  final List<ProductAvail> _items = [];

  List<ProductAvail> get items => _items;

  void add (ProductAvail item) {
    bool founded = false;
    debugPrint('The value of founded is: ' + founded.toString());
    debugPrint('The number of elements is: ' + this._items.length.toString());
    this._items.forEach((element) {debugPrint('The element is: ' + element.productId.toString());});
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) {
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
    notifyListeners();
  }
  void remove (ProductAvail item){
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) { if (element.productId == item.productId) (element.avail == 1) ? founded = true : element.avail -= 1;});
    }
    if (founded) this._items.remove(item);
    notifyListeners();
  }
  void incrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.avail += 1;});
    notifyListeners();
  }
  void decrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.avail -= 1;});
    notifyListeners();
  }
  ProductAvail  getItem (int index) {
    return _items[index];
  }
  int get numItems => this._items.length;
}